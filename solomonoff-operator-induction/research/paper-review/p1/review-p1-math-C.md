# Paper 1: mathematical and scholarly review C (out-of-distribution behaviour, computable versions, NN Bayes, steeper summary, related work; Appendices F, G, H, I)

Reviewer: p1-math-C.

**Scope.** `paper/sections/ood.tex`, `comp.tex`, `nn.tex`, `steeper.tex`, `related.tex`, and the appendices `app-ood.tex` (F), `app-comp.tex` (G), `app-nn.tex` (H) and `app-verification.tex` (I), as compiled in `paper/main.pdf` (build of 12 October 2026, 16:59). The other appendices are covered by reviewers A (setting, versions, learning) and B (history, examples).

**Sources checked against.** `research/tracks/context/notes-final.md` §§1–4, 6, 7 (with `referee.md` and `checks/`), `research/tracks/examples/notes-final.md` §5 (with check e5), `research/tracks/steeper/notes-final.md` and Paper 2's sections (for `steeper.tex`), the Vaintrob–Hänni slides (`research/prior/vaintrob-hanni-nnbayes-generalization-slides.txt`, read in the parts the paper cites: slides 10–17, 29–38 and Appendices A, F, J, K), Hänni's notes in `research/prior/` (every quotation in these sections was checked against them), `research/00-brief.md`, the binding notes at the top of `paper/OUTLINE.md`, and `paper/CLAIMS.md`.

**Method.** I read every statement and proof in the nine files line by line against the final notes, re-derived each proof, checked every quotation of Hänni and of the slides against the source text, and checked each literature description against what the notes and the bib comments say was seen. Where a claim is numerical I recomputed it. Independent code is in `research/paper-review/scratch/p1-math-C/` (all deterministic or seeded, run with `python3 -I`):

| script | what it checks | result |
|---|---|---|
| `c1_pointwise_bound.py` | the combinatorial step of the pointwise bound on the semimeasure-convention error $e(x^*)$ (issue C-01), on 2000 random finite mixtures with partial, wrong and shared-randomness hypotheses | holds in every trial (min slack $-3\cdot10^{-16}$); $e/e_{\rm norm}$ reaches 3300, so a bound on $e$ is not implied by the one on $e_{\rm norm}$ |
| `c2_comp_constants.py` | the explicit constant 16 of `thm:comp:circuitbayes` (bisection for the largest fixed point); $70\ell+531$ and the constant $6.7$ of `prop:comp:occam`; $1+\sum_kH_{\binom dk}\le d+d^2\ln2$ of `rem:comp:uniformties`; the precision schedule of `thm:comp:timebounded`(b); the $\log\log L$ arithmetic of `ex:ood:easyhard`; the constant of `rem:comp:constant` | largest ratio $10.847$ at $\mathcal E\approx0.63$, $d=1$ (paper: $10.85<16$); $70\ell+531$, $6.7$ and the harmonic bound hold with slack; **the precision term is infinite for $\varepsilon_k=k^{-2}$** (C-03) |
| `c3_kernels_ladder.py` | the Walsh eigenvalues of the bias-free two-layer ReLU NNGP and NTK at $d=8$; the evenness identities; the anti-correlation identity of `rem:nn:oddparity`(c) with kernel ridge regression; the conjunction ladder for formulas ($d=3,4$) and for circuits of `def:comp:circuits` ($d=4$, stages $k=2,3$), by my own enumeration | odd eigenvalues $\le2.2\cdot10^{-18}$; identity to $1.2\cdot10^{-12}$, training sums $\ge36$; least-size consistent functions are exactly the $k$-conjunctions at every stage; ladder mistakes $6$ and $14$ for formulas ($=2^d-2$) |
| `mirror/.../e5_dsl_odd_lengths.py` | re-run of the examples track's grammar computation on a scratch copy | output byte-identical to the saved one; every number in `tab:ood:grammar` and in the online paragraph reproduced; but the code gives the tilting program a different prior mass from the one the paper describes (C-31) |

**A parallel list.** While I was writing, a second issue list for the same scope appeared in this scratch folder (`make_issues_p1_math_C.py`, ids P1C-01 to P1C-41, with scripts `c1_e5_tilt.py`, `c1b_prior_share.py`, `c2_comp_nn_checks.py`, `c3_ladder_formulas.py`, `c4_pointwise_e_check.py`), apparently from a parallel run of this review writing to the same output files. I checked each of its items against the paper, the sources and, where relevant, the code. The items I could verify and had not already listed are merged into this report, each marked with its P1C id (C-42 to C-55; C-13, C-24, C-31, C-33 and C-39 extended). Where the two lists overlap I kept my wording and severity. The second instance has since written its additional items to `p1/review-p1-math-C-supplement.md` and `p1/issues-p1-math-C-supplement.json` (20 items); all 20 are reflected in this report, so the supplement need not be merged separately. Two severities differ: its P1C-09 (process-style hedges in `related.tex`) is my minor C-28, and its P1C-12 (third-person references to the sole author) is my minor C-44, because the binding note sanctions citing Hänni's notes in the third person. That list does not contain C-01 (it takes the false sentence as given, in its P1C-04), C-03, C-06, C-17, C-19, C-20, C-29, C-38, C-40 or C-41.

## 1. Verdict

The mathematics of these sections is, with one exception, sound and faithful to the final notes. Every proof in Appendices F, G and H is correct as written, apart from a boundary slip in one proof sketch (C-03) and two degenerate cases (the empty set in `thm:comp:circuitbayes`(a), C-49; the empty string in `ex:ood:hanniexamples`(c), C-45). The quantitative claims I could test all reproduce. The exception is a sentence in `ood.tex` asserting that there is no pointwise bound on the semimeasure-convention error; this is false, and a short proof of the bound is given under C-01. The summary of Paper 2 (`steeper.tex`) misstates one quantity in a way that makes Paper 2's theorem look stronger than it is (C-02). Two further problems touch the mathematics: `rem:ood:answer`(iii) states for 'the error' an upper bound that is proved only for the normalised error and that contradicts the false sentence of C-01 (C-39); and the running-time parts of three statements in `comp.tex` have no proof or sketch (C-42). The description of the tilted grammar computation does not match the code (C-31).

The scholarly side needs more work than the mathematics. Three claims about sources are stronger than the sources: what `ex:ood:hanniexamples` "makes precise" of Hänni's remark (C-04), the slides' out-of-distribution position (C-05), and the novelty list of `rem:related:new` (C-11). One observation of the slides is presented without credit (C-06). The citation of Hänni's steeper-prior proposal renders as "Hänni and Wyeth, undated" (C-10). Hänni's own request is cited as a personal communication to the author, who is Hänni (C-43). The compiled PDF still contains the verification appendix, which the binding note forbids (C-12).

Counts: **2 fatal, 16 major, 37 minor** (55 issues). The fatal ones each need a one-sentence fix.

## 2. Out-of-distribution behaviour (`ood.tex`, Appendix F)

**Correct and faithful.** `prop:ood:hanni` (both parts; the wrapper $p\mapsto wzp$ is injective and preserves consistency because no input of $D$ lies in $Q$), `rem:ood:logterm`, `prop:ood:relative` (reading $p$ before $z$ gives the genuine conditional complexity), `prop:ood:machine` (a) and (b) with the proof in Appendix F, including the remark on $D=\emptyset$, `thm:ood:twosided` (a)–(c), including the even/odd tape split for $\MF$ in (c), `prop:ood:draftfalse` (the coding-theorem argument for (b) is right, and normalisation is handled by the constant-1 program), `thm:ood:cumulative` (with $c=0$ for $W$, which holds because $\KF$ is defined through $V$ itself), `prop:ood:budget` (a property separating $x_k$ from its predecessors separates no other $x_j$: for $j<k$ it avoids $x_j$, for $j>k$ it contains $x_k$; so Kraft applies), `prop:ood:converse` (a)–(c), `prop:ood:sandwich`, `prop:ood:labelled` with all four parts, `ex:ood:easyhard` (the arithmetic $K(\lceil\log L\rceil)\le2\log\log L$ for large $L$ is right; c2(f)), `prop:ood:intended`, and the bounds in `ex:ood:hanniexamples` (in (a) "probability at most $\frac12$ at most $K(\mathcal T)+c$ times" follows from the first sum of `thm:ood:cumulative`, each such step costing at least one bit). All quotations of Hänni in the section match his notes and draft.

