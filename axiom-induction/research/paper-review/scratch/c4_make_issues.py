"""Build issues-consistency.json and the numbered issue list for review-consistency.md.

Run: python3 c4_make_issues.py  (writes ../issues-consistency.json and c4_issue_list.md)
"""
import json, os

HERE = os.path.dirname(os.path.abspath(__file__))
P = "paper/sections/"

issues = [
# ---------------------------------------------------------------- fatal
dict(id="C-01", file=P+"abstract.tex; "+P+"intro.tex",
 label_or_line="abstract.tex line 3 ('First, closed instances never favour ...'); intro.tex line 53 (A2 heading and first sentence)",
 severity="fatal",
 problem="The abstract and answer A2 state without qualification that closed instances never favour forall x phi over its instance schema, and that the odds 'stay at the prior odds or fall by a constant factor per datum'. The body proves this only for the calculi and likelihoods listed in thm:univ:B and states an exception: under the stream filter Lsel with a background and learned weights the Bayes factor of B+forall x phi against B+sigma_phi tends to h(w*), which exceeds 1 for small w*. For calculi with conjunction rules the direction is open. Under strict L0 the odds drop to 0 at the first datum, which is neither 'stay' nor 'a constant factor per datum'.",
 evidence="universal.tex lines 82-86 (prop:univ:B2: Bayes factor -> h(w*) in [c,1/c], > 1 iff w* < sqrt(c)/(1+sqrt(c)); data i.i.d. from a law of B+sigma_phi, so the setting is well specified); universal.tex line 72 ('Not covered: Lsel with a background and learned weights (prop:univ:B2), and-detours, normalised likelihoods in C_U3'); rem:univ:detour line 79 ('whether detours can reverse the direction is open'); tab:univ:odds row L0 (strict): 0 for n >= 1. CLAIMS.md A2 keeps the exceptions ('non-logical and bounded (prop:univ:B2) or calculus-specific (rem:univ:detour)'); the intro mentions the and-detour exception but not B2, and the abstract mentions neither. See also MB-01 (same overstatement in the body of section 3).",
 fix="Abstract: 'First, in the calculi we analyse, closed instances never make forall x phi more probable than its instance schema, apart from a bounded drift under a selection-aware likelihood with learned weights: the odds stay at the prior odds, fall by a constant factor per datum, or drop to zero.' Intro A2: add 'apart from a bounded, non-logical drift under Lsel with learned weights and a background (prop:univ:B2)' next to the and-detour exception."),

dict(id="C-02", file=P+"intro.tex", label_or_line="tab:intro:verdicts, row H2 (line 77)", severity="fatal",
 problem="The verdict cell for H2 ('concentration on {T: P_T = P_T*}') reads 'confirmed for fixed weights; a.e. weight vector with Dirichlet weights'. This says that the concentration hypothesis holds for almost every weight vector under Dirichlet weights. The paper proves the opposite: with Dirichlet weights the exact generator class has posterior mass 0 at every n for all w* off a countable set. What holds for a.e. w* is identification of the instance union under L0.",
 evidence="ident.tex lines 83-85 (rem:ident:exact, status 'refuted; counter-statement proved'); thm:ident:limit(b) line 76 (instance union, L0, a.e. w*); sound.tex line 85 (rem:sound:vacuous). Source verdict, model notes-final §9.1 H2: 'Dirichlet weights: instance union identified for a.e. w*; the exact class has mass 0.'",
 fix="Replace the cell by: 'confirmed for fixed weights; with Dirichlet weights the exact class has mass 0 (rem:ident:exact), and the instance union is identified for a.e. w* under L0 (thm:ident:limit(b)); KL-minimisers for finite classes only'. Add rem:ident:exact and thm:ident:limit to the 'where' column."),

dict(id="C-03", file=P+"intro.tex", label_or_line="line 63 (A7, last clause)", severity="fatal",
 problem="'plain Lone is proved to charge only logarithmically (cor:time:log)' asserts a proved upper bound on what plain L1 charges. cor:time:log is a lower bound: plain L1 is proved to charge at least about the logarithm of the assigner's nondeterministic time. Whether it charges more is open, and the paper conjectures a polynomial charge (conj:time:poly).",
 evidence="time.tex line 170 (cor:time:log: '-ln P_T(phi_w) >= zeta s(m) - ln(C/Z_T)'); time.tex line 191 (rem:time:summary (4): 'Plain Lone is proved to charge at least zeta s(m) nats ... a polynomial charge is conj:time:poly'); discussion.tex line 20 states it correctly ('for plain Lone only a logarithmic charge is proved'); conj:time:poly line 182.",
 fix="'for plain Lone only a logarithmic charge is proved (cor:time:log); a polynomial charge is conjectured (conj:time:poly).'"),

# ---------------------------------------------------------------- major
dict(id="C-04", file=P+"abstract.tex", label_or_line="line 3 ('Second, with well-specified data the posterior concentrates on the theories with the data's law and identifies their theorems')", severity="major",
 problem="The abstract drops the hypotheses of the identification results. Concentration on the theories with the data's law is proved for fixed weights (setting W); with the paper's default Dirichlet weights the exact class has mass 0 and only the instance union is identified, for a.e. weight vector, under L0. Identification of the theorems needs L1 with parameters admissible (or L0). Under the selection-aware likelihood that the paper recommends, theorems are not identified (prior-share regime).",
 evidence="ident.tex def:ident:W line 23 ('fixed law P_T ... (fixed weights)'); thm:ident:doob; rem:ident:exact; thm:ident:limit(b); cor:ident:deductive and the paragraph after it (line 40); thm:univ:omega(b). Intro A4 (line 57) does carry the hypotheses.",
 fix="'Second, with well-specified data and fixed weights the posterior concentrates on the theories with the data's law and identifies their theorems (L1, parameters admissible) or their instances (L0), not the axioms; with learned weights the instance union is identified for almost every weight vector.'"),

dict(id="C-05", file=P+"abstract.tex; "+P+"intro.tex; "+P+"discussion.tex",
 label_or_line="abstract.tex line 3 ('the posterior then goes to the best-fitting generator'); intro.tex line 59 (A5); discussion.tex line 35",
 severity="major",
 problem="All three state as a general fact that under misspecification the posterior goes to the best-fitting generator. thm:ident:kl proves this for finite classes only, and rem:ident:fullclass says that in the full template class the KL-projection picture can fail (infimum KL 0 approached by unsound hybrids; conjecture: unsound mass -> 1). The intro's own 'What is not achieved (ii)' says the same, so A5 and the abstract contradict it.",
 evidence="ident.tex line 157 (thm:ident:kl: 'Let H be finite'); line 160 ('it need not describe the full template class'); rem:ident:fullclass line 177; intro.tex line 100 (ii); tab:intro:verdicts H2 ('KL-minimisers for finite classes only').",
 fix="Abstract: 'the posterior then goes, in finite classes, to the best-fitting generator'. Intro A5: 'In finite classes the posterior goes to the best-fitting generator (thm:ident:kl); in the full class even this can fail (rem:ident:fullclass).' Discussion line 35: same qualifier."),

dict(id="C-06", file=P+"abstract.tex", label_or_line="line 3 (last sentence)", severity="major",
 problem="'Adversarial referees with independent code checked the results; no human has.' The verification appendix says that results added in the revisions were not checked by a referee, and these include headline results quoted in the abstract and the intro (the averaged and shrinking-threshold soundness theorems, the symbol-size charge prop:time:sigma, the computability result prop:model:compute).",
 evidence="app-verification.tex line 17 ('Results added in the revisions were checked by their track and re-read by the section writers, but not by a referee; among them are ... model Thms 4.7, 4.8, ..., 6.14 ...'); app-ident.tex line 11; app-pa.tex line 12.",
 fix="'Adversarial referees with independent code checked the first versions; results added in revision were checked only by their tracks (Appendix H). No human has checked the mathematics.'"),

dict(id="C-07", file=P+"app-verification.tex", label_or_line="line 17 (paragraph 'What this means for the reader', list of unrefereed results)", severity="major",
 problem="The list of results added after the referee reports is incomplete, and it disagrees with the appendices that state the same fact. It omits model Props 2.7 and 2.8 (prop:model:compute, prop:model:max; new section §2.4 answering referee Q2), Rem 8.3 (rem:ident:nearmiss) and the new proof of Thm 5.1(b), which app-ident lists; it omits experiments Prop X11 (prop:pa:redundant), which app-pa lists; and it omits universal Lemma S1, the exact rates of U16(b), the new proof of U10(c3), U12(b) for f_q = 0 (Watson's lemma) and the two-part part of U14(c), and experiments' full proof of X8(c), all added in response to the referees. 'Among them are' hides the gap; a reader cannot tell which results are unrefereed.",
 evidence="model notes-final §2.4 heading '(new; referee Q2)'; model §12.1 rows Q2, Q6, M4; universal §15.1 rows M2 ('Lemma S1 ... Exact rates for Split_k and Both0'), M3, m5, m6; experiments §16.1 row M3 ('X8(c) proved in full'); app-ident.tex line 11; app-pa.tex line 12.",
 fix="Replace 'among them are' by a complete list compiled from the four verification logs (add model Props 2.7, 2.8, Rem 4.5, Rem 8.3, the proof of Thm 5.1(b); universal Lemma S1, U10(c3), U12(b) (f_q = 0), U14(c) (two-part), U16(b); experiments X8(c), X11), and make app-ident and app-pa refer to this list instead of keeping their own."),

dict(id="C-08", file=P+"intro.tex", label_or_line="line 61 (A6, heading and 'Misspecified, a waiting prover wins with probability 1')", severity="major",
 problem="The heading 'The thresholded verifier is sound only for well-specified data' and the sentence 'Misspecified, a waiting prover wins with probability 1' turn one example into a general statement. The body shows a single misspecified setting in which a waiting prover wins with probability 1, a misspecified setting in which the verifier is merely incomplete, and computed misspecified settings (E4 C2, C3) in which the prover never won. What is proved is that soundness is guaranteed only under well-specification.",
 evidence="sound.tex line 16 ('Under misspecification there is no guarantee; in an example a waiting prover wins with probability 1'); prop:sound:misspec line 49 ('In the setting of ex:ident:escape'); sound.tex line 56 ('Misspecification can also make the verifier incomplete instead'); rem:sound:e4 line 128 ((C2) 0/100, (C3) 0/100).",
 fix="Heading: 'The thresholded verifier is guaranteed sound only for well-specified data.' Sentence: 'Misspecified, there is no guarantee: in an example a waiting prover wins with probability 1 (prop:sound:misspec).'"),

dict(id="C-09", file=P+"intro.tex; "+P+"discussion.tex", label_or_line="intro.tex line 61 (A6); discussion.tex line 29 (good version, 'Output') and line 33",
 severity="major",
 problem="The shrinking-threshold theorem is quoted as the soundness guarantee for learned weights in general, and the discussion builds it into the recommended 'good version'. thm:sound:shrink requires a likelihood linear in the weights (L0, or the experiments' chain); its proof uses lem:sound:regret(a), which needs linearity. The good version's likelihood is a derivation grammar (L1, or L^sigma), in which a tree citing several theory axioms carries a product of weights and Z_T depends on w, so it is not linear in w. For that likelihood only the averaged theorem (thm:sound:avg) applies.",
 evidence="sound.tex line 109 (thm:sound:shrink: 'a likelihood linear in w (L0; also the experiments' chain C_ch(J))'); app-sound.tex line 124 ('by lem:sound:regret(a), which needs the likelihood to be linear in w'); def:model:lone line 142 (citation by w_tau at each theory-citation node); discussion.tex line 28 (the good version's likelihood is L1 / L^sigma).",
 fix="Intro A6: 'With Dirichlet weights this holds on average over the weights (thm:sound:avg), or, for likelihoods linear in the weights, with a threshold shrinking in n (thm:sound:shrink).' Discussion line 29: 'with a threshold that shrinks with n when the weights are learned and the likelihood is linear in them; for a derivation likelihood only the averaged guarantee is proved.'"),

dict(id="C-10", file=P+"discussion.tex", label_or_line="line 33 ('What it can promise') against line 28 (the good version's likelihood)", severity="major",
 problem="The good version includes 'a model of which theorems get reported, by a known filter (Lsel) or a prior over filters', and the next paragraph promises for it 'identification of the theorem set under Lone with parameters admissible'. With a selection-aware likelihood the theorem set is exactly what is not identified: under Lsel, Hall and Hsch have the same law and the provability of forall x phi tends to a prior share. The promise list holds for plain L1, not for the version the section recommends.",
 evidence="thm:univ:omega(b) (universal.tex line 135: 'Hall, Hsch under Lcl or Lsel' give a limit in (0,1)); tab:univ:c5 (Lsel row stays at 0.750); discussion.tex line 35 itself ('It cannot certify forall x phi from closed instances').",
 fix="In 'What it can promise' say which component each guarantee needs: 'with plain L1 (parameters admissible) the theorem set is identified; with a selection model only the reported part Th(T) cap S is, and deductive questions beyond S keep their prior share (thm:univ:omega(b)).'"),

dict(id="C-11", file=P+"intro.tex", label_or_line="line 63 (A7: 'Templates block his schema but not the collapse')", severity="major",
 problem="The intro drops the hypotheses of prop:time:collapse. That result needs background PA and covers only Sigma_n-sound assigners on Sigma_n sentences; for merely consistent assigners (the class in Haenni's equivalence) the reflection sentence can be inconsistent with PA. The discussion (line 16) and rem:time:summary(2) keep at least 'in arithmetic'; the intro does not.",
 evidence="prop:time:collapse (time.tex lines 89-97); time.tex line 99 ('for merely consistent assigners rho_{f,n} can be inconsistent with PA'); discussion.tex line 16 ('in arithmetic one ground reflection sentence reproduces any Sigma_n-sound assigner'). See also MB-05 for time.tex.",
 fix="'Templates block his schema (prop:time:notemplate), but over PA one ground reflection sentence reproduces any Sigma_n-sound assigner on Sigma_n sentences (prop:time:collapse).'"),

dict(id="C-12", file=P+"intro.tex; "+P+"discussion.tex", label_or_line="intro.tex line 63 (A7); discussion.tex line 20 ('The charge lies between ...')",
 severity="major",
 problem="The same result is stated in two incompatible ways. Intro A7 and the discussion say that symbol-size penalties charge a hard assigner 'between its nondeterministic time and its deterministic time'. time.tex says that they charge 'a polynomial root of t(m)', t the nondeterministic time, and that is what prop:time:sigma with thm:time:ntime gives: derivation size l forces X in NTIME(l^c), so the charge is at least t^(1/c), not t.",
 evidence="time.tex line 173 ('symbol-size penalties charge a polynomial root of t(m)'); thm:time:ntime line 114 (X in NTIME(l(m)^{c_e})); prop:time:sigma(b) line 177 (kappa s(m)/4 with X outside NTIME(s^{c_1})). MB-06 flags the same wording in rem:time:summary(3).",
 fix="Use one statement everywhere: 'charges at least a fixed polynomial root of the assigner's nondeterministic time (proved for template theories) and, for the collapse constructions, at most a polynomial of its deterministic time (proof sketch).'"),

dict(id="C-13", file=P+"intro.tex", label_or_line="line 57 (A4: 'a derivation likelihood does not change the MDL finding of AS: a schema and its root split tie at matched weights and differ by Occam terms with learned weights')",
 severity="major",
 problem="The justification given is incomplete in the way that matters. The MDL finding is that MDL tracks usage statistics; what preserves it under a derivation likelihood is that the split still wins linearly when the instantiation grammar misfits the usage (prop:ident:splitlzero(d), prop:ident:splitlone(c)). The intro cites only the tie and the Occam terms, which read as if the posterior respected the schema's boundary.",
 evidence="rem:ident:mdl (ident.tex line 130: 'with usage that Qg misfits, it wins linearly under both ... when the instantiation model is misspecified, the posterior tracks usage, not the logical boundary of a schema'); discussion.tex line 16 ('told apart by Occam terms or by usage statistics').",
 fix="'... a schema and its root split tie at matched weights, differ by Occam terms with learned weights, and the split wins linearly when the grammar misfits the usage (rem:ident:mdl).'"),

dict(id="C-14", file=P+"intro.tex", label_or_line="tab:intro:verdicts, row H7 (line 86: 'no r.e. theory survives Th(N)')", severity="major",
 problem="prop:pa:thn covers consistent r.e. theories. Inconsistent r.e. theories derive every sentence and, without a refutation rule, are never removed under a 0/1-support likelihood; with a computable rule they are removed only at growing depth.",
 evidence="prop:pa:thn (pa.tex line 165: 'every consistent r.e. theory has posterior 0 eventually'); prop:pa:refute (line 169: 'Without a refutation rule inconsistent theories are never refuted').",
 fix="'no consistent r.e. theory survives Th(N); inconsistent ones fall only to refutation at growing depth'."),

dict(id="C-15", file=P+"discussion.tex", label_or_line="line 35 ('It removes ... an inconsistent theory only by refutation (prop:pa:incons, prop:pa:refute)')", severity="major",
 problem="This contradicts three body results. A false spare sentence makes T* + sigma inconsistent, and positive data remove that inconsistent theory like n^(-1/2) (rem:ident:sparetotal), with no refutation. Inconsistent templates such as the bare formula metavariable die within a few data under generative likelihoods (prop:univ:hanni, tab:univ:inc, rem:sound:belc). prop:pa:incons says only that the size principle charges inconsistency no more than a spare slot, and it is proved for the two-part likelihood, not for L1.",
 evidence="ident.tex line 148 (rem:ident:sparetotal); universal.tex line 147 and tab:univ:inc; sound.tex line 188; pa.tex line 266 (prop:pa:incons, 'Under Lmax'); app-verification.tex line 204, item (7) (prop:pa:incons under the normalised L1 is open). The same discussion sentence also says the false spare is removed 'only polynomially', so the two clauses describe the same theory differently.",
 fix="'It removes a false spare sentence, and with it the inconsistent theory T* + sigma, only polynomially (prop:ident:spare, rem:ident:sparetotal): the size principle does not charge inconsistency as such (prop:pa:incons), so certifying consistency needs refutation at growing depth (prop:pa:refute).'"),

dict(id="C-16", file=P+"time.tex; "+P+"app-time.tex; "+P+"model.tex",
 label_or_line="prop:time:twosorted (time.tex line 62, status 'Sigma_1-completeness of Q known'); app-time.tex line 34; model.tex lines 20 and 24 (L_A contains <, Q has no axiom for <)",
 severity="major",
 problem="Cross-track inconsistency left unreconciled. The model track's Prop 6.2 (and the proof of Prop 6.3) uses Sigma_1-completeness of Q for Acc_f(code(phi)). The universal track found, and the paper's own correction table records, that in L_A with < and no Q axiom about <, Q is Sigma_1-complete only for <-free sentences (Q does not prove 0 < S0). The paper never says that Acc_f and Rej_f are written without <, or that < is defined by Dlt in B.",
 evidence="app-verification.tex line 55 ('Sigma_1-completeness of Q restricted to <-free sentences (m2)'); universal notes-final lines 388-391 and §15.1 m2; model notes-final line 886 (no restriction); model.tex line 20 (L_A = {0,S,+,.,<,=}) and line 24 (Q1-Q7 do not mention <); time.tex line 59 ('a Sigma_1 formula of arithmetic ... (via Kleene's T predicate)').",
 fix="In time.tex line 59 add: 'written without <, bounded quantifiers being expressed by exists z (x+z=y), so that Sigma_1-completeness of Q applies' (or put Dlt into B), and add this to the status note of prop:time:twosorted and to the proof in app-time. Record the reconciliation in tab:ver:conflicts."),

dict(id="C-17", file=P+"app-verification.tex", label_or_line="tab:ver:corrections (lines 37-75) and the sentence at line 22 ('lists every claim of the first versions that was refuted or weakened')",
 severity="major",
 problem="The table does not list every correction in the four verification logs, although the text says it does. Missing: model m5 (check c9 was tautological for the split; replaced by c9b); pa m10 (the toy tower covers only the provable part of the data, a scope restriction) and the accepted part of m11 (two-part bounds, now Rem 5.4); experiments m1 (the 'brute force' tests shared code with the implementation; independent reference test added), m3 (citations of superseded drafts), m9 (summary wording), m13 (fallback counters not reported) and m14 (the E5(a2) slope, first reported as -0.259 from 200 draws, now -0.251 +- 0.002). Only the last appears elsewhere (tab:exp:e5 caption).",
 evidence="model notes-final §12.1 row m5; pa notes-final §9.1 rows m10, m11; experiments notes-final §16.1 rows m1, m3, m9, m13, m14; app-experiments.tex line 146 (caption of tab:exp:e5: 'the first version reported -0.259 from 200 draws').",
 fix="Add the missing items to the 'weakened' rows of each track (one clause each), or change line 22 to say that minor wording and evidence fixes are omitted and name which."),

# ---------------------------------------------------------------- minor
dict(id="C-18", file=P+"abstract.tex", label_or_line="line 3 (''the axioms prove forall x phi' tends to a prior share or to zero')", severity="minor",
 problem="This is the well-specified statement (thm:univ:omega(a)). Under misspecification (unmodelled selection, no guard) the limit is class-dependent and can be 1 over Q (prop:univ:noguard(b), (d); prop:univ:sentences(d)). Intro A3 says so; the abstract does not, and the abstract's caveat sentence speaks only of 'positive guarantees'.",
 evidence="intro.tex line 55 ('or, when the likelihood ignores how the data were selected, to a class-dependent limit'); prop:univ:noguard(b) ('= 1 at every n without them'); tab:univ:noguard (1.000 over Q to n = 10^12).",
 fix="'... tends to a prior share or to zero when the data are well specified, and to a class-dependent limit when the selection is not modelled'."),

dict(id="C-19", file=P+"intro.tex", label_or_line="tab:intro:verdicts, row H4(a) (line 79)", severity="minor",
 problem="The 'where' column cites only prop:univ:memo, which carries the memorisation half of the verdict. The over-general half ('confirmed') rests on thm:univ:size.",
 evidence="universal.tex line 113 ('proved for over-general templates' via thm:univ:size).",
 fix="Cite thm:univ:size,prop:univ:memo."),

dict(id="C-20", file=P+"intro.tex", label_or_line="tab:intro:verdicts, row H5 (line 84, 'spares cost approx. 1/2 log n'); A9 (line 67, 'decays only like n^{-1/2}'); A2 (line 53, memoriser class 'exp(-O(ln^2 n))')",
 severity="minor",
 problem="Bare log without unit, against NOTATION §1 ('never a bare \\log'; every code length carries its unit). The n^{-1/2} rate and the 1/2 log2 n cost hold for Dirichlet(1/2) weights; with fixed weights spares decay exponentially. The memoriser-class rate needs Laplace weights (prop:univ:memo(ii')). Hypotheses dropped in the summary (compare MA-10, MA-13).",
 evidence="prop:ident:spare(a) line 138 ('at alpha_sigma = 1/2, 1/2 log2 n bits'); rem:ident:sparetotal ('With fixed weights the factor is (1-w_sigma)^n'); prop:univ:memo(ii') line 110 ('Laplace weights').",
 fix="H5: 'spares cost about 1/2 log2 n bits (Dirichlet(1/2) weights)'. A9: 'with Dirichlet(1/2) weights a spare slot ... decays only like n^{-1/2}'. A2: 'the memoriser class with Laplace weights, under a geometric numeral law, ...'."),

dict(id="C-21", file=P+"intro.tex", label_or_line="line 101 ('What is not achieved' (iii))", severity="minor",
 problem="The list of conjectured rates omits the universal-track conjectures that OUTLINE §1 item 5 requires (the limits of prop:univ:noguard(d) and prop:univ:sentences(d), and prop:univ:memo(iii)); app-verification lists them.",
 evidence="OUTLINE.md §1 item 5; app-verification.tex lines 176-177.",
 fix="Add 'the over-Q limits of the split races (prop:univ:noguard(d), prop:univ:sentences(d)) and the memoriser rate (prop:univ:memo(iii))'."),

dict(id="C-22", file=P+"experiments.tex", label_or_line="tab:exp:e1 caption (line 65: 'Means over 5 seeds and, where the three formulas agree, over phi')",
 severity="minor",
 problem="The table averages over phi also where the formulas disagree. In the L1sel row the generator mass is 0.391/0.391/0.515 at n=4 (mean 0.43) and 0.516/0.516/0.731 at n=256 (mean 0.59); in the allq/L1 row 0.764/0.764/0.649 (mean 0.73). The caption's condition is not what was done.",
 evidence="code/results/e1_universal.md (generator sch L1sel; allq L1), recomputed by scratch/c1_e1_table.py.",
 fix="Caption: 'Means over 5 seeds and over the three formulas (per-formula values in code/results/e1_universal.md)', or give the L1sel row per formula as for the P(|-) column."),

dict(id="C-23", file=P+"ident.tex", label_or_line="tab:ident:misspec, rows 'instances: numerals only; finite set' (line 207) and 'small n, rarely cited axioms' (line 217)",
 severity="minor",
 problem="(i) The row lists L0 and L1 for both outcomes, but Mem(D_n) on the finite selected support appears only under L0 at n = 1024; L1 was run to n = 512, where Hsch is still the MAP. (ii) 'unsound lumps (E2: 5/25 seeds)' gives the count of seeds in which a verifier accepted a false probe; the posterior landed on an unsound MAP in 7/25 seeds at n = 8 (5/25 at n = 16).",
 evidence="code/results/e3_misspec.md (generator small: L0 MAP Mem at 1024; L1 table ends at 512 with H_sch); code/results/e2_pa.md legacy-vs-causal table ('unsound MAP, causal' 7/25 at n = 8, 5/25 at n = 16; 'accepting seeds' 5/25 at some n <= 64).",
 fix="(i) Write 'L0 (L1 to n = 512)' and 'Mem(D_n) (L0, n = 1024)'. (ii) 'unsound lumps (E2: unsound MAP in 7/25 seeds at n = 8; false acceptance in 5/25)'."),

dict(id="C-24", file=P+"pa.tex", label_or_line="rem:pa:merge (line 256)", severity="minor",
 problem="Conflict C14 asks for the rate of the forall-elimination penalty 'with scopes' under each rule law. The remark gives the fixed code, the learned depth-indexed code and mixed practice, but omits the learned shared code, which is linear (2 bits per datum at n = 10^6 in tab:pa:rulecode).",
 evidence="CLAIMS.md C14 and rem:pa:merge entry ('learned shared 2000004 bits at 10^6'); tab:pa:rulecode (app-pa.tex line 205).",
 fix="Add 'linear under a learned rule law shared across depths (tab:pa:rulecode)'."),

dict(id="C-25", file=P+"sound.tex; "+P+"experiments.tex", label_or_line="sound.tex line 134 (rem:sound:lumps: 'R_{1/2}(n,8)'); sound.tex lines 41, 85 ('W*'); experiments.tex lines 142-144 and tab:exp:e4 ('w*' = prior of T*)",
 severity="minor",
 problem="Notation drifts from NOTATION.md. rem:sound:lumps writes R_{1/2}(n,8) (the model track's name) where experiments.tex writes \\Rreg(n,8) for the same quantity. rem:sound:tight and rem:sound:vacuous write W* for W*_d. In E4, w* denotes the prior mass of T*, while NOTATION and thm:sound:shrink in the same paper use w* for the true weight vector; 'delta = w* delta'' for a one-component T* then reads as delta = delta'.",
 evidence="NOTATION.md §3 rows '(T,w), w_tau, w*' and '\\Rreg(n,K)'; experiments.tex line 142 ('when delta = w* delta''), line 144 ('w* = 7*10^-6 (the pool version ...)'); app-experiments.tex tab:exp:e4 column 'w*'.",
 fix="Use \\Rreg(n,8) in rem:sound:lumps, W*_d throughout, and pi(T*) (or 2^{-bits(T*)}) for the prior mass of T* in E4 and tab:exp:e4."),

dict(id="C-26", file=P+"universal.tex; "+P+"sound.tex; "+P+"pa.tex; "+P+"ident.tex",
 label_or_line="universal.tex line 110 (\\DirMult), line 113 (\\Mem); sound.tex line 67 (\\Hk{k}, \\Acc_k), line 134 (\\SeenQ); pa.tex line 252 (\\SeenQ), line 237 (T_{L_infty}); ident.tex line 209 (T_E, T_N); experiments.tex line 27 (\\Qelim); app-pa.tex line 149 (Q^-)",
 severity="minor",
 problem="Symbols used before their definition or never defined: DirMult (defined in ident.tex line 108, used earlier in prop:univ:memo); Mem(D_n) (first used universal.tex line 113, defined only in experiments.tex line 29); SeenQ and Trim (used in sound.tex and pa.tex, defined in section 8); H_k and Acc_k (only 'AS Def 2.6'); the elimination-term law Qelim (never defined); T_E, T_N (only in app-pa); T_{L_infty} ('AS Prop 5.12'); Q^- (never defined). In ident.tex R_n is the spare-slot ratio while tab:ident:misspec in the same section uses R_m for numeral splits.",
 evidence="grep of the section files in reading order; NOTATION.md §3, §7 (where each symbol should be defined).",
 fix="Define Mem(E) and DirMult at first use (or in section 2), give one sentence each for SeenQ/Trim, H_k, Acc_k, Qelim, T_E/T_N, T_{L_infty}, Q^- where first used, and rename the spare ratio (e.g. R^spare_n)."),

dict(id="C-27", file=P+"universal.tex; "+P+"pa.tex; "+P+"time.tex",
 label_or_line="universal.tex lines 72, 181, 198 (prop:univ:sim, lem:univ:waste, prop:univ:rk, prop:univ:eqfrag); pa.tex lines 172, 182, 188, 194, 210 (rem:pa:tower, rem:pa:pointwise, lem:pa:motive, rem:pa:shift, prop:pa:fragments, prop:pa:redundant); time.tex line 99",
 severity="minor",
 problem="These results are used in the main text as if stated there, but are stated only in the appendices, against the ledger's section column ('univ / app', 'pa / app': statement in the section, proof in the appendix). prop:univ:eqfrag is described in prose in section 3 with a \\Cref that sends the reader to Appendix B for the statement.",
 evidence="CLAIMS.md rows prop:univ:sim, lem:univ:waste, prop:univ:rk, prop:univ:eqfrag, lem:pa:motive, prop:pa:fragments, prop:pa:redundant, rem:pa:pointwise, rem:pa:tower, rem:pa:shift (section 'univ / app' or 'pa / app'); c3_status2.out (environment locations).",
 fix="Either move the statements into the sections (short) or write 'stated and proved in app:univ' at each main-text use, and update the ledger's section column."),

dict(id="C-28", file=P+"pa.tex; "+P+"app-pa.tex", label_or_line="pa.tex line 106 (unlabelled refuted remark); tab:pa:merge (app-pa.tex line 190)", severity="minor",
 problem="The refuted 'constant margin' remark has no label, so app-verification points to prop:pa:occam instead of the refuted claim. tab:pa:merge, the evidence for rem:pa:merge, is never referenced.",
 evidence="Label/reference cross-check (labels never referenced include tab:pa:merge); app-verification.tex line 59.",
 fix="Label the remark (rem:pa:sdpcrefuted) and cite it in tab:ver:corrections; cite tab:pa:merge in rem:pa:merge."),

dict(id="C-29", file=P+"universal.tex", label_or_line="line 8 ('All results are from the universal track')", severity="minor",
 problem="The section also states rem:univ:B2cit (an editor's reconciliation from experiments §1.7 and Prop X6(b)) and reports E1 and E3(a) numbers from the experiments track.",
 evidence="rem:univ:B2cit \\src{editor, from experiments ...}; universal.tex lines 96 and 189.",
 fix="'Results are from the universal track unless the source note says otherwise; E1 and E3(a) numbers are from the experiments track.'"),

dict(id="C-30", file=P+"model.tex", label_or_line="tab:model:calculi caption (line 69: 'The direction (factor at most 1) is proved for C_min and C_U3 (thm:univ:B)')",
 severity="minor",
 problem="For C_U3 thm:univ:B(B3) covers only mu_T, Lmax and the scores; normalised likelihoods in C_U3 are listed as not covered. The caption states the direction for C_U3 without the restriction (the table row says 'trees, mu_T', which a reader may not connect to the caption).",
 evidence="universal.tex line 69 (B3) and line 72 ('Not covered: ... normalised likelihoods in C_U3').",
 fix="'... is proved for C_min (all listed likelihoods) and, unnormalised, for C_U3 (thm:univ:B) ...'."),

dict(id="C-31", file=P+"app-universal.tex", label_or_line="tab:univ:inc caption (line 137)", severity="minor",
 problem="Conflict C26 requires every table to state the Dirichlet alpha. This table uses the class of tab:univ:c2 (alpha = 1 in c2) but was computed by c10(d), and the appendix convention is alpha = 1/2 for c8-c10; the caption does not say which.",
 evidence="CLAIMS.md C26; app-universal.tex line 9 ('Dirichlet alpha = 1 in c2-c7, alpha = 1/2 in c8-c10').",
 fix="State alpha in the caption."),

dict(id="C-32", file=P+"ident.tex; "+P+"app-pa.tex; "+P+"sound.tex",
 label_or_line="rem:ident:nearmiss (ident.tex line 237); rem:pa:pointwise (app-pa.tex line 112); rem:pa:shift (app-pa.tex line 135); ex:sound:constant (sound.tex line 118, \\src)",
 severity="minor",
 problem="Status and source notes differ from the ledger: rem:ident:nearmiss, rem:pa:pointwise and rem:pa:shift drop the 'open' part of their ledger status (the text keeps it); ex:sound:constant cites 'experiments Prop X8' where the ledger cites the check check_fixed_weight (X8 does not contain the example).",
 evidence="CLAIMS.md rows rem:ident:nearmiss ('proved (transfer); open'), rem:pa:pointwise ('proved; open'), rem:pa:shift ('proved; computed (checked); open'), ex:sound:constant (source 'experiments check_fixed_weight'); scratch/c3_status2.out.",
 fix="Add '; open' to the three statuses and change the source of ex:sound:constant to 'model Ex 4.9; experiments check_fixed_weight'."),

dict(id="C-33", file=P+"discussion.tex", label_or_line="line 40 ('\"making some mistakes\" is a noise mixture, harmless for soundness only if the noise model is part of the well-specified generator (E4(C1) in rem:sound:e4)')",
 severity="minor",
 problem="E4(C1) does not illustrate a noise mixture: there the mistakes are a schema z+0=Sz inside a pool theory, which changes the theory's theorems, and the verifier accepts falsehoods in 100/100 streams. The supporting source for 'harmless if the noise model is part of the generator' is the model track's remark on noise mixtures (Thm 4.1 transfers) and rem:ident:nearmiss.",
 evidence="rem:sound:e4 (C1) and tab:exp:e4 (MAP 'Hsch with the mistake schema'); model notes-final §9.3 ('allow some mistakes': Theorem 4.1 still holds if the noise model is part of the well-specified generator); rem:ident:nearmiss.",
 fix="Cite rem:ident:nearmiss and prop:univ:robust for the positive statement and E4(C1) as the counter-case: 'if the mistakes are modelled as axioms (E4(C1)) the verifier accepts them'."),

dict(id="C-34", file=P+"app-verification.tex", label_or_line="tab:ver:corrections, pa rows (lines 58, 61, 62)", severity="minor",
 problem="The pa rows name items by their first-version numbers (Prop 3.5(c), §4.5) while every grey source note in the paper uses the final numbering (pa Prop 4.6, §5.5). A reader cannot match 'Prop 3.5(c)' to the cited notes-final.md, where it appears only as 'old Prop 3.5(c)'.",
 evidence="pa.tex line 184 (\\src{pa Prop 4.6; referee M4, m7}); pa notes-final §9.4.",
 fix="Use final numbering with the old one in parentheses: 'Prop 4.6(c) (old 3.5(c)), F8; M4', '§5.5 (old §4.5)'."),

dict(id="C-35", file=P+"app-verification.tex", label_or_line="app:ver:sketches (lines 171-201)", severity="minor",
 problem="The lists are incomplete: the conjecture that a deeper nesting would win on heavy-tailed data (experiments.tex line 138); the heuristic waiting times of the I-Sigma_n chain in prop:ident:gold (ident.tex line 95; only those of prop:pa:isigma are listed); the 'eventual behaviour' sketch of ex:pa:euler (its status names both sketches; only 'covering' is listed); the rate '(prior ratio/delta_r)^{1/alpha} data' of rem:ident:sparetotal, which rests on the sketch of prop:ident:spare(b) (cf. MA-25).",
 evidence="ex:pa:euler status 'computed; proof sketch (covering, eventual behaviour)'; experiments.tex line 138 '(conjecture)'; ident.tex line 95 '(a heuristic)'.",
 fix="Add the four items."),

dict(id="C-36", file=P+"app-verification.tex", label_or_line="app:ver:refs (line 209)", severity="minor",
 problem="The list of references not verified against their sources omits doob1949application (bibliographic data confirmed only through a secondary bibliography; the theorem is cited, not read), krichevsky1981performance (the KT rate is cited as known; pa's log: 'standard, not re-checked') and rylln1952axiomatizability (data copied from AS's bibliography).",
 evidence="bib/ident.bib comment on doob1949application; pa notes-final §9.2 'references' row; NOTATION.md §11 table.",
 fix="Add the three entries with what was checked."),

dict(id="C-37", file=P+"discussion.tex", label_or_line="sec:disc:open (lines 50-62; 'collected ... and deduplicated')", severity="minor",
 problem="Two open problems of the model track that the paper itself states as open are missing: whether equal instance sets (or laws) imply equivalence for single DT templates (model §10 problem 8; ident.tex line 61 'this converse is open') and for which assigners a Craig set is a finite union of DT templates (problem 15; app-time.tex line 156).",
 evidence="model notes-final §10 items 8, 15; prop:ident:splits(c); app-time.tex line 156.",
 fix="Add both to items 2 or 6."),

dict(id="C-38", file="paper/main.pdf", label_or_line="whole paper (main text pp. 5-60, appendices pp. 63-122)", severity="minor",
 problem="The main text runs to about 56 pages and the appendices to about 60, against the outline's targets of about 40 (cap 46) and 36 pages. Part of the excess is duplicated material (C-39 to C-42).",
 evidence="main.aux: sec:intro p. 5, sec:disc p. 57, app:model p. 63, app:ver p. 115; pdfinfo: 122 pages; OUTLINE.md 'Page budget'.",
 fix="Remove the duplicates listed in C-39 to C-42 and move secondary remarks (e.g. rem:univ:kreisel, rem:pa:overlap, rem:time:convention) to the appendices."),

# ---------------------------------------------------------------- duplication (minor)
dict(id="C-39", file=P+"intro.tex; "+P+"time.tex; "+P+"model.tex",
 label_or_line="intro.tex line 36; time.tex line 18; intro.tex line 34 and model.tex line 185", severity="minor",
 problem="Duplicated material: Haenni's collapse argument is quoted twice with the same quotations ('T(quoted-phi) = accept => phi', 'being an axiom of the right form is in fact decidable', 'a model of the phis ...'), and his score proposal is quoted in both the intro and section 2.",
 evidence="Direct comparison of the passages.",
 fix="Keep the full quotations in the intro and refer to sec:intro:note from time.tex and model.tex."),

dict(id="C-40", file=P+"sound.tex; "+P+"pa.tex; "+P+"ident.tex; "+P+"universal.tex; "+P+"time.tex; "+P+"experiments.tex; "+P+"app-ident.tex",
 label_or_line="E2: rem:sound:lumps, rem:pa:e2, rem:pa:lumps, experiments E2 (2); E4: rem:sound:e4 vs experiments E4; E6: rem:pa:e6, rem:ident:splitsL1, experiments E6; E8: rem:ident:e8, app-ident 'E8 windows' (line 145), experiments E8; E3(a): rem:ident:e3a, universal.tex line 189, experiments E3(a); E3(b): rem:pa:e3b, experiments E3(b); E5: ident.tex line 145, experiments E5(a); E7: rem:time:links(iii), rem:time:e7, experiments E7",
 severity="minor",
 problem="Duplicated material: each experiment's findings are written out in its section 8 paragraph and again, with the same numbers, in one to three thematic sections. The copies are consistent today (checked against code/results), but every later correction must be made in up to four places.",
 evidence="Numbers cross-checked in this review against code/results/e2_pa.md, e3_misspec.md, e4_ville.md, e5_gold.md, e6_equivalent.md, e7_prior.md, e8_split_l1.md.",
 fix="State each experiment's numbers once (section 8 or the thematic remark) and cite that place elsewhere in one clause."),

dict(id="C-41", file=P+"app-ident.tex; "+P+"app-sound.tex; "+P+"app-time.tex; "+P+"app-pa.tex",
 label_or_line="proof of rem:ident:exact (app-ident.tex line 75) and proof of rem:sound:vacuous (app-sound.tex line 80); proof of prop:time:notemplate (app-time.tex lines 47-60) and proof of prop:pa:refl (app-pa.tex line 110)",
 severity="minor",
 problem="Duplicated material: the same proof is written out twice in each pair. app-time's proof already ends with the reflection case.",
 evidence="Direct comparison: the affine-slice argument and the constant-body argument are repeated almost word for word.",
 fix="Keep one proof of each and refer to it from the other appendix."),

dict(id="C-42", file=P+"ident.tex; "+P+"sound.tex; "+P+"app-ident.tex; "+P+"app-sound.tex; "+P+"pa.tex; "+P+"universal.tex; "+P+"discussion.tex",
 label_or_line="c4 misspecified run (ex:ident:escape; sound.tex line 56; app-ident.tex line 201; app-sound.tex line 44); spare formula 19.03/19.82 (prop:pa:spare; app-ident.tex line 152); Bel(forall x phi) approx. 0.69 (universal.tex line 150; rem:sound:belc); prior shares (universal.tex line 144; tab:univ:share; intro A3); the MDL quotation (rem:univ:mdl; ident.tex line 104; pa.tex line 91); the 'good version' (sec:univ:intuition line 224; sec:disc:good)",
 severity="minor",
 problem="Duplicated material: the same computed numbers or passages appear in two to four places.",
 evidence="Direct comparison of the passages.",
 fix="Keep one copy of each and cross-reference it."),
]

# sanity
ids = [i["id"] for i in issues]
assert len(ids) == len(set(ids))
for i in issues:
    for k in ("id", "file", "label_or_line", "severity", "problem", "evidence", "fix"):
        assert i.get(k), (i["id"], k)
    assert i["severity"] in ("fatal", "major", "minor")

with open(os.path.join(HERE, "..", "issues-consistency.json"), "w") as f:
    json.dump(issues, f, indent=1, ensure_ascii=False)

lines = []
for n, i in enumerate(issues, 1):
    lines.append(f"{n}. **{i['id']}** ({i['severity']}). `{i['file']}`, {i['label_or_line']}.  ")
    lines.append(f"   *Problem.* {i['problem']}  ")
    lines.append(f"   *Evidence.* {i['evidence']}  ")
    lines.append(f"   *Fix.* {i['fix']}")
    lines.append("")
with open(os.path.join(HERE, "c4_issue_list.md"), "w") as f:
    f.write("\n".join(lines))

from collections import Counter
print(len(issues), Counter(i["severity"] for i in issues))
