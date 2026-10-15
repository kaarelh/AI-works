"""Writes research/paper-review/p1/issues-p1-math-C.json (reviewer p1-math-C). Usage: python3 -I make_issues_p1_math_C.py <out.json>"""
import json, sys

I = []
def add(id_, file, loc, sev, problem, evidence, fix):
    I.append(dict(id=id_, file=file, label_or_line=loc, severity=sev, problem=problem, evidence=evidence, fix=fix))

# ---------------- MAJOR ----------------
add("P1C-01", "paper/sections/app-ood.tex", "line 39 (grammar paragraph), table tab:ood:grammar rows 'tilted'; also ood.tex line 171 (ex:ood:hanniexamples(c)) and app-ood.tex line 69 (tab:ood:hanni)", "major",
    "The 'tilted' rows are described wrongly. The paper says the extra program 'if |x| even then 0 else |x|' gets 'prior mass equal to (or ten times) that of all plain programs'. The computation actually gives it the mass of the training-consistent plain programs, i.e. of the single intended class |x|, which is 7.4 times smaller. The main text then reports 'about 0.11 when one extra program tilts the grammar' without saying that this extra program carries ten times the intended program's prior mass (44% of all prior mass, about 2600 times its own weight in the grammar).",
    "examples/checks/e5_dsl_odd_lengths.py line 88: extra_programs=[(bad, tilt * 0.5 * m_plain_ok)], where m_plain_ok is the mass of the plain classes consistent with training (0.093932, class 'len' only; total plain-expression mass 0.695313). Independent rerun (scratch/p1-math-C/c1_e5_tilt.py, .out.txt): as coded, P(correct) = 0.557 (x1) and 0.114 (x10), reproducing the table. With the paper's wording (mass = x1 or x10 that of ALL plain programs) it is 0.148 and 0.017. In c1b_prior_share.out.txt the x10 program holds 0.443 of the total prior. The same e5 output shows that the program's natural grammar mass is 1.784e-4 (ratio 3.8e-3 to the consistent plain mass), so x10 inflates it about 2633-fold. The wrong description is inherited from the e5 docstring and examples notes §5.3, which contradict the code.",
    "app-ood.tex: replace the description with: 'The tilted rows add one program \"if |x| even then 0 else |x|\" with prior mass equal to (or ten times) that of the intended program |x| (the only plain program consistent with the training data); with the factor ten it carries 44% of the total prior mass.' In ood.tex line 171 replace 'about 0.11 when one extra program tilts the grammar' with 'and about 0.11 when a single extra program with ten times the prior mass of the intended one is added'. In tab:ood:hanni write '0.11 with a tilted prior'.")

add("P1C-02", "paper/sections/nn.tex", "rem:nn:slides (line 81), item (vi)", "major",
    "Item (vi) reads 'out of distribution the guarantee \"is simply false\" (\\cref{thm:comp:ladder})', which makes the conjunction ladder the evidence for the slides' statement. In the slides, 'simply false' refers to the in-distribution PAC guarantee, which fails out of distribution for a trivial reason. The ladder refutes the physicist's argument for deterministic Occam/argmax learning over circuits. The slides add that their own NN learner is 'not the deterministic argmax' and lies on 'the good side' of the table, and that for NN Bayes 'an online mistake bound might still hold'. The paper's own rem:comp:uniformties draws the same distinction.",
    "Slides, Appendix K, slide 104: 'Our theorem is in-distribution, and out of distribution the statement is simply false: nothing stops the learner from being wrong on inputs the training distribution never reaches.' Slide 37: 'An online mistake bound might still hold, and we have a heuristic argument for one ... but the analogous claim for circuits is strictly false. (Appendix K.)' Slide 108: 'Our sigma->0 learner is not the deterministic argmax ... the good side of this table ... the Bayesian version (Appendix A) survives.'",
    "Replace (vi) with: '(vi) out of distribution the in-distribution guarantee \"is simply false\". For deterministic Occam learning over circuits even an online mistake bound fails (the conjunction ladder, \\cref{thm:comp:ladder}). For their own learner, which spreads ties and predicts by majority, the slides conjecture on heuristic grounds that an online mistake bound may still hold (cf. \\cref{rem:comp:uniformties}).'")

add("P1C-03", "paper/sections/nn.tex", "rem:nn:rigorous (line 86)", "major",
    "Under 'Proved' the remark lists 'the Gaussian-process limits fail on sparse and odd parities where SFI succeeds'. For sparse parities, what is proved concerns the squared error of the real-valued kernel or GP-mean predictor, averaged over random k-sparse targets (thm:nn:walsh(b), cor:nn:separation). The paper says two paragraphs earlier: 'we do not claim a 0-1 version in general'. As printed, the summary claims a classification failure that is not proved. The intro repeats it loosely as 'a separation between Gaussian-process limits and SFI on parities'.",
    "nn.tex line 69: 'The separation is in squared error of the real-valued predictor; we do not claim a 0--1 version in general.' Context notes §4.6 (v): 'the regression predictor is diagonal in the Walsh basis and needs binom(d,k) samples for k-sparse parities'. Classification failure is proved only for bias-free two-layer ReLU kernels and odd |S|>=3 (rem:nn:oddparity(b): zero prior mass; (c): anti-correlation of the regression predictor).",
    "Rewrite the item as: 'kernel regression and GP posterior means in the Gaussian-process limits need binom(d,k) samples, in squared error, on random k-sparse parities, where SFI needs O(k log d); for bias-free two-layer ReLU kernels odd parities of degree at least 3 are never learned, have GP-classification prior mass 0, and are anti-correlated with the predictor on unseen points.'")