**Problems.** The false sentence on pointwise bounds (C-01). The interpretation of Hänni's easy-to-hard remark (C-04). `rem:ood:lopsided` comments on two arguments of Hänni that the paper never introduces (C-07). `conj:ood:natural` is not a mathematical statement (C-08). The tilted-grammar computation is misdescribed (C-31). `rem:ood:answer`(iii) contradicts line 134 and drops hypotheses (C-39). Minor: the superlative title of `rem:ood:answer` (C-15), the draft/notes attribution (C-25), $\KP$ defined only in Appendix B (C-26), $Q_d$ (C-30), the 1345 classes (C-32), the decidedness of the test sentence and the convention statements of the lower bounds (C-33), "posterior weight of $p$" under $\MF$ (C-34), refutations of internal readings (C-35), the infinite event in the $\MF$ part of the proof of `prop:ood:hanni` (C-40), the empty string (C-45), $K(Q)$ undefined (C-46), and a computer check of a trivial disjointness inside a proof (C-47).

**The pointwise bound (C-01) in more detail.** The paper says, after `prop:ood:labelled`: "The mass undefined at $x^*$ is not lsc, so there is no pointwise bound on $e(x^*)$." The source says only that *the argument* does not bound $e(x^*)$ pointwise. In fact the bound holds, with the same exponent as for $e_{\rm norm}$. Draw a hypothesis from $\nu$'s prior, run it on all of $B$, and output the last point once $|B|-1$ points have returned the label $f$ gives them. Every hypothesis that is right on $A$ and not right at $x^*$ makes this sampler output $x^*$. Its output law is lsc uniformly in $f$, so the conditional coding theorem gives $\nu(f|_A)-\nu(f)\le2^{-K(x^*\mid f)+c}$, and $e(x^*)\le2^{L_\nu(f)-K(x^*\mid f)+c}$. The undefined mass is not lsc as a function, but a hypothesis that is right on $A$ identifies $x^*$ by waiting, and that is enough. The paper should not assert the opposite. Within the sources, the fix is to say that the argument bounds only the defined-and-wrong mass.

## 3. Computable versions (`comp.tex`, Appendix G)

**Correct and faithful.** `thm:comp:timebounded`(a) and its proof (both cases on short inputs are handled by $-\log A\ge0$), `prop:comp:round`, `cor:comp:poly` ($c_A(|x|+2)^{e_A}\le(|x|+2)^{e_A+\log c_A}$ since $|x|+2\ge2$), `prop:comp:history` (the catch-up recursion $r_k\ge\min(k,r_{k-1}+2)$ gives $r_k=k$ for $k\ge2k_0-2$), `prop:comp:samplers` ($q^{\rm samp}\ge P_A/|Y|$ on short inputs, also when the sampler is cut off by the clock), `thm:comp:circuitbayes` (the strictness argument in (a); the gadget injection, $-\log(1-P_i)\le\Gamma(S)+2$, the chord bound and the explicit constant, whose two brackets I re-derived: $10.65$ at $X=\log6$, $\ge-9.03$ and $>-4$ in the two cases; c2(a) finds the largest ratio $10.847$), `rem:comp:gap` (the converse $L\le\csize(5+2\log(d+1+\csize))$ checks), `prop:comp:occam` (constants $5.7$ and $6.7$ re-derived and checked, c2(c); $70\ell+531$, c2(b)), `rem:comp:majority`, `lem:comp:mobius`, `thm:comp:ladder` for both languages (the slot count for circuits and the per-level mistake argument are right; c3(c),(d) confirm the stage structure independently), `rem:comp:adversary`, and `rem:comp:uniformties` (c2(d)). The quotations of Hänni's polytime and circuit notes match.

**Problems.** The precision schedule $k^{-2}$ in `thm:comp:timebounded`(b) breaks at $k=1$ (C-03; inherited from the notes). The first row of the slides' table is said to be proved, but the upper half of its $\Theta$ is never stated (C-14). The symmetric-tie observation of `rem:comp:uniformties` is in the slides and is not credited to them (C-06). The running-time claims of `prop:comp:round`, `cor:comp:poly` and `prop:comp:history` are stated as parts of results but nowhere proved or sketched (C-42). Minor: "fails exponentially" (C-17), formatting (C-22), $\ell_2$ undefined and "of order" for "at least" (C-23), "$|x|^{\omega(1)}$" (C-24), wording in `def:comp:circuits` (C-37) and in the ladder's proof idea (C-38), the time bound needed for the chain predictors to lie in the class (C-41), the undefined activation rounds $k_i$ (C-48), $B=\emptyset$ (C-49), $\csize$ for formulas (C-50), the citation in `rem:comp:apples` (C-51), a dropped condition in `q:comp:samplers` (C-52), and non-verbatim quotations (C-53).

## 4. NN Bayes (`nn.tex`, Appendix H)

**Correct and faithful.** `prop:nn:functionspace`, `prop:nn:upper`, `prop:nn:typical`, `prop:nn:nolower`, `prop:nn:uniform` (the padding count $1/(N_s\cdot16(d+1+S)^2)$ is exact), `rem:nn:bridge`, `thm:nn:walsh` with its proof, `cor:nn:separation` ($|y^*-\hat g|=e+w\le2e$ with $\hat g=y^*(1-e-w)$), `rem:nn:oddparity` (a)–(c): the evenness identities, the vanishing of the odd eigenvalues, the zero GP-classification mass and the anti-correlation identity are all right, and c3(a),(b) confirm them numerically. The quotations of Hänni ("kinda like a circuit version of solomonoff function induction", "should just be true about any low complexity prior on functions — the NNs aren't doing anything here", "first main afaik-open problem", "doing sth more like a polyfit", "true for NN bayes as well") match the sources. Items (i)–(v) of `rem:nn:slides` match the slides, up to the omissions in C-20.

**Problems.** Item (vi) of `rem:nn:slides` misreports the slides' out-of-distribution position (C-05). `rem:nn:rigorous` lists an interpretation and a classification failure for sparse parities as proved (C-13). The request quoted in the first sentence of the section is cited as a personal communication to the author from himself (C-43). Minor: the Cesàro/fixed-$n$ conflation in `cor:nn:separation` (C-16), the undefined $\sigma$ (C-18), the literature paraphrases (C-19), the slides' caveats quoted too strongly and the setting of their main theorem simplified (C-20), to-do items among the open questions (C-36), the statuses (C-27), the sole author 'not having checked' his own slides (C-44), and notation (C-54).

## 5. Steeper summary, related work and the verification appendix

**`steeper.tex`.** Every number matches Paper 2 (window $(9.54\cdot10^{-7},8.06\cdot10^{-3}]$ at $\kappa=0$ and $3.66\cdot10^{-3}$ at $\kappa=30$; $0.983$, $37.7$ of $11{,}710$ bits, $0.199$; $1.6\cdot10^{-5}$, 31%, 25%; the absorption bound $(\lambda\ell_U+O(1))/(\lambda-1)$; $\min(\lambda,2)$ bits per shared coin; $k+(k+\delta^*)/(\lambda-1)$; product sophistication $d\pm O(\log d)$). The absorption objection is called "the absorption objection" and credited as a standard point that Hänni's note already makes, as the binding note requires. Problems: $t_n$ is described as doubly logarithmic (C-02); "all of them are proved there" covers $\kappa=0$ illustrations (C-09); the citation renders as "Hänni and Wyeth, undated" (C-10); a misquotation (C-21); dropped hypotheses and an overstatement below the window (C-55); and the citation of Hänni's request as a personal communication (C-43).

**`related.tex`.** The descriptions of Solomonoff (2008), Özkural, Hutter, Lattimore–Hutter–Gavane, Wood–Sunehag–Hutter, Lattimore–Hutter, Poland–Hutter, Leike–Hutter and Ryabko agree with what the notes say was seen (abstracts and secondary sources), and the hedges are present. Problems: the novelty remark (C-11), process-style hedges (C-28), and the description of Bārzdiņš–Freivalds (C-29).

**`app-verification.tex`.** The appendix is an internal record and violates the binding note in the compiled PDF; `main.tex` says that the conversion drops it (C-12). Its account of my sections agrees with the sources, except that its line 125 records the change of quotation behind C-04.

## 6. Notes for the editor

* Four of the major issues (C-03, C-31, and the "proved" in C-14; the precision schedule and the tilted-grammar description are wrong in the notes too) are inherited from the final notes, as is the empty-string slip C-45; the paper copied them faithfully. They should still be fixed, since they are visible to a reader.
* C-01 can be fixed without new mathematics (delete the claim). The stronger statement is true by the argument above and would be a natural addition to `prop:ood:labelled`, but it is not in the sources, so it needs to be checked like the other results before it goes in.

## 7. Numbered issue list

### 1. C-01 [fatal] paper/sections/ood.tex, line 134 (paragraph after prop:ood:labelled)

