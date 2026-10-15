r"""Merges into make_issues.py the findings of the parallel p1-math-C list (make_issues_p1_math_C.py, same folder)
that I verified independently, and corrects my C-31 (tilted grammar). Run once: python3 -I patch_merge.py
"""
import os

HERE = os.path.dirname(os.path.abspath(__file__))
P = os.path.join(HERE, "make_issues.py")
s = open(P).read()
if "C-42" in s:
    raise SystemExit("already merged")


def span(s, id_):
    i = s.index('add("%s"' % id_)
    j = s.find('\nadd("', i + 5)
    if j < 0:
        j = s.index("\n\ndef main", i)
    return i, j


def replace(s, id_, new):
    i, j = span(s, id_)
    return s[:i] + new.strip("\n") + "\n" + s[j:]


NEW = {}
NEW["C-13"] = r"""
add("C-13", "paper/sections/nn.tex", "rem:nn:rigorous, line 86", "major",
    "Under 'Proved' the remark lists two items that are not proved as stated. (i) '... with no general lower bound, so the "
    "comparison object is circuit SFI': the inference to the right comparison object is an interpretation. (ii) 'the "
    "Gaussian-process limits fail on sparse and odd parities where SFI succeeds': for sparse parities what is proved is a "
    "squared-error statement about the real-valued kernel/GP-mean predictor, averaged over random $k$-sparse targets; a "
    "0--1 (classification) failure is proved only for bias-free two-layer ReLU kernels and odd $|S|\\ge3$. The same list "
    "says Occam 'fails exponentially', which in description length is $2^{\\Omega(\\ell/\\log\\ell)}$ (C-17).",
    "prop:nn:nolower proves only that no general lower bound holds (context notes \\S4.6(iii) draws the comparison-object "
    "conclusion in prose). nn.tex line 69: 'The separation is in squared error of the real-valued predictor; we do not "
    "claim a 0--1 version in general.' thm:nn:walsh(b), cor:nn:separation, rem:nn:oddparity(b),(c). (Point (ii) was also "
    "found by the parallel reviewer, P1C-03; verified.)",
    "Rewrite: 'Proved: ... there is no general lower bound (\\cref{prop:nn:nolower}), which suggests that the natural "
    "comparison object is circuit SFI; in the Gaussian-process limits, kernel regression and GP means need "
    "$\\binom dk$ samples in squared error on random $k$-sparse parities where SFI needs $O(k\\log d)$, and for bias-free "
    "two-layer ReLU kernels odd parities of degree at least 3 are never learned, have GP-classification prior mass 0 and "
    "are anti-correlated with the predictor on unseen points; ... Occam selection makes $2^{\\Omega(\\ell/\\log\\ell)}$ "
    "mistakes on some ordering.'")
"""

NEW["C-24"] = r"""
add("C-24", "paper/sections/comp.tex", "cor:comp:poly and the sentence after it, lines 47-54", "minor",
    "'constant regret against all polynomial-time predictors in time $|x|^{\\omega(1)}$ per round' misdescribes the "
    "cost: the exponent $g(k)$ grows with the round index, so for a fixed input length the per-round cost grows without "
    "bound in $k$; it is not a function of $|x|$ alone. The source's length-clocked variant (clock $(|x|+2)^{g(|x|)}$, "
    "distinct inputs), which does give $|x|^{\\omega(1)}$, is omitted.",
    "cor:comp:poly: round $k$ costs simulations of $(|x_k|+2)^{g(k)}$ steps. Context notes Cor 3.2b, last sentences. "
    "(Also found by the parallel reviewer, P1C-26.)",
    "Write 'in time $(|x_k|+2)^{g(k)}$ per round, for an arbitrarily slowly growing $g$; with the clock "
    "$(|x|+2)^{g(|x|)}$ the same holds on distinct inputs in time $|x|^{\\omega(1)}$ per round, the function-setting "
    "analogue of Hänni's $n^{\\omega(1)}$'.")
"""