add("P1C-04", "paper/sections/ood.tex", "rem:ood:answer (line 145), items (iii) and (iv)", "major",
    "(iii) says that for simple f 'the error at a test point lies between 2^{-sep(x*;A)-O(1)} and 2^{L_nu(f)-sep(x*;A|f)+O(1)}'. The section's conventions define 'the error' e(x*) in the semimeasure convention. The upper bound is proved only for e_norm and e^wr, and the paper itself says at line 134 that 'there is no pointwise bound on e(x*)'. As written, (iii) contradicts line 134. The lower bound also needs a simple wrong label: the proved form carries -K(y). (iv) drops the hypotheses of the lower bound: binary computable f, uniform inputs on {0,1}^d with d >= ceil(log n)+1.",
    "prop:ood:labelled bounds only e^wr <= e_norm <= 2^{L_nu(f)-K(x*|f)+c}, and its lower bound is 2^{-sep(x*;A)-K(y)-c}. ood.tex line 134: 'The mass undefined at x* is not lsc, so there is no pointwise bound on e(x*)'. prop:learn:typical (learn.tex line 138) assumes uniform inputs on {0,1}^d with d >= ceil(log n)+1 and, for general f, computable binary f.",
    "(iii): 'For simple f, the defined-and-wrong error e^wr(x*) is at least 2^{-sep(x*;A)-K(y)-O(1)} for every wrong label y, and the normalised error e_norm(x*) is at most 2^{L_nu(f)-sep(x*;A|f)+O(1)}; the semimeasure-convention error has no pointwise upper bound.' (iv): add 'for computable binary f and uniform inputs on {0,1}^d with d >= ceil(log n)+1'.")

add("P1C-05", "paper/sections/comp.tex", "rem:comp:selection (line 128) and thm:comp:ladder (line 121)", "major",
    "rem:comp:selection says that 'the first and last rows' of the slides' table 'are proved here', where the first row is 2^{Theta(C/log C)} worst-case mistakes for deterministic argmax. thm:comp:ladder proves only the lower bound 2^{Omega(l/log l)}, for the conjunction target, and states 'the trivial upper bound is 2^{l+1}'. This leaves an apparent exponential gap. q:comp:open (line 136) asks whether some target has 2^{Omega(l)} mistakes, so for general targets the Theta is open. For the conjunction target the matching upper bound 2^d = 2^{O(l/log l)} is immediate, but the theorem never says so. A reader sees 'Theta ... proved here' next to a theorem that states Omega and 2^{l+1}.",
    "Context notes Thm 3.11: 'For f=AND_[d] the lower bound is tight up to the constant in the exponent, since there are only 2^d inputs.' This sentence is not in thm:comp:ladder. Slides slide 105 state M*(f)=2^{Theta(C/log C)} for f = x1 AND ... AND xd. Context notes §7 item 5 keeps the general gap 2^{Omega(l/log l)} vs 2^{O(l)} open.",
    "Add to thm:comp:ladder: 'For this target the number of mistakes is at most 2^d = 2^{O(l/log l)}, so the bound is tight for it; for general targets only 2^{l+1} is known (\\cref{q:comp:open}).' In rem:comp:selection write: 'For the conjunction target the first row is \\cref{thm:comp:ladder}; the last row is \\cref{rem:comp:majority}.'")

add("P1C-06", "paper/sections/comp.tex", "thm:comp:timebounded(b) (line 24); prop:comp:round, last sentence (line 36); cor:comp:poly, last clause (line 47); prop:comp:history, last clause (line 63)", "major",
    "Running-time claims that are only sketched, or not argued at all, appear inside theorem, proposition and corollary statements. Once \\status is removed, nothing in these statements marks them as unproved. The binding note requires sketches to be labelled and forbids presenting the statement as fully proved. The appendix gives a 'Proof sketch' for thm:comp:timebounded(b) only. The running-time parts of prop:comp:round, prop:comp:history and cor:comp:poly have no proof or sketch anywhere. The 'Proof of prop:comp:history' covers the regret only. The machine model is admitted to be unwritten only in q:comp:open.",
    "Statuses at comp.tex lines 21, 35, 62: '(b) proof sketch', 'running time proof sketch', 'regret proved; running time proof sketch'. app-comp.tex line 11: 'The machine model (RAM versus multitape) and the cost of running the clocks are not written out; this part is a proof sketch.' app-comp.tex line 18: 'Proof of prop:comp:history (regret)'. Context notes Prop 3.2c: cost '[proof sketch]'.",
    "Split each statement. Keep the regret bounds in the theorem, proposition and corollary. Move every per-round cost claim to one 'Remark (running time; proof sketch)' after prop:comp:history. That remark should give the sketch for all four, including the stored-weight update for M_rd and the replay bookkeeping, and should state that the RAM model is assumed and the cost of the clocks is not analysed. Alternatively, write '(running time: proof sketch in \\cref{app:comp})' inside each statement and add the missing sketches.")