* **Problem.** The sentence "The mass undefined at $x^*$ is not lsc, so there is no pointwise bound on $e(x^*)$" is false as a mathematical statement, and stronger than the source. A pointwise bound of exactly the same form as for $e_{\rm norm}$ holds for the semimeasure-convention error: $e(x^*)\le2^{L_\nu(f)-K(x^*\mid f)+c}$ for $\nu\in\{W,\MF\}$.
* **Evidence.** Proof. Let $M'$ be the probabilistic machine that, given the labelled sample $f$ (a finite list), draws a hypothesis from $\nu$'s prior (fair coins fed to $V$ until it halts on a program $p$, for $W$; the tape $\omega$ of $T_U$, read lazily, for $\MF$), runs it on all points of $B$ in parallel, and as soon as $|B|-1$ points have halted with the label that $f$ gives them, outputs the remaining point. Its output law $P_f$ is a discrete semimeasure, lsc uniformly in $f$, so $P_f(x)\le2^{-K(x\mid f)+c}$ (conditional coding theorem, the same tool as in the proof of prop:ood:labelled). Every hypothesis that is correct on $A=B\setminus\{x^*\}$ and not correct at $x^*$ (wrong OR undefined there) makes $M'$ output $x^*$, so $P_f(x^*)\ge\nu(f|_A)-\nu(f)=e(x^*)\,\nu(f|_A)$. With $\nu(f|_A)\ge\nu(f)=2^{-L_\nu(f)}$ this gives the bound. The lack of lower semicomputability of the undefined mass is circumvented because a single hypothesis that is correct on $A$ identifies $x^*$ by waiting. The source (context notes-final \S2.4, 'Reading' after Prop 2.16) only says 'the argument does not bound the semimeasure-convention $e(x^*)$ pointwise'; the paper turned this into a non-existence claim. Independent check: scratch/p1-math-C/c1_pointwise_bound.py verifies the combinatorial step ($P_f(x)\ge\nu(f|_{B\setminus x})-\nu(f)$ for all $x$, $\sum_xP_f(x)\le\nu(\emptyset)$) on 2000 random finite mixtures with partial, wrong and shared-randomness hypotheses (min slack $-3\cdot10^{-16}$), and shows $e/e_{\rm norm}$ up to 3300 there, so the bound on $e$ is not a corollary of the one on $e_{\rm norm}$.
* **Fix.** Delete the claim. Minimal fix within the sources: 'The argument above bounds only the mass that is defined and wrong; \cref{cor:learn:perstep} bounds $e(x^*)$ in distribution.' If the authors want the stronger statement, add it as part of prop:ood:labelled with the waiting-sampler proof above, after it has been checked like the other results.

### 2. C-02 [fatal] paper/sections/steeper.tex, line 14 (paragraph 'The model--randomness split')

* **Problem.** 'with $t_n$ doubly logarithmic in the input length' is wrong and overstates Paper 2's theorem: $t_n$ is logarithmic in the input length; it is $2\log(t_n+1)$, the exponent in the bound, that is doubly logarithmic. As printed, the lower end of the odds interval would be triply logarithmic.
* **Evidence.** Paper 2, sections/split.tex line 39: $t_n:=\lceil\log(2d_n+2+2\log(i_n+1))\rceil$ with $d_n$ the largest input length; Paper 2 intro.tex line 19: 'with $2\log(t_n+1)$ doubly logarithmic in the input length'; steeper notes-final \S0 item 3: '$2\log(t_N+1)$ is doubly logarithmic in $n$ and triply in $N$'.
* **Fix.** Write 'with $2\log(t_n+1)$ doubly logarithmic in the input length (and triply logarithmic in the sample size)'.

### 3. C-03 [major] paper/sections/comp.tex; paper/sections/app-comp.tex, thm:comp:timebounded(b), comp.tex line 24; precision paragraph, app-comp.tex line 11

* **Problem.** Wrong precision schedule. With relative precision $\varepsilon_k=k^{-2}$ the first round has $\varepsilon_1=1$, so a stored weight may be rounded to $0$ (and the machine's weight is then lost for ever); the error term $\sum_j\log\frac{1+\varepsilon_j}{1-\varepsilon_j}$ used in the sketch is infinite, not $O(1)$. The statement 'weights stored with relative precision $k^{-2}$ change the cumulative loss by $O(1)$' is false as written.
* **Evidence.** app-comp.tex line 11 uses $\hat V_k\ge w_i|Y|^k\prod_j q_i(1-\varepsilon_j)$, which is $0$ when $\varepsilon_1=1$. scratch/p1-math-C/c2_comp_constants.out.txt (e): the sum is infinite for $\varepsilon_j=j^{-2}$ and $1.88$ bits for $\varepsilon_j=(j+1)^{-2}$. The same slip is in the source (context notes-final Thm 3.1(b)).
* **Fix.** Use $\varepsilon_k=(k+1)^{-2}$ (or any summable sequence with $\varepsilon_k\le\frac12$) in the theorem and in the appendix; the bound then holds with additive term $\sum_j\log\frac{1+\varepsilon_j}{1-\varepsilon_j}\le1.9$ bits.

### 4. C-04 [major] paper/sections/ood.tex, ex:ood:hanniexamples(a), line 169

* **Problem.** 'This makes precise Hänni's weakly held hypothesis that for Solomonoff induction ``ood generalization is a thing, but easy-to-hard generalization is not''' claims more than is shown. The example proves only that a hard test sentence keeps a (tiny) failure floor $2^{-K(\mathcal T)-2\log\log L-c}$; nothing in the section makes the first half ('ood generalization is a thing') precise, the floor is far too small to say easy-to-hard generalisation 'is not a thing', and Hänni's hypothesis concerns sequence SI and was retracted in the next sentence of his note.
* **Evidence.** Source of the quote: prior/hanni-does-solomonoff-generalize-well-out-of-distribution.md line 18 continues 'ahh idk if that's the right thing to say. maybe it's more like: true ood generalization is not a thing'. The context notes (Ex 2.15) claim only to make precise the remark that 'easy-to-hard generalization is not a thing'. The longer quote was introduced at the planning stage (app-verification.tex line 125). tab:ood:hanni itself says the floor 'is tiny for a natural theory'.
* **Fix.** Write: 'This gives one precise sense to Hänni's tentative remark that for Solomonoff induction ``easy-to-hard generalization is not'' a thing: no number of easy sentences removes a (small) floor on the wrong-label probability of a hard one.' Drop 'ood generalization is a thing' or say that the section does not address it.

### 5. C-05 [major] paper/sections/nn.tex, rem:nn:slides, item (vi), line 81

* **Problem.** The slides' out-of-distribution position is misreported. The paper writes 'out of distribution the guarantee ``is simply false'' (\cref{thm:comp:ladder})', tying the quote to the ladder. In the slides 'simply false' refers to the in-distribution PAC guarantee off the support ('nothing stops the learner from being wrong on inputs the training distribution never reaches'); the ladder refutes the Occam (argmax) online-mistake claim for circuits; and the slides say that an OOD online mistake bound 'might still hold' for NN Bayes, with a heuristic argument they 'suspect is morally right', and that their $\sigma\to0$ learner (symmetric ties, majority vote) is on 'the good side' of the selection-rule table. The paper's rendering is more negative than the source.
* **Evidence.** Slides text, research/prior/vaintrob-hanni-nnbayes-generalization-slides.txt lines 858-866 (slide 37: 'The in-distribution guarantee is simply false out of distribution --- there are easy counterexamples. An online mistake bound might still hold ... but the analogous claim for circuits is strictly false. (Appendix K.)'), lines 2723-2726 (slide 104), lines 2834-2841 (slide 108). Context notes \S4.5 item 11 lists 'an OOD mistake bound for NN Bayes' among the slides' open problems.
* **Fix.** Replace (vi) by: 'out of distribution the in-distribution guarantee ``is simply false''; an online mistake bound might still hold for NN Bayes (they give a heuristic argument and list it as open), while the analogous claim for Occam learning over circuits fails (their Appendix K; \cref{thm:comp:ladder}).'

### 6. C-06 [major] paper/sections/comp.tex, rem:comp:uniformties, line 133

* **Problem.** Missing credit. The observation that symmetric (uniform) tie-breaking with majority prediction makes only $O(d)$ mistakes on the ladder is stated in the Vaintrob--Hänni slides; the remark presents it without citation, as following 'the direction of the companion paper on steeper priors'.
* **Evidence.** Slide 108 (slides text lines 2834-2841): 'Our $\sigma\to0$ learner is not the deterministic argmax: ties spread symmetrically ... and we predict by majority --- the good side of this table. On the ladder the surviving conjunctions get equal mass, so the majority errs $O(d)$ times.' Context notes Rem 3.12-3.13: 'Remark 3.13 is the formula-prior version of that remark'; 'This is the ladder instance of two rows of the slides' table'.
* **Fix.** Add: 'The slides make this observation for their strong-prior learner (Appendix K); we give the formula-prior version with explicit constants.'

### 7. C-07 [major] paper/sections/ood.tex, rem:ood:lopsided, line 97

* **Problem.** Dangling references a reader cannot follow: 'A human who generalises after seeing the data is history-aware' and 'Hänni's ``fake ood generalization''' refer to arguments of Hänni (the 'human inductor' and 'fake OOD generalisation') that are never introduced anywhere in the paper.
* **Evidence.** grep over paper/sections: 'fake' and 'human' occur only here. Source: prior/hanni-does-solomonoff-generalize-well-out-of-distribution.md lines 5-9 and 18; context notes-final Rem 2.8a introduces both with quotations.
* **Fix.** Either quote the two passages with \citep{hanni2026notes} ('a human with the right prompt thinking for a long time could generalize well, and that's computable'; '``fake ood generalization'', which is where you've already seen many ``ood generalizations'' of the same kind') before commenting on them, or delete the last sentence of the remark.

### 8. C-08 [major] paper/sections/ood.tex, conj:ood:natural, lines 177-182

* **Problem.** A conjecture environment holds a statement that the paper itself says 'is not a precise statement' and that is false for some universal machines. 'Natural universal machines', 'natural training sets' and 'close to 1' are undefined, so this is not a conjecture in the mathematical sense; a reader will notice.
* **Evidence.** ood.tex line 182: 'This is not a precise statement, and by \cref{prop:ood:machine} it fails for some universal machines'. The binding note requires conjectures in standard form; examples notes \S7 item 4 lists this as an open problem ('I see no route'), not as a conjecture with a statement.
* **Fix.** Move it out of the conjecture environment: either an 'Open problem' paragraph ('Find a fixed reference machine and a training distribution for which the intended answers of \cref{ex:ood:hanniexamples} provably get posterior probability close to 1') or a sentence in the discussion stating the informal expectation. Update discussion.tex line 22 and app-verification.tex line 140, which cite conj:ood:natural.

### 9. C-09 [major] paper/sections/steeper.tex, line 6 ('all of them are proved there'), lines 10-12

* **Problem.** 'This section summarises the results; all of them are proved there' is stronger than the source. Several numbers quoted in the section are illustrations obtained by setting the unknown machine constant to 0 (0.983, 37.7 bits, 0.199, the window end 8.06e-3, '31%'), and others are computed (the window ends, 1.6e-5); Paper 2's own notes say such numbers 'are not proved'.
* **Evidence.** Steeper notes-final, status tags: 'Illustration (kappa = 0): a number obtained by setting the unknown machine constant kappa to 0. Such numbers are not proved; robust versions are given where they exist.' The section flags some of them in passing ('machine constant set to 0, an illustration'), which contradicts the blanket sentence.
* **Fix.** Write: 'This section summarises the results, which are proved there; numbers given 'with the machine constant set to 0' are illustrations, not proved values, and the window ends are computed from the proved formulas.'

### 10. C-10 [major] paper/sections/steeper.tex; paper/bib/core.bib, steeper.tex line 6; core.bib lines 26-33 (hanni2026lesswrong)

* **Problem.** The citation of Hänni's proposal renders as '(Hänni, 2026b; Hänni and Wyeth, undated)'. Listing Cole Wyeth as a co-author of a comment thread attaches his name to Hänni's proposal, 'undated' is not a bibliographic year, and the citation is unnecessary: both quoted phrases are in Hänni's own note.
* **Evidence.** main.bbl line 178: '\bibitem[H{\"a}nni and Wyeth(undated)]{hanni2026lesswrong}'. Both quotes ('the length of the program plus the negative log likelihood ... higher coefficient on the length of the program'; 'each input gets its own private randomness') are in prior/hanni-grokking-a-notion.md lines 41 and 61, i.e. in \citep{hanni2026notes}. Binding note: the absorption objection must not be attributed to Wyeth; a neutral footnote may record the thread.
* **Fix.** Cite only \citep{hanni2026notes} here. If the thread is cited anywhere, make the entry Hänni's single-authored comment ('K. Hänni, comment in the LessWrong thread ``Jonas Hallgren's Shortform''', with the year of the comment or an access date), and use it at most in the one neutral footnote the binding note allows.