NEW["C-31"] = r"""
add("C-31", "paper/sections/app-ood.tex; paper/sections/ood.tex",
    "app-ood.tex line 39 and tab:ood:grammar ('tilted' rows), tab:ood:hanni line 69; ood.tex ex:ood:hanniexamples(c), line 171",
    "major",
    "The 'tilted' rows of the grammar computation are described wrongly. app-ood.tex says the extra program 'if $|x|$ even "
    "then $0$ else $|x|$' gets 'prior mass equal to (or ten times) that of all plain programs'. The code gives it the mass "
    "of the training-consistent plain programs (the single class $|x|$), which is 7.4 times smaller; with the printed "
    "description the intended answer would get $0.148$ and $0.017$, not $0.557$ and $0.114$. The main text then reports "
    "'about $0.11$ when one extra program tilts the grammar' without saying that this program carries ten times the "
    "intended program's prior mass (44% of all prior mass, about 2600 times its natural grammar weight); with the factor "
    "ten the prior masses sum to $1.06$, so the 'prior' is not a sub-probability (harmless for a normalised predictive, "
    "but unstated). Also in (c), 'SFI makes at most $c$ online errors' leaves 'online error' undefined.",
    "research/tracks/examples/checks/e5_dsl_odd_lengths.py line 88: extra_programs=[(bad, tilt * 0.5 * m_plain_ok)], with "
    "m_plain_ok the mass of the plain classes consistent with training (0.093932, class 'len' only; all plain classes "
    "0.695313). The e5 docstring and examples notes \\S5.3 carry the same wrong description. My rerun in "
    "scratch/p1-math-C/mirror/ reproduces 0.557/0.114 byte for byte; scratch/p1-math-C/c1_e5_tilt.out.txt (written by the "
    "parallel reviewer; I checked it against the code) gives 0.148/0.017 under the printed description and the 44% share. "
    "(Found first by the parallel reviewer, P1C-01 and P1C-25; verified.)",
    "app-ood.tex: 'The tilted rows add one program ... with prior mass equal to (or ten times) that of the intended program "
    "$|x|$, the only plain program consistent with the training data; with the factor ten it carries 44% of the prior "
    "mass (masses renormalised).' ood.tex line 171: 'and about $0.11$ when a single extra program with ten times the prior "
    "mass of the intended one is added'; tab:ood:hanni: '$0.11$ with a tilted prior'. Define the online errors as the "
    "steps where the correct label gets probability at most $\\frac12$ (thm:ood:cumulative).")
"""

NEW["C-32"] = r"""
add("C-32", "paper/sections/app-ood.tex", "grammar paragraph, line 39", "minor",
    "'Programs with the same values on all strings of length 1 to 8 are merged into 1345 classes': 1345 is the number of "
    "plain-expression value classes; if-programs are combinations of a condition and two classes.",
    "e5 output: 'expression classes (distinct value vectors, depth <= 2): 1345'.",
    "Write 'Plain expressions with the same values ... are merged into 1345 classes; an if-program is a condition and two "
    "such classes'.")
"""

NEW["C-33"] = r"""
add("C-33", "paper/sections/ood.tex", "ex:ood:easyhard, line 138; thm:ood:twosided, lines 57-60", "minor",
    "(i) The test sentence must be decided by $\\mathcal T$ (it has a label); the example says only that it has no proof "
    "or refutation of length at most $L'$, which an undecidable sentence also satisfies. (ii) OUTLINE requires every lower "
    "bound to say that it bounds the defined (abiding or violating) mass and therefore holds in both conventions; "
    "thm:ood:twosided and ex:ood:easyhard do not say it.",
    "Context notes Ex 2.15: 'The test statement $x^*$ is decidable in $T$, but its shortest proof or refutation is longer "
    "than $L'$'. OUTLINE \\S7 Notes ('Say for each lower bound that it bounds the defined-and-wrong mass'). (Point (ii) "
    "also found by the parallel reviewer, P1C-23.)",
    "Add 'and the test sentence $x^*$, decided by $\\mathcal T$, none of length at most $L'$'; add after thm:ood:twosided: "
    "'All these bounds concern defined outputs, so they hold in both conventions.'")
"""