add("P1C-07", "paper/sections/ood.tex", "conj:ood:natural (lines 177-182)", "major",
    "This is a conjecture environment whose content the paper itself calls 'not a precise statement'. 'Natural universal machines', 'natural training sets' and 'close to 1' are undefined. The paper adds that by prop:ood:machine the statement fails for some universal machines. A numbered conjecture that cannot be true or false is non-standard and will be noticed.",
    "ood.tex line 182: 'This is not a precise statement, and by \\cref{prop:ood:machine} it fails for some universal machines'. Examples notes §5.1: '[conjecture] for natural machines and large natural training sets; no proof is known'. Examples notes §7 item 4 lists the precise version as an open problem.",
    "Remove the conjecture environment. State the expectation in prose in sec:ood:examples, or in Discussion/Open problems, as an informal open question: 'For a fixed natural reference machine (for example a standard prefix-free encoding of a programming language) and natural training distributions, do the intended answers of \\cref{ex:ood:hanniexamples} get posterior probability close to 1?' Update the discussion's pointer (discussion.tex line 22) to it.")

add("P1C-08", "paper/sections/related.tex", "rem:related:new (line 18)", "major",
    "The remark lists 'the OOD results of \\cref{sec:ood}' among the items the search did not find. That section includes thm:ood:cumulative, which ood.tex itself calls 'the error form of the mistake bound', and the same remark lists the halving/mistake bound as existing. It also includes prop:ood:intended, which is the dominance bound, and prop:ood:machine(a), which the remark presents as an analogue of known machine dependence. The source lists specific items only. The item on time-bounded mixtures also drops the source's qualifier 'in the function setting; the sequence analogues are Hänni's polytime note and the speed-prior literature'. The literature claim is broader than the source and inconsistent with the remark's own 'exists' list.",
    "Context notes §6, 'Apparently new': 'the OOD results of §2 for SFI: the two-sided separation bounds (Prop 2.1, Thm 2.5, Prop 2.6), the novelty budget (Prop 2.8), the failure of the naive converse ... (Prop 2.13), the sandwich (Prop 2.14), the converse given the labelled sample (Prop 2.16) ... easy-to-hard and shortest-proof examples (Ex 2.15, 2.15a)'. Thm 2.7 (thm:ood:cumulative) is not listed. Also: 'time-bounded SFI ... in the function setting; the sequence analogues are Hänni's polytime note and the speed-prior literature'. ood.tex line 84: 'This is the error form of the mistake bound'.",
    "Replace 'the OOD results of \\cref{sec:ood}' with the specific list: \\cref{prop:ood:hanni,thm:ood:twosided,prop:ood:draftfalse,prop:ood:budget,prop:ood:converse,prop:ood:sandwich,prop:ood:labelled,ex:ood:easyhard} and the MF form of \\cref{prop:ood:machine}. Add 'in the function setting (the sequence analogues are \\citet{hanni2026notes} and speed priors)' to the time-bounded item.")

add("P1C-09", "paper/sections/related.tex", "lines 6, 8, 10, 12, 18; also nn.tex line 91", "major",
    "The visible text reports how much of the literature was read and leaves an internal to-do: '(we have seen only the abstract)', 'according to their abstract', 'in their abstract', 'was not checked against his texts', 'we have not checked', 'Vovk's earlier universal forecasting algorithms \\citep{vovk1992universal} we have not examined', 'At the level of a search that saw abstracts and secondary sources only', 'Each of these should be checked against ... before any claim of novelty', and nn.tex's 'These descriptions follow the abstracts.' This is the process vocabulary and 'unverified' printing that the binding note excludes. Citing a work only to say it was not examined is not standard practice. related.tex ('expected but was not checked') and hist.tex line 135 ('is known, but not checked') also disagree about the Hutter identification.",
    "OUTLINE binding note: 'never print \"unverified\"'; 'No process vocabulary'. related.tex header comment: 'Every content claim below is hedged: only abstracts or secondary descriptions were seen.' bib/related.bib: vovk1992universal '% unverified: content not seen'.",
    "Use standard scholarly hedges and remove the to-do. Examples: 'Solomonoff (2008) describes three kinds of induction, the third concerning \"an unordered set of ordered pairs\" ...'; 'Lattimore et al. (2011) show that ...'; 'We expect, but do not prove, that \\SFIhist{} agrees with Hutter's universal chronological semimeasure up to constant factors' (one consistent wording, also in hist.tex). Drop the vovk1992universal sentence or describe its content. Replace the opening and closing sentences of rem:related:new with 'To our knowledge, the following are new: ...' and remove 'should be checked ... before any claim of novelty'. Delete 'These descriptions follow the abstracts.'")