### 11. C-11 [major] paper/sections/related.tex, rem:related:new, line 18

* **Problem.** (i) The remark ends with an instruction to the authors, 'Each of these should be checked against ... before any claim of novelty', and opens with a description of the search process; in an arXiv paper this reads as unfinished scholarship. (ii) The 'not found' list is broader than the source: it includes 'the OOD results of \cref{sec:ood}' wholesale, although \cref{thm:ood:cumulative} is the error form of the classical mistake bound (\cref{cor:learn:mistakes}, status 'known'), \cref{prop:ood:machine} is the analogue of Leike--Hutter (listed as existing two lines earlier), and \cref{prop:ood:intended} is immediate; and it lists the time-bounded mixtures without the source's qualifier 'in the function setting; the sequence analogues are Hänni's polytime note and the speed-prior literature' (comp.tex itself calls prop:comp:history 'the function-setting form of Hänni's amortised warm-up').
* **Evidence.** Context notes-final \S6, 'Apparently new': names the specific OOD items (Prop 2.1, Thm 2.5, Prop 2.6, Prop 2.8, Prop 2.13, Prop 2.14, Prop 2.16, Cor 2.17, Ex 2.15/2.15a) and qualifies the time-bounded items as above.
* **Fix.** Rewrite as 'To our knowledge (our search covered abstracts and secondary descriptions), the following have not appeared before: ...', list the OOD items by label (prop:ood:hanni in this form, thm:ood:twosided, prop:ood:budget, prop:ood:converse, prop:ood:sandwich, prop:ood:labelled, ex:ood:easyhard), add 'in the function setting' to the time-bounded items with a pointer to Hänni's sequence construction and the speed prior, and delete the last sentence.

### 12. C-12 [major] paper/sections/app-verification.tex; paper/main.tex, whole appendix (Appendix I); line 136; main.tex last \input

* **Problem.** The compiled PDF still contains the verification appendix ('How the claims were checked'), which the binding note forbids: it is built on process vocabulary ('track', 'referee', 'CLAIMS.md', conflict codes C1-C25, 'Co Ex 2.15', script and seed tables), and line 136 prints 'a promised Wyeth--Hutter reference not cited', a visible mention of Wyeth outside the one neutral footnote the binding note allows.
* **Evidence.** main.tex: '\input{sections/app-verification}' with the comment that 'the arXiv conversion pass drops this \input'. OUTLINE.md binding note: 'No verification appendix.' Other sections still cite H1-H10 via tab:intro:verdicts.
* **Fix.** Drop the \input in the conversion pass as planned; move the short account to the acknowledgements and the 'Code and data' statement; make sure no \cref to app:verification survives and that nothing from line 136 migrates.

### 13. C-13 [major] paper/sections/nn.tex, rem:nn:rigorous, line 86

* **Problem.** Under 'Proved' the remark lists two items that are not proved as stated. (i) '... with no general lower bound, so the comparison object is circuit SFI': the inference to the right comparison object is an interpretation. (ii) 'the Gaussian-process limits fail on sparse and odd parities where SFI succeeds': for sparse parities what is proved is a squared-error statement about the real-valued kernel/GP-mean predictor, averaged over random $k$-sparse targets; a 0--1 (classification) failure is proved only for bias-free two-layer ReLU kernels and odd $|S|\ge3$. The same list says Occam 'fails exponentially', which in description length is $2^{\Omega(\ell/\log\ell)}$ (C-17).
* **Evidence.** prop:nn:nolower proves only that no general lower bound holds (context notes \S4.6(iii) draws the comparison-object conclusion in prose). nn.tex line 69: 'The separation is in squared error of the real-valued predictor; we do not claim a 0--1 version in general.' thm:nn:walsh(b), cor:nn:separation, rem:nn:oddparity(b),(c). (Point (ii) was also found by the parallel reviewer, P1C-03; verified.)
* **Fix.** Rewrite: 'Proved: ... there is no general lower bound (\cref{prop:nn:nolower}), which suggests that the natural comparison object is circuit SFI; in the Gaussian-process limits, kernel regression and GP means need $\binom dk$ samples in squared error on random $k$-sparse parities where SFI needs $O(k\log d)$, and for bias-free two-layer ReLU kernels odd parities of degree at least 3 are never learned, have GP-classification prior mass 0 and are anti-correlated with the predictor on unseen points; ... Occam selection makes $2^{\Omega(\ell/\log\ell)}$ mistakes on some ordering.'

### 14. C-14 [major] paper/sections/comp.tex, thm:comp:ladder (line 121) and rem:comp:selection (line 128)

* **Problem.** rem:comp:selection says the slides' first row, deterministic argmax with $2^{\Theta(C/\log C)}$ worst-case mistakes, is 'proved here', but the paper proves only the lower bound and states as upper bound only 'the trivial upper bound is $2^{\ell+1}$', while q:comp:open asks whether $2^{\Omega(\ell)}$ is possible. The $\Theta$ holds for the conjunction target because there are only $2^d=2^{O(\ell/\log\ell)}$ inputs, but the paper never says so, so the three statements look inconsistent.
* **Evidence.** Context notes-final Thm 3.11: 'For $f=\mathrm{AND}_{[d]}$ the lower bound is tight up to the constant in the exponent, since there are only $2^d$ inputs'; \S7 item 5. This sentence is missing from comp.tex and app-comp.tex.
* **Fix.** Add to thm:comp:ladder: 'For this target the bound is tight up to the constant in the exponent, since there are only $2^d$ inputs.' In rem:comp:selection write 'The first row (for the conjunction target) and the last row are proved here'.

### 15. C-31 [major] paper/sections/app-ood.tex; paper/sections/ood.tex, app-ood.tex line 39 and tab:ood:grammar ('tilted' rows), tab:ood:hanni line 69; ood.tex ex:ood:hanniexamples(c), line 171

* **Problem.** The 'tilted' rows of the grammar computation are described wrongly. app-ood.tex says the extra program 'if $|x|$ even then $0$ else $|x|$' gets 'prior mass equal to (or ten times) that of all plain programs'. The code gives it the mass of the training-consistent plain programs (the single class $|x|$), which is 7.4 times smaller; with the printed description the intended answer would get $0.148$ and $0.017$, not $0.557$ and $0.114$. The main text then reports 'about $0.11$ when one extra program tilts the grammar' without saying that this program carries ten times the intended program's prior mass (44% of all prior mass, about 2600 times its natural grammar weight); with the factor ten the prior masses sum to $1.06$, so the 'prior' is not a sub-probability (harmless for a normalised predictive, but unstated). Also in (c), 'SFI makes at most $c$ online errors' leaves 'online error' undefined.
* **Evidence.** research/tracks/examples/checks/e5_dsl_odd_lengths.py line 88: extra_programs=[(bad, tilt * 0.5 * m_plain_ok)], with m_plain_ok the mass of the plain classes consistent with training (0.093932, class 'len' only; all plain classes 0.695313). The e5 docstring and examples notes \S5.3 carry the same wrong description. My rerun in scratch/p1-math-C/mirror/ reproduces 0.557/0.114 byte for byte; scratch/p1-math-C/c1_e5_tilt.out.txt (written by the parallel reviewer; I checked it against the code) gives 0.148/0.017 under the printed description and the 44% share. (Found first by the parallel reviewer, P1C-01 and P1C-25; verified.)
* **Fix.** app-ood.tex: 'The tilted rows add one program ... with prior mass equal to (or ten times) that of the intended program $|x|$, the only plain program consistent with the training data; with the factor ten it carries 44% of the prior mass (masses renormalised).' ood.tex line 171: 'and about $0.11$ when a single extra program with ten times the prior mass of the intended one is added'; tab:ood:hanni: '$0.11$ with a tilted prior'. Define the online errors as the steps where the correct label gets probability at most $\frac12$ (thm:ood:cumulative).

### 16. C-39 [major] paper/sections/ood.tex, rem:ood:answer (iii), (iv), line 145

* **Problem.** (iii) says that for simple $f$ 'the error at a test point lies between $2^{-\sep(x^*;A)-O(1)}$ and $2^{L_\nu(f)-\sep(x^*;A\mid f)+O(1)}$'. In this section 'the error' $e(x^*)$ is the semimeasure-convention error, but the upper bound is proved only for $e_{\rm norm}$ (and $e^{\rm wr}$), and line 134 of the same section asserts that there is no pointwise bound on $e(x^*)$: the two sentences contradict each other. (By C-01 the bound on $e$ is in fact true, but it is not proved in the paper.) The lower end needs a wrong label of complexity $O(1)$ (the proved form carries $-K(y)$). (iv) drops the hypotheses of the lower bound: binary computable $f$, uniform inputs on $\{0,1\}^d$ with $d\ge\lceil\log n\rceil+1$.
* **Evidence.** prop:ood:labelled bounds $e^{\rm wr}\le e_{\rm norm}\le2^{L_\nu(f)-K(x^*\mid f)+c}$ and has lower bound $2^{-\sep(x^*;A)-K(y)-c}$; ood.tex line 134; prop:learn:typical (learn.tex line 138). (The contradiction with line 134 was also found by the parallel reviewer, P1C-04; verified.)
* **Fix.** (iii): 'For simple $f$ and binary labels, $e^{\rm wr}(x^*)\ge2^{-\sep(x^*;A)-O(1)}$ and $e_{\rm norm}(x^*)\le2^{L_\nu(f)-\sep(x^*;A\mid f)+O(1)}$.' (iv): add 'for computable binary $f$ and uniform inputs on $\{0,1\}^d$ with $d\ge\lceil\log n\rceil+1$'.

### 17. C-42 [major] paper/sections/comp.tex; paper/sections/app-comp.tex, prop:comp:round (line 36), cor:comp:poly (line 47), prop:comp:history (line 63); thm:comp:timebounded(b) (line 24)

* **Problem.** Running-time claims that are only sketched, or not argued at all, sit inside the statements of two propositions and a corollary. prop:comp:round ('Round $k$ costs ... simulations ... plus as many arithmetic operations'), cor:comp:poly ('round $k$ costs ...') and prop:comp:history ('round $k$ costs $O(\#\{i:k_i\le k\}\,g(k)t(\tilde n_k))$ steps plus the replay memory') have proofs that cover only the regret; no sketch of the running time is given anywhere (Appendix G sketches only thm:comp:timebounded(b)). Once the \status tags are removed, nothing marks these parts as unproved, which the binding note forbids.
* **Evidence.** comp.tex lines 39-41 (proof of prop:comp:round: regret only) and 50-52 (proof of cor:comp:poly: regret only); app-comp.tex lines 18-20 (proof of prop:comp:history, 'regret'); statuses 'running time proof sketch'. Binding note: 'Proof sketches are labelled ``Proof sketch'', and the statement must not be presented as fully proved.' (Found by the parallel reviewer, P1C-06; verified.)
* **Fix.** Move the running-time sentences out of the statements into remarks headed 'Running time (proof sketch)', each with two sentences of argument (the incremental update of thm:comp:timebounded(b) applies to the round-indexed mixtures; for prop:comp:history add the replay cost), and state the unwritten machine-model caveat there.

### 18. C-43 [major] paper/bib/core.bib; paper/sections/nn.tex; paper/sections/steeper.tex, hanni2026request (core.bib lines 19-25); cited at nn.tex line 8 and steeper.tex line 14

* **Problem.** With Kaarel Hänni as sole author, the bibliography lists 'Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in .../research/00-brief.md'. A personal communication from the author to himself is not a citable source, and a reader cannot make sense of it. In these sections it supports the quotations 'kinda like a circuit version of solomonoff function induction' (nn.tex) and 'a preference for a simple sampler over a model where the sampled bits are filled in ... both get similar posterior' (steeper.tex).
* **Evidence.** core.bib lines 19-25; main.bbl. OUTLINE binding note (sole author; ideas credited through his notes or by stating the authorship arrangement). (Found by the parallel reviewer, P1C-11; verified.)
* **Fix.** Drop the citation and present the two remarks as the author's own ('The author has described NN Bayes as ...'; 'The author also asked for ...'), or cite a note in the public notes repository if the text is there.

### 19. C-15 [minor] paper/sections/ood.tex, rem:ood:answer, title, line 143

* **Problem.** The title 'the strongest true positive statements' asserts a maximality that nothing in the paper proves; the source uses the phrase only as a quoted question.
* **Evidence.** Context notes-final \S2.5 heading: 'Answer to ``the strongest true positive statement''' (in quotation marks).
* **Fix.** Retitle 'summary of the positive statements'.

### 20. C-16 [minor] paper/sections/nn.tex, cor:nn:separation, line 66

* **Problem.** 'while SFI needs $O(k\log d/\varepsilon)$ in this averaged sense' compares a Cesàro average over steps $1..n$ (SFI) with an error at fixed $n$ averaged over targets (kernels); 'this averaged sense' conflates the two averages.
* **Evidence.** The SFI bound in the statement is 'averaged over the first $n$ steps'; the kernel bound is thm:nn:walsh(b) at sample size $n$. Context notes Cor 4.7 says 'in the Cesàro sense, or per step by Cor 2.17(a)'.
* **Fix.** Write 'SFI needs $O(k\log d/\varepsilon)$ samples for Cesàro-averaged squared error $\varepsilon$, and $O((k\log d+\log(1/\varepsilon))/\varepsilon)$ for the error at a single step (\cref{cor:learn:perstep}(a))'.

### 21. C-17 [minor] paper/sections/comp.tex; paper/sections/nn.tex, comp.tex line 10; nn.tex line 86

* **Problem.** 'Occam ... fails exponentially out of distribution': the bound is $2^{\Omega(\ell/\log\ell)}$ in the description length, i.e. exponential in $d$ but not in $\ell$, and q:comp:open asks whether $2^{\Omega(\ell)}$ is possible.
* **Evidence.** thm:comp:ladder; q:comp:open.
* **Fix.** Write 'makes $2^{\Omega(\ell/\log\ell)}$ mistakes (exponentially many in the input dimension)'.

### 22. C-18 [minor] paper/sections/nn.tex, rem:nn:rigorous line 86; q:nn:bridges line 94

* **Problem.** 'at fixed $\sigma$' uses a symbol never defined in the paper (the slides' prior scale).
* **Evidence.** grep: $\sigma$ occurs in nn.tex only in these two places; rem:nn:slides speaks of 'the strong-prior limit' without naming $\sigma$.
* **Fix.** Write 'at a fixed (not vanishing) prior scale' or define $\sigma$ in rem:nn:slides (ii).

### 23. C-19 [minor] paper/sections/nn.tex, rem:nn:oddparity(a) line 73; rem:nn:literature line 91

* **Problem.** Two literature paraphrases are slightly stronger than the abstracts: Basri et al. state that a network without bias cannot represent or learn 'simple, low frequency functions with odd frequencies' (the paper: 'cannot learn odd frequencies'); Mingard et al. (2025) attribute generalisation to a simplicity bias 'together with the structure of the data' (the paper drops this).
* **Evidence.** Context notes-final Rem 4.8(a) and \S4.7 (snippet contents); bib/nn.bib comments.
* **Fix.** Use the abstracts' wording: 'cannot learn low-frequency functions with odd frequencies (on the sphere)'; 'attribute much of generalisation to a prior bias towards simple functions together with the structure of the data'.

### 24. C-20 [minor] paper/sections/nn.tex, rem:nn:slides, line 81

* **Problem.** The slides' caveats are quoted more strongly than written: 'their appendices ``have largely been generated by Claude'' and have not been ``meticulously reviewed'''. The slides say 'Many of these appendices have largely been generated by Claude' and 'I haven't meticulously reviewed many appendix slides yet'. Item (ii) also omits two caveats of the main theorem's setting: conditioning on outputs with margin $\frac12$, and 'We don't actually consider any sort of limiting learner' ($\sigma$ small enough for each width, not a limit).
* **Evidence.** Slides text lines 888-890 and 280-296 (slides 15, 38).
* **Fix.** Quote exactly ('many of these appendices ... many appendix slides'); in (ii) write 'for each width, with the prior scale small enough and outputs conditioned with margin $\frac12$'.

### 25. C-21 [minor] paper/sections/steeper.tex, line 14, last sentence

* **Problem.** Misquotation: Hänni wrote '1 bit paying for 1 bit', and about the sequence case, not 'with shared randomness'.
* **Evidence.** prior/hanni-grokking-a-notion.md line 8: 'this doesn't show up in the seq case because there it's pretty much just 1 bit paying for 1 bit'.
* **Fix.** Write 'where, as in sequence prediction, ``1 bit paying for 1 bit'' holds' or paraphrase without quotation marks.

### 26. C-22 [minor] paper/sections/comp.tex, rem:comp:majority, line 111; line 117

* **Problem.** Formatting: the remark ends with a colon ('For Occam the assumption can fail at every step:') followed by a subsection heading, so the sentence dangles; line 117 prints '(Appendix K) (Vaintrob and Hänni, 2026b)' with double parentheses.
* **Evidence.** PDF p. 42.
* **Fix.** End the remark with 'For Occam the assumption can fail at every step (\cref{thm:comp:ladder}).'; write 'from Appendix K of the slides of \citet{vaintrobhanni2026nnbayes}'.

### 27. C-23 [minor] paper/sections/app-comp.tex, rem:comp:constant, line 15

* **Problem.** 'his regret, $\max(\ell_1,\ell_2)$ bits' uses $\ell_2$ without defining it (in Hänni's note the round after which the comparator runs within the clock); and the constant is 'of order $2^{2^{2^i}}$' where it is only at least that ($n_A\ge n_i$, and $n_A$ is much larger when $c_A$ is large).
* **Evidence.** prior/hanni-polytime-solomonoff.md, proof of the theorem; context notes-final Rem 3.1a ('is at least $2^{2^{2^i}}$'); scratch/p1-math-C/c2_comp_constants.out.txt (g).
* **Fix.** Define $\ell_2$ ('the round after which $P$ runs within the clock') and write 'at least $2^{2^{2^i}}$'.

### 28. C-24 [minor] paper/sections/comp.tex, cor:comp:poly and the sentence after it, lines 47-54

* **Problem.** 'constant regret against all polynomial-time predictors in time $|x|^{\omega(1)}$ per round' misdescribes the cost: the exponent $g(k)$ grows with the round index, so for a fixed input length the per-round cost grows without bound in $k$; it is not a function of $|x|$ alone. The source's length-clocked variant (clock $(|x|+2)^{g(|x|)}$, distinct inputs), which does give $|x|^{\omega(1)}$, is omitted.
* **Evidence.** cor:comp:poly: round $k$ costs simulations of $(|x_k|+2)^{g(k)}$ steps. Context notes Cor 3.2b, last sentences. (Also found by the parallel reviewer, P1C-26.)
* **Fix.** Write 'in time $(|x_k|+2)^{g(k)}$ per round, for an arbitrarily slowly growing $g$; with the clock $(|x|+2)^{g(|x|)}$ the same holds on distinct inputs in time $|x|^{\omega(1)}$ per round, the function-setting analogue of Hänni's $n^{\omega(1)}$'.

### 29. C-25 [minor] paper/sections/ood.tex, lines 7 and 53

* **Problem.** 'His draft adds a two-sided version, asks for a converse, and lists examples': the converse question and the 'plausibly' examples are in Hänni's notes, not in the PDF draft; and 'the draft' is never identified for the reader (all is cited as \citep{hanni2026notes}).
* **Evidence.** prior/hanni-sfi-notes.md line 34 (converse); prior/hanni-some-examples-where-function-solomonoff-generalizes-well-ood.md (examples); prior/hanni-sfi-draft-2025-09.txt lines 197-203 (two-sided result only).
* **Fix.** Write 'A draft of his (September 2025, in \citep{hanni2026notes}) adds a two-sided version; his notes ask for a converse and list examples ...'.

### 30. C-26 [minor] paper/sections/ood.tex, thm:ood:twosided(c), line 60

* **Problem.** The main-text theorem uses $\KP(z\mid x)$, which is defined only in an appendix remark (\cref{rem:versions:Wdelim}, Appendix B).
* **Evidence.** grep: \KP occurs in the main text only in ood.tex line 60; its definition is in app-versions.tex line 8.
* **Fix.** Define it in one clause: '$\KP(z\mid x)$, the length of a shortest $h\in\dom V$ with $\varphi_{V(h)}(x)=z$ (\cref{rem:versions:Wdelim})'.

### 31. C-27 [minor] paper/sections/ood.tex, comp.tex, nn.tex, related.tex, \status tags

* **Problem.** Several \status values are outside the agreed set and contain process words that the conversion pass may carry into the text: 'proved (corrected)' (prop:ood:relative, thm:comp:timebounded, prop:comp:samplers), 'refuted as stated; remark', 'proved; analogue known', 'proved; disjointness computed (context c7)', 'proved (trivial)', 'proved (given the coding theorem)', 'warm-up arithmetic re-checked (context c8)'. rem:nn:oddparity has the single status 'proved; computed; known' although only (a) is known and (b), (c) are new (OUTLINE rule 1 asks for part labels).
* **Evidence.** OUTLINE.md rule 1 and binding note ('keep them accurate: the conversion reads them'); context notes Rem 4.8 ('(b) ... new as far as I know', '(c) ... new as far as I know').
* **Fix.** Normalise to the agreed values, e.g. rem:nn:oddparity: '(a) known; proved; (b), (c) proved; computed'; drop '(corrected)', '(trivial)' and the track names.

### 32. C-28 [minor] paper/sections/related.tex, lines 6 and 12

* **Problem.** '(we have seen only the abstract)' and 'Vovk's earlier universal forecasting algorithms \citep{vovk1992universal} we have not examined' are not standard in a paper; citing a work while saying it was not examined invites the question why it is cited.
* **Evidence.** bib/related.bib: vovk1992universal 'content not seen'. The binding note asks for hedged content claims, not for process statements.
* **Fix.** Use standard hedges ('as described in its abstract', 'according to secondary sources'); drop the Vovk 1992 citation or describe it by its abstract.

### 33. C-29 [minor] paper/sections/related.tex, line 12

* **Problem.** 'Inductive inference of recursive functions (Gold; Barzdin--Freivalds; Case--Smith) is the deterministic, identification-in-the-limit ancestor': Barzdin and Freivalds study prediction with bounded numbers of errors (the paper cites them for the mistake bound, cor:learn:mistakes), not identification in the limit.
* **Evidence.** learn.tex cor:learn:mistakes status 'known (Littlestone 1988; Barzdin--Freivalds 1972, content unverified)'; context notes \S6 item 11 ('deterministic-identification ancestors').
* **Fix.** Write 'the deterministic ancestor: identification in the limit and prediction of recursive functions'.

### 34. C-30 [minor] paper/sections/ood.tex, prop:ood:draftfalse(a), line 67

* **Problem.** '$Q_d$' and '$K(Q_d)\to\infty$' use $d$ as a sequence index, while $d$ is the input length elsewhere in the paper and in part (b) of the same proposition.
* **Evidence.** NOTATION.md: $d$ = input length. Source uses $Q_n$ as a sequence index.
* **Fix.** Write $Q_m$ ($m\to\infty$) or 'a sequence of decidable $Q$ with $K(Q)\to\infty$'.

### 35. C-32 [minor] paper/sections/app-ood.tex, grammar paragraph, line 39

* **Problem.** 'Programs with the same values on all strings of length 1 to 8 are merged into 1345 classes': 1345 is the number of plain-expression value classes; if-programs are combinations of a condition and two classes.
* **Evidence.** e5 output: 'expression classes (distinct value vectors, depth <= 2): 1345'.
* **Fix.** Write 'Plain expressions with the same values ... are merged into 1345 classes; an if-program is a condition and two such classes'.

### 36. C-33 [minor] paper/sections/ood.tex, ex:ood:easyhard, line 138; thm:ood:twosided, lines 57-60

* **Problem.** (i) The test sentence must be decided by $\mathcal T$ (it has a label); the example says only that it has no proof or refutation of length at most $L'$, which an undecidable sentence also satisfies. (ii) OUTLINE requires every lower bound to say that it bounds the defined (abiding or violating) mass and therefore holds in both conventions; thm:ood:twosided and ex:ood:easyhard do not say it.
* **Evidence.** Context notes Ex 2.15: 'The test statement $x^*$ is decidable in $T$, but its shortest proof or refutation is longer than $L'$'. OUTLINE \S7 Notes ('Say for each lower bound that it bounds the defined-and-wrong mass'). (Point (ii) also found by the parallel reviewer, P1C-23.)
* **Fix.** Add 'and the test sentence $x^*$, decided by $\mathcal T$, none of length at most $L'$'; add after thm:ood:twosided: 'All these bounds concern defined outputs, so they hold in both conventions.'

### 37. C-34 [minor] paper/sections/ood.tex, prop:ood:relative, line 38

* **Problem.** '$2^{-|p|}/\nu(D)$, the posterior weight of $p$' is exact for $W$ only; under $\MF$ the deterministic program $p$ has posterior weight $2^{-|p|-O(1)}/\MF(D)$.
* **Evidence.** Context notes Prop 2.3: 'The same holds for $M_F$ with $2^{-|p|}/M_F(D)$, by $M_F\ge2^{-c}W$' (a bound, not the posterior weight).
* **Fix.** Write 'the posterior weight of $p$ under $W$ (up to a constant factor under $\MF$)'.

### 38. C-35 [minor] paper/sections/ood.tex; paper/sections/comp.tex, rem:ood:lopsided line 97; rem:comp:distinct line 31

* **Problem.** Both remarks refute readings that appear only in the research notes ('Reading ... as ``the total OOD error lies between ...'' is wrong'; 'One might hope that restricting (a) to distinct inputs loses nothing'). The binding note allows refuted claims only where they inform the reader; the informative content is the positive statement.
* **Evidence.** CLAIMS.md rows rem:ood:lopsided, rem:comp:distinct: '(Co notes.md) is refuted'.
* **Fix.** State the facts directly: 'The novelty lower bounds sum to at most $2^{-c}$: separation forces constant error at single steps but only $O(1)$ in total' and 'Distinctness is needed: ...'.

### 39. C-36 [minor] paper/sections/nn.tex; paper/sections/comp.tex, q:nn:bridges line 94; q:comp:open line 136

* **Problem.** The open-question paragraphs contain to-do items rather than mathematical questions: 'a check of the slides' main theorem' and 'The machine-model details of the running times above ... are not written out'.
* **Evidence.** Binding note: open questions under 'Open problems'; gaps in proofs belong with the proof sketch.
* **Fix.** Rephrase as questions ('Does the slides' main theorem hold as stated? Does ``few mistakes'' imply a small circuit for NN Bayes?') and move the machine-model caveat to the proof sketch of thm:comp:timebounded(b).

### 40. C-37 [minor] paper/sections/comp.tex, def:comp:circuits, line 82

* **Problem.** 'The prior $w(C):=2^{-s}/N_s$ is the code length of ``size in unary, then the gate list''' (it is $2^{-\text{code length}}$); 'appends $\gamma\le d+1$ gates computing $[x=a]$ and a new output gate' reads as $\gamma+1$ gates, while $\gamma$ counts the output gate too ($\max(d-1,1)$ gates for $[x=a]$ plus one).
* **Evidence.** Context notes \S3.2 ('This is $2^{-|\mathrm{desc}(C)|}$'; 'So $g\le d+1$ gates are added').
* **Fix.** Write 'is $2^{-\ell}$ for the code length $\ell$ of ...' and 'appends $\gamma\le d+1$ gates in all: $\max(d-1,1)$ gates computing $[x=a]$ and a new output gate'.

### 41. C-38 [minor] paper/sections/comp.tex, proof idea of thm:comp:ladder, line 124

* **Problem.** 'Each is wrong only at its own point $1_S$' is true only among inputs of weight $k$ ($\mathrm{AND}_S$ is also wrong at every heavier input containing $S$ other than $1^d$).
* **Evidence.** app-comp.tex line 52 states it correctly for $|S|=|S'|=k$.
* **Fix.** Write 'Among the inputs of weight $k$, each is wrong only at its own point $1_S$'.

### 42. C-40 [minor] paper/sections/ood.tex, proof of prop:ood:hanni, line 24

* **Problem.** For $\MF$ the proof ends 'apply \cref{thm:setting:universal}', but that theorem's dominance is stated for data sets; the claim about the infinite event 'agrees with $b$ on all of $Q\cap\dom b$' needs the tape-prefix argument (tapes of $T_U$ that start with a program for $T_{Q,b}$).
* **Evidence.** thm:setting:universal is stated for $D\ne\emptyset$ (finite); context notes Prop 2.1(2): 'The infinite event is a countable intersection of events, and the same inclusion applies to it.'
* **Fix.** Add: 'The tapes of $T_U$ that begin with a program for $T_{Q,b}$ have measure at least $2^{-K(Q,b)-c}\MF(D)$ among those consistent with $D$, and each gives a function equal to $b$ on $Q\cap\dom b$.'

### 43. C-41 [minor] paper/sections/comp.tex, prop:comp:history, line 66

* **Problem.** 'The class contains the chain and skipped-string predictors' holds for a linear time bound; the proposition is stated for a general $t$.
* **Evidence.** Context notes Prop 3.2c: 'The class contains the chain and skipped-string predictors (with $p(n)=n$)'.
* **Fix.** Add 'for $t(n)=n$'.

### 44. C-44 [minor] paper/sections/nn.tex; paper/sections/comp.tex, rem:nn:slides line 81; rem:comp:selection line 128

* **Problem.** With the slides' co-author as the paper's sole author, 'the rest is unchecked' and 'the other claims are the slides' and we have not checked them' read oddly: the author reports not having checked his own slides. The same holds for sentences that argue with 'Hänni' in the third person ('Hänni's version has an extra ... term, which is not needed'). The binding note allows crediting his notes by citation, but the presentation of the slides needs the authorship arrangement stated where it matters.
* **Evidence.** Binding note: 'Hänni's ideas are credited through citations to his notes, or by stating the authorship arrangement'. (Related to the parallel reviewer's P1C-12, which I grade minor because the binding note sanctions the third-person citation of the notes.)
* **Fix.** In rem:nn:slides write 'The slides \citep{vaintrobhanni2026nnbayes} claim ...; of these, only (i), Appendix J and Appendix K are proved in this paper', and avoid first-person statements about checking; in nn.tex line 24 write 'The version in \citet{hanni2026notes} has an extra ... term; it is not needed.'