NEW["C-39"] = r"""
add("C-39", "paper/sections/ood.tex", "rem:ood:answer (iii), (iv), line 145", "major",
    "(iii) says that for simple $f$ 'the error at a test point lies between $2^{-\\sep(x^*;A)-O(1)}$ and "
    "$2^{L_\\nu(f)-\\sep(x^*;A\\mid f)+O(1)}$'. In this section 'the error' $e(x^*)$ is the semimeasure-convention error, "
    "but the upper bound is proved only for $e_{\\rm norm}$ (and $e^{\\rm wr}$), and line 134 of the same section asserts "
    "that there is no pointwise bound on $e(x^*)$: the two sentences contradict each other. (By C-01 the bound on $e$ is "
    "in fact true, but it is not proved in the paper.) The lower end needs a wrong label of complexity $O(1)$ (the proved "
    "form carries $-K(y)$). (iv) drops the hypotheses of the lower bound: binary computable $f$, uniform inputs on "
    "$\\{0,1\\}^d$ with $d\\ge\\lceil\\log n\\rceil+1$.",
    "prop:ood:labelled bounds $e^{\\rm wr}\\le e_{\\rm norm}\\le2^{L_\\nu(f)-K(x^*\\mid f)+c}$ and has lower bound "
    "$2^{-\\sep(x^*;A)-K(y)-c}$; ood.tex line 134; prop:learn:typical (learn.tex line 138). (The contradiction with line "
    "134 was also found by the parallel reviewer, P1C-04; verified.)",
    "(iii): 'For simple $f$ and binary labels, $e^{\\rm wr}(x^*)\\ge2^{-\\sep(x^*;A)-O(1)}$ and "
    "$e_{\\rm norm}(x^*)\\le2^{L_\\nu(f)-\\sep(x^*;A\\mid f)+O(1)}$.' (iv): add 'for computable binary $f$ and uniform inputs "
    "on $\\{0,1\\}^d$ with $d\\ge\\lceil\\log n\\rceil+1$'.")
"""

