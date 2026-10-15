"""Builds p1/issues-p1-math-C.json and the numbered issue list of p1/review-p1-math-C.md (reviewer p1-math-C).

The narrative head of the review is in review_head.md (same folder); this script appends the issue list to it.
"""
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
P1 = os.path.abspath(os.path.join(HERE, "..", "..", "p1"))

I = []


def add(id_, file, where, sev, problem, evidence, fix):
    I.append(dict(id=id_, file=file, label_or_line=where, severity=sev, problem=problem, evidence=evidence, fix=fix))


# ---------------------------------------------------------------- fatal
add("C-01", "paper/sections/ood.tex", "line 134 (paragraph after prop:ood:labelled)", "fatal",
    "The sentence \"The mass undefined at $x^*$ is not lsc, so there is no pointwise bound on $e(x^*)$\" is false as a "
    "mathematical statement, and stronger than the source. A pointwise bound of exactly the same form as for $e_{\\rm norm}$ "
    "holds for the semimeasure-convention error: $e(x^*)\\le2^{L_\\nu(f)-K(x^*\\mid f)+c}$ for $\\nu\\in\\{W,\\MF\\}$.",
    "Proof. Let $M'$ be the probabilistic machine that, given the labelled sample $f$ (a finite list), draws a hypothesis "
    "from $\\nu$'s prior (fair coins fed to $V$ until it halts on a program $p$, for $W$; the tape $\\omega$ of $T_U$, read "
    "lazily, for $\\MF$), runs it on all points of $B$ in parallel, and as soon as $|B|-1$ points have halted with the label "
    "that $f$ gives them, outputs the remaining point. Its output law $P_f$ is a discrete semimeasure, lsc uniformly in $f$, "
    "so $P_f(x)\\le2^{-K(x\\mid f)+c}$ (conditional coding theorem, the same tool as in the proof of prop:ood:labelled). "
    "Every hypothesis that is correct on $A=B\\setminus\\{x^*\\}$ and not correct at $x^*$ (wrong OR undefined there) makes "
    "$M'$ output $x^*$, so $P_f(x^*)\\ge\\nu(f|_A)-\\nu(f)=e(x^*)\\,\\nu(f|_A)$. With $\\nu(f|_A)\\ge\\nu(f)=2^{-L_\\nu(f)}$ "
    "this gives the bound. The lack of lower semicomputability of the undefined mass is circumvented because a single "
    "hypothesis that is correct on $A$ identifies $x^*$ by waiting. The source (context notes-final \\S2.4, 'Reading' after "
    "Prop 2.16) only says 'the argument does not bound the semimeasure-convention $e(x^*)$ pointwise'; the paper turned "
    "this into a non-existence claim. Independent check: scratch/p1-math-C/c1_pointwise_bound.py verifies the "
    "combinatorial step ($P_f(x)\\ge\\nu(f|_{B\\setminus x})-\\nu(f)$ for all $x$, $\\sum_xP_f(x)\\le\\nu(\\emptyset)$) on 2000 "
    "random finite mixtures with partial, wrong and shared-randomness hypotheses (min slack $-3\\cdot10^{-16}$), and shows "
    "$e/e_{\\rm norm}$ up to 3300 there, so the bound on $e$ is not a corollary of the one on $e_{\\rm norm}$.",
    "Delete the claim. Minimal fix within the sources: 'The argument above bounds only the mass that is defined and wrong; "
    "\\cref{cor:learn:perstep} bounds $e(x^*)$ in distribution.' If the authors want the stronger statement, add it as part "
    "of prop:ood:labelled with the waiting-sampler proof above, after it has been checked like the other results.")

add("C-02", "paper/sections/steeper.tex", "line 14 (paragraph 'The model--randomness split')", "fatal",
    "'with $t_n$ doubly logarithmic in the input length' is wrong and overstates Paper 2's theorem: $t_n$ is logarithmic in "
    "the input length; it is $2\\log(t_n+1)$, the exponent in the bound, that is doubly logarithmic. As printed, the lower "
    "end of the odds interval would be triply logarithmic.",
    "Paper 2, sections/split.tex line 39: $t_n:=\\lceil\\log(2d_n+2+2\\log(i_n+1))\\rceil$ with $d_n$ the largest input length; "
    "Paper 2 intro.tex line 19: 'with $2\\log(t_n+1)$ doubly logarithmic in the input length'; steeper notes-final \\S0 item 3: "
    "'$2\\log(t_N+1)$ is doubly logarithmic in $n$ and triply in $N$'.",
    "Write 'with $2\\log(t_n+1)$ doubly logarithmic in the input length (and triply logarithmic in the sample size)'.")