add("P1C-10", "paper/bib/core.bib", "hanni2026lesswrong (lines 26-33), cited in steeper.tex line 6", "major",
    "The steeper summary cites '(Hänni, 2026b; Hänni and Wyeth, undated)' in the sentence that introduces Hänni's proposal, right before the paragraph on the absorption objection. The entry's bibliographic data are marked unverified in core.bib ('the LessWrong page did not resolve'), and its year is 'undated'. The binding note allows only checked references. It also lists Cole Wyeth as co-author of 'Comments in the thread', so his name is printed next to the absorption objection, which the binding note keeps apart from him; at most one neutral footnote may mention the thread. The two quotations in that sentence are in Hänni's own note (hanni2026notes). Only the later 'somewhat cherry-picked' (line 12) is thread-only.",
    "Rendered PDF line 'noise rather than a model plus memorised errors of the teacher (Hänni, 2026b; Hänni and Wyeth, undated)'. core.bib line 26: '% unverified: the LessWrong page did not resolve ... The date of the comments is not known.' research/prior/hanni-grokking-a-notion.md lines 41, 61 contain both quotations. hanni-lesswrong-comment-thread.md line 31 contains 'somewhat cherry-picked'.",
    "In steeper.tex line 6 cite only \\citep{hanni2026notes}. For 'somewhat cherry-picked', either drop the quotation or cite Hänni's own comment in a separate entry with Hänni as sole author and a checked date. If the thread must be mentioned, use the single neutral footnote the binding note permits. Delete the co-authored entry from the bibliography (shared with paper-steeper/bib/core.bib).")

add("P1C-11", "paper/bib/core.bib", "hanni2026request (lines 19-25); cited in nn.tex line 8 and steeper.tex line 14 (also learn.tex, intro.tex)", "major",
    "Kaarel Hänni is the sole author, yet the bibliography lists 'Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in ... research/00-brief.md'. A personal communication from the author to himself cannot be cited, and a reader cannot make sense of it. In my sections it supports the quotations 'kinda like a circuit version of solomonoff function induction' (nn.tex) and 'a preference for a simple sampler over a model where the sampled bits are filled in' / 'both get similar posterior' (steeper.tex).",
    "main.bbl lines 169-176. Main.tex author line: Kaarel Hänni alone. The quotations are verbatim from research/00-brief.md lines 7 and 23.",
    "Do not cite the request. Describe these ideas as the author's in the first person or impersonally, e.g. 'NN Bayes can be viewed as a circuit version of SFI (\\citealt{vaintrobhanni2026nnbayes})' and 'Solomonoff induction has no preference between a simple sampler and a model in which the sampled bits are filled in; both get similar posterior weight'. If a source is wanted, cite the note in hanni2026notes that contains the idea. This needs a global change, coordinated with intro.tex and learn.tex (cf. reviewer B MB-06).")

add("P1C-12", "paper/sections/ood.tex, comp.tex, nn.tex, steeper.tex", "e.g. ood.tex lines 7, 27, 34, 48, 53, 111, 153; comp.tex lines 10, 54, 58, 99, 111; nn.tex lines 8, 24, 33, 47, 51, 54, 81, 86, 91; steeper.tex lines 6, 8, 12, 14", "major",
    "The sections refer to the sole author in the third person and argue with him: 'Hänni's version has an extra loglog(1/p) term, which is not needed'; 'His step ... is a circuit coding theorem'; 'Hänni's objection ... is made rigorous'; 'which Hänni doubts'; 'H\\\"anni anticipated'. The slides co-authored by the author are treated as an outside source ('the other claims are the slides' and we have not checked them'; 'We re-checked the proof ... the rest is unchecked'). With 'Kaarel Hänni' as the only name on the title page, a reader cannot tell who 'we' is or why the author does not check his own slides. The binding note allows citing his notes as his notes, but the paper never states this convention.",
    "OUTLINE binding note (authorship): 'Ideas from the author's notes are cited as his notes (\\citep{hanni2026notes}) or described as the author's.' intro.tex line 5: '\\citet{hanni2026notes} proposes ...'. There is no sentence anywhere explaining the third-person convention.",
    "Add one sentence to the introduction: 'We cite the author's earlier working notes as \\citet{hanni2026notes} and discuss the claims made there as claims of those notes.' Then change 'Hänni's X' to 'the notes' X' or 'X of \\citet{hanni2026notes}' in these sections. Rephrase statements about the slides as 'the slides state ...; we do not prove these claims here'.")

