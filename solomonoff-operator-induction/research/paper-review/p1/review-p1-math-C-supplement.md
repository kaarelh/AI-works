# Paper 1, review C: supplement from a second, independent run

**Reviewer.** p1-math-C, second instance.

**Scope.** The same as the main review:
* `ood.tex`, `comp.tex`, `nn.tex`, `related.tex`, `steeper.tex`;
* `app-ood.tex`, `app-comp.tex`, `app-nn.tex`;
* the parts of `app-verification.tex`, `main.tex` and `bib/core.bib` that bear on these sections.

**Sources.** The context, examples and steeper final notes; the Vaintrob–Hänni slides; Hänni's notes; `research/00-brief.md`; the binding notes of `paper/OUTLINE.md`.

## Why this file exists

Two instances of reviewer C ran at the same time and wrote to the same paths. The current `p1/review-p1-math-C.md` and `p1/issues-p1-math-C.json` belong to the other instance, with ids C-01 to C-41. I have left them as they are.

My own review was independent and found 41 issues (14 major, 27 minor), ids P1C-01 to P1C-41. The full list is in `scratch/p1-math-C/reviewer2_full_issues.json`. Twenty-one of them duplicate an issue of the other run; the mapping is at the end of this file and in `scratch/p1-math-C/duplicate_mapping.json`.

This supplement contains only the 20 issues that are new, or that correct the other run. They are in `p1/issues-p1-math-C-supplement.json`, with the same fields. The lead editor should treat C-01 to C-41 together with the issues below as reviewer C's report.

## Agreement with the other run, and one correction

**C-01 (fatal) confirmed.** ood.tex line 134 says 'there is no pointwise bound on e(x*)'. This is false. I first missed it, saw the other run's script in the shared scratch folder, and then re-derived the argument myself.
* Given f, sample a hypothesis from the prior and run it on all of B.
* Output the remaining point once |B|−1 points have halted with f's label.
* This is a semimeasure on B that is lsc uniformly in f.
* It outputs x* with probability at least ν(f|_A)−ν(f).
* So e(x*) ≤ 2^{L_ν(f)−K(x*|f)+c}.

My own code (`scratch/p1-math-C/c4_pointwise_e_check.py`) checks the combinatorial step exactly on 3000 random finite mixtures with partial and wrong hypotheses, |Y| = 3:
* minimum slack: −1.1e−16;
* largest e/e_norm: 615, so the bound on e is not implied by the bound on e_norm.

**C-03 (major) confirmed.** With ε_j = j^{-2}, ε_1 = 1, so Σ_j log((1+ε_j)/(1−ε_j)) is infinite.

**C-02 confirmed.** t_n is logarithmic, not doubly logarithmic. I rated it major (a wrong statement in a summary); the other run rated it fatal. Either way the fix is one phrase.

**C-31 is wrong in its diagnosis and its fix.** C-31 accepts the paper's description that the tilted program has 'ten times the prior mass of all plain programs'. It does not; see P1C-01 below.
* `scratch/p1-math-C/c1_e5_tilt.py` reruns the grammar through the project's `code/sfi_dsl.py`.
* The table's 0.557 and 0.114 come from tilt × the mass of the training-consistent plain programs, which is the intended class |x| alone (0.0470).
* The paper's description (tilt × the mass of all plain programs, 0.348) gives 0.148 and 0.017.
* C-31's suggested replacement wording should not be applied.

## Independent checks of this run (`research/paper-review/scratch/p1-math-C/`)

All run with `python3 -I`; outputs are saved next to each script.

| script | result |
|---|---|
| `c1_e5_tilt.py`, `c1b_prior_share.py` | the tilted weighting as coded vs as described (above); at ×10 the extra program holds 44.3% of the prior, about 2600× its natural grammar weight; the ×10 masses sum to 1.06 |
| `c2_comp_nn_checks.py` | circuit constant max ratio 10.847 (paper 10.85 < 16); brackets 10.652 and −9.028; 70ℓ+531 suffices; constant part of the Occam mistake bound ≤ 4.02 (paper 5.7); uniform-tie bound d + d² ln 2 holds for d ≤ 40; Möbius lemma exhaustive for d ≤ 4; odd Walsh levels ≥ 3 of both bias-free ReLU kernels below 6e−17 at d = 7; padding identity and gadget weight bound hold |
| `c3_ladder_formulas.py` | own dynamic program over truth tables, d = 3, 4: least-size consistent functions are exactly the k-conjunctions; Occam ladder mistakes 7 and 15 under two tie rules |
| `c4_pointwise_e_check.py` | the combinatorial step of C-01 (above) |