# ---------------------------------------------------------------- major
add("C-03", "paper/sections/comp.tex; paper/sections/app-comp.tex",
    "thm:comp:timebounded(b), comp.tex line 24; precision paragraph, app-comp.tex line 11", "major",
    "Wrong precision schedule. With relative precision $\\varepsilon_k=k^{-2}$ the first round has $\\varepsilon_1=1$, so a "
    "stored weight may be rounded to $0$ (and the machine's weight is then lost for ever); the error term "
    "$\\sum_j\\log\\frac{1+\\varepsilon_j}{1-\\varepsilon_j}$ used in the sketch is infinite, not $O(1)$. The statement "
    "'weights stored with relative precision $k^{-2}$ change the cumulative loss by $O(1)$' is false as written.",
    "app-comp.tex line 11 uses $\\hat V_k\\ge w_i|Y|^k\\prod_j q_i(1-\\varepsilon_j)$, which is $0$ when $\\varepsilon_1=1$. "
    "scratch/p1-math-C/c2_comp_constants.out.txt (e): the sum is infinite for $\\varepsilon_j=j^{-2}$ and $1.88$ bits for "
    "$\\varepsilon_j=(j+1)^{-2}$. The same slip is in the source (context notes-final Thm 3.1(b)).",
    "Use $\\varepsilon_k=(k+1)^{-2}$ (or any summable sequence with $\\varepsilon_k\\le\\frac12$) in the theorem and in the "
    "appendix; the bound then holds with additive term $\\sum_j\\log\\frac{1+\\varepsilon_j}{1-\\varepsilon_j}\\le1.9$ bits.")

add("C-04", "paper/sections/ood.tex", "ex:ood:hanniexamples(a), line 169", "major",
    "'This makes precise Hänni's weakly held hypothesis that for Solomonoff induction ``ood generalization is a thing, "
    "but easy-to-hard generalization is not''' claims more than is shown. The example proves only that a hard test "
    "sentence keeps a (tiny) failure floor $2^{-K(\\mathcal T)-2\\log\\log L-c}$; nothing in the section makes the first half "
    "('ood generalization is a thing') precise, the floor is far too small to say easy-to-hard generalisation 'is not a "
    "thing', and Hänni's hypothesis concerns sequence SI and was retracted in the next sentence of his note.",
    "Source of the quote: prior/hanni-does-solomonoff-generalize-well-out-of-distribution.md line 18 continues 'ahh idk "
    "if that's the right thing to say. maybe it's more like: true ood generalization is not a thing'. The context notes "
    "(Ex 2.15) claim only to make precise the remark that 'easy-to-hard generalization is not a thing'. The longer quote "
    "was introduced at the planning stage (app-verification.tex line 125). tab:ood:hanni itself says the floor 'is tiny "
    "for a natural theory'.",
    "Write: 'This gives one precise sense to Hänni's tentative remark that for Solomonoff induction ``easy-to-hard "
    "generalization is not'' a thing: no number of easy sentences removes a (small) floor on the wrong-label probability "
    "of a hard one.' Drop 'ood generalization is a thing' or say that the section does not address it.")

add("C-05", "paper/sections/nn.tex", "rem:nn:slides, item (vi), line 81", "major",
    "The slides' out-of-distribution position is misreported. The paper writes 'out of distribution the guarantee ``is "
    "simply false'' (\\cref{thm:comp:ladder})', tying the quote to the ladder. In the slides 'simply false' refers to the "
    "in-distribution PAC guarantee off the support ('nothing stops the learner from being wrong on inputs the training "
    "distribution never reaches'); the ladder refutes the Occam (argmax) online-mistake claim for circuits; and the "
    "slides say that an OOD online mistake bound 'might still hold' for NN Bayes, with a heuristic argument they "
    "'suspect is morally right', and that their $\\sigma\\to0$ learner (symmetric ties, majority vote) is on 'the good side' "
    "of the selection-rule table. The paper's rendering is more negative than the source.",
    "Slides text, research/prior/vaintrob-hanni-nnbayes-generalization-slides.txt lines 858-866 (slide 37: 'The "
    "in-distribution guarantee is simply false out of distribution --- there are easy counterexamples. An online mistake "
    "bound might still hold ... but the analogous claim for circuits is strictly false. (Appendix K.)'), lines 2723-2726 "
    "(slide 104), lines 2834-2841 (slide 108). Context notes \\S4.5 item 11 lists 'an OOD mistake bound for NN Bayes' among "
    "the slides' open problems.",
    "Replace (vi) by: 'out of distribution the in-distribution guarantee ``is simply false''; an online mistake bound "
    "might still hold for NN Bayes (they give a heuristic argument and list it as open), while the analogous claim for "
    "Occam learning over circuits fails (their Appendix K; \\cref{thm:comp:ladder}).'")