### 45. C-45 [minor] paper/sections/ood.tex, ex:ood:hanniexamples(c), line 171

* **Problem.** The witness for the wrong answer fails at one input: '``$|x|$ even'' and ``output $0$'' cost $O(1)$ bits, so a wrong answer keeps probability at least $2^{-c'}$' on every even-length input; at the empty string (length $0$, even) 'output $0$' is the correct answer. The claim is true with another simple wrong behaviour.
* **Evidence.** Hänni's example asks for generalisation 'to all strings' (prior/hanni-some-examples-where-function-solomonoff-generalizes-well-ood.md line 7). Same slip in examples notes \S5.3. (Found by the parallel reviewer, P1C-17; verified.)
* **Fix.** Use 'output $|x|+1$'.

### 46. C-46 [minor] paper/sections/ood.tex, conventions paragraph line 13; prop:ood:budget line 88

* **Problem.** $K(Q)$ is used in thm:ood:twosided(c), prop:ood:budget, prop:ood:draftfalse and ex:ood:easyhard but never defined (only $K(Q,b)$ is); and $\sep_k$ is a minimum over an empty set when $x_k$ repeats an earlier input, which the conventions do not exclude.
* **Evidence.** ood.tex line 13 defines $K(Q,b)$ only. (Found by the parallel reviewer, P1C-21; verified.)
* **Fix.** Add '$K(Q)$ is the least $K(e)$ over total deciders $\varphi_e$ of $Q$' and '($\sep_k:=\infty$ if no decidable $Q$ separates $x_k$, e.g. if $x_k$ repeats)'.