add("P1C-13", "paper/sections/steeper.tex", "line 14 (the model-randomness split paragraph)", "major",
    "'with t_n doubly logarithmic in the input length' is wrong. t_n = ceil(log(2d_n+2+2log(i_n+1))) is logarithmic in the input length. The exponent 2log(t_n+1) in the odds bound is doubly logarithmic in d, and triply logarithmic in n and in the sampled randomness. Paper 2 states this correctly.",
    "paper-steeper/sections/split.tex line 39 defines t_n:=ceil(log(2d_n+2+2log(i_n+1))). Line 32: 'so the cost 2log(t_D+1) is doubly logarithmic in d and triply logarithmic in n'. paper-steeper intro.tex line 19: 'with 2log(t_n+1) doubly logarithmic in the input length'. Steeper notes §0, item 3.",
    "Write 'with 2log(t_n+1) doubly logarithmic in the input length (and triply logarithmic in n and in the sampled randomness)'.")

add("P1C-14", "paper/main.tex", "line 46 (\\input{sections/app-verification}); app-verification.tex (printed as Appendix I)", "major",
    "The PDF under review still prints the internal verification appendix. It names tracks, referees, H1-H10, CLAIMS.md and scripts, and prints 'a promised Wyeth--Hutter reference not cited (not relevant)' (app-verification.tex line 136). The binding note forbids a verification appendix and process vocabulary. main.tex's comment says the conversion pass will drop it; until then the arXiv standard is not met, and the Wyeth mention violates the binding note in spirit.",
    "main.pdf ToC: 'I How the claims were checked 96'. PDF text: 'C25: a promised Wyeth–Hutter reference not cited (not relevant)'. OUTLINE binding note: 'No verification appendix.'",
    "Remove the \\input and any \\cref{app:verification}. There are none in ood/comp/nn/related/steeper. Keep a short account of how the paper was prepared and checked in the acknowledgements, plus the 'Code and data' statement. Check that no printed text names Wyeth except the one optional neutral footnote.")

# ---------------- MINOR ----------------
add("P1C-15", "paper/sections/ood.tex, comp.tex, nn.tex, related.tex", "\\status at ood.tex 37, 44, 96, 126, 144; comp.tex 21, 35, 57, 62, 69, 98, 120, 127; nn.tex 11, 20, 27, 50, 80, 85, 90; related.tex 17", "minor",
    "Several \\status values are outside the allowed set {proved, computed, conjecture, known, proof sketch, refuted, known; unverified, known; unverified (claimed in the slides)}. Examples: 'proved (corrected)', 'proved; analogue known', 'refuted as stated; remark', 'proved; disjointness computed (context c7)', 'remark', 'regret proved; running time proof sketch', 'proved (trivial)', 'proved (given the coding theorem)', 'known (snippets; unverified)', and 'warm-up arithmetic re-checked (context c8)'. The binding note says the conversion pass reads these values, so they must map mechanically. Process words such as 'corrected' must not reach the PDF.",
    "OUTLINE Rules 1 and the binding note: 'keep them accurate: the conversion reads them'.",
    "Normalise to the allowed values with part labels, e.g. thm:comp:timebounded '(a) proved; (b) proof sketch; computed'; prop:ood:relative 'proved'; rem:ood:lopsided 'refuted' (or no status for a remark); rem:related:new 'known; unverified'.")

add("P1C-16", "paper/sections/ood.tex", "line 7", "minor",
    "'His draft adds a two-sided version, asks for a converse, and lists examples where SFI \"plausibly\" generalises well.' Only the two-sided version is in the PDF draft. The converse question is in his SFI notes, and the examples are in a separate note.",
    "research/prior/hanni-sfi-draft-2025-09.txt contains no 'converse' and no 'plausibl'. The converse is in hanni-sfi-notes.md line 34; the examples are in hanni-some-examples-where-function-solomonoff-generalizes-well-ood.md.",
    "'His draft adds a two-sided version; his notes ask for a converse and list examples where SFI \"plausibly\" generalises well.'")

add("P1C-17", "paper/sections/ood.tex", "ex:ood:hanniexamples(c) (line 171)", "minor",
    "'\"|x| even\" and \"output 0\" cost O(1) bits, so a wrong answer keeps probability at least 2^{-c'}' fails at the empty string. It has even length 0, and 'output 0' is the correct answer there. Hänni's example asks for generalisation 'to all strings'. The claim itself is true, but the witness behaviour is wrong at one input. The source has the same slip.",
    "Examples notes §5.3: '\"|x| is even\" and \"output 0\" are O(1) bits, so a wrong answer has probability >= 2^{-c'} on every even-length input'. At x = epsilon, |x| = 0.",
    "Use 'output 1', which is wrong on every even length, or take the property '|x| even and x nonempty'.")

add("P1C-18", "paper/sections/ood.tex", "ex:ood:hanniexamples(a) (line 169)", "minor",
    "'This makes precise Hänni's weakly held hypothesis that for Solomonoff induction \"ood generalization is a thing, but easy-to-hard generalization is not\"'. Only the second half is made precise. In the same note Hänni immediately qualified the first half ('maybe it's more like: true ood generalization is not a thing for solomonoff').",
    "research/prior/hanni-does-solomonoff-generalize-well-out-of-distribution.md line 18.",
    "'This makes precise the second half of a hypothesis Hänni held only weakly ...: easy-to-hard generalisation fails in the sense above.'")