add("C-06", "paper/sections/comp.tex", "rem:comp:uniformties, line 133", "major",
    "Missing credit. The observation that symmetric (uniform) tie-breaking with majority prediction makes only $O(d)$ "
    "mistakes on the ladder is stated in the Vaintrob--Hänni slides; the remark presents it without citation, as "
    "following 'the direction of the companion paper on steeper priors'.",
    "Slide 108 (slides text lines 2834-2841): 'Our $\\sigma\\to0$ learner is not the deterministic argmax: ties spread "
    "symmetrically ... and we predict by majority --- the good side of this table. On the ladder the surviving "
    "conjunctions get equal mass, so the majority errs $O(d)$ times.' Context notes Rem 3.12-3.13: 'Remark 3.13 is the "
    "formula-prior version of that remark'; 'This is the ladder instance of two rows of the slides' table'.",
    "Add: 'The slides make this observation for their strong-prior learner (Appendix K); we give the formula-prior "
    "version with explicit constants.'")

add("C-07", "paper/sections/ood.tex", "rem:ood:lopsided, line 97", "major",
    "Dangling references a reader cannot follow: 'A human who generalises after seeing the data is history-aware' and "
    "'Hänni's ``fake ood generalization''' refer to arguments of Hänni (the 'human inductor' and 'fake OOD "
    "generalisation') that are never introduced anywhere in the paper.",
    "grep over paper/sections: 'fake' and 'human' occur only here. Source: prior/hanni-does-solomonoff-generalize-well-"
    "out-of-distribution.md lines 5-9 and 18; context notes-final Rem 2.8a introduces both with quotations.",
    "Either quote the two passages with \\citep{hanni2026notes} ('a human with the right prompt thinking for a long time "
    "could generalize well, and that's computable'; '``fake ood generalization'', which is where you've already seen many "
    "``ood generalizations'' of the same kind') before commenting on them, or delete the last sentence of the remark.")

add("C-08", "paper/sections/ood.tex", "conj:ood:natural, lines 177-182", "major",
    "A conjecture environment holds a statement that the paper itself says 'is not a precise statement' and that is false "
    "for some universal machines. 'Natural universal machines', 'natural training sets' and 'close to 1' are undefined, so "
    "this is not a conjecture in the mathematical sense; a reader will notice.",
    "ood.tex line 182: 'This is not a precise statement, and by \\cref{prop:ood:machine} it fails for some universal "
    "machines'. The binding note requires conjectures in standard form; examples notes \\S7 item 4 lists this as an open "
    "problem ('I see no route'), not as a conjecture with a statement.",
    "Move it out of the conjecture environment: either an 'Open problem' paragraph ('Find a fixed reference machine and "
    "a training distribution for which the intended answers of \\cref{ex:ood:hanniexamples} provably get posterior "
    "probability close to 1') or a sentence in the discussion stating the informal expectation. Update "
    "discussion.tex line 22 and app-verification.tex line 140, which cite conj:ood:natural.")

add("C-09", "paper/sections/steeper.tex", "line 6 ('all of them are proved there'), lines 10-12", "major",
    "'This section summarises the results; all of them are proved there' is stronger than the source. Several numbers "
    "quoted in the section are illustrations obtained by setting the unknown machine constant to 0 (0.983, 37.7 bits, "
    "0.199, the window end 8.06e-3, '31%'), and others are computed (the window ends, 1.6e-5); Paper 2's own notes say "
    "such numbers 'are not proved'.",
    "Steeper notes-final, status tags: 'Illustration (kappa = 0): a number obtained by setting the unknown machine "
    "constant kappa to 0. Such numbers are not proved; robust versions are given where they exist.' The section flags "
    "some of them in passing ('machine constant set to 0, an illustration'), which contradicts the blanket sentence.",
    "Write: 'This section summarises the results, which are proved there; numbers given 'with the machine constant set "
    "to 0' are illustrations, not proved values, and the window ends are computed from the proved formulas.'")

add("C-10", "paper/sections/steeper.tex; paper/bib/core.bib", "steeper.tex line 6; core.bib lines 26-33 (hanni2026lesswrong)",
    "major",
    "The citation of Hänni's proposal renders as '(Hänni, 2026b; Hänni and Wyeth, undated)'. Listing Cole Wyeth "
    "as a co-author of a comment thread attaches his name to Hänni's proposal, 'undated' is not a bibliographic year, "
    "and the citation is unnecessary: both quoted phrases are in Hänni's own note.",
    "main.bbl line 178: '\\bibitem[H{\\\"a}nni and Wyeth(undated)]{hanni2026lesswrong}'. Both quotes ('the length of the "
    "program plus the negative log likelihood ... higher coefficient on the length of the program'; 'each input gets its "
    "own private randomness') are in prior/hanni-grokking-a-notion.md lines 41 and 61, i.e. in \\citep{hanni2026notes}. "
    "Binding note: the absorption objection must not be attributed to Wyeth; a neutral footnote may record the thread.",
    "Cite only \\citep{hanni2026notes} here. If the thread is cited anywhere, make the entry Hänni's single-authored "
    "comment ('K. Hänni, comment in the LessWrong thread ``Jonas Hallgren's Shortform''', with the year of the comment "
    "or an access date), and use it at most in the one neutral footnote the binding note allows.")