### 47. C-47 [minor] paper/sections/app-ood.tex; paper/sections/ood.tex, proof of prop:ood:labelled line 31; status at ood.tex line 126

* **Problem.** The parenthesis 'A direct computation on a finite mixture ... confirms the disjointness on all subsets of a five-point domain' presents a computer check of a two-line logical fact inside a proof; the status 'disjointness computed' has the same problem.
* **Evidence.** The disjointness is proved in the preceding sentence. (Found by the parallel reviewer, P1C-24.)
* **Fix.** Delete the parenthesis and the 'disjointness computed' part of the status.

### 48. C-48 [minor] paper/sections/comp.tex, prop:comp:round line 36; def:comp:timebounded line 17

* **Problem.** The activation rounds $k_i$ are used but never defined (the definition introduces only activation lengths $n_i$); and $n_i$, $n_A$, $n'_A$ denote input lengths, against the paper-wide convention ($n$ sample size, $d$ input length).
* **Evidence.** NOTATION.md; def:comp:timebounded. (Found by the parallel reviewer, P1C-27; verified.)
* **Fix.** Define 'activation rounds $k_1<k_2<\cdots$' in prop:comp:round; rename the activation lengths (e.g. $\ell_i$, $\ell_A$).

### 49. C-49 [minor] paper/sections/comp.tex, thm:comp:circuitbayes(a), line 90