add("P1C-19", "paper/sections/ood.tex", "rem:ood:lopsided (line 97)", "minor",
    "'reading \\cref{prop:ood:budget} as a formalisation of Hänni's \"fake ood generalization\" is an interpretation' uses a term that is not defined or quoted anywhere in the paper, so the reader cannot follow it.",
    "The term is from hanni-does-solomonoff-generalize-well-out-of-distribution.md line 18: 'there is \"fake ood generalization\", which is where you've already seen many \"ood generalizations\" of the same kind'.",
    "Quote the definition once, or drop the sentence.")

add("P1C-20", "paper/sections/ood.tex", "prop:ood:relative (line 38)", "minor",
    "'2^{-|p|}/nu(D), the posterior weight of p' is the posterior weight of p only for nu = W. For M_F it is the W-prior weight of p divided by the M_F evidence.",
    "Context notes Prop 2.3: 'The same holds for M_F with 2^{-|p|}/M_F(D), by M_F >= 2^{-c}W'.",
    "'... times 2^{-|p|}/nu(D) (for nu = W, the posterior weight of p)'.")

add("P1C-21", "paper/sections/ood.tex", "conventions paragraph (line 13); prop:ood:budget (line 88)", "minor",
    "K(Q) is used in thm:ood:twosided(c), prop:ood:budget, prop:ood:draftfalse and ex:ood:easyhard but is never defined; only K(Q,b) is. prop:ood:budget's minimum is over an empty set if x_k repeats an earlier input. The conventions do not assume the inputs are distinct.",
    "ood.tex line 13 defines only K(Q,b). prop:ood:budget does not state that the inputs are distinct.",
    "Add 'K(Q) is the least K(e) over indices e of total deciders of Q.' In prop:ood:budget add 'distinct inputs x_1, x_2, ...'.")

add("P1C-22", "paper/sections/ood.tex", "prop:ood:draftfalse (line 67)", "minor",
    "(a) writes Q_d for a sequence of properties with K(Q_d) -> infinity, while (b), the same proposition, and the whole paper use d for the input length. A reader takes Q_d to depend on the input length.",
    "NOTATION: d = input length. Context notes use Q_n.",
    "Rename to Q_j with j -> infinity.")

add("P1C-23", "paper/sections/ood.tex", "thm:ood:twosided (lines 57-60); ex:ood:easyhard (line 138)", "minor",
    "The outline requires every lower bound to say that it bounds the defined-and-wrong (or defined-and-abiding) mass and holds in both conventions. thm:ood:twosided and ex:ood:easyhard do not say this. ex:ood:easyhard's 'the correct label has probability at least 2^{-K(T)-c}' also needs x* to be decided by T. That is implicit in 'labelled'.",
    "OUTLINE §7 notes: 'Say for each lower bound that it bounds the defined-and-wrong mass and holds in both conventions.'",
    "Add 'All lower bounds here are on defined outputs, so they hold in both conventions.' In ex:ood:easyhard add 'x* is decided by T'.")

add("P1C-24", "paper/sections/app-ood.tex", "proof of prop:ood:labelled (line 31); status at ood.tex line 126", "minor",
    "The parenthetical 'A direct computation on a finite mixture ... confirms the disjointness on all subsets of a five-point domain' presents a computer check of a two-line logical fact. This is out of place in a proof. The status 'disjointness computed' has the same problem.",
    "The disjointness argument is complete in the preceding sentence.",
    "Delete the parenthetical and set the status to 'proved'.")

add("P1C-25", "paper/sections/app-ood.tex", "grammar paragraph (line 39)", "minor",
    "'Programs with the same values on all strings of length 1 to 8 are merged into 1345 classes' is inaccurate: the 1345 classes are the depth-<=2 plain expressions, and if-programs are combinations of a condition and two classes. In the x10 tilted prior the masses sum to 1.06, so the prior is not a sub-probability. The predictive is a normalised ratio, so this is harmless, but it should be said.",
    "e5 output: 'expression classes (distinct value vectors, depth <= 2): 1345'. scratch/p1-math-C/c1b_prior_share.out.txt: plain 0.348 + if-programs 0.242 + extra 0.470 = 1.06.",
    "'Plain expressions with equal values on all strings of length 1 to 8 are merged into 1345 classes ... The posterior predictive is computed from the normalised prior.'")