add("C-11", "paper/sections/related.tex", "rem:related:new, line 18", "major",
    "(i) The remark ends with an instruction to the authors, 'Each of these should be checked against ... before any claim "
    "of novelty', and opens with a description of the search process; in an arXiv paper this reads as unfinished "
    "scholarship. (ii) The 'not found' list is broader than the source: it includes 'the OOD results of \\cref{sec:ood}' "
    "wholesale, although \\cref{thm:ood:cumulative} is the error form of the classical mistake bound "
    "(\\cref{cor:learn:mistakes}, status 'known'), \\cref{prop:ood:machine} is the analogue of Leike--Hutter (listed as "
    "existing two lines earlier), and \\cref{prop:ood:intended} is immediate; and it lists the time-bounded mixtures "
    "without the source's qualifier 'in the function setting; the sequence analogues are Hänni's polytime note and the "
    "speed-prior literature' (comp.tex itself calls prop:comp:history 'the function-setting form of Hänni's amortised "
    "warm-up').",
    "Context notes-final \\S6, 'Apparently new': names the specific OOD items (Prop 2.1, Thm 2.5, Prop 2.6, Prop 2.8, Prop "
    "2.13, Prop 2.14, Prop 2.16, Cor 2.17, Ex 2.15/2.15a) and qualifies the time-bounded items as above.",
    "Rewrite as 'To our knowledge (our search covered abstracts and secondary descriptions), the following have not "
    "appeared before: ...', list the OOD items by label (prop:ood:hanni in this form, thm:ood:twosided, prop:ood:budget, "
    "prop:ood:converse, prop:ood:sandwich, prop:ood:labelled, ex:ood:easyhard), add 'in the function setting' to the "
    "time-bounded items with a pointer to Hänni's sequence construction and the speed prior, and delete the last "
    "sentence.")

add("C-12", "paper/sections/app-verification.tex; paper/main.tex", "whole appendix (Appendix I); line 136; main.tex last \\input",
    "major",
    "The compiled PDF still contains the verification appendix ('How the claims were checked'), which the binding note "
    "forbids: it is built on process vocabulary ('track', 'referee', 'CLAIMS.md', conflict codes C1-C25, 'Co Ex 2.15', "
    "script and seed tables), and line 136 prints 'a promised Wyeth--Hutter reference not cited', a visible mention of "
    "Wyeth outside the one neutral footnote the binding note allows.",
    "main.tex: '\\input{sections/app-verification}' with the comment that 'the arXiv conversion pass drops this \\input'. "
    "OUTLINE.md binding note: 'No verification appendix.' Other sections still cite H1-H10 via tab:intro:verdicts.",
    "Drop the \\input in the conversion pass as planned; move the short account to the acknowledgements and the 'Code and "
    "data' statement; make sure no \\cref to app:verification survives and that nothing from line 136 migrates.")

add("C-13", "paper/sections/nn.tex", "rem:nn:rigorous, line 86", "major",
    "Under 'Proved' the remark lists '... with no general lower bound, so the comparison object is circuit SFI'. The "
    "inference to the right comparison object is an interpretation, not a proved statement; listing it as proved "
    "misleads. The same list says Occam 'fails exponentially', which for description length $\\ell$ is "
    "$2^{\\Omega(\\ell/\\log\\ell)}$ (see C-17).",
    "Context notes-final \\S4.6 (iii) presents it as a consequence in prose ('So the right comparison object is circuit "
    "SFI'); prop:nn:nolower proves only that no general lower bound holds.",
    "Split the sentence: 'Proved: ... there is no general lower bound (\\cref{prop:nn:nolower}). This suggests that the "
    "natural comparison object is circuit SFI rather than program SFI.' Write '$2^{\\Omega(\\ell/\\log\\ell)}$ mistakes' "
    "instead of 'exponentially'.")

add("C-14", "paper/sections/comp.tex", "thm:comp:ladder (line 121) and rem:comp:selection (line 128)", "major",
    "rem:comp:selection says the slides' first row, deterministic argmax with $2^{\\Theta(C/\\log C)}$ worst-case mistakes, "
    "is 'proved here', but the paper proves only the lower bound and states as upper bound only 'the trivial upper bound "
    "is $2^{\\ell+1}$', while q:comp:open asks whether $2^{\\Omega(\\ell)}$ is possible. The $\\Theta$ holds for the "
    "conjunction target because there are only $2^d=2^{O(\\ell/\\log\\ell)}$ inputs, but the paper never says so, so the "
    "three statements look inconsistent.",
    "Context notes-final Thm 3.11: 'For $f=\\mathrm{AND}_{[d]}$ the lower bound is tight up to the constant in the "
    "exponent, since there are only $2^d$ inputs'; \\S7 item 5. This sentence is missing from comp.tex and app-comp.tex.",
    "Add to thm:comp:ladder: 'For this target the bound is tight up to the constant in the exponent, since there are only "
    "$2^d$ inputs.' In rem:comp:selection write 'The first row (for the conjunction target) and the last row are proved "
    "here'.")