* **Problem.** 'For every $B\subseteq\{0,1\}^d$ ... some circuit of size at most $\lceil L_B\rceil$ agrees with $f$ on $B$' fails for $B=\emptyset$ ($L_B=0$, and there are no circuits of size $0$); the proof uses $B\ne\emptyset$.
* **Evidence.** app-comp.tex line 27 ('strictly because ... on $B\ne\emptyset$'). (Found by the parallel reviewer, P1C-29; verified.)
* **Fix.** Write 'for every nonempty $B$'.

### 50. C-50 [minor] paper/sections/app-comp.tex, rem:comp:adversary, line 59

* **Problem.** '(For formulas the slot count gives $|V_h|\le\csize(h)$ ...)' uses $\csize$, defined as circuit size, for formula size.
* **Evidence.** def:comp:circuits defines $\csize$ for circuits. (Found by the parallel reviewer, P1C-32.)
* **Fix.** Write 'the formula size of $h$'.

### 51. C-51 [minor] paper/sections/comp.tex, rem:comp:apples, line 58

* **Problem.** 'no x-only learner competes with them, since the chain and skipped-string predictors run in linear time while SFI's loss on those data is unbounded (\cref{thm:hist:chain,thm:hist:skipped})': those theorems are about SFI; the statement for every order-free learner is prop:hist:orderfree.
* **Evidence.** hist.tex thm:hist:chain, thm:hist:skipped (SFI); prop:hist:orderfree (all order-independent predictors). (Found by the parallel reviewer, P1C-33; verified.)
* **Fix.** Cite \cref{prop:hist:orderfree} for the general claim.