add("P1C-26", "paper/sections/comp.tex", "cor:comp:poly and the sentence after it (lines 47, 54)", "minor",
    "'constant regret against all polynomial-time predictors in time |x|^{omega(1)} per round' is inaccurate. The clock is (|x_k|+2)^{g(k)}, with the exponent growing in the round index, not in |x|. If |x_k| stays bounded, the time per round is not |x|^{omega(1)} in the usual sense. The source also gives the length-clocked variant (|x|+2)^{g(|x|)}, which achieves |x|^{omega(1)} on distinct inputs. The paper omits it.",
    "Context notes Cor 3.2b: 'time |x|^{omega(1)} with an arbitrarily slowly growing omega(1). The length-clocked version (clock (|x|+2)^{g(|x|)}) gives the same on distinct inputs.' Hänni's Remark 4 concerns sequences, where n is the round count.",
    "'... in time (|x_k|+2)^{g(k)} per simulation, with g growing arbitrarily slowly; the length-clocked variant with clock (|x|+2)^{g(|x|)} gives time |x|^{omega(1)} on distinct inputs.'")

add("P1C-27", "paper/sections/comp.tex", "prop:comp:round (line 36); def:comp:timebounded (line 17)", "minor",
    "The activation rounds k_i are used but never defined; the definition introduces only activation lengths n_i. The section also uses n_i, n_A and n'_A for input lengths, which clashes with the paper-wide convention that n is the sample size and d the input length.",
    "NOTATION.md: d = input length, n = sample size. comp.tex line 22: n_A := max(n_i, ...).",
    "Define 'activation rounds k_1 < k_2 < ...' in prop:comp:round. Rename the length thresholds, e.g. to ell_i, ell_A and ell'_A.")

add("P1C-28", "paper/sections/app-comp.tex", "rem:comp:constant (line 15)", "minor",
    "'the constant ... is of order 2^{2^{2^i}}' should be 'at least'. n_A can exceed n_i when c_A is large.",
    "Context notes Rem 3.1a: 'is at least 2^{2^{2^i}}'.",
    "Replace 'is of order' with 'is at least'.")

add("P1C-29", "paper/sections/comp.tex", "thm:comp:circuitbayes(a) (line 90)", "minor",
    "'For every B ⊆ {0,1}^d ... some circuit of size at most ceil(L_B) agrees with f on B' fails for B = empty set: L_B = 0 and there are no circuits of size 0. The proof uses B nonempty ('strictly because ... B != empty').",
    "app-comp.tex line 27; def:comp:circuits: sizes s >= 1.",
    "'For every nonempty B ⊆ {0,1}^d'.")

add("P1C-30", "paper/sections/comp.tex", "def:comp:circuits (line 82)", "minor",
    "'The prior w(C):=2^{-s}/N_s is the code length of \"size in unary, then the gate list\"': w is 2 to the minus the code length, not the code length. 'appends gamma <= d+1 gates computing [x=a] and a new output gate' can be read as gamma+1 gates. In the source, gamma = max(d-1,1)+1 includes the output gate.",
    "Context notes §3.2: 'This is 2^{-|desc(C)|} for the prefix-free description ...'; 'So g <= d+1 gates are added'.",
    "'w(C) = 2^{-|desc(C)|} for the prefix-free description ...'; 'appends gamma <= d+1 gates (those computing [x=a] and a new output gate)'.")

add("P1C-31", "paper/sections/comp.tex", "rem:comp:majority, last sentence (line 111)", "minor",
    "The remark ends with 'For Occam the assumption can fail at every step:' and then a new subsection begins. The colon dangles.",
    "comp.tex lines 111-115.",
    "End with 'For Occam the assumption can fail at every step (\\cref{thm:comp:ladder}).'")

add("P1C-32", "paper/sections/app-comp.tex", "rem:comp:adversary (line 59)", "minor",
    "'(For formulas the slot count gives |V_h| <= csize(h) ...)' uses csize, defined as circuit size, for formula size.",
    "def:comp:circuits defines csize for circuits.",
    "Write 'formula size' or introduce a symbol for it.")

add("P1C-33", "paper/sections/comp.tex", "rem:comp:apples (line 58)", "minor",
    "'no x-only learner competes with them, since ... SFI's loss on those data is unbounded (\\cref{thm:hist:chain,thm:hist:skipped})': those theorems are about SFI. The statement for every order-free (x-only) learner is prop:hist:orderfree.",
    "CLAIMS.md: prop:hist:orderfree: every order-free predictor pays the chain and skipped-string lower bounds.",
    "Cite \\cref{prop:hist:orderfree} as well.")

add("P1C-34", "paper/sections/comp.tex", "q:comp:samplers (line 75)", "minor",
    "The Monte Carlo heuristic omits the source's condition that the sampler's probabilities be bounded away from 0 and 1.",
    "Context notes Q 3.4: 'when the sampler's probabilities are bounded away from 0 and 1, an expected excess log loss of order 1/t per round'.",
    "Add the condition.")

add("P1C-35", "paper/sections/comp.tex", "line 10 and rem:comp:gap (line 99)", "minor",
    "Quotation marks are put around text that is not verbatim. 'regret and complexity are polynomially related' is the file name or title of a note, not a sentence in it. '\"log loss <= poly(m)\"' and '\"a circuit of size poly(m)\"' paraphrase 'the log loss is at most poly(m)' and 'a circuit of size at most poly(m)'.",
    "research/prior/hanni-circuit-for-circuit-induction-regret-and-complexity-are-polynomially-related.md (title only), lines 10-11.",
    "Quote exactly, or paraphrase without quotation marks.")