# ---------------------------------------------------------------- minor
add("C-15", "paper/sections/ood.tex", "rem:ood:answer, title, line 143", "minor",
    "The title 'the strongest true positive statements' asserts a maximality that nothing in the paper proves; the source "
    "uses the phrase only as a quoted question.",
    "Context notes-final \\S2.5 heading: 'Answer to ``the strongest true positive statement''' (in quotation marks).",
    "Retitle 'summary of the positive statements'.")

add("C-16", "paper/sections/nn.tex", "cor:nn:separation, line 66", "minor",
    "'while SFI needs $O(k\\log d/\\varepsilon)$ in this averaged sense' compares a Cesàro average over steps $1..n$ "
    "(SFI) with an error at fixed $n$ averaged over targets (kernels); 'this averaged sense' conflates the two averages.",
    "The SFI bound in the statement is 'averaged over the first $n$ steps'; the kernel bound is thm:nn:walsh(b) at "
    "sample size $n$. Context notes Cor 4.7 says 'in the Cesàro sense, or per step by Cor 2.17(a)'.",
    "Write 'SFI needs $O(k\\log d/\\varepsilon)$ samples for Cesàro-averaged squared error $\\varepsilon$, and "
    "$O((k\\log d+\\log(1/\\varepsilon))/\\varepsilon)$ for the error at a single step (\\cref{cor:learn:perstep}(a))'.")

add("C-17", "paper/sections/comp.tex; paper/sections/nn.tex", "comp.tex line 10; nn.tex line 86", "minor",
    "'Occam ... fails exponentially out of distribution': the bound is $2^{\\Omega(\\ell/\\log\\ell)}$ in the description "
    "length, i.e. exponential in $d$ but not in $\\ell$, and q:comp:open asks whether $2^{\\Omega(\\ell)}$ is possible.",
    "thm:comp:ladder; q:comp:open.",
    "Write 'makes $2^{\\Omega(\\ell/\\log\\ell)}$ mistakes (exponentially many in the input dimension)'.")

add("C-18", "paper/sections/nn.tex", "rem:nn:rigorous line 86; q:nn:bridges line 94", "minor",
    "'at fixed $\\sigma$' uses a symbol never defined in the paper (the slides' prior scale).",
    "grep: $\\sigma$ occurs in nn.tex only in these two places; rem:nn:slides speaks of 'the strong-prior limit' without "
    "naming $\\sigma$.",
    "Write 'at a fixed (not vanishing) prior scale' or define $\\sigma$ in rem:nn:slides (ii).")

add("C-19", "paper/sections/nn.tex", "rem:nn:oddparity(a) line 73; rem:nn:literature line 91", "minor",
    "Two literature paraphrases are slightly stronger than the abstracts: Basri et al. state that a network without bias "
    "cannot represent or learn 'simple, low frequency functions with odd frequencies' (the paper: 'cannot learn odd "
    "frequencies'); Mingard et al. (2025) attribute generalisation to a simplicity bias 'together with the structure of "
    "the data' (the paper drops this).",
    "Context notes-final Rem 4.8(a) and \\S4.7 (snippet contents); bib/nn.bib comments.",
    "Use the abstracts' wording: 'cannot learn low-frequency functions with odd frequencies (on the sphere)'; 'attribute "
    "much of generalisation to a prior bias towards simple functions together with the structure of the data'.")

add("C-20", "paper/sections/nn.tex", "rem:nn:slides, line 81", "minor",
    "The slides' caveats are quoted more strongly than written: 'their appendices ``have largely been generated by "
    "Claude'' and have not been ``meticulously reviewed'''. The slides say 'Many of these appendices have largely been "
    "generated by Claude' and 'I haven't meticulously reviewed many appendix slides yet'. Item (ii) also omits two caveats "
    "of the main theorem's setting: conditioning on outputs with margin $\\frac12$, and 'We don't actually consider any sort "
    "of limiting learner' ($\\sigma$ small enough for each width, not a limit).",
    "Slides text lines 888-890 and 280-296 (slides 15, 38).",
    "Quote exactly ('many of these appendices ... many appendix slides'); in (ii) write 'for each width, with the prior "
    "scale small enough and outputs conditioned with margin $\\frac12$'.")

add("C-21", "paper/sections/steeper.tex", "line 14, last sentence", "minor",
    "Misquotation: Hänni wrote '1 bit paying for 1 bit', and about the sequence case, not 'with shared randomness'.",
    "prior/hanni-grokking-a-notion.md line 8: 'this doesn't show up in the seq case because there it's pretty much just 1 "
    "bit paying for 1 bit'.",
    "Write 'where, as in sequence prediction, ``1 bit paying for 1 bit'' holds' or paraphrase without quotation marks.")