EXTRA = r"""
# ---------------------------------------------------------------- merged after verification from the parallel list
add("C-42", "paper/sections/comp.tex; paper/sections/app-comp.tex",
    "prop:comp:round (line 36), cor:comp:poly (line 47), prop:comp:history (line 63); thm:comp:timebounded(b) (line 24)",
    "major",
    "Running-time claims that are only sketched, or not argued at all, sit inside the statements of two propositions and "
    "a corollary. prop:comp:round ('Round $k$ costs ... simulations ... plus as many arithmetic operations'), "
    "cor:comp:poly ('round $k$ costs ...') and prop:comp:history ('round $k$ costs "
    "$O(\\#\\{i:k_i\\le k\\}\\,g(k)t(\\tilde n_k))$ steps plus the replay memory') have proofs that cover only the regret; "
    "no sketch of the running time is given anywhere (Appendix G sketches only thm:comp:timebounded(b)). Once the "
    "\\status tags are removed, nothing marks these parts as unproved, which the binding note forbids.",
    "comp.tex lines 39-41 (proof of prop:comp:round: regret only) and 50-52 (proof of cor:comp:poly: regret only); "
    "app-comp.tex lines 18-20 (proof of prop:comp:history, 'regret'); statuses 'running time proof sketch'. Binding note: "
    "'Proof sketches are labelled ``Proof sketch'', and the statement must not be presented as fully proved.' (Found by "
    "the parallel reviewer, P1C-06; verified.)",
    "Move the running-time sentences out of the statements into remarks headed 'Running time (proof sketch)', each with "
    "two sentences of argument (the incremental update of thm:comp:timebounded(b) applies to the round-indexed "
    "mixtures; for prop:comp:history add the replay cost), and state the unwritten machine-model caveat there.")

add("C-43", "paper/bib/core.bib; paper/sections/nn.tex; paper/sections/steeper.tex",
    "hanni2026request (core.bib lines 19-25); cited at nn.tex line 8 and steeper.tex line 14", "major",
    "With Kaarel Hänni as sole author, the bibliography lists 'Kaarel Hänni. Request for a paper on Solomonoff function "
    "induction. Personal communication to the author, 11 October 2026; quoted verbatim in .../research/00-brief.md'. A "
    "personal communication from the author to himself is not a citable source, and a reader cannot make sense of it. In "
    "these sections it supports the quotations 'kinda like a circuit version of solomonoff function induction' (nn.tex) "
    "and 'a preference for a simple sampler over a model where the sampled bits are filled in ... both get similar "
    "posterior' (steeper.tex).",
    "core.bib lines 19-25; main.bbl. OUTLINE binding note (sole author; ideas credited through his notes or by stating "
    "the authorship arrangement). (Found by the parallel reviewer, P1C-11; verified.)",
    "Drop the citation and present the two remarks as the author's own ('The author has described NN Bayes as ...'; "
    "'The author also asked for ...'), or cite a note in the public notes repository if the text is there.")

add("C-44", "paper/sections/nn.tex; paper/sections/comp.tex", "rem:nn:slides line 81; rem:comp:selection line 128",
    "minor",
    "With the slides' co-author as the paper's sole author, 'the rest is unchecked' and 'the other claims are the slides' "
    "and we have not checked them' read oddly: the author reports not having checked his own slides. The same holds for "
    "sentences that argue with 'Hänni' in the third person ('Hänni's version has an extra ... term, which is not "
    "needed'). The binding note allows crediting his notes by citation, but the presentation of the slides needs the "
    "authorship arrangement stated where it matters.",
    "Binding note: 'Hänni's ideas are credited through citations to his notes, or by stating the authorship "
    "arrangement'. (Related to the parallel reviewer's P1C-12, which I grade minor because the binding note sanctions the "
    "third-person citation of the notes.)",
    "In rem:nn:slides write 'The slides \\citep{vaintrobhanni2026nnbayes} claim ...; of these, only (i), Appendix J and "
    "Appendix K are proved in this paper', and avoid first-person statements about checking; in nn.tex line 24 write 'The "
    "version in \\citet{hanni2026notes} has an extra ... term; it is not needed.'")

add("C-45", "paper/sections/ood.tex", "ex:ood:hanniexamples(c), line 171", "minor",
    "The witness for the wrong answer fails at one input: '``$|x|$ even'' and ``output $0$'' cost $O(1)$ bits, so a wrong "
    "answer keeps probability at least $2^{-c'}$' on every even-length input; at the empty string (length $0$, even) "
    "'output $0$' is the correct answer. The claim is true with another simple wrong behaviour.",
    "Hänni's example asks for generalisation 'to all strings' (prior/hanni-some-examples-where-function-solomonoff-"
    "generalizes-well-ood.md line 7). Same slip in examples notes \\S5.3. (Found by the parallel reviewer, P1C-17; "
    "verified.)",
    "Use 'output $|x|+1$'.")

add("C-46", "paper/sections/ood.tex", "conventions paragraph line 13; prop:ood:budget line 88", "minor",
    "$K(Q)$ is used in thm:ood:twosided(c), prop:ood:budget, prop:ood:draftfalse and ex:ood:easyhard but never defined "
    "(only $K(Q,b)$ is); and $\\sep_k$ is a minimum over an empty set when $x_k$ repeats an earlier input, which the "
    "conventions do not exclude.",
    "ood.tex line 13 defines $K(Q,b)$ only. (Found by the parallel reviewer, P1C-21; verified.)",
    "Add '$K(Q)$ is the least $K(e)$ over total deciders $\\varphi_e$ of $Q$' and '($\\sep_k:=\\infty$ if no decidable $Q$ "
    "separates $x_k$, e.g. if $x_k$ repeats)'.")

add("C-47", "paper/sections/app-ood.tex; paper/sections/ood.tex",
    "proof of prop:ood:labelled line 31; status at ood.tex line 126", "minor",
    "The parenthesis 'A direct computation on a finite mixture ... confirms the disjointness on all subsets of a "
    "five-point domain' presents a computer check of a two-line logical fact inside a proof; the status 'disjointness "
    "computed' has the same problem.",
    "The disjointness is proved in the preceding sentence. (Found by the parallel reviewer, P1C-24.)",
    "Delete the parenthesis and the 'disjointness computed' part of the status.")

add("C-48", "paper/sections/comp.tex", "prop:comp:round line 36; def:comp:timebounded line 17", "minor",
    "The activation rounds $k_i$ are used but never defined (the definition introduces only activation lengths $n_i$); "
    "and $n_i$, $n_A$, $n'_A$ denote input lengths, against the paper-wide convention ($n$ sample size, $d$ input length).",
    "NOTATION.md; def:comp:timebounded. (Found by the parallel reviewer, P1C-27; verified.)",
    "Define 'activation rounds $k_1<k_2<\\cdots$' in prop:comp:round; rename the activation lengths (e.g. $\\ell_i$, "
    "$\\ell_A$).")

add("C-49", "paper/sections/comp.tex", "thm:comp:circuitbayes(a), line 90", "minor",
    "'For every $B\\subseteq\\{0,1\\}^d$ ... some circuit of size at most $\\lceil L_B\\rceil$ agrees with $f$ on $B$' fails "
    "for $B=\\emptyset$ ($L_B=0$, and there are no circuits of size $0$); the proof uses $B\\ne\\emptyset$.",
    "app-comp.tex line 27 ('strictly because ... on $B\\ne\\emptyset$'). (Found by the parallel reviewer, P1C-29; "
    "verified.)",
    "Write 'for every nonempty $B$'.")

add("C-50", "paper/sections/app-comp.tex", "rem:comp:adversary, line 59", "minor",
    "'(For formulas the slot count gives $|V_h|\\le\\csize(h)$ ...)' uses $\\csize$, defined as circuit size, for formula "
    "size.",
    "def:comp:circuits defines $\\csize$ for circuits. (Found by the parallel reviewer, P1C-32.)",
    "Write 'the formula size of $h$'.")

add("C-51", "paper/sections/comp.tex", "rem:comp:apples, line 58", "minor",
    "'no x-only learner competes with them, since the chain and skipped-string predictors run in linear time while SFI's "
    "loss on those data is unbounded (\\cref{thm:hist:chain,thm:hist:skipped})': those theorems are about SFI; the "
    "statement for every order-free learner is prop:hist:orderfree.",
    "hist.tex thm:hist:chain, thm:hist:skipped (SFI); prop:hist:orderfree (all order-independent predictors). (Found by "
    "the parallel reviewer, P1C-33; verified.)",
    "Cite \\cref{prop:hist:orderfree} for the general claim.")

add("C-52", "paper/sections/comp.tex", "q:comp:samplers, line 75", "minor",
    "The Monte Carlo heuristic omits the source's condition that the sampler's probabilities be bounded away from $0$ and "
    "$1$.",
    "Context notes Q 3.4. (Found by the parallel reviewer, P1C-34.)",
    "Add 'when the sampler's probabilities are bounded away from 0 and 1'.")

add("C-53", "paper/sections/comp.tex", "line 10; rem:comp:gap line 99", "minor",
    "Quotation marks around text that is not verbatim: 'regret and complexity are polynomially related' is the file name "
    "of Hänni's note, and the quoted 'log loss <= poly(m)' and 'a circuit of size poly(m)' paraphrase 'the log loss is at "
    "most poly(m)' and 'a circuit of size at most poly(m)'.",
    "prior/hanni-circuit-for-circuit-induction-regret-and-complexity-are-polynomially-related.md lines 1-12. (Also noted "
    "by the parallel reviewer, P1C-35.)",
    "Quote the text verbatim or remove the quotation marks.")

add("C-54", "paper/sections/nn.tex; paper/sections/app-nn.tex",
    "thm:nn:walsh line 58; rem:nn:oddparity(c) line 75; app-nn.tex lines 10, 21-23", "minor",
    "Notation: $\\Lambda_{|S|}$ in the statement, $\\Lambda_S$ in the proof; $K$ for the Gram matrix in (c), against $K$ "
    "for Kolmogorov complexity; (c) does not restate its hypotheses (these two kernels, odd $|S|\\ge3$); 'From (a)' in the "
    "proof of (c) means thm:nn:walsh(a), not rem:nn:oddparity(a).",
    "nn.tex, app-nn.tex as cited. (Also noted by the parallel reviewer, P1C-37.)",
    "Use $\\Lambda_{|S|}$ throughout, write $G$ for the Gram matrix, open (c) with 'For these two kernels and odd "
    "$|S|\\ge3$', and write 'From \\cref{thm:nn:walsh}(a)'.")

add("C-55", "paper/sections/steeper.tex", "lines 8, 10, 14", "minor",
    "Some summaries drop hypotheses or overstate: 'the product class pays $\\min(\\lambda,2)$ bits per coin' holds for "
    "incompressible coin sequences ($\\min(\\lambda,2)(K(\\beta\\mid k)-\\kappa)$); '$0.199$' is at randomness deficiency "
    "$0$; the $\\lambda$-MAPs are eventually equivalent to $\\nu$ almost surely; 'every countable product class' needs "
    "Kraft weights; and 'A few per cent below $2^{-20}$ and further down, near-optimal hypotheses reproduce the errors' "
    "overstates what is proved (at 6% below, error-label probability at least $0.48$; at 10% below, $0.66$; nothing in the "
    "top 0.6%).",
    "Paper 2 absorb.tex line 78 (prop:absorb:price), teacher.tex table and line 131, split.tex; steeper notes-final \\S0. "
    "(Also found by the parallel reviewer, P1C-39 and P1C-41; verified.)",
    "Add the qualifiers 'for incompressible coin sequences', 'for incompressible error rules', 'almost surely', 'with "
    "Kraft weights'; replace the last sentence by 'Below $2^{-20}$, by a relative margin of a few per cent, near-optimal "
    "hypotheses give the erroneous labels substantial probability (at least $0.48$ at 6% below).'")
"""

for k, v in NEW.items():
    s = replace(s, k, v)
i = s.index("\n\ndef main")
s = s[:i] + "\n" + EXTRA + s[i:]
open(P, "w").write(s)
print("merged")