add("P1C-36", "paper/sections/nn.tex", "cor:nn:separation (line 66)", "minor",
    "'For |S|=k and i.i.d. uniform inputs, SFI ... has cumulative posterior error at most ... on every sequence of inputs' mixes the i.i.d. setting with a pathwise statement. 'SFI needs O(k log d/epsilon) in this averaged sense' compares SFI's Cesàro average over steps with the kernels' error at a fixed n averaged over targets, but only the word 'averaged' is shared.",
    "Context notes Cor 4.7: 'On any sequence of distinct inputs ...'; 'SFI needs O(k log d/epsilon) in the Cesàro sense, or per step by Cor 2.17(a)'.",
    "State the pathwise bound for every input sequence first, then the i.i.d. consequence. Write 'in the Cesàro sense (per step, O((k log d + log n)/epsilon) by \\cref{cor:learn:perstep}(a))'.")

add("P1C-37", "paper/sections/nn.tex, app-nn.tex", "thm:nn:walsh (line 58), rem:nn:oddparity(c) (line 75); app-nn.tex lines 10, 21-23", "minor",
    "The notation is inconsistent. Lambda_{|S|} (statement) vs Lambda_S (proof). <x,x'> is the inner product in R^d and <z,chi_S> the L^2 pairing. K denotes the Gram matrix, which clashes with Kolmogorov complexity K. rem:nn:oddparity(c) does not restate its hypotheses (these two kernels, odd |S| >= 3). 'From (a)' in the proof of (c) means thm:nn:walsh(a).",
    "nn.tex lines 58, 75; app-nn.tex lines 10, 22, 23.",
    "Use Lambda_{|S|} throughout. Write E_x[z(x)chi_S(x)] for the L^2 pairing and G for the Gram matrix. Begin (c) with 'For these kernels and odd |S| >= 3'. Write 'From \\cref{thm:nn:walsh}(a)'.")

add("P1C-38", "paper/sections/steeper.tex", "line 6", "minor",
    "'This section summarises the results; all of them are proved there.' Several summarised items are computed (the window endpoints 9.54e-7, 8.06e-3 and 3.66e-3; 0.983, 37.7 bits and 0.199; the envelope figures 31% and 25%), and one is open ('whether structured error rules leave a window is open').",
    "Steeper notes §0: '[computed: c3]' for the windows; Prop 2.17 '[proved; computed: c7(B)]'.",
    "'... all of them are proved there, with the numerical values computed from the explicit bounds.'")

add("P1C-39", "paper/sections/steeper.tex", "lines 8, 10, 14", "minor",
    "Some summaries drop hypotheses. 'the product class pays min(lambda,2) bits per coin' holds for incompressible coin sequences: the bound is min(lambda,2)(K(beta|k)-kappa). The 0.199 figure holds at randomness deficiency 0. 'the lambda-MAPs are eventually equivalent to nu' holds almost surely. 'every countable product class' should say 'with Kraft weights'.",
    "Steeper notes Prop 1.7(i), §0 item 2 ('0.199 (kappa=0, delta_S=0)'), Thm 4 ('almost surely ...'; 'every countable product class with Kraft weights').",
    "Add 'for incompressible coin sequences', '(error rule of deficiency 0)', 'almost surely' and 'with Kraft weights'.")

add("P1C-40", "paper/sections/steeper.tex", "line 14, last sentence", "minor",
    "Misquotation. Hänni wrote '1 bit paying for 1 bit', and of the sequence case ('this doesn't show up in the seq case because there it's pretty much just 1 bit paying for 1 bit'). The paper prints '\"1 bit pays for 1 bit\"' and attaches it to shared randomness.",
    "research/prior/hanni-grokking-a-notion.md line 8.",
    "Quote '1 bit paying for 1 bit' and say that he wrote it of sequence prediction, which the summary reads as the shared-randomness case.")

add("P1C-41", "paper/sections/steeper.tex", "line 10", "minor",
    "'A few per cent below 2^{-20} and further down, near-optimal hypotheses reproduce the errors' overstates what is proved. At 6% below, the bound gives the error label probability at least 0.48; at 10% below, at least 0.66. In the top 0.6% below the threshold nothing is proved.",
    "Steeper notes §0 item 2: 'at c=0.9*2^{-m} the error label gets probability at least 0.66, at 0.94*2^{-m} at least 0.48, and in the top 0.6% below 2^{-m} nothing is proved'.",
    "'Below 2^{-20} near-optimal hypotheses give the erroneous labels probability at least 0.48 at 6% below the threshold and at least 0.66 at 10% below.'")

json.dump(I, open(sys.argv[1], "w"), indent=1, ensure_ascii=False)
from collections import Counter
print(len(I), Counter(x["severity"] for x in I))