add("C-22", "paper/sections/comp.tex", "rem:comp:majority, line 111; line 117", "minor",
    "Formatting: the remark ends with a colon ('For Occam the assumption can fail at every step:') followed by a "
    "subsection heading, so the sentence dangles; line 117 prints '(Appendix K) (Vaintrob and Hänni, 2026b)' with "
    "double parentheses.",
    "PDF p. 42.",
    "End the remark with 'For Occam the assumption can fail at every step (\\cref{thm:comp:ladder}).'; write 'from "
    "Appendix K of the slides of \\citet{vaintrobhanni2026nnbayes}'.")

add("C-23", "paper/sections/app-comp.tex", "rem:comp:constant, line 15", "minor",
    "'his regret, $\\max(\\ell_1,\\ell_2)$ bits' uses $\\ell_2$ without defining it (in Hänni's note the round after which "
    "the comparator runs within the clock); and the constant is 'of order $2^{2^{2^i}}$' where it is only at least that "
    "($n_A\\ge n_i$, and $n_A$ is much larger when $c_A$ is large).",
    "prior/hanni-polytime-solomonoff.md, proof of the theorem; context notes-final Rem 3.1a ('is at least "
    "$2^{2^{2^i}}$'); scratch/p1-math-C/c2_comp_constants.out.txt (g).",
    "Define $\\ell_2$ ('the round after which $P$ runs within the clock') and write 'at least $2^{2^{2^i}}$'.")

add("C-24", "paper/sections/comp.tex", "cor:comp:poly and the sentence after it, lines 47-54", "minor",
    "'constant regret against all polynomial-time predictors in time $|x|^{\\omega(1)}$ per round' misdescribes the "
    "cost: the exponent $g(k)$ grows with the round index, so for a fixed input length the per-round cost grows without "
    "bound in $k$; it is not a function of $|x|$ alone.",
    "cor:comp:poly: round $k$ costs simulations of $(|x_k|+2)^{g(k)}$ steps.",
    "Write 'in time $(|x_k|+2)^{g(k)}$ per round, for an arbitrarily slowly growing $g$, the function-setting analogue "
    "of Hänni's $n^{\\omega(1)}$'.")

add("C-25", "paper/sections/ood.tex", "lines 7 and 53", "minor",
    "'His draft adds a two-sided version, asks for a converse, and lists examples': the converse question and the "
    "'plausibly' examples are in Hänni's notes, not in the PDF draft; and 'the draft' is never identified for the "
    "reader (all is cited as \\citep{hanni2026notes}).",
    "prior/hanni-sfi-notes.md line 34 (converse); prior/hanni-some-examples-where-function-solomonoff-generalizes-well-"
    "ood.md (examples); prior/hanni-sfi-draft-2025-09.txt lines 197-203 (two-sided result only).",
    "Write 'A draft of his (September 2025, in \\citep{hanni2026notes}) adds a two-sided version; his notes ask for a "
    "converse and list examples ...'.")

add("C-26", "paper/sections/ood.tex", "thm:ood:twosided(c), line 60", "minor",
    "The main-text theorem uses $\\KP(z\\mid x)$, which is defined only in an appendix remark "
    "(\\cref{rem:versions:Wdelim}, Appendix B).",
    "grep: \\KP occurs in the main text only in ood.tex line 60; its definition is in app-versions.tex line 8.",
    "Define it in one clause: '$\\KP(z\\mid x)$, the length of a shortest $h\\in\\dom V$ with $\\varphi_{V(h)}(x)=z$ "
    "(\\cref{rem:versions:Wdelim})'.")

add("C-27", "paper/sections/ood.tex, comp.tex, nn.tex, related.tex", "\\status tags", "minor",
    "Several \\status values are outside the agreed set and contain process words that the conversion pass may carry into "
    "the text: 'proved (corrected)' (prop:ood:relative, thm:comp:timebounded, prop:comp:samplers), 'refuted as stated; "
    "remark', 'proved; analogue known', 'proved; disjointness computed (context c7)', 'proved (trivial)', 'proved (given "
    "the coding theorem)', 'warm-up arithmetic re-checked (context c8)'. rem:nn:oddparity has the single status "
    "'proved; computed; known' although only (a) is known and (b), (c) are new (OUTLINE rule 1 asks for part labels).",
    "OUTLINE.md rule 1 and binding note ('keep them accurate: the conversion reads them'); context notes Rem 4.8 "
    "('(b) ... new as far as I know', '(c) ... new as far as I know').",
    "Normalise to the agreed values, e.g. rem:nn:oddparity: '(a) known; proved; (b), (c) proved; computed'; drop "
    "'(corrected)', '(trivial)' and the track names.")

add("C-28", "paper/sections/related.tex", "lines 6 and 12", "minor",
    "'(we have seen only the abstract)' and 'Vovk's earlier universal forecasting algorithms \\citep{vovk1992universal} we "
    "have not examined' are not standard in a paper; citing a work while saying it was not examined invites the question "
    "why it is cited.",
    "bib/related.bib: vovk1992universal 'content not seen'. The binding note asks for hedged content claims, not for "
    "process statements.",
    "Use standard hedges ('as described in its abstract', 'according to secondary sources'); drop the Vovk 1992 citation "
    "or describe it by its abstract.")