Every other statement and proof in the eight files I re-derived and found correct. This agrees with the other run's §§2–5.

## Issues not in the other run (20: 7 major, 13 minor)

### P1C-01 (major)

* **File:** `paper/sections/app-ood.tex`
* **Location:** line 39 (grammar paragraph), table tab:ood:grammar rows 'tilted'; also ood.tex line 171 (ex:ood:hanniexamples(c)) and app-ood.tex line 69 (tab:ood:hanni)
* **Problem.** Correction to C-31 of the concurrent run, and to app-ood.tex. The 'tilted' extra program does NOT get 'prior mass equal to (or ten times) that of all plain programs' (app-ood.tex line 39; repeated in C-31's diagnosis and fix). It gets tilt times the mass of the plain programs consistent with the training data, i.e. of the single intended class |x|, which is 7.4 times smaller. The printed numbers 0.557/0.114 belong to that weighting; with the described weighting they would be 0.148/0.017. At x10 the one extra program carries 44% of the total prior mass (and the masses sum to 1.06, harmless because the predictive is a ratio). The main text's 'about 0.11 when one extra program tilts the grammar' hides all of this. This is a wrong description of a computation that a reader would act on, so major, not minor.
* **Evidence.** examples/checks/e5_dsl_odd_lengths.py line 88: extra_programs=[(bad, tilt * 0.5 * m_plain_ok)], where m_plain_ok is the mass of the plain classes consistent with training (0.093932, class 'len' only; total plain-expression mass 0.695313). Independent rerun (scratch/p1-math-C/c1_e5_tilt.py, .out.txt): as coded, P(correct) = 0.557 (x1) and 0.114 (x10), reproducing the table. With the paper's wording (mass = x1 or x10 that of ALL plain programs) it is 0.148 and 0.017. In c1b_prior_share.out.txt the x10 program holds 0.443 of the total prior. The same e5 output shows that the program's natural grammar mass is 1.784e-4 (ratio 3.8e-3 to the consistent plain mass), so x10 inflates it about 2633-fold. The wrong description is inherited from the e5 docstring and examples notes §5.3, which contradict the code.
* **Fix.** app-ood.tex: 'The tilted rows add one program "if |x| even then 0 else |x|" with prior mass equal to (or ten times) that of the intended program |x|, the only plain program consistent with the training data; with the factor ten it carries 44% of the prior mass (the predictive is computed after normalising).' ood.tex line 171: '... and about 0.11 when a single extra program with ten times the prior mass of the intended one is added'. tab:ood:hanni: '0.11 with a tilted prior'. Do NOT apply C-31's suggested wording ('ten times (resp. once) the prior mass of all plain programs'), which is wrong.

### P1C-03 (major)

* **File:** `paper/sections/nn.tex`
* **Location:** rem:nn:rigorous (line 86)
* **Problem.** Under 'Proved' the remark lists 'the Gaussian-process limits fail on sparse and odd parities where SFI succeeds'. For sparse parities, what is proved concerns the squared error of the real-valued kernel or GP-mean predictor, averaged over random k-sparse targets (thm:nn:walsh(b), cor:nn:separation). The paper says two paragraphs earlier: 'we do not claim a 0-1 version in general'. As printed, the summary claims a classification failure that is not proved. The intro repeats it loosely as 'a separation between Gaussian-process limits and SFI on parities'.
* **Evidence.** nn.tex line 69: 'The separation is in squared error of the real-valued predictor; we do not claim a 0--1 version in general.' Context notes §4.6 (v): 'the regression predictor is diagonal in the Walsh basis and needs binom(d,k) samples for k-sparse parities'. Classification failure is proved only for bias-free two-layer ReLU kernels and odd |S|>=3 (rem:nn:oddparity(b): zero prior mass; (c): anti-correlation of the regression predictor).
* **Fix.** Rewrite the item as: 'kernel regression and GP posterior means in the Gaussian-process limits need binom(d,k) samples, in squared error, on random k-sparse parities, where SFI needs O(k log d); for bias-free two-layer ReLU kernels odd parities of degree at least 3 are never learned, have GP-classification prior mass 0, and are anti-correlated with the predictor on unseen points.'

### P1C-06 (major)

* **File:** `paper/sections/comp.tex`
* **Location:** thm:comp:timebounded(b) (line 24); prop:comp:round, last sentence (line 36); cor:comp:poly, last clause (line 47); prop:comp:history, last clause (line 63)
* **Problem.** Running-time claims that are only sketched, or not argued at all, appear inside theorem, proposition and corollary statements. Once \status is removed, nothing in these statements marks them as unproved. The binding note requires sketches to be labelled and forbids presenting the statement as fully proved. The appendix gives a 'Proof sketch' for thm:comp:timebounded(b) only. The running-time parts of prop:comp:round, prop:comp:history and cor:comp:poly have no proof or sketch anywhere. The 'Proof of prop:comp:history' covers the regret only. The machine model is admitted to be unwritten only in q:comp:open.
* **Evidence.** Statuses at comp.tex lines 21, 35, 62: '(b) proof sketch', 'running time proof sketch', 'regret proved; running time proof sketch'. app-comp.tex line 11: 'The machine model (RAM versus multitape) and the cost of running the clocks are not written out; this part is a proof sketch.' app-comp.tex line 18: 'Proof of prop:comp:history (regret)'. Context notes Prop 3.2c: cost '[proof sketch]'.
* **Fix.** Split each statement. Keep the regret bounds in the theorem, proposition and corollary. Move every per-round cost claim to one 'Remark (running time; proof sketch)' after prop:comp:history. That remark should give the sketch for all four, including the stored-weight update for M_rd and the replay bookkeeping, and should state that the RAM model is assumed and the cost of the clocks is not analysed. Alternatively, write '(running time: proof sketch in \cref{app:comp})' inside each statement and add the missing sketches.

### P1C-09 (major)

* **File:** `paper/sections/related.tex`
* **Location:** lines 6, 8, 10, 12, 18; also nn.tex line 91
* **Problem.** Beyond C-11(i) and C-28 (which cover 'Each of these should be checked ...', '(we have seen only the abstract)' and the Vovk sentence), the following printed reading-status hedges remain non-standard: related.tex line 8 'according to their abstract', 'in their abstract', 'that it agrees with Hutter's construction up to constant factors is expected but was not checked against his texts'; line 10 'whether their random-selection result coincides with \cref{prop:learn:splits} we have not checked'; line 18 'At the level of a search that saw abstracts and secondary sources only'; nn.tex line 91 'These descriptions follow the abstracts.' In addition related.tex ('is expected but was not checked') and hist.tex line 135 ('is known, but not checked against the sources') contradict each other on the Hutter identification.
* **Evidence.** OUTLINE binding note: 'never print "unverified"'; 'No process vocabulary'. related.tex header comment: 'Every content claim below is hedged: only abstracts or secondary descriptions were seen.' bib/related.bib: vovk1992universal '% unverified: content not seen'.
* **Fix.** Use one consistent formulation in related.tex and hist.tex, e.g. 'We expect, but do not prove, that \SFIhist{} agrees with Hutter's universal chronological semimeasure up to constant factors (he works with finite alphabets).' Replace 'according to their abstract'/'in their abstract' by plain attribution ('X show that ...') or by 'X report that ...'; delete 'we have not checked' (or say 'we do not compare the two statements here'); delete the first clause of rem:related:new and 'These descriptions follow the abstracts.'

### P1C-11 (major)

* **File:** `paper/bib/core.bib`
* **Location:** hanni2026request (lines 19-25); cited in nn.tex line 8 and steeper.tex line 14 (also learn.tex, intro.tex)
* **Problem.** Kaarel Hänni is the sole author, yet the bibliography lists 'Kaarel Hänni. Request for a paper on Solomonoff function induction. Personal communication to the author, 11 October 2026; quoted verbatim in ... research/00-brief.md'. A personal communication from the author to himself cannot be cited, and a reader cannot make sense of it. In my sections it supports the quotations 'kinda like a circuit version of solomonoff function induction' (nn.tex) and 'a preference for a simple sampler over a model where the sampled bits are filled in' / 'both get similar posterior' (steeper.tex).
* **Evidence.** main.bbl lines 169-176. Main.tex author line: Kaarel Hänni alone. The quotations are verbatim from research/00-brief.md lines 7 and 23.
* **Fix.** Do not cite the request. Describe these ideas as the author's in the first person or impersonally, e.g. 'NN Bayes can be viewed as a circuit version of SFI (\citealt{vaintrobhanni2026nnbayes})' and 'Solomonoff induction has no preference between a simple sampler and a model in which the sampled bits are filled in; both get similar posterior weight'. If a source is wanted, cite the note in hanni2026notes that contains the idea. This needs a global change, coordinated with intro.tex and learn.tex (cf. reviewer B MB-06).

### P1C-12 (major)

* **File:** `paper/sections/ood.tex, comp.tex, nn.tex, steeper.tex`
* **Location:** e.g. ood.tex lines 7, 27, 34, 48, 53, 111, 153; comp.tex lines 10, 54, 58, 99, 111; nn.tex lines 8, 24, 33, 47, 51, 54, 81, 86, 91; steeper.tex lines 6, 8, 12, 14
* **Problem.** The sections refer to the sole author in the third person and argue with him: 'Hänni's version has an extra loglog(1/p) term, which is not needed'; 'His step ... is a circuit coding theorem'; 'Hänni's objection ... is made rigorous'; 'which Hänni doubts'; 'H\"anni anticipated'. The slides co-authored by the author are treated as an outside source ('the other claims are the slides' and we have not checked them'; 'We re-checked the proof ... the rest is unchecked'). With 'Kaarel Hänni' as the only name on the title page, a reader cannot tell who 'we' is or why the author does not check his own slides. The binding note allows citing his notes as his notes, but the paper never states this convention.
* **Evidence.** OUTLINE binding note (authorship): 'Ideas from the author's notes are cited as his notes (\citep{hanni2026notes}) or described as the author's.' intro.tex line 5: '\citet{hanni2026notes} proposes ...'. There is no sentence anywhere explaining the third-person convention.
* **Fix.** Add one sentence to the introduction: 'We cite the author's earlier working notes as \citet{hanni2026notes} and discuss the claims made there as claims of those notes.' Then change 'Hänni's X' to 'the notes' X' or 'X of \citet{hanni2026notes}' in these sections. Rephrase statements about the slides as 'the slides state ...; we do not prove these claims here'.

### P1C-04 (major)

* **File:** `paper/sections/ood.tex`
* **Location:** rem:ood:answer (line 145), items (iii) and (iv)
* **Problem.** Depends on C-01 (which this reviewer confirms independently, scratch/p1-math-C/c4_pointwise_e_check.py). rem:ood:answer(iii) bounds 'the error at a test point' from above by 2^{L_nu(f)-sep(x*;A|f)+O(1)}. In this section 'the error' is the semimeasure-convention e(x*), for which the paper proves no upper bound (prop:ood:labelled bounds e_norm and e^wr only) and at line 134 even asserts that none exists. If C-01 is fixed by the minimal option (deleting the sentence without adding the e(x*) bound), (iii) remains unproved as stated. The lower end also needs the -K(y) term (cf. C-39).
* **Evidence.** prop:ood:labelled bounds only e^wr <= e_norm <= 2^{L_nu(f)-K(x*|f)+c}, and its lower bound is 2^{-sep(x*;A)-K(y)-c}. ood.tex line 134: 'The mass undefined at x* is not lsc, so there is no pointwise bound on e(x*)'. prop:learn:typical (learn.tex line 138) assumes uniform inputs on {0,1}^d with d >= ceil(log n)+1 and, for general f, computable binary f.
* **Fix.** Either add the pointwise bound e(x*) <= 2^{L_nu(f)-K(x*|f)+c} to prop:ood:labelled with the waiting-sampler proof (C-01's full option), which makes (iii) true as written; or restrict (iii) to e_norm (upper end) and e^wr (lower end, with K(y)).

### P1C-17 (minor)

* **File:** `paper/sections/ood.tex`
* **Location:** ex:ood:hanniexamples(c) (line 171)
* **Problem.** '"|x| even" and "output 0" cost O(1) bits, so a wrong answer keeps probability at least 2^{-c'}' fails at the empty string. It has even length 0, and 'output 0' is the correct answer there. Hänni's example asks for generalisation 'to all strings'. The claim itself is true, but the witness behaviour is wrong at one input. The source has the same slip.
* **Evidence.** Examples notes §5.3: '"|x| is even" and "output 0" are O(1) bits, so a wrong answer has probability >= 2^{-c'} on every even-length input'. At x = epsilon, |x| = 0.
* **Fix.** Use 'output 1', which is wrong on every even length, or take the property '|x| even and x nonempty'.

### P1C-21 (minor)

* **File:** `paper/sections/ood.tex`
* **Location:** conventions paragraph (line 13); prop:ood:budget (line 88)
* **Problem.** K(Q) is used in thm:ood:twosided(c), prop:ood:budget, prop:ood:draftfalse and ex:ood:easyhard but is never defined; only K(Q,b) is. prop:ood:budget's minimum is over an empty set if x_k repeats an earlier input. The conventions do not assume the inputs are distinct.
* **Evidence.** ood.tex line 13 defines only K(Q,b). prop:ood:budget does not state that the inputs are distinct.
* **Fix.** Add 'K(Q) is the least K(e) over indices e of total deciders of Q.' In prop:ood:budget add 'distinct inputs x_1, x_2, ...'.

### P1C-23 (minor)

* **File:** `paper/sections/ood.tex`
* **Location:** thm:ood:twosided (lines 57-60); ex:ood:easyhard (line 138)
* **Problem.** The OUTLINE requires every lower bound to say that it bounds the defined (wrong or abiding) mass and holds in both conventions; thm:ood:twosided (a)-(c) and ex:ood:easyhard never say so (the decidedness of x* in ex:ood:easyhard is C-33).
* **Evidence.** OUTLINE §7 notes: 'Say for each lower bound that it bounds the defined-and-wrong mass and holds in both conventions.'
* **Fix.** Add after thm:ood:twosided: 'All lower bounds in this subsection are on defined outputs, so they hold in both conventions.' Repeat in ex:ood:easyhard.

### P1C-24 (minor)

* **File:** `paper/sections/app-ood.tex`
* **Location:** proof of prop:ood:labelled (line 31); status at ood.tex line 126
* **Problem.** The parenthetical 'A direct computation on a finite mixture ... confirms the disjointness on all subsets of a five-point domain' presents a computer check of a two-line logical fact. This is out of place in a proof. The status 'disjointness computed' has the same problem.
* **Evidence.** The disjointness argument is complete in the preceding sentence.
* **Fix.** Delete the parenthetical and set the status to 'proved'.

### P1C-27 (minor)

* **File:** `paper/sections/comp.tex`
* **Location:** prop:comp:round (line 36); def:comp:timebounded (line 17)
* **Problem.** The activation rounds k_i are used but never defined; the definition introduces only activation lengths n_i. The section also uses n_i, n_A and n'_A for input lengths, which clashes with the paper-wide convention that n is the sample size and d the input length.
* **Evidence.** NOTATION.md: d = input length, n = sample size. comp.tex line 22: n_A := max(n_i, ...).
* **Fix.** Define 'activation rounds k_1 < k_2 < ...' in prop:comp:round. Rename the length thresholds, e.g. to ell_i, ell_A and ell'_A.

### P1C-29 (minor)

* **File:** `paper/sections/comp.tex`
* **Location:** thm:comp:circuitbayes(a) (line 90)
* **Problem.** 'For every B ⊆ {0,1}^d ... some circuit of size at most ceil(L_B) agrees with f on B' fails for B = empty set: L_B = 0 and there are no circuits of size 0. The proof uses B nonempty ('strictly because ... B != empty').
* **Evidence.** app-comp.tex line 27; def:comp:circuits: sizes s >= 1.
* **Fix.** 'For every nonempty B ⊆ {0,1}^d'.

### P1C-32 (minor)

* **File:** `paper/sections/app-comp.tex`
* **Location:** rem:comp:adversary (line 59)
* **Problem.** '(For formulas the slot count gives |V_h| <= csize(h) ...)' uses csize, defined as circuit size, for formula size.
* **Evidence.** def:comp:circuits defines csize for circuits.
* **Fix.** Write 'formula size' or introduce a symbol for it.

### P1C-33 (minor)

* **File:** `paper/sections/comp.tex`
* **Location:** rem:comp:apples (line 58)
* **Problem.** 'no x-only learner competes with them, since ... SFI's loss on those data is unbounded (\cref{thm:hist:chain,thm:hist:skipped})': those theorems are about SFI. The statement for every order-free (x-only) learner is prop:hist:orderfree.
* **Evidence.** CLAIMS.md: prop:hist:orderfree: every order-free predictor pays the chain and skipped-string lower bounds.
* **Fix.** Cite \cref{prop:hist:orderfree} as well.

### P1C-34 (minor)

* **File:** `paper/sections/comp.tex`
* **Location:** q:comp:samplers (line 75)
* **Problem.** The Monte Carlo heuristic omits the source's condition that the sampler's probabilities be bounded away from 0 and 1.
* **Evidence.** Context notes Q 3.4: 'when the sampler's probabilities are bounded away from 0 and 1, an expected excess log loss of order 1/t per round'.
* **Fix.** Add the condition.

### P1C-35 (minor)

* **File:** `paper/sections/comp.tex`
* **Location:** line 10 and rem:comp:gap (line 99)
* **Problem.** Quotation marks are put around text that is not verbatim. 'regret and complexity are polynomially related' is the file name or title of a note, not a sentence in it. '"log loss <= poly(m)"' and '"a circuit of size poly(m)"' paraphrase 'the log loss is at most poly(m)' and 'a circuit of size at most poly(m)'.
* **Evidence.** research/prior/hanni-circuit-for-circuit-induction-regret-and-complexity-are-polynomially-related.md (title only), lines 10-11.
* **Fix.** Quote exactly, or paraphrase without quotation marks.

### P1C-37 (minor)

* **File:** `paper/sections/nn.tex, app-nn.tex`
* **Location:** thm:nn:walsh (line 58), rem:nn:oddparity(c) (line 75); app-nn.tex lines 10, 21-23
* **Problem.** The notation is inconsistent. Lambda_{|S|} (statement) vs Lambda_S (proof). <x,x'> is the inner product in R^d and <z,chi_S> the L^2 pairing. K denotes the Gram matrix, which clashes with Kolmogorov complexity K. rem:nn:oddparity(c) does not restate its hypotheses (these two kernels, odd |S| >= 3). 'From (a)' in the proof of (c) means thm:nn:walsh(a).
* **Evidence.** nn.tex lines 58, 75; app-nn.tex lines 10, 22, 23.
* **Fix.** Use Lambda_{|S|} throughout. Write E_x[z(x)chi_S(x)] for the L^2 pairing and G for the Gram matrix. Begin (c) with 'For these kernels and odd |S| >= 3'. Write 'From \cref{thm:nn:walsh}(a)'.

### P1C-39 (minor)

* **File:** `paper/sections/steeper.tex`
* **Location:** lines 8, 10, 14
* **Problem.** Some summaries drop hypotheses. 'the product class pays min(lambda,2) bits per coin' holds for incompressible coin sequences: the bound is min(lambda,2)(K(beta|k)-kappa). The 0.199 figure holds at randomness deficiency 0. 'the lambda-MAPs are eventually equivalent to nu' holds almost surely. 'every countable product class' should say 'with Kraft weights'.
* **Evidence.** Steeper notes Prop 1.7(i), §0 item 2 ('0.199 (kappa=0, delta_S=0)'), Thm 4 ('almost surely ...'; 'every countable product class with Kraft weights').
* **Fix.** Add 'for incompressible coin sequences', '(error rule of deficiency 0)', 'almost surely' and 'with Kraft weights'.

### P1C-41 (minor)

* **File:** `paper/sections/steeper.tex`
* **Location:** line 10
* **Problem.** 'A few per cent below 2^{-20} and further down, near-optimal hypotheses reproduce the errors' overstates what is proved. At 6% below, the bound gives the error label probability at least 0.48; at 10% below, at least 0.66. In the top 0.6% below the threshold nothing is proved.
* **Evidence.** Steeper notes §0 item 2: 'at c=0.9*2^{-m} the error label gets probability at least 0.66, at 0.94*2^{-m} at least 0.48, and in the top 0.6% below 2^{-m} nothing is proved'.
* **Fix.** 'Below 2^{-20} near-optimal hypotheses give the erroneous labels probability at least 0.48 at 6% below the threshold and at least 0.66 at 10% below.'

## Duplicates of the other run (not repeated here)

| this run | other run |
|---|---|
| P1C-02 | C-05 |
| P1C-05 | C-14 |
| P1C-07 | C-08 |
| P1C-08 | C-11(ii) |
| P1C-10 | C-10 |
| P1C-13 | C-02 |
| P1C-14 | C-12 |
| P1C-15 | C-27 |
| P1C-16 | C-25 |
| P1C-18 | C-04 |
| P1C-19 | C-07 |
| P1C-20 | C-34 |
| P1C-22 | C-30 |
| P1C-25 | C-32 (+ P1C-01) |
| P1C-26 | C-24 |
| P1C-28 | C-23 |
| P1C-30 | C-37 |
| P1C-31 | C-22 |
| P1C-36 | C-16 |
| P1C-38 | C-09 |
| P1C-40 | C-21 |

**Partial overlaps.** Beyond the items in the table:
* **P1C-04** reduces to a dependency on C-01 and C-39.
* **P1C-09** keeps only the hedges that C-11(i) and C-28 do not cover.
* **P1C-23** keeps only the statement of conventions; the decidedness of x* is C-33.