### 52. C-52 [minor] paper/sections/comp.tex, q:comp:samplers, line 75

* **Problem.** The Monte Carlo heuristic omits the source's condition that the sampler's probabilities be bounded away from $0$ and $1$.
* **Evidence.** Context notes Q 3.4. (Found by the parallel reviewer, P1C-34.)
* **Fix.** Add 'when the sampler's probabilities are bounded away from 0 and 1'.

### 53. C-53 [minor] paper/sections/comp.tex, line 10; rem:comp:gap line 99

* **Problem.** Quotation marks around text that is not verbatim: 'regret and complexity are polynomially related' is the file name of Hänni's note, and the quoted 'log loss <= poly(m)' and 'a circuit of size poly(m)' paraphrase 'the log loss is at most poly(m)' and 'a circuit of size at most poly(m)'.
* **Evidence.** prior/hanni-circuit-for-circuit-induction-regret-and-complexity-are-polynomially-related.md lines 1-12. (Also noted by the parallel reviewer, P1C-35.)
* **Fix.** Quote the text verbatim or remove the quotation marks.

### 54. C-54 [minor] paper/sections/nn.tex; paper/sections/app-nn.tex, thm:nn:walsh line 58; rem:nn:oddparity(c) line 75; app-nn.tex lines 10, 21-23

* **Problem.** Notation: $\Lambda_{|S|}$ in the statement, $\Lambda_S$ in the proof; $K$ for the Gram matrix in (c), against $K$ for Kolmogorov complexity; (c) does not restate its hypotheses (these two kernels, odd $|S|\ge3$); 'From (a)' in the proof of (c) means thm:nn:walsh(a), not rem:nn:oddparity(a).
* **Evidence.** nn.tex, app-nn.tex as cited. (Also noted by the parallel reviewer, P1C-37.)
* **Fix.** Use $\Lambda_{|S|}$ throughout, write $G$ for the Gram matrix, open (c) with 'For these two kernels and odd $|S|\ge3$', and write 'From \cref{thm:nn:walsh}(a)'.

### 55. C-55 [minor] paper/sections/steeper.tex, lines 8, 10, 14

* **Problem.** Some summaries drop hypotheses or overstate: 'the product class pays $\min(\lambda,2)$ bits per coin' holds for incompressible coin sequences ($\min(\lambda,2)(K(\beta\mid k)-\kappa)$); '$0.199$' is at randomness deficiency $0$; the $\lambda$-MAPs are eventually equivalent to $\nu$ almost surely; 'every countable product class' needs Kraft weights; and 'A few per cent below $2^{-20}$ and further down, near-optimal hypotheses reproduce the errors' overstates what is proved (at 6% below, error-label probability at least $0.48$; at 10% below, $0.66$; nothing in the top 0.6%).
* **Evidence.** Paper 2 absorb.tex line 78 (prop:absorb:price), teacher.tex table and line 131, split.tex; steeper notes-final \S0. (Also found by the parallel reviewer, P1C-39 and P1C-41; verified.)
* **Fix.** Add the qualifiers 'for incompressible coin sequences', 'for incompressible error rules', 'almost surely', 'with Kraft weights'; replace the last sentence by 'Below $2^{-20}$, by a relative margin of a few per cent, near-optimal hypotheses give the erroneous labels substantial probability (at least $0.48$ at 6% below).'