add("C-29", "paper/sections/related.tex", "line 12", "minor",
    "'Inductive inference of recursive functions (Gold; Barzdin--Freivalds; Case--Smith) is the deterministic, "
    "identification-in-the-limit ancestor': Barzdin and Freivalds study prediction with bounded numbers of errors (the "
    "paper cites them for the mistake bound, cor:learn:mistakes), not identification in the limit.",
    "learn.tex cor:learn:mistakes status 'known (Littlestone 1988; Barzdin--Freivalds 1972, content unverified)'; "
    "context notes \\S6 item 11 ('deterministic-identification ancestors').",
    "Write 'the deterministic ancestor: identification in the limit and prediction of recursive functions'.")

add("C-30", "paper/sections/ood.tex", "prop:ood:draftfalse(a), line 67", "minor",
    "'$Q_d$' and '$K(Q_d)\\to\\infty$' use $d$ as a sequence index, while $d$ is the input length elsewhere in the paper and "
    "in part (b) of the same proposition.",
    "NOTATION.md: $d$ = input length. Source uses $Q_n$ as a sequence index.",
    "Write $Q_m$ ($m\\to\\infty$) or 'a sequence of decidable $Q$ with $K(Q)\\to\\infty$'.")

add("C-31", "paper/sections/ood.tex", "ex:ood:hanniexamples(c), line 171", "minor",
    "'about $0.11$ when one extra program tilts the grammar' omits that the extra program has ten times the prior mass of "
    "all plain programs together; with equal mass the value is $0.557$. 'SFI makes at most $c$ online errors' leaves "
    "'online error' undefined (it means steps where the correct label gets probability at most $\\frac12$).",
    "app-ood.tex table tab:ood:grammar (tilted x1: 0.557; x10: 0.114); scratch/p1-math-C/mirror/.../e5_dsl_odd_lengths."
    "out.txt reproduces the table byte for byte.",
    "Write 'and about $0.11$ (resp. $0.56$) when one extra program with ten times (resp. once) the prior mass of all plain "
    "programs is added'; define the online errors as in thm:ood:cumulative.")

add("C-32", "paper/sections/app-ood.tex", "grammar paragraph, line 39", "minor",
    "'Programs with the same values on all strings of length 1 to 8 are merged into 1345 classes': 1345 is the number of "
    "plain-expression value classes, not of all programs.",
    "e5 output: 'expression classes (distinct value vectors, depth <= 2): 1345'.",
    "Write 'Plain expressions with the same values ... are merged into 1345 classes'.")

add("C-33", "paper/sections/ood.tex", "ex:ood:easyhard, line 138", "minor",
    "The test sentence must be decided by $\\mathcal T$ (it has a label); the example says only that it has no proof or "
    "refutation of length at most $L'$, which an undecidable sentence also satisfies.",
    "Context notes Ex 2.15: 'The test statement $x^*$ is decidable in $T$, but its shortest proof or refutation is longer "
    "than $L'$'.",
    "Add 'and the test sentence $x^*$, decided by $\\mathcal T$, none of length at most $L'$'.")

add("C-34", "paper/sections/ood.tex", "prop:ood:relative, line 38", "minor",
    "'$2^{-|p|}/\\nu(D)$, the posterior weight of $p$' is exact for $W$ only; under $\\MF$ the deterministic program $p$ has "
    "posterior weight $2^{-|p|-O(1)}/\\MF(D)$.",
    "Context notes Prop 2.3: 'The same holds for $M_F$ with $2^{-|p|}/M_F(D)$, by $M_F\\ge2^{-c}W$' (a bound, not the "
    "posterior weight).",
    "Write 'the posterior weight of $p$ under $W$ (up to a constant factor under $\\MF$)'.")

add("C-35", "paper/sections/ood.tex; paper/sections/comp.tex", "rem:ood:lopsided line 97; rem:comp:distinct line 31", "minor",
    "Both remarks refute readings that appear only in the research notes ('Reading ... as ``the total OOD error lies "
    "between ...'' is wrong'; 'One might hope that restricting (a) to distinct inputs loses nothing'). The binding note "
    "allows refuted claims only where they inform the reader; the informative content is the positive statement.",
    "CLAIMS.md rows rem:ood:lopsided, rem:comp:distinct: '(Co notes.md) is refuted'.",
    "State the facts directly: 'The novelty lower bounds sum to at most $2^{-c}$: separation forces constant error at "
    "single steps but only $O(1)$ in total' and 'Distinctness is needed: ...'.")

add("C-36", "paper/sections/nn.tex; paper/sections/comp.tex", "q:nn:bridges line 94; q:comp:open line 136", "minor",
    "The open-question paragraphs contain to-do items rather than mathematical questions: 'a check of the slides' main "
    "theorem' and 'The machine-model details of the running times above ... are not written out'.",
    "Binding note: open questions under 'Open problems'; gaps in proofs belong with the proof sketch.",
    "Rephrase as questions ('Does the slides' main theorem hold as stated? Does ``few mistakes'' imply a small circuit for "
    "NN Bayes?') and move the machine-model caveat to the proof sketch of thm:comp:timebounded(b).")

add("C-37", "paper/sections/comp.tex", "def:comp:circuits, line 82", "minor",
    "'The prior $w(C):=2^{-s}/N_s$ is the code length of ``size in unary, then the gate list''' (it is $2^{-\\text{code "
    "length}}$); 'appends $\\gamma\\le d+1$ gates computing $[x=a]$ and a new output gate' reads as $\\gamma+1$ gates, while "
    "$\\gamma$ counts the output gate too ($\\max(d-1,1)$ gates for $[x=a]$ plus one).",
    "Context notes \\S3.2 ('This is $2^{-|\\mathrm{desc}(C)|}$'; 'So $g\\le d+1$ gates are added').",
    "Write 'is $2^{-\\ell}$ for the code length $\\ell$ of ...' and 'appends $\\gamma\\le d+1$ gates in all: $\\max(d-1,1)$ "
    "gates computing $[x=a]$ and a new output gate'.")

add("C-38", "paper/sections/comp.tex", "proof idea of thm:comp:ladder, line 124", "minor",
    "'Each is wrong only at its own point $1_S$' is true only among inputs of weight $k$ ($\\mathrm{AND}_S$ is also wrong at "
    "every heavier input containing $S$ other than $1^d$).",
    "app-comp.tex line 52 states it correctly for $|S|=|S'|=k$.",
    "Write 'Among the inputs of weight $k$, each is wrong only at its own point $1_S$'.")

add("C-39", "paper/sections/ood.tex", "rem:ood:answer (iii), (iv), line 145", "minor",
    "Missing hypotheses: the lower end $2^{-\\sep(x^*;A)-O(1)}$ in (iii) needs a label of complexity $O(1)$ (binary "
    "labels; in general $2^{-\\sep-K(y)-c}$); the lower bound in (iv) needs binary computable $f$ and input length "
    "$d\\ge\\lceil\\log n\\rceil+1$.",
    "prop:ood:labelled (with $K(y)$); prop:learn:typical (hypotheses $d\\ge\\ell$, binary $f$).",
    "Add 'for binary labels' to (iii) and 'for binary $f$ and $d\\ge\\lceil\\log n\\rceil+1$' to (iv).")

add("C-40", "paper/sections/ood.tex", "proof of prop:ood:hanni, line 24", "minor",
    "For $\\MF$ the proof ends 'apply \\cref{thm:setting:universal}', but that theorem's dominance is stated for data sets; "
    "the claim about the infinite event 'agrees with $b$ on all of $Q\\cap\\dom b$' needs the tape-prefix argument (tapes "
    "of $T_U$ that start with a program for $T_{Q,b}$).",
    "thm:setting:universal is stated for $D\\ne\\emptyset$ (finite); context notes Prop 2.1(2): 'The infinite event is a "
    "countable intersection of events, and the same inclusion applies to it.'",
    "Add: 'The tapes of $T_U$ that begin with a program for $T_{Q,b}$ have measure at least $2^{-K(Q,b)-c}\\MF(D)$ among "
    "those consistent with $D$, and each gives a function equal to $b$ on $Q\\cap\\dom b$.'")

add("C-41", "paper/sections/comp.tex", "prop:comp:history, line 66", "minor",
    "'The class contains the chain and skipped-string predictors' holds for a linear time bound; the proposition is "
    "stated for a general $t$.",
    "Context notes Prop 3.2c: 'The class contains the chain and skipped-string predictors (with $p(n)=n$)'.",
    "Add 'for $t(n)=n$'.")


def main():
    with open(os.path.join(P1, "issues-p1-math-C.json"), "w") as fh:
        json.dump(I, fh, indent=1, ensure_ascii=False)
    head = open(os.path.join(HERE, "review_head.md")).read()
    lines = [head.rstrip(), "", "## 7. Numbered issue list", ""]
    for k, it in enumerate(I, 1):
        lines.append(f"### {k}. {it['id']} [{it['severity']}] {it['file']}, {it['label_or_line']}")
        lines.append("")
        lines.append(f"* **Problem.** {it['problem']}")
        lines.append(f"* **Evidence.** {it['evidence']}")
        lines.append(f"* **Fix.** {it['fix']}")
        lines.append("")
    with open(os.path.join(P1, "review-p1-math-C.md"), "w") as fh:
        fh.write("\n".join(lines) + "\n")
    sev = {}
    for it in I:
        sev[it["severity"]] = sev.get(it["severity"], 0) + 1
    print(len(I), sev)


if __name__ == "__main__":
    main()
