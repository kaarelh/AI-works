#!/usr/bin/env python3
"""Lead editor: merge the five reviews' issues into four group issue files and a rejected list.

Reads research/paper-review/issues-*.json; writes research/paper-review/edits/{front,model-ident-sound,
univ-time,pa-exp}-issues.json, rejected.json, and the merge map (appended to DECISIONS.md section 14).
Deterministic; no randomness. Run: python3 -I lead_make_edits.py (from any directory).
"""
import json, os, glob, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REVIEW = os.path.dirname(HERE)
EDITS = os.path.join(REVIEW, "edits")

orig = {}
for f in sorted(glob.glob(os.path.join(REVIEW, "issues-*.json"))):
    for i in json.load(open(f)):
        assert i["id"] not in orig, i["id"]
        i["_review"] = os.path.basename(f)
        orig[i["id"]] = i

ORIG_FIX = "orig"   # use the reviewer's fix verbatim
groups = {"front": [], "model-ident-sound": [], "univ-time": [], "pa-exp": []}
rejected = []


def add(group, gid, sources, file, loc, sev, verdict, fix, note=None, problem=None, evidence=None):
    for s in sources:
        assert s in orig, s
    if problem is None:
        problem = " ".join(("[%s] " % s if len(sources) > 1 else "") + orig[s]["problem"] for s in sources)
    if evidence is None:
        evidence = " ".join(("[%s] " % s if len(sources) > 1 else "") + orig[s]["evidence"] for s in sources)
    if fix == ORIG_FIX:
        fix = " ".join(("[%s] " % s if len(sources) > 1 else "") + orig[s]["fix"] for s in sources)
    item = {
        "id": gid,
        "sources": sources,
        "file": file,
        "label_or_line": loc,
        "severity": sev,
        "reviewer_severity": {s: orig[s]["severity"] for s in sources},
        "verdict": verdict,
        "problem": problem,
        "evidence": evidence,
        "fix": fix,
    }
    if note:
        item["verdict_note"] = note
    groups[group].append(item)


def reject(src, part, reason):
    rejected.append({"id": "REJ-%02d" % (len(rejected) + 1), "source": src, "file": orig[src]["file"],
                     "label_or_line": orig[src]["label_or_line"], "severity": orig[src]["severity"],
                     "reviewer_problem": orig[src]["problem"], "rejected_part": part, "reason": reason,
                     "where_the_rest_is_handled": ", ".join("%s:%s" % (g, i["id"]) for g, its in groups.items()
                                                            for i in its if src in i["sources"]) or "nowhere (fully rejected)"})


A, AM, P = "accepted", "accepted, fix modified", "partly accepted"
D = "DECISIONS.md"

# =====================================================================================================
# FRONT: abstract, intro, discussion, app-verification, preamble, main.tex
# =====================================================================================================
G = "front"
add(G, "F-01", ["C-01"], "paper/sections/abstract.tex; paper/sections/intro.tex",
    "abstract l.3 ('First, closed instances never favour ...'); intro A2 (l.57) heading and first sentence", "fatal", A,
    "Use the canonical wording of %s §9.1 (abstract: the binding text of §8.3; A2: the long form, shortened, keeping "
    "'in the comparisons analysed', the three odds regimes (stay / constant factor per datum / drop to zero), the "
    "non-logical L1^sel weight exception with a pointer to prop:univ:B2, and the open ∧-detour case). Verified: universal "
    "notes §4 'Not covered, or false' lists the L1-sel background case (fixed and learned weights) and ∧-detours; "
    "the paper's thm:univ:B covers neither." % D,
    note="Same overstatement as MB-01 in the body (univ-time U-01).")
add(G, "F-02", ["C-02"], "paper/sections/intro.tex", "tab:intro:verdicts, row H2 (l.81)", "fatal", A,
    "Replace the H2 cells by the binding text of %s §10.F1 (exact class mass 0 with Dirichlet weights; instance union "
    "a.e. under L0; KL-minimisers for finite classes only; where = thm:ident:doob, rem:ident:exact, thm:ident:limit, "
    "thm:ident:kl). The table itself moves to app:ver:process (F-20)." % D,
    note="Verified against model notes-final §9.1 H2 and rem:ident:exact (refuted; counter-statement proved).")
add(G, "F-03", ["C-03"], "paper/sections/intro.tex", "A7 (l.67), last clause", "fatal", A,
    "Replace 'plain L1 is proved to charge only logarithmically (cor:time:log)' by 'for plain L1 only a logarithmic "
    "charge is proved (cor:time:log); a polynomial charge is conjectured (conj:time:poly)'. A7 as a whole follows %s §9.6 "
    "(see F-12)." % D,
    note="cor:time:log is a lower bound (time.tex l.170; model notes Cor 6.13).")
add(G, "F-04", ["R-20"], "paper/sections/discussion.tex", "l.16 (sec:disc:proposal, 'Templates')", "fatal", A,
    "Replace the sentence by the binding text of %s §10.F3 (citation likelihood, Dirichlet sum and the two-step chain "
    "computed exactly over a pool; general derivation likelihood only a computable real with undecidable positivity)." % D,
    note="prop:exp:exact covers L0, the Dirichlet sum and C_ch(J) for checked shapes only; prop:model:compute(c).")
add(G, "F-05", ["C-04", "R-10"], "paper/sections/abstract.tex", "l.3 ('Second, with well-specified data ...'; key terms)",
    "major", A,
    "Replace the abstract by the binding text of %s §8.3 (fixed weights; theorems not axioms; the size principle glossed "
    "as 'theories predicting unobserved sentences lose a constant factor per datum'; ω-gap named after the statement it "
    "names). Keep ≤ 250 words." % D)
add(G, "F-06", ["C-05"], "paper/sections/abstract.tex; paper/sections/intro.tex; paper/sections/discussion.tex",
    "abstract l.3; intro A5 (l.63); discussion l.35", "major", A,
    "Use %s §9.4 everywhere: 'in finite classes the posterior goes to the best-fitting generator (thm:ident:kl); in the "
    "full class even this can fail (rem:ident:fullclass)'." % D)
add(G, "F-07", ["C-06"], "paper/sections/abstract.tex; paper/sections/intro.tex", "abstract l.3 (last sentence); intro l.115",
    "major", A,
    "Abstract: 'AI referees checked first versions; no human has checked the mathematics.' (binding §8.3). Intro §1.5 and "
    "the short answer item 10 use %s §9.9 (first versions refereed; revisions checked only by tracks and writers)." % D)
add(G, "F-08", ["C-07", "MA-21"], "paper/sections/app-verification.tex", "l.17 ('What this means for the reader', list of "
    "unrefereed results)", "major", A,
    "Replace 'among them are' by one complete list compiled from the four verification logs (model §12, universal §15, "
    "pa §9, experiments §16), adding at least: model Props 2.7, 2.8, Rem 4.5, Rem 8.3, the new proof of Thm 5.1(b), "
    "Props 5.5(d), 5.6, 6.11, 6.14, 7.6, 8.2, Lemmas 4.6, 6.10, Thms 4.7, 4.8, 6.12, Cor 6.13, Ex 3.6; universal Lemma S1, "
    "Lemma N0, Props N1-N3, B2, U2n, U2t, U10(e), the new proof of U10(c3), U12(b) for f_q = 0, U14(c) two-part part, "
    "U16(b) exact rates; pa Props 1.4, 2.3, 3.1-3.4, 4.8, Lemma 4.7, Rems 4.9, 5.4, the full proof of Prop 4.3; "
    "experiments Props X8(c) (full proof), X10, X11, X12, X13 and E8. Use the paper's labels next to the track numbers. "
    "app-ident, app-pa and app-sound replace their own lists by a pointer to this paragraph (MIS M-20, pa-exp P-24); "
    "check that the three appendices and this list agree.")
add(G, "F-09", ["C-08"], "paper/sections/intro.tex", "A6 (l.65), heading and 'Misspecified, a waiting prover wins with "
    "probability 1'", "major", A,
    "Heading: 'The thresholded verifier is guaranteed sound only for well-specified data.' Sentence: 'Misspecified, there "
    "is no guarantee: in an example a waiting prover wins with probability 1 (prop:sound:misspec); elsewhere the verifier "
    "is merely incomplete.' (%s §9.5)." % D)
add(G, "F-10", ["C-09"], "paper/sections/intro.tex; paper/sections/discussion.tex", "intro A6 (l.65); discussion l.29 "
    "(good version, 'Output') and l.33", "major", A,
    "Use %s §9.5: the shrinking threshold needs a likelihood linear in the weights (citation; the experiments' chain); for "
    "a derivation-grammar likelihood with learned weights only the averaged guarantee is proved. Discussion: binding text "
    "§10.F4." % D,
    note="Verified: thm:sound:shrink hypothesis 'a likelihood linear in w'; its proof uses lem:sound:regret(a) on T*'s "
    "law (app-sound l.124; experiments X8(c) termwise bound).")
add(G, "F-11", ["C-10"], "paper/sections/discussion.tex", "l.33 ('What it can promise') against l.28", "major", A,
    "Binding text %s §10.F4: say which component each guarantee needs; with a selection model only Th(T) ∩ S is "
    "identified and deductive questions beyond S keep their prior share (thm:univ:omega(b))." % D)
add(G, "F-12", ["C-11", "C-12"], "paper/sections/intro.tex; paper/sections/discussion.tex",
    "intro A7 (l.67: 'Templates block his schema but not the collapse'; 'between its nondeterministic time and its "
    "deterministic time'); discussion l.16 and l.20", "major", A,
    "Use %s §9.6 in A7, the short answer item 9 and discussion §9.1 ('Templates', 'A time penalty'): 'over PA', "
    "'Σ_n-sound assigners on Σ_n sentences', 'whether templates block the collapse for merely consistent assigners is "
    "open'; the charge is 'at least a fixed polynomial root of the nondeterministic time (proved, infinitely often, for "
    "theories with polynomial-time membership) and, for the collapse constructions, at most a polynomial of the "
    "deterministic time (proof sketch)'. Never 'between its nondeterministic and deterministic time' without 'a polynomial "
    "root of'." % D,
    note="Same wording fixed in time.tex rem:time:summary by univ-time (U-05, U-06).")
add(G, "F-13", ["C-13"], "paper/sections/intro.tex", "A4 (l.61): 'a derivation likelihood does not change the MDL finding "
    "of AS ...'", "major", A,
    "Use the MDL sentence of %s §9.3: tie at matched weights, Occam terms with learned weights, and a linear split win "
    "when the instantiation grammar misfits the usage, so the posterior tracks usage (rem:ident:mdl). In the reordered "
    "intro this sentence belongs to the 'templates' answer (%s §8.1)." % (D, D))
add(G, "F-14", ["C-14"], "paper/sections/intro.tex", "tab:intro:verdicts, row H7 (l.90)", "major", A,
    "Binding text %s §10.F1 (row H7): 'no consistent r.e. theory survives Th(N), and inconsistent ones are refuted only "
    "at growing depth'." % D)
add(G, "F-15", ["C-15"], "paper/sections/discussion.tex", "l.35 ('It removes ... an inconsistent theory only by "
    "refutation')", "major", A,
    "Binding text %s §10.F5 (with learned weights a false spare sentence, and the inconsistent T* ∪ {σ}, is removed only "
    "polynomially; the likelihood charges mass spent off the data, not inconsistency; certifying consistency needs "
    "refutation at growing depth)." % D,
    note="Wording adjusted from the reviewer's: added 'with learned weights' (with fixed weights the decay is "
    "exponential, rem:ident:sparetotal) and replaced 'the size principle does not charge inconsistency' by the precise "
    "statement (generative likelihoods do remove inconsistent theories that waste mass, tab:univ:inc).")
add(G, "F-16", ["C-17", "C-34"], "paper/sections/app-verification.tex", "tab:ver:corrections (l.37-75) and l.22",
    "major", A,
    "Add the missing items, one clause each, to the 'weakened' rows: model m5 (c9 tautological; c9b); pa m10 (toy tower "
    "covers only the provable part) and the accepted part of m11; experiments m1, m3, m9, m13, m14 (E5(a2) slope -0.259 "
    "→ -0.251 ± 0.002). Or change l.22 to say that minor evidence and wording fixes are omitted and name them. Use the "
    "final numbering in pa rows with the old one in parentheses (C-34: 'Prop 4.6(c) (old 3.5(c)), F8; M4'; '§5.5 (old "
    "§4.5)'). Also add rows for the corrections made in this revision that change a statement (%s §10: MB-01/02, MA-01/02, "
    "C1, C2, C-02, C-03, MA-03..09, MB-03..09, C3..C15), each one line citing the issue id, in tab:ver:writing." % D)
add(G, "F-16b", ["C-16"], "paper/sections/app-verification.tex", "tab:ver:conflicts", "major", A,
    "Record the reconciliation of Σ1-completeness of Q (restricted to <-free sentences; Acc_f, Rej_f written without <; "
    "model and universal tracks) as a row of tab:ver:conflicts. The statements are fixed by univ-time (U-10) and "
    "model-ident-sound (M-19).")
add(G, "F-17", ["R-01"], "paper/sections/intro.tex", "l.29-68 (sec:intro:note, sec:intro:reading, sec:intro:answers)",
    "major", A,
    "Insert the binding short answer of %s §8.2 directly after the verbatim question (framed box or quote). Restructure "
    "the intro as in §8.1; §1.1 at most a third of a page with no long quotations (they live in §2.6, §2.7, §6 and §9.3, "
    "%s §4)." % (D, D))
add(G, "F-18", ["R-02"], "paper/sections/intro.tex", "l.54-72 (A1-A9)", "major", AM,
    "Reorder the answers to follow the question (%s §8.1 item 6): version; ∀xφ; templates (new answer, text in §8.1); "
    "derivation-length prior; time; his last bullet as the binding 3×2 table of §8.1; side results (verifier, "
    "trichotomy) last." % D,
    note="The global reordering of sections proposed in the readability review (§3.1) is not adopted (rejected.json); "
    "only the intro's answers are reordered.")
add(G, "F-19", ["R-03"], "paper/sections/intro.tex", "A2 (l.57)", "major", A,
    "Add the generator-view numbers to A2 (they are also items 4-5 of the short answer): at c = 0.3 in C_min, {∀xφ} "
    "outputs ∀xφ itself with probability 1/(1+c) = 0.77 and each instance multiplies its odds against φ(z) by "
    "c/(1+c) = 0.23 (prop:univ:factor; tab:univ:odds row L1).",
    note="Numbers recomputed from the paper's own formulas (prop:univ:factor with Z_sch = 1-c, Z_all = (1-c)(1+c)).")
add(G, "F-20", ["R-05"], "paper/sections/intro.tex; paper/sections/discussion.tex; paper/sections/app-verification.tex",
    "tab:intro:verdicts (l.74-95); intro l.57, l.67; discussion l.20", "major", A,
    "Move tab:intro:verdicts (label unchanged) to app:ver:process, after the paragraph that introduces the brief, with "
    "the cell fixes F-02, F-14, C-19, C-20 and \\crefabbrev. Intro: one sentence with a pointer. Replace 'refutes the "
    "brief's H6/H4(a)' and similar phrases in intro and discussion by the claim itself (%s §6.2)." % D)
add(G, "F-21", ["R-06", "R-11"], "paper/sections/intro.tex", "l.47 (model paragraph); l.52 (blanket sentence); A1-A9",
    "major", A,
    "At most two \\cref per answer; no undefined symbols in the intro (C_min, L1^sel, 'closure reading', 'parameters "
    "admissible', C*_d, 'guard', 'hard assigner' either glossed in a clause or replaced by words); glosses of %s §6.3 for "
    "spare template, ω-gap, motive, DTRC; delete the blanket sentence l.52 and put the key hypothesis into each answer; "
    "remove the variant names L1^σ, L1^sel, L1^sel_cit from the model paragraph." % D)
add(G, "F-22", ["R-07", "C-42"], "paper/sections/intro.tex; paper/sections/discussion.tex", "A1 (l.55); discussion "
    "l.25-31", "major", P,
    "The recommended inducer is stated once, in full, in sec:disc:good (with the fixes F-10/F-11); A1 gives it in two "
    "lines of words with a pointer. universal.tex §3.9 keeps only what is specific to ∀xφ (univ-time). No boxed copy at "
    "the end of §2.",
    note="R-07's third copy (a box at the end of §2) rejected: it would recreate the duplication that C-42 and R-26 ask "
    "to remove.")
add(G, "F-23", ["R-08"], "paper/sections/intro.tex", "A6 (l.65)", "major", A,
    "Open the verifier answer with: 'Used as a proof checker, the posterior accepts a sentence when theories deriving it "
    "carry at least 1-δ of the mass; we ask whether a prover that adapts to the checker can get a non-theorem accepted.' "
    "Place it among the side results (F-18).")
add(G, "F-24", ["R-09"], "paper/sections/intro.tex", "A8 (l.69)", "major", A,
    "Write: 'on a computed stream of six library theorems, Q plus the theorems as axioms beats Q + T_Ind, and that theory "
    "is strictly weaker than PA (rem:pa:streams)'; keep 'within the candidates scored'. Use %s §9.8 for the rest." % D)
add(G, "F-25", ["R-13", "C-38", "R-35"], "paper/main.pdf; paper/main.tex; paper/sections/intro.tex; "
    "paper/sections/discussion.tex", "whole main text; front-group sections", "major", A,
    "Meet the targets of %s §2 for the front sections: intro 3.5 pp (cap 3.75), discussion 2.5 pp (cap 2.75). Set "
    "\\setcounter{tocdepth}{1} in main.tex (TOC one page; main text from p. 3). After all groups finish, run the final "
    "build and the page check of §2; report per-section spans in the changelog." % D)
add(G, "F-26", ["R-15", "C-39"], "paper/sections/intro.tex; paper/sections/discussion.tex", "intro l.36-40 "
    "(sec:intro:note); discussion l.40", "major", AM,
    "Quote Hänni's note once per item, in the canonical homes of %s §4 (collapse argument: time.tex §6; variants: "
    "model §2.6; trichotomy: §2.7; other ideas: discussion §9.3; polytime: conj:time:polytime). Intro §1.1: one sentence "
    "per item with a pointer, at most short phrases quoted. Discussion §9.3: point by point without re-quoting long "
    "passages." % D,
    note="C-39 proposed keeping the full quotations in the intro; rejected in favour of R-01/R-15 (the intro must reach "
    "the answer on page 1). See rejected.json.")
add(G, "F-27", ["R-26"], "paper/sections/discussion.tex", "l.14-35 (§9.1, §9.2)", "major", A,
    "Cut §9.1 to three short paragraphs that add interpretation only (no restated results beyond one canonical sentence "
    "each); §9.2 is the single statement of the good version (F-22); keep §9.3 (no long quotes), trim §9.4 by about 30%%, "
    "keep §9.5 with C-37's additions. Target 2.5 pp.")
add(G, "F-28", ["R-33", "R-34"], "paper/preamble.tex; paper/sections/intro.tex", "\\src (l.37), \\status (l.35); "
    "intro l.115", "major", A,
    "Apply the binding preamble code of %s §7 (\\emergencystretch, \\status with \\textup, breakable \\src, no-op "
    "\\identbrk/\\pabrk/\\expbrk, \\crefabbrev, citation aliases in \\AtBeginDocument). Land this first (it affects all "
    "builds). Intro l.115: 'as a small grey note'." % D)
add(G, "F-29", ["R-16", "C-28"], "paper/sections/app-verification.tex", "tab:ver:corrections; app:ver:sketches",
    "major", A,
    "App. H is the home of refuted first-version claims (%s §5). Make every row of tab:ver:corrections point to where the "
    "item now lives (rem:model:subcrit and the r6 numbers in App. A; rem:sound:hyp's refuted sentences in App. D; "
    "rem:exp:refuted in App. G; the constant-margin remark as rem:pa:sdpcrefuted in App. F, replacing the pointer to "
    "prop:pa:occam; tab:pa:merge cited by pa-exp)." % D)
add(G, "F-30", ["R-17"], "paper/sections/intro.tex; paper/sections/discussion.tex", "intro §1.2-§1.5; discussion",
    "major", A,
    "No 'track X's ...' naming, no 'the brief's H...', no 'referee m...' in running text (%s §6.2). One sentence in §1.5 "
    "says the results come from four independently refereed research notes (app:ver)." % D)
add(G, "F-31", ["R-27", "C-26"], "paper/sections/intro.tex; paper/sections/abstract.tex", "intro A2-A9; abstract",
    "major", A,
    "Gloss at first use in the intro (and abstract where used) with the wordings of %s §6.3: spare template, ω-gap, "
    "motive, DTRC, anchor, cautious verifier; and rename Gold's languages to \\mathcal L_k in A9 and the verdict table "
    "(%s §6.1)." % (D, D))
# --- front minors
add(G, "F-32", ["C-18"], "paper/sections/abstract.tex", "l.3", "minor", A,
    "Covered by the binding abstract (%s §8.3); if words allow, add 'when the data are drawn from the model' after "
    "'zero'. The intro's A3 keeps the class-dependent limit under unmodelled selection." % D)
add(G, "F-33", ["C-19"], "paper/sections/intro.tex", "tab:intro:verdicts, row H4(a)", "minor", A, ORIG_FIX)
add(G, "F-34", ["C-20"], "paper/sections/intro.tex", "tab:intro:verdicts H5; A9; A2", "minor", A, ORIG_FIX)
add(G, "F-35", ["C-21"], "paper/sections/intro.tex", "'What is not achieved' (iii)", "minor", A, ORIG_FIX)
add(G, "F-36", ["C-33"], "paper/sections/discussion.tex", "l.40 (\"making some mistakes\")", "minor", A, ORIG_FIX)
add(G, "F-37", ["C-35"], "paper/sections/app-verification.tex", "app:ver:sketches", "minor", A,
    "Add the four items (heavy-tail nesting conjecture; heuristic waiting times of prop:ident:gold; 'eventual behaviour' "
    "sketch of ex:pa:euler; the waiting time of rem:ident:sparetotal from the sketch of prop:ident:spare(b)), and mirror "
    "every status change of %s §11 (e.g. prop:ident:spare(c) hypothesis, rem:time:upper for ρ_{f,n}, prop:pa:wellspec "
    "Dirichlet part, prop:exp:exact(d), rem:sound:indep, rem:pa:pointwise open part)." % D)
add(G, "F-38", ["C-36"], "paper/sections/app-verification.tex", "app:ver:refs", "minor", A, ORIG_FIX)
add(G, "F-39", ["C-37"], "paper/sections/discussion.tex", "sec:disc:open", "minor", A,
    "Add both open problems (equal laws ⇒ equivalence for single DT templates, prop:ident:splits(c); for which assigners a "
    "Craig set is a finite union of DT templates), and the two open items made explicit in this revision: "
    "prop:univ:open(d) for countable classes with learned-weight provers, and whether templates block the collapse for "
    "merely consistent assigners.")
add(G, "F-40", ["R-12"], "paper/sections/intro.tex", "l.98-126 (sec:intro:contrib, sec:intro:guide)", "minor", A,
    "Merge contributions into the guide (one line per section); move 'What is not achieved' directly after the answers "
    "(%s §8.1). Keep both labels." % D)
add(G, "F-41", ["R-39", "R-40"], "paper/sections/intro.tex; paper/preamble.tex", "tab:intro:verdicts", "minor", A,
    "The table moves to App. H (F-20), which removes the float split of A8; call \\crefabbrev inside it (%s §6.5)." % D)
add(G, "F-42", ["R-41"], "paper/main.tex; paper/preamble.tex; paper/sections/intro.tex", "title footnote l.6; intro l.47, "
    "l.113", "minor", A,
    "Citation aliases as in %s §6.4 (\\defcitealias in \\AtBeginDocument; \\citetalias in the title footnote; first "
    "mention 'AS \\citep{...}, on axiom schemas, and IL \\citep{...}, on inferential learning')." % D)
add(G, "F-43", ["R-44"], "paper/sections/intro.tex; paper/sections/discussion.tex", "intro l.33; discussion l.64",
    "minor", A, "Keep the framing sentence in the intro (one sentence after the short answer) and the discussion's "
    "closing paragraph only; pa-exp removes the experiments copy (P-17).")
add(G, "F-44", ["R-45"], "paper/sections/app-verification.tex", "appendix as a whole", "minor", A,
    "App. H keeps each refuted item once (tab:ver:corrections), receives tab:intro:verdicts, and points to the other "
    "appendices rather than repeating them. Overall appendix cap 66 pp (%s §2)." % D)
add(G, "F-45", ["R-28"], "paper/sections/app-notation.tex (new, optional); paper/main.tex", "appendix front", "minor", P,
    "Optional: a one-page notation table (label app:notation) from NOTATION.md, input as the first appendix; if added, "
    "§1.5 says where it is. Symbol renamings: only those of %s §6.1." % D,
    note="Most of R-28's renamings rejected (rejected.json); the notation table is kept as an option.")
add(G, "F-46", ["C-27"], "paper/CLAIMS.md", "ledger (final sync)", "minor", A,
    "After all groups finish, update CLAIMS.md from the four changelogs: section column of moved items (C-27), the new "
    "statements of %s §10 (incl. the H2 verdict and prop:pa:must, prop:pa:wellspec, prop:pa:memo, ex:pa:skel, "
    "rem:pa:e3b), the statuses of §11, and the C-16 reconciliation. Only the front group edits CLAIMS.md." % D,
    problem="CLAIMS.md (the ledger) will be out of date after the revision: several statements, statuses and sections "
    "change, and some ledger entries repeat errors found by the reviewers (e.g. prop:pa:must, prop:pa:wellspec, "
    "ex:pa:skel, rem:pa:e3b per C1, C2, C4, C5).",
    evidence="The reviewers' fixes C1, C2, C4, C5 each ask to correct CLAIMS.md too; C-27 asks to update its section "
    "column.")

# =====================================================================================================
# MODEL-IDENT-SOUND
# =====================================================================================================
G = "model-ident-sound"
add(G, "M-01", ["MA-02"], "paper/sections/model.tex", "def:model:scores (l.191), last sentence", "fatal", A,
    "Binding text %s §10.M1 (L_ε at ε = 1 is a per-datum bounded-search relaxation of S_nc on positive data, equal to it "
    "only when joint consistency reduces to per-datum non-refutation within k steps; ε → 0 gives the generative P_T, "
    "support Th(T) under L1 with parameters admissible). No later result depends on the old identity (checked: "
    "tab:model:likelihoods footnote and prop:pa:nc use only the per-datum form)." % D,
    note="Verified: pa notes Def 0.3 states the identity too, but T = {¬(d1∧d2)}, D = {d1, d2} gives L_ε > 0 = S_nc.")
add(G, "M-02", ["MA-01"], "paper/sections/sound.tex", "l.131 (text after rem:sound:e4)", "fatal", A,
    "Binding text %s §10.M2. The source (experiments notes §6 finding 2) says X8(c) applies 'with its shrinking "
    "threshold'; the E4 verifier uses the constant δ = 0.05·π(T*)." % D)
add(G, "M-03", ["MA-03"], "paper/sections/model.tex; paper/sections/app-model.tex", "rem:model:graded (l.216, "
    "'Refuted'); app-model l.135", "major", AM,
    "Binding text %s §10.M8: state the refutation in the remark's own setting by the elementary inequality "
    "P^g_{T'}(b)/P^g_T(b) ≥ 2^{κ(ℓ_T(b)−ℓ_{T'}(b))} Z_T, and move the referee's numbers (0.032/0.346; L2 0.016/0.24) to "
    "App. A labelled as computed for ℓ = symbol size of the least MP tree, normalised over a finite universe of 570 "
    "formulas, where the normaliser need not be ≤ 1 (r6). Shorten the refuted clause to the binding text (§5)." % D,
    note="Verified in referee_code/r6_stronger_theory.py: ℓ is 'least tree size (sum of formula sizes)' over 570 "
    "formulas, so the quoted values imply Z_{T'} = 1.45 > 1 against the remark's Z ≤ 1. The reviewer's own prefix-code "
    "bound (2^-18 against 2^-5) is not used: it is not from a source (rejected.json).")
add(G, "M-04", ["MA-04", "MA-16"], "paper/sections/ident.tex; paper/sections/app-ident.tex",
    "prop:ident:spare (c) (l.140), (d2) (l.142); app-ident l.160-162", "major", AM,
    "Binding text %s §10.M7: add Σ_s Q_σ(s)²/P*(s) < ∞ to (c); name where the sketch uses it (quadratic expansion in u); "
    "state that the case 'in the span but outside the convex hull' is not covered. Rename R_n → BF^σ_n (%s §6.1). Do not "
    "add a rate for the infinite-χ² case (the reviewer's heuristic is not a source)." % (D, D),
    note="The finite-χ² requirement is visible in the paper's own sketch (−nIu²/2 + √n Z u needs I < ∞); the reviewer's "
    "heavy-tail computation (a4) confirms the rate changes. E5's nested spare has bounded likelihood ratio, so E5 is "
    "unaffected.")
add(G, "M-05", ["MA-05", "C-41"], "paper/sections/sound.tex; paper/sections/app-sound.tex", "rem:sound:vacuous (l.84-86); "
    "app-sound l.80", "major", A,
    "Binding text %s §10.M4 (L0 or likelihoods affine in w; under L1 plausible, not proved); status per §11. The proof in "
    "App. D points to the affine-slice argument in the proof of rem:ident:exact (canonical home, %s §4) and adds only "
    "the intersection with Th_d(T) = Th_d(T*)." % (D, D))
add(G, "M-06", ["MA-06"], "paper/sections/sound.tex; paper/sections/app-sound.tex", "rem:sound:tight (l.41); app-sound l.35",
    "major", A,
    "Binding text %s §10.M3 (L1 clause for d = ∞ only; counterexample T* = {a, a→b}, T' = T* ∪ {b} at finite d). The "
    "remark moves to App. D (§3) with a one-sentence pointer in §5.2 ('the constant δ ≤ W*_d δ' is tight, rem:sound:tight')." % D)
add(G, "M-07", ["MA-07"], "paper/sections/ident.tex", "rem:ident:x5 (l.87-89)", "major", AM,
    "Binding text %s §10.M6 and status of §11. pa-exp makes experiments.tex l.20 and the E1 setup cite this remark "
    "instead of thm:ident:doob (P-16)." % D,
    note="Verified: def:ident:W needs fixed laws; E1, E4, E6 pools contain Dirichlet-integrated multi-component members "
    "and data-dependent Mem(D_n)/causal theories (experiments §1.8, §3, §6, §8). The source X5(c) has the same gap.")
add(G, "M-08", ["MA-08", "C-25"], "paper/sections/sound.tex", "thm:sound:shrink (l.108-110); rem:sound:lumps (l.134)",
    "major", A,
    "Binding text %s §10.M5: add the pool version to thm:sound:shrink (from experiments Prop X8(c), which allows any pool "
    "R_n ∋ T* chosen from the data, δ_n ≤ 2^{−bits(T*)} R_α(n,K) δ'); rem:sound:lumps cites the pool version and writes "
    "\\Rreg(n,8)." % D,
    note="Verified: experiments notes Prop X8(c) and its proof (pathwise bound with Z'_n over R_n ⊆ F).")
add(G, "M-09", ["MA-09"], "paper/sections/app-ident.tex", "tab:ident:c2 (l.95-107), misspecified prediction row and caption",
    "major", A,
    "Binding text %s §10.M9 (prediction + (K−1)/2 = −0.00, 41.0, 481.9, 4921.9, 49353.3; caption: both predictions include "
    "the mean (K−1)/2 of nKL(r̂‖r))." % D,
    note="Verified: model checks/c2_split.py l.100 adds (K−1)/2 only 'if kl == 0'; E[nKL(r̂‖p)] = nKL(r‖p) + (K−1)/2 + o(1).")
add(G, "M-10", ["R-21", "R-15"], "paper/sections/sound.tex; paper/sections/model.tex; paper/sections/app-sound.tex; "
    "paper/sections/app-model.tex", "§5.6 (l.139-194: sec:sound:tri, def:sound:tri, props laws/belief/bracket/fiftyfifty, "
    "exs renorm/fifty, rem:sound:indep, Hänni's three questions)", "major", A,
    "Move the trichotomy (labels unchanged, including sec:sound:tri) to model.tex as §2.7 'Hänni's trichotomy' after "
    "sec:model:scores, compressed to about 0.9 pp; answer each of his three questions next to its example instead of in "
    "a closing paragraph; rem:sound:belc stays in §5. Move app:sound:tri (with rem:sound:completeref) to app-model.tex. "
    "Rename the 50/50 rule H → F_{1/2} (%s §6.1). The quotations of his trichotomy live here (canonical, %s §4)." % (D, D))
add(G, "M-11", ["R-18", "R-19", "C-30"], "paper/sections/model.tex; paper/sections/app-model.tex", "§2 (l.31-243): "
    "tab:model:calculi, def:model:calculi, lem:model:a4, def:model:prior, def:model:variants, prop:model:max", "major", A,
    "Apply the §2 moves of %s §3: tab:model:calculi to App. A (caption fix C-30: 'proved for C_min (all listed "
    "likelihoods) and, unnormalised, for C_U3 (thm:univ:B)'; \\crefabbrev); keep three lines of prose naming the calculi; "
    "lem:model:a4 and the Elias-γ details to App. A; prop:model:max to App. A with pointer; tighten rem:model:priors, the "
    "cost paragraph and the AS recap. Keep in §2: theory and template, prior, Q in two sentences, L0, L0^cl, L1 (C_min "
    "as simplest instance), L2, L1^σ, L1^max, L1^sel, L1^sel_cit, noise mixtures, L_ε, scores, trichotomy (M-10), size "
    "principle, computability. Add after def:model:lone: 'Subscripted α_• are rule probabilities; the Dirichlet parameter "
    "is α or α_τ.'" % D)
add(G, "M-12", ["R-16"], "paper/sections/model.tex; paper/sections/ident.tex; paper/sections/sound.tex", "rem:model:subcrit "
    "(l.117-119); rem:model:graded (l.216); rem:ident:exact (l.83-85); rem:sound:hyp (l.45); rem:sound:vacuous (l.85)",
    "major", A,
    "Per %s §5: rem:model:subcrit to App. A; refuted part of rem:model:graded per M-03; rem:ident:exact stays, at most "
    "four lines, stated under L0 (thm:ident:limit(b)'s hypotheses); the two refuted sentences of rem:sound:hyp to App. D; "
    "delete the first-version sentence of rem:sound:vacuous. Where a corrected statement depends on a refuted one, "
    "write '(an earlier version claimed more; \\cref{app:ver:corrections})'." % D)
add(G, "M-13", ["R-17", "R-05", "R-29"], "paper/sections/model.tex; paper/sections/ident.tex; paper/sections/sound.tex",
    "running text throughout (e.g. def:model:calculi 'track universal's chains ... track pa's natural deduction'; "
    "sound.tex l.16 'the brief's H3', l.131 'brief's H2', l.188 'universal's c2 class')", "major", A,
    "Name objects by content and remove process vocabulary from running text (%s §6.2); provenance stays in \\src. "
    "Replace 'the brief's H3/H2' by the claim; 'in universal's c2 class' → 'in the class of \\cref{tab:univ:c2}'. "
    "Check-script names only in \\src, captions, appendices." % D)
add(G, "M-14", ["R-13", "C-38"], "paper/sections/model.tex; paper/sections/ident.tex; paper/sections/sound.tex",
    "whole sections", "major", A,
    "Meet %s §2: model 5.5 pp (cap 5.75, including the trichotomy), ident 5.0 (cap 5.25), sound 3.5 (cap 3.75), with the "
    "moves of §3 (model: tab:model:calculi, lem:model:a4, rem:model:subcrit, Elias-γ details, prop:model:max; ident: "
    "prop:ident:rates, ex:ident:lonedq, conj:ident:cder, prop:ident:proofs; sound: rem:sound:tight, parts of rem:sound:hyp, "
    "trichotomy to §2) and tightening. Pointers per rule 4." % D)
add(G, "M-15", ["R-14", "C-40", "C-42", "C31"], "paper/sections/ident.tex; paper/sections/sound.tex; "
    "paper/sections/app-ident.tex; paper/sections/app-sound.tex", "rem:ident:e8, rem:ident:e3a, rem:ident:splitsL1, "
    "rem:sound:e4, rem:sound:lumps; app-ident 'E8 windows' (l.145), l.152, l.201; sound l.56; app-sound l.44", "major", A,
    "Canonical homes per %s §4: rem:ident:e8 (E8), rem:ident:e3a (E3(a)), E5 after prop:ident:spare and prop:ident:gold, "
    "rem:sound:e4 (E4), rem:sound:lumps (E2 acceptances). Drop the E6 sentence of rem:ident:splitsL1 (pointer to "
    "rem:pa:e6); delete app-ident 'E8 windows' (details go to App. G); cite ex:ident:escape for the c4 run in sound.tex "
    "l.56, app-sound and app-ident l.201; cite prop:pa:spare for 19.03/19.82 in app-ident l.152. In rem:ident:e3a fix the "
    "heavy-tail wording (C31): 'a depth-2 nesting wins (C_2 in 3 seeds, {φ(z), φ(SSz)} in 2)'." % D)
add(G, "M-16", ["R-27", "C-26"], "paper/sections/model.tex; paper/sections/ident.tex; paper/sections/sound.tex",
    "first uses of: spare (ident l.17), ω-gap, KT (lem:model:dirsum), H_k/Acc_k (prop:sound:cautious), SeenQ/Trim "
    "(rem:sound:lumps), T_E/T_N (tab:ident:misspec)", "major", A,
    "One-clause definitions at first use with the wordings of %s §6.3 (spare template; ω-gap; KT expanded in "
    "lem:model:dirsum; H_k(DT°) and Acc_k; SeenQ/Trim with a pointer to §8.1; T_E, T_N in tab:ident:misspec)." % D)
add(G, "M-17", ["R-28", "C-25", "R-39"], "paper/sections/ident.tex; paper/sections/sound.tex; paper/sections/model.tex",
    "prop:ident:gold (L_i); prop:ident:spare (R_n); trichotomy H(s); rem:sound:tight/vacuous (W*); tab:ident:misspec",
    "major", P,
    "Apply only the renamings of %s §6.1 in these files: Gold's languages → \\mathcal L_k (retitle prop:ident:gold); "
    "spare ratio R_n → BF^σ_n; 50/50 rule H → F_{1/2}; W* → W*_d; add the α-disambiguation sentence after "
    "def:model:lone; \\crefabbrev inside tab:ident:misspec (R-39)." % D,
    note="Renaming α_•, q, ρ, c, K rejected (rejected.json).")
add(G, "M-18", ["R-15", "C-39"], "paper/sections/model.tex", "l.185 (Hänni's variants quote, sec:model:scores)", "major", A,
    "model §2.6 is the canonical home of the variants and weighting quotes (%s §4): keep them here, trimmed; the intro "
    "refers here." % D)
add(G, "M-19", ["C-16"], "paper/sections/model.tex", "l.24 (Robinson arithmetic paragraph)", "major", A,
    "Add: 'Q has no axiom about <; it is Σ1-complete for <-free Σ1 sentences.' (%s §10.U9; univ-time writes Acc_f "
    "without <)." % D)
add(G, "M-20", ["C-07", "MA-21"], "paper/sections/app-ident.tex; paper/sections/app-sound.tex", "app-ident l.11; "
    "app-sound opening", "major", A,
    "Keep each appendix's sentence on what the referee re-did; replace app-ident's list of results added after the "
    "referee by a pointer to the complete list in app:ver:process (front F-08); add the same two sentences to app-sound "
    "(refereed: thm:sound:fixed, prop:sound:cautious, prop:sound:complete, the trichotomy results 7.1-7.3; added after "
    "the referee: lem:sound:regret, thm:sound:avg, thm:sound:shrink, rem:sound:vacuous, ex:sound:constant's mechanism, "
    "prop:sound:fiftyfifty — see app:ver:process).")
# --- minors
for gid, src, file, loc in [
    ("M-21", "MA-10", "paper/sections/ident.tex", "l.17"),
    ("M-22", "MA-11", "paper/sections/app-model.tex; paper/sections/ident.tex", "tab:model:likelihoods row P^η; rem:ident:nearmiss"),
    ("M-23", "MA-12", "paper/sections/sound.tex; paper/sections/app-sound.tex", "thm:sound:avg pool version (l.105); app-sound l.115"),
    ("M-24", "MA-13", "paper/sections/ident.tex", "rem:ident:memo (l.98)"),
    ("M-25", "MA-14", "paper/sections/model.tex", "prop:model:whichsize(c) (l.209)"),
    ("M-26", "MA-17", "paper/sections/sound.tex", "l.56"),
    ("M-27", "MA-18", "paper/sections/model.tex", "lem:model:size 'Computed' (l.201)"),
    ("M-28", "MA-19", "paper/sections/sound.tex", "l.38 (escalation bound)"),
    ("M-29", "MA-20", "paper/sections/ident.tex", "prop:ident:proofs(c) (l.234; moves to App. C)"),
    ("M-30", "MA-22", "paper/sections/ident.tex", "prop:ident:splits(c) (l.61)"),
    ("M-31", "MA-23", "paper/sections/sound.tex", "rem:sound:hyp (l.45; part moves to App. D)"),
    ("M-32", "MA-24", "paper/sections/sound.tex", "ex:sound:constant (l.118-122)"),
    ("M-33", "MA-27", "paper/sections/model.tex", "lem:model:lone(b) (l.152)"),
    ("M-34", "C-23", "paper/sections/ident.tex", "tab:ident:misspec rows l.207, l.217"),
    ("M-35", "R-36", "paper/sections/app-sound.tex", "tab:sound:constant (l.133-147)"),
    ("M-36", "R-43", "paper/sections/model.tex", "l.22-23"),
]:
    add(G, gid, [src], file, loc, "minor", A, ORIG_FIX)
add(G, "M-37", ["MA-15"], "paper/sections/sound.tex", "rem:sound:indep (l.183-185; moves to §2.7)", "minor", A,
    "Apply the reviewer's three wording fixes; status per %s §11 ('proved for ground ψ; proof sketch when ψ is generated "
    "by a schema')." % D)
add(G, "M-38", ["MA-25"], "paper/sections/ident.tex", "rem:ident:sparetotal (l.148)", "minor", A,
    "Mark the waiting-time sentence '(from the sketch of \\cref{prop:ident:spare}(b))'; status per %s §11." % D)
add(G, "M-39", ["MA-26"], "paper/sections/model.tex", "def:model:scores (S_nc,β)", "minor", A,
    "Included in the binding text of %s §10.M1 ('for β > 1 ...; S_nc,1 = S_nc')." % D)
add(G, "M-40", ["C-32"], "paper/sections/ident.tex; paper/sections/sound.tex", "rem:ident:nearmiss status (l.237); "
    "ex:sound:constant \\src (l.118)", "minor", A,
    "rem:ident:nearmiss: status 'proved (the transfer); open (size of the generator class)'; ex:sound:constant: "
    "\\src{model Ex 4.9; experiments check\\_fixed\\_weight} (%s §11)." % D)
add(G, "M-41", ["R-32"], "paper/sections/ident.tex", "§4.4 opening (l.104) and rem:ident:mdl (l.129-131)", "minor", A,
    "ident §4.4 is the canonical home of the MDL quotation and conclusion: open rem:ident:mdl with its conclusion "
    "('when the instantiation model is misspecified, the posterior tracks usage, not the logical boundary of a schema'), "
    "then the three qualifications one line each; qualification (iii) absorbs the ∀xφ split rates now in rem:univ:mdl "
    "(univ-time keeps only a pointer there).")
add(G, "M-42", ["R-37"], "paper/sections/ident.tex; paper/sections/sound.tex; paper/sections/model.tex",
    "long status strings in heads (e.g. thm:ident:limit, lem:model:lone, prop:model:compute)", "minor", A,
    "Status strings in heads ≤ about 70 characters; per-part exceptions inline (%s §7)." % D)
add(G, "M-43", ["C-27"], "paper/sections/ident.tex; paper/sections/sound.tex; paper/sections/model.tex",
    "main-text uses of statements that now live only in an appendix", "minor", A,
    "At each main-text use of a statement that lives only in an appendix (after the moves of %s §3), write the result's "
    "conclusion and '\\cref{...} in \\cref{app:...}'. Report moved items in the changelog for the CLAIMS.md sync." % D)

add(G, "M-44", ["C9"], "paper/sections/app-model.tex", "l.58 (CND and L1^sch: 'it is a prefix code, so ...')", "minor", A,
    "Align with %s §10.P9: 'with at least log2 of the alphabet size bits per written symbol (about log2 25 with the "
    "variable names used) it is a prefix code, so L1^sch is the two-part form of a sub-probability; the reported "
    "β = log2 23 under-charges by about 3%%, which changes no conclusion'." % D,
    note="Same Kraft condition as C9 (pa.tex, pa-exp P-09); the appendix sentence asserts the prefix property "
    "unconditionally before its parenthetical caveat.")

# =====================================================================================================
# UNIV-TIME
# =====================================================================================================
G = "univ-time"
add(G, "U-01", ["MB-01", "MB-22"], "paper/sections/universal.tex", "l.8 (opening), l.39 (subsection title), l.68 "
    "(thm:univ:B title), l.72 ('Not covered'), l.86, l.222, l.224", "fatal", AM,
    "Binding text %s §10.U1 (section opening; subsection and theorem titles 'do not favour'; the new 'Not covered' "
    "paragraph naming the fixed-weight and learned-weight L1^sel background effects, ∧-detours, normalised C_U3, and the "
    "scores with a background or quantified data; l.86; l.222). In §3.9 (l.224), write 'accepts ∀xφ only if, eventually, "
    "the prior share of provers over theories and filters is ≥ 1−δ (for finite n see cor:univ:sound)' (MB-22), and name "
    "the filter likelihood as 'a known filter (L1^sel, or the per-citation L1^sel_cit, under which the background effect "
    "vanishes, rem:univ:B2cit)'." % D,
    note="Verified in universal notes §4 'Not covered, or false' (both L1-sel background cases) and the proof of Prop B2 "
    "(effective weight w_e = wc/(1−w+wc)). MB-01's alternative of switching the recommendation to L1^sel_cit is not "
    "adopted (rejected.json); the tie under L1^sel_cit is stated as a fact.")
add(G, "U-02", ["MB-02", "MB-14"], "paper/sections/universal.tex; paper/sections/app-universal.tex", "thm:univ:B (B1), "
    "(B3) (l.69); app-universal l.20", "fatal", A,
    "Binding text %s §10.U2: (B3) under the scores only for single axioms and quantifier-free data (equality by "
    "Herbrand's theorem); (B1) equality conditions stated. Write the Herbrand step in the App. B proof." % D,
    note="Verified: S_prove uses first-order ⊢ (universal §1.5); Th(H_sch) ⊆ Th(H_all), and the datum ¬∃x¬φ is proved "
    "by H_all only, so the scores favour the ∀-version on such data. Universal notes (B3) has the same gap.")
add(G, "U-03", ["MB-03"], "paper/sections/universal.tex; paper/sections/app-universal.tex", "prop:univ:hanni (l.147); "
    "app-universal l.123", "major", P,
    "Binding text %s §10.U4: state that provers of all the data share one factor under S_nc and S_g (so the trichotomy "
    "conclusion holds), and that the S_nc limit is the prior restricted to the larger set {T : T ∪ I_c(φ) consistent}, "
    "which contains non-provers such as ∅. Make no claim about non-provers under S_g beyond that." % D,
    note="S_nc part verified. The S_g part of MB-03 depends on whether D_+ counts repeated data, which the definition "
    "leaves open; with repetitions counted, non-provers vanish under S_g. No S_g limit is claimed (rejected.json).")
add(G, "U-04", ["MB-04"], "paper/sections/time.tex", "rem:time:summary (1) (l.191); l.20", "major", AM,
    "Binding text %s §10.U6 item (1): Craig's sets have polynomial-time membership like finite DT° theories, so such a "
    "penalty charges them as it charges template theories; no time-penalised prior is defined, so no bound on the "
    "change to thm:time:equiv is claimed." % D,
    note="Verified: no time-penalised prior is defined in §6; rem:model:priors(iii) itself says a Levin factor changes "
    "ln π by O(ln ℓ(T)). The model notes' 'additive constant' is not proved; the reviewer's alternative quantitative "
    "statements are not adopted.")
add(G, "U-05", ["MB-05", "C-11"], "paper/sections/time.tex", "l.20; rem:time:summary (2) (l.191)", "major", A,
    "Binding text %s §10.U6 item (2) (over PA; Σ_n-sound assigners on Σ_n sentences; linear in |f|; open for merely "
    "consistent assigners). Delete the l.20 paragraph (the summary moves to the start of §6, U-14)." % D)
add(G, "U-06", ["MB-06", "C-12"], "paper/sections/time.tex", "rem:time:summary (3) (l.191)", "major", A,
    "Binding text %s §10.U6 item (3) (a fixed polynomial root of the nondeterministic time, infinitely often, for theories "
    "with polynomial-time membership; constants −ln(Z_T/Z^σ_T) and log2 Z_T kept; upper bound proof sketch; none for "
    "ρ_{f,n}); status per §11." % D)
add(G, "U-07", ["MB-07"], "paper/sections/time.tex; paper/sections/app-time.tex", "rem:time:upper (l.130); app-time l.92",
    "major", A, "Binding text %s §10.U7; status per §11." % D)
add(G, "U-08", ["MB-08"], "paper/sections/universal.tex; paper/sections/app-universal.tex", "prop:univ:open (d) (l.168); "
    "app-universal l.155", "major", A,
    "Binding text %s §10.U5 (finite classes; H_both 'only polynomially, like 1/n in C_min'); the App. B proof says 'for the "
    "finitely many hypotheses compared'." % D,
    note="Verified: universal notes U11(d) proof is 'from (c) and U4(2) for the finitely many hypotheses compared'.")
add(G, "U-09", ["MB-09"], "paper/sections/time.tex", "prop:time:lonesize (l.140)", "major", A,
    "Binding text %s §10.U8: '−ln Pr(tree) = 12.77 + 12.21k nats (12.206 per round)'." % D,
    note="Verified from app-time l.97 (12.206 per round, 12.77 for citation and final ∀E) and tab:time:c12 (378.95 at "
    "k = 30 > 12.8 + 12.2·30).")
add(G, "U-10", ["C-16"], "paper/sections/time.tex; paper/sections/app-time.tex", "§6.2 (l.59); prop:time:twosorted status "
    "(l.62); app-time l.34", "major", A,
    "Binding text %s §10.U9: Acc_f and Rej_f written without <; status and proof mention Σ1-completeness for <-free "
    "sentences. (model-ident-sound adds the Q sentence; front records the reconciliation.)" % D)
add(G, "U-11", ["R-22", "R-04", "R-03"], "paper/sections/universal.tex; paper/sections/app-universal.tex",
    "§3 opening to §3.2 (l.8-96); §3.9 (l.220-224); tab:univ:odds; tab:univ:c2", "major", AM,
    "Open §3 with the first paragraph of §3.9 (where the intuition is right, where it needs refinement, what licenses "
    "∀xφ; with the U-01 wording). Keep prop:univ:factor and thm:univ:odds as separate results (labels and part references "
    "stay); make thm:univ:odds display its formulas (binding text %s §10.U3) with the 0.77/0.23 running-example "
    "sentence; move tab:univ:odds to App. B; move tab:univ:c2 (label unchanged) into §3.2 as the running example for "
    "φ = 0+x=x (R-04). §3.9 then keeps only the ∀xφ-specific part of the good version and cor:univ:sound." % D,
    note="Merging prop:univ:factor into thm:univ:odds (R-22) is not adopted: two labelled statements cited separately "
    "elsewhere would have to change.")
add(G, "U-12", ["R-23", "R-37"], "paper/sections/universal.tex", "thm:univ:omega (l.131-142); other long status heads "
    "(prop:univ:noguard, prop:univ:sentences, prop:univ:quant); time.tex prop:time:single (l.66)", "major", P,
    "Do not split thm:univ:omega. Instead: define 'faithful for C' in one sentence before the theorem; add a one-line "
    "gloss of the ω-gap; head status '(a)-(c), (d1), (e) proved; computed' with '(d2) \\status{proved for the pair; proof "
    "sketch in general}' inline at (d2); same pattern for the other long heads (%s §7). In prop:time:single move "
    "'assuming Con(PA) and the standard formalisation of computations' into the statement." % D,
    note="R-23's split into a theorem plus a new proposition rejected: it needs a new label and would invalidate the "
    "part references thm:univ:omega(b), (c3), (d), (e) in model, intro, discussion, ident and app-verification "
    "(rejected.json).")
add(G, "U-13", ["R-24"], "paper/sections/time.tex; paper/sections/app-time.tex", "opening (l.18-20); §6.5 (l.136-185); "
    "rem:time:summary (l.190-194)", "major", P,
    "Open §6 with the collapse argument and its quotations (canonical home, %s §4), then rem:time:summary (new text "
    "U-04..U-06) moved to the start; delete l.20. Move lem:time:symexp, prop:time:codelength, thm:time:log and "
    "rem:time:convention to App. E with the pointer sentences of %s §3; keep cor:time:log, prop:time:sigma, "
    "conj:time:poly. Keep conj:time:polytime in §6, shortened." % (D, D),
    note="Moving conj:time:polytime to §9.5 rejected (cited by discussion and app-verification; rejected.json).")
add(G, "U-14", ["R-13", "C-38"], "paper/sections/universal.tex; paper/sections/time.tex", "whole sections", "major", A,
    "Meet %s §2: universal 6.25 pp (cap 6.5), time 4.5 (cap 4.75), with the moves of §3 (universal: tab:univ:odds, "
    "prop:univ:overspec, prop:univ:rkrate and the waste paragraph, lem:univ:survivors, rem:univ:kreisel, the proof of "
    "cor:univ:sound, script defaults; time: lem:time:symexp, prop:time:codelength, thm:time:log, rem:time:convention) and "
    "tightening (detour, hutter, openrefuted, the c8 paragraph, the equational-fragment paragraph, §3.8; text after "
    "prop:time:cheap; rem:time:links)." % D)
add(G, "U-15", ["R-16"], "paper/sections/time.tex; paper/sections/universal.tex", "prop:time:lonesize; time l.127; "
    "rem:univ:detour; rem:univ:openrefuted; app sentences narrating first versions", "major", A,
    "Keep rem:univ:detour, rem:univ:openrefuted and prop:time:lonesize, each ≤ 4 lines (%s §5); delete '(The pre-referee "
    "version let c depend on T; referee m1.)' (time l.127); shorten 'The first version conjectured ...' to one clause." % D)
add(G, "U-16", ["R-17", "R-05"], "paper/sections/universal.tex; paper/sections/time.tex", "universal l.8 ('All results "
    "are from the universal track'), l.113 ('the brief's H4(a)'); time l.18 ('The brief (H6) conjectured'), l.104, l.109 "
    "(the brief's sentence refuted)", "major", A,
    "Remove process vocabulary from running text (%s §6.2): state the claims directly (e.g. 'so a penalty on the time to "
    "check membership does not price the collapse'); 'the track's prior' → 'the prior 2^{-(Σ|A|+#axioms)}'; keep "
    "provenance in \\src. Fix C-29 at the same time ('Results are from the universal track unless the source note says "
    "otherwise' can go entirely once \\src carries provenance)." % D)
add(G, "U-17", ["R-15"], "paper/sections/universal.tex; paper/sections/time.tex", "universal l.8 (re-quotation of the "
    "question); time l.18-20", "major", A,
    "Delete the re-quotation of the question at the start of §3 (canonical in the intro). time.tex §6 opening is the "
    "canonical home of the collapse quotations (%s §4): keep them, short, and do not repeat them elsewhere in §6." % D)
add(G, "U-18", ["R-27", "C-26"], "paper/sections/universal.tex", "prop:univ:memo (l.110: DirMult), l.113 (Mem), first "
    "uses of ω-gap and spare", "major", A,
    "Define DirMult and Mem(E) at first use in §3 (give the DirMult formula here and cite it from prop:ident:splitlzero, "
    "or the reverse, once); gloss ω-gap and spare template at first use (%s §6.3)." % D)
add(G, "U-19", ["R-14", "C-40", "C-42"], "paper/sections/universal.tex; paper/sections/time.tex", "universal l.96 (E1), "
    "l.150 (Bel ≈ 0.69), l.189 (E3(a)), rem:univ:mdl (l.236-238); time rem:time:links(iii) (l.199), rem:time:e7 (l.204)",
    "major", A,
    "Canonical homes per %s §4: the E1 paragraph after prop:univ:both stays (canonical E1); l.189 E3(a) sentence → one "
    "clause citing rem:ident:e3a; l.150 → pointer to rem:sound:belc; rem:univ:mdl keeps only the ∀xφ-specific split rates "
    "and points to rem:ident:mdl (no re-quote of AS); rem:time:e7 is the canonical E7 home (τ and λ), with C30's "
    "wording 'slightly at τ = 1, markedly at τ = 4'; rem:time:links(iii) becomes a one-clause pointer." % D)
# --- minors
for gid, src, file, loc in [
    ("U-20", "MB-10", "paper/sections/universal.tex", "thm:univ:confirm (l.119)"),
    ("U-21", "MB-11", "paper/sections/universal.tex; paper/sections/app-universal.tex", "prop:univ:noguard(b) (l.184); tab:univ:noguard caption"),
    ("U-22", "MB-12", "paper/sections/time.tex", "rem:time:convention (l.53) against l.74"),
    ("U-23", "MB-13", "paper/sections/universal.tex; paper/sections/app-universal.tex", "prop:univ:factor (l.42); app l.14"),
    ("U-24", "MB-15", "paper/sections/universal.tex", "thm:univ:size, last sentence (l.102)"),
    ("U-25", "MB-16", "paper/sections/universal.tex", "l.122 (dyadic family)"),
    ("U-26", "MB-17", "paper/sections/universal.tex", "l.181 (waste paragraph; moves to App. B)"),
    ("U-27", "MB-18", "paper/sections/time.tex; paper/sections/app-time.tex", "prop:time:notemplate (l.80); app-time l.62"),
    ("U-28", "MB-19", "paper/sections/time.tex", "l.111 ('no theory escapes this')"),
    ("U-29", "MB-20", "paper/sections/time.tex", "rem:time:convention (l.53; moves to App. E)"),
    ("U-30", "MB-21", "paper/sections/app-time.tex", "proof of prop:time:codelength (l.131)"),
    ("U-31", "MB-23", "paper/sections/universal.tex", "l.17 (S_nc,β, β > 1)"),
    ("U-32", "MB-25", "paper/sections/universal.tex", "thm:univ:omega(e) (l.138)"),
    ("U-33", "MB-26", "paper/sections/universal.tex; paper/sections/app-time.tex", "universal l.234-235; app-time l.154-155 (overfull)"),
    ("U-34", "C-29", "paper/sections/universal.tex", "l.8"),
    ("U-35", "C-31", "paper/sections/app-universal.tex", "tab:univ:inc caption (l.137)"),
    ("U-36", "R-31", "paper/sections/universal.tex", "§3.6 (l.183-189); l.198"),
    ("U-37", "R-38", "paper/sections/universal.tex", "tab:univ:hyp (l.19-36)"),
    ("U-38", "R-42", "paper/sections/universal.tex", "l.45, l.72, l.142, l.187, l.230-232 (proof idea style)"),
]:
    add(G, gid, [src], file, loc, "minor", A, ORIG_FIX)
def override(group, gid, **kw):
    for i in groups[group]:
        if i["id"] == gid:
            i.update(kw)
            return
    raise KeyError(gid)
override(G, "U-21", verdict=AM,
         fix="State in prop:univ:noguard(b) and the tab:univ:noguard caption that (b) is proved for Laplace-weighted "
             "memorisers while the computations use Dirichlet(½) weights (α stated in the caption).",
         verdict_note="The reviewer's alternative (state a Krichevsky–Trofimov version of the bound) would be a new "
                      "result; only the hypothesis mismatch is made explicit.")
override(G, "U-27", verdict=AM,
         fix="State prop:time:notemplate for the acceptance part C_f (as proved) and add: 'The rejection part, and "
             "templates whose instances mix the two parts, are not treated here (\\cref{app:ver:open})'. Do not extend "
             "the statement to A_f without a proof from the sources.",
         verdict_note="app-verification's open item (6) already records that the rejection part is not proved; the "
                      "reviewer's sketch for mixed templates is not a source.")
override("model-ident-sound", "M-28",
         verdict_note="Verified against IL Thm 4.16 (inferential-learning caution.tex l.265-271): the bound holds for "
                      "valid escalations with δ in place of δ_m, and is vacuous for invalid ones without a reject "
                      "threshold; model notes l.629 claimed it 'transfers unchanged'.")
add(G, "U-39", ["MB-24"], "paper/sections/universal.tex", "thm:univ:B proof idea (l.72)", "minor", A,
    "Included in the binding text of %s §10.U1 ('through the extra ∀E step')." % D)
add(G, "U-40", ["R-29"], "paper/sections/universal.tex", "l.17, l.189 (script names in running text)", "minor", A,
    "Script names only in \\src, captions and appendices (%s §6.2); move the l.17 defaults to App. B and state α in each "
    "table caption; l.189 'In c8' → 'In the computations of \\cref{tab:univ:noguard}'." % D)
add(G, "U-41", ["C-27"], "paper/sections/universal.tex; paper/sections/time.tex", "uses of prop:univ:sim, lem:univ:waste, "
    "prop:univ:rk, prop:univ:eqfrag; time l.99", "minor", A,
    "At each main-text use of a statement that lives only in App. B or E (including those moved now), write its "
    "conclusion and '\\cref{...} in \\cref{app:...}' (prop:univ:eqfrag: state its conclusion in one sentence in §3.7). "
    "Report moved items in the changelog for the CLAIMS.md sync.")

# =====================================================================================================
# PA-EXP
# =====================================================================================================
G = "pa-exp"
add(G, "P-01", ["C1", "C24"], "paper/sections/pa.tex; paper/sections/app-pa.tex", "prop:pa:must (l.156); app-pa l.97",
    "fatal", A,
    "Binding text %s §10.P1 (drop F_0 as an example of (c); explain why R_d refutes it); fix the app-pa proof. In (b) "
    "write 'one or two library theorems suffice (associativity alone: 17·log2 23 = 76.9 > 72 bits)' (C24), with "
    "β_ax per P-03." % D,
    note="Verified: under R_d (def:pa:refute) a negated datum ¬s' is an instance of F_0, derivable by a one-line "
    "citation, and (b) needs d to cover 11-55-line derivations. pa notes Prop 3.4(c) has the same error.")
add(G, "P-02", ["C2"], "paper/sections/pa.tex; paper/sections/app-pa.tex", "prop:pa:wellspec (l.152) last sentence; "
    "app-pa l.95", "fatal", A,
    "Binding text %s §10.P2 (exponential at generic fixed weights in setting W, at the KL rate of prop:ident:rates(a); "
    "polynomial only with Dirichlet weights, proof sketch); status per §11; update the app-pa proof." % D,
    note="Verified: def:ident:W fixes the laws; rem:ident:sparetotal gives (1−w_σ)^n with fixed weights; pa notes §3.6 "
    "mixes the two settings.")
add(G, "P-03", ["C3"], "paper/sections/pa.tex", "def:pa:lsch (l.22-23); prop:pa:memo (l.123-125); tab:pa:theorems caption "
    "(l.140); Answer (3) (l.159)", "major", AM,
    "Binding text %s §10.P3: introduce β_ax (bits per axiom symbol; default β_ax = β); restate prop:pa:memo with β_ax and "
    "with D_T, ℓ_cite at the proof-text β; caption 'memorising wins at the first occurrence for every theorem at the "
    "default β_ax = β'; Answer (3) with β_ax ≥ β*(s)." % D,
    note="Verified: with one β the 'iff β < β*(s)' is vacuous as written; pa's c6 output and the referee's M3 already "
    "read β* as a threshold for the axiom-prior rate. The reviewer's general claim 'memorising wins for every β' is "
    "replaced by the computed statement for the six theorems.")
add(G, "P-04", ["C4"], "paper/sections/pa.tex; paper/sections/app-pa.tex", "ex:pa:skel (l.200-202); app-pa l.141",
    "major", A, "Binding text %s §10.P4; same split in the app-pa details paragraph." % D,
    note="Verified in pa checks/c8_narrow.out (B): +42838.5 bits is the 119-template theory (slope −20.5); +2.0 is the "
    "164-template covering theory, not computed.")
add(G, "P-05", ["C5"], "paper/sections/pa.tex; paper/sections/experiments.tex", "rem:pa:e3b (l.217); tab:exp:e3b (l.131)",
    "major", AM,
    "Binding text %s §10.P5: say the 2·10^-178 is the T*-equivalent mass in this pool, carried by frag-complete (about "
    "590 bits behind frag-atoms, from code/results/e3_misspec.md), and that a T*-equivalent adding only T_Ind to "
    "frag-atoms was not in the pool and would lose only polynomially (prop:ident:spare). Same caveat in the tab:exp:e3b "
    "caption. Do not quote the reviewer's re-run numbers." % D,
    note="Verified from e3_misspec.md (atomic: frag-complete −397..−437 bits vs frag-atoms −986..−1028 relative to T*). "
    "The reviewer's 2.2·10^-14 comes from a scratch re-run, not a source (rejected.json).")
add(G, "P-06", ["C6"], "paper/sections/pa.tex", "tab:pa:failures row F3 (l.279)", "major", A,
    "Binding text %s §10.P6." % D)
add(G, "P-07", ["C7"], "paper/sections/pa.tex", "rem:pa:zf (l.81), last sentence", "major", A,
    "Binding text %s §10.P7." % D)
add(G, "P-08", ["C8"], "paper/sections/pa.tex", "paragraph 'Answer.' (l.159)", "major", A,
    "Binding text %s §10.P8 (item (1) under the full-sum L1; items (2)-(4) under L1^sch; the MAP sentence as a "
    "two-candidate computation, cf. R-09)." % D)
add(G, "P-09", ["C9", "C37"], "paper/sections/pa.tex", "paragraph after "
    "def:pa:lsch (l.26); prop:pa:gibbs (l.148)", "major", A,
    "Binding text %s §10.P9 (Kraft for β ≥ log2 alphabet size; β = log2 23 under-charges by about 3%%; gibbs example with "
    "the alphabet condition); status per §11. (app-model l.58 already states the caveat; model-ident-sound need not act.)" % D)
add(G, "P-10", ["C10", "C-32"], "paper/sections/app-pa.tex; paper/sections/pa.tex", "rem:pa:pointwise (app-pa l.112-113); "
    "pa l.182; rem:pa:shift status (app-pa l.135)", "major", A,
    "Binding text %s §10.P10; status 'proved; open'. rem:pa:shift status 'proved; computed; open' (C-32)." % D)
add(G, "P-11", ["C11"], "paper/sections/pa.tex", "sec:pa:answer (l.298)", "major", A,
    "Binding text %s §10.P11 (broad usage laws; once every needed axiom is cited; narrow/atomic direct use ends weaker); "
    "delete the last sentence (refuted first version; it is in tab:ver:corrections)." % D)
add(G, "P-12", ["C12"], "paper/sections/experiments.tex; paper/sections/app-experiments.tex", "prop:exp:exact(d) (l.35); "
    "app-experiments l.53", "major", A, "Binding text %s §10.P12; status per §11." % D)
add(G, "P-13", ["C13"], "paper/sections/pa.tex", "prop:pa:occam status (l.97)", "major", A,
    "Status per %s §10.P13 / §11." % D)
add(G, "P-14", ["C14"], "paper/sections/app-pa.tex", "l.99 ('Decodable-code costs are 3.6-7.5% higher')", "major", A,
    "Write 3.4-7.5% (min T_LNP assoc 4219.8/4081.9; from the D and D(dec) columns of pa checks/c6_theorem_data.out).",
    note="Verified against c6_theorem_data.out.")
add(G, "P-15", ["C15"], "paper/sections/app-pa.tex", "Euler paragraph (l.208)", "major", AM,
    "Write 'mass 0.0049 (ρ = 0.9) and 0.0727 (ρ = 0.97), summed over false k < 200' (%s §10.P14). Do not quote the "
    "reviewer's tail sum 0.0737." % D,
    note="c5_euler.py sums over k < 200 (verified by the reviewer); the source output is 0.0727 with that truncation.")
add(G, "P-16", ["C21", "MA-07"], "paper/sections/experiments.tex", "l.20 ('where thm:ident:doob does not cover ...'); "
    "E1 setup (l.48: 'Every generator has one component, so thm:ident:doob applies')", "major", A,
    "Cite rem:ident:x5 (new text, MIS M-07): 'the generator is a prior atom and Doob's argument in the (T,w) form "
    "applies to a fixed pool (rem:ident:x5); the data-dependent members (Mem(D_n), causal theories) are covered only by "
    "the pool versions of the soundness theorems'. Same at l.20.")
add(G, "P-17", ["R-14", "C-40", "C-42", "R-44"], "paper/sections/experiments.tex; paper/sections/app-experiments.tex; "
    "paper/sections/pa.tex", "§8.2 (l.45-169), tab:exp:e1/e2/e3a/e3b; prop:exp:comm; rem:exp:refuted; pa.tex rem:pa:e2, "
    "rem:pa:e3b, rem:pa:e6, l.91 (MDL quotation)", "major", A,
    "Restructure §8 per %s §3: keep framing (two sentences, 'a small exact laboratory' only, R-44), implementation "
    "(~0.6 pp), prop:exp:exact, a new summary table tab:exp:summary (experiment | setup in one line | result tested | "
    "finding | where in the main text), rem:exp:limits. Move the E1-E8 paragraphs and tab:exp:e1, e2, e3a, e3b (labels "
    "unchanged) to a new subsection app:exp:results; rem:exp:refuted and pool-construction details to App. G; "
    "prop:exp:comm to pa.tex before rem:pa:e6. Canonical homes: rem:pa:e2 (E2 identification; acceptances only cited "
    "from rem:sound:lumps), rem:pa:e3b (E3(b)), rem:pa:e6 (E6). Delete the AS MDL re-quotation at pa l.91 (canonical in "
    "ident §4.4). App. G does not repeat what tab:exp:e2seen and tab:exp:e4-e8 already show (R-45)." % D)
add(G, "P-18", ["R-25"], "paper/sections/pa.tex; paper/sections/app-pa.tex", "def:pa:lsch (l.22-26); l.91, l.110 (§7.3)",
    "major", A,
    "In the main text distinguish only 'a fixed instantiation grammar' from 'a learned positional grammar shared by all "
    "templates (SDPC)'; give the §7.3 result as 'with a fixed or per-template grammar the split wins linearly "
    "(\\cref{tab:pa:mdl}); with a shared learned grammar it is held at the prior margin up to Occam terms'. Move the code "
    "names NAIVE/PC/DPC/RDPC/CF, u7/G1-G3 descriptions and the decodable-variant details to App. F (%s §3)." % D)
add(G, "P-19", ["R-13", "C-38"], "paper/sections/pa.tex; paper/sections/experiments.tex", "whole sections", "major", A,
    "Meet %s §2: pa 6.5 pp (cap 6.75, including prop:exp:comm), experiments 2.75 (cap 3.0), with the moves of §3 (pa: "
    "details of def:pa:lsch, tab:pa:costs, prop:pa:recursion, prop:pa:chain, code names, rem:pa:sdpcrefuted; experiments: "
    "E1-E8 and their tables, rem:exp:refuted, pool details, proof idea of prop:exp:exact) and tightening (rem:pa:usage, "
    "rem:pa:zf, §7.3 opening and G1 numbers, rem:pa:lumps, rem:pa:merge, text after prop:pa:isigma)." % D)
add(G, "P-20", ["R-16", "C-28"], "paper/sections/pa.tex; paper/sections/app-pa.tex; paper/sections/experiments.tex",
    "pa l.57; unlabelled remark l.106-108; l.298 last sentence; rem:exp:refuted (l.183-192); tab:pa:merge", "major", A,
    "Per %s §5: delete pa l.57 ('The first version's argument ... was wrong'); move the constant-margin remark to App. F "
    "with the new label rem:pa:sdpcrefuted; delete the last sentence of sec:pa:answer; move rem:exp:refuted to App. G; "
    "cite tab:pa:merge in rem:pa:merge (C-28)." % D)
add(G, "P-21", ["R-17", "R-05"], "paper/sections/pa.tex; paper/sections/experiments.tex", "pa l.17 ('Track pa computes "
    "...'), throughout; experiments l.20, l.164 ('does not test the brief's H6')", "major", A,
    "Remove process vocabulary from running text (%s §6.2): 'Track pa computes with ...' → 'The computations of this "
    "section use ...'; 'track experiments' → 'the experiments of §8'; replace 'the brief's H6' by the claim." % D)
add(G, "P-22", ["R-27", "C-26", "R-30"], "paper/sections/pa.tex; paper/sections/experiments.tex; "
    "paper/sections/app-pa.tex", "motive (first use), DTRC (§7.6 title), T_{L∞} (tab:pa:dtrc), Q^- (prop:pa:fragments), "
    "Q_e (experiments l.27), SeenQ/Trim, pool names (tab:exp:e2, tab:exp:e3b)", "major", A,
    "Glosses at first use per %s §6.3 (motive; DTRC; T_{\\mathcal L_∞} with AS Prop 5.12; Q^- = any subset of Q1-Q7; "
    "Q_e = elimination-term law of the chain; SeenQ, Trim); one caption line for pool names in tab:exp:summary and in "
    "App. G (R-30). Rename 'the L_∞ side' and T_{L_∞} to calligraphic (§6.1)." % D)
add(G, "P-23", ["MA-08", "C-25"], "paper/sections/experiments.tex", "l.75 (E2: 'the applicable soundness statement is "
    "thm:sound:shrink'); l.96; l.142-144 and tab:exp:e4 (w* as prior of T*)", "minor", A,
    "After MIS adds the pool version of thm:sound:shrink (M-08), cite 'the pool version of thm:sound:shrink' at l.75 and "
    "l.96 and write \\Rreg(n,8); in E4 and tab:exp:e4 never write w* for the prior constant: π(T*) in (A), and in "
    "(B, C) the pool-version constant 2^{-bits(T*)}/(Σ_H 2^{-bits(T)} + 1) under a name such as W*_pool (%s §6.1)." % D)
add(G, "P-24", ["C-07"], "paper/sections/app-pa.tex", "l.12 (list of results added in the revision)", "minor", A,
    "Keep the sentence on what the referee re-checked; replace the list of unrefereed additions by a pointer to the "
    "complete list in app:ver:process (front F-08); check that they agree.")
# --- minors
for gid, src, file, loc in [
    ("P-25", "C16", "paper/sections/experiments.tex", "E2 item (2) (l.96; moves to App. G)"),
    ("P-26", "C17", "paper/sections/experiments.tex", "E8 paragraph (l.169; moves to App. G; rem:ident:e8 is MIS)"),
    ("P-27", "C18", "paper/sections/experiments.tex", "rem:exp:limits (v) and status (l.174, l.179)"),
    ("P-28", "C20", "paper/sections/experiments.tex", "E1 setup (l.48)"),
    ("P-29", "C22", "paper/sections/app-pa.tex", "l.31 (bounded collection)"),
    ("P-30", "C23", "paper/sections/pa.tex", "rem:pa:streams (iii) (l.144)"),
    ("P-31", "C25", "paper/sections/experiments.tex", "E5(b) (l.149)"),
    ("P-32", "C26", "paper/sections/experiments.tex", "E6 paragraph (l.161)"),
    ("P-33", "C27", "paper/sections/app-experiments.tex", "app:exp:pools (l.68)"),
    ("P-34", "C28", "paper/sections/app-pa.tex", "l.156"),
    ("P-35", "C29", "paper/sections/pa.tex", "l.263 ('the minimal model')"),
    ("P-36", "C32", "paper/sections/app-pa.tex", "proof of prop:pa:readonce(a) (l.132)"),
    ("P-37", "C33", "paper/sections/app-pa.tex", "proof of prop:pa:lower, step 2 (l.37)"),
    ("P-38", "C34", "paper/sections/experiments.tex", "E1 item (3) (l.71)"),
    ("P-39", "C35", "paper/sections/experiments.tex", "E2 item (3) (l.97)"),
    ("P-40", "C36", "paper/sections/pa.tex", "rem:pa:usage (iii) (l.73)"),
    ("P-42", "C-24", "paper/sections/pa.tex", "rem:pa:merge (l.256)"),
]:
    add(G, gid, [src], file, loc, "minor", A, ORIG_FIX)
add(G, "P-41", ["C19", "C-22"], "paper/sections/experiments.tex", "tab:exp:e1 caption (l.65)", "minor", A,
    "Caption: 'Means over 5 seeds and over the three formulas (per-formula values in code/results/e1_universal.md)', or "
    "give the L1^sel row per formula (0.39/0.38/0.47/0.52 and 0.52/0.50/0.65/0.73, from e1_universal.md).")
add(G, "P-43", ["C30"], "paper/sections/experiments.tex", "E7 paragraph (l.164)", "minor", A,
    "In the App. G E7 paragraph write 'favours small unsound lumps (slightly at τ = 1, markedly at τ = 4)'; the "
    "canonical rem:time:e7 (univ-time) carries the same wording.")
add(G, "P-44", ["C31"], "paper/sections/experiments.tex", "E3(a) discussion (l.138)", "minor", A, ORIG_FIX,
    note="The same wording is fixed in rem:ident:e3a by model-ident-sound (M-15).")
add(G, "P-45", ["C-41"], "paper/sections/app-pa.tex", "proof of prop:pa:refl (l.110)", "minor", A,
    "Replace the proof by 'as for \\cref{prop:time:notemplate} (\\cref{app:time:templates}), with Prv_T for Acc_f' "
    "(canonical home of the constant-body argument: app-time).")
add(G, "P-46", ["C-27"], "paper/sections/pa.tex", "uses of lem:pa:motive, prop:pa:fragments, prop:pa:redundant, "
    "rem:pa:pointwise, rem:pa:tower, rem:pa:shift (l.172, 182, 188, 194, 210)", "minor", A,
    "At each main-text use of a statement that lives only in App. F (including those moved now), write its conclusion "
    "and '\\cref{...} in \\cref{app:...}'. Report moved items in the changelog for the CLAIMS.md sync.")
add(G, "P-47", ["R-32"], "paper/sections/pa.tex", "l.91, l.110 (MDL finding)", "minor", A,
    "No re-quotation of AS's MDL sentence in §7.3 (canonical in ident §4.4); one clause with a pointer to rem:ident:mdl.")

# =====================================================================================================
# REJECTED (parts of reviewer fixes, or reviewer claims, that are not adopted)
# =====================================================================================================
reject("MB-03", "Stating, as MB-03 does, that under S_g (g ≡ 1 on provable data, g_∞ > 0) theories that fail finitely "
       "many instances keep positive limit mass.",
       "This holds only if D_+ is read as a set of distinct data, the reviewer's own proviso. If repeated data count, "
       "as in the posterior over the data sequence D_n, every unprovable instance recurs a.s. under full-support Q and "
       "costs a factor g_∞ < 1 at each occurrence, so such theories vanish. def:model:scores (and model notes §1.5) "
       "do not fix the reading, so the revision makes no claim about non-provers under S_g. The S_nc part of MB-03 is "
       "adopted (univ-time U-03).")
reject("MB-01", "The alternative fix 'recommend L1^sel_cit instead' of L1^sel in the good version.",
       "The sources (universal §11) recommend a selection-aware likelihood or a prior over filters; switching the "
       "recommendation is a new claim. The tie under L1^sel_cit (rem:univ:B2cit) is stated as a fact instead (U-01).")
reject("R-23", "Splitting thm:univ:omega into a theorem (a), (b) and a new proposition (c)-(e).",
       "It needs a new label and would invalidate the part references thm:univ:omega(b), (c3), (d), (e) used in model "
       "(tab:model:calculi), intro, discussion, ident and app-verification, across groups. The readability goal is met "
       "by shortening the status head, defining 'faithful' before the theorem and adding a gloss (U-12).")
reject("R-22", "Merging prop:univ:factor and thm:univ:odds into one theorem.",
       "Both labels are cited separately (app-universal, app-verification, model table caption). thm:univ:odds instead "
       "displays its formulas and tab:univ:odds moves to App. B (U-11).")
reject("R-24", "Moving conj:time:polytime to the discussion's open problems (§9.5).",
       "The conjecture is a labelled result cited by the discussion and app-verification; it stays in §6, shortened, "
       "and the open-problem list cites it (U-13).")
reject("R-07", "A short boxed statement of the recommended inducer at the end of §2 (in addition to A1 and §9.2).",
       "That would be a third statement of the same recipe, against the deduplication of C-42 and R-26. The recipe is "
       "stated in full once (sec:disc:good) and in two lines in A1 (F-22).")
reject("R-28", "Renaming the rule probabilities α_• (→ r_•), the query and probe q (→ s_t, ψ), the Q_open parameter "
       "probability ρ (→ p_par), the constant c, the channel K (→ Γ), the vacuous-quantifier count L (→ k).",
       "Each symbol is used across several sections and groups (e.g. ρ in model, universal, app-universal tables and "
       "formulas); the proposed replacements collide with other uses (r_w, r_s, r; p, p_f; Γ_f). The clashes are "
       "across sections, typographically distinct, or resolved by subscripts; a disambiguation sentence is added for α. "
       "Only the same-page clashes are renamed (DECISIONS §6.1).")
reject("C-39", "Keeping the full quotations of Hänni's collapse argument in the introduction.",
       "Conflicts with R-01/R-15: the introduction must reach the answer on page 1. The quotations keep one home, in §6 "
       "where the argument is analysed (DECISIONS §4; F-26, U-17).")
reject("C5", "Quoting the reviewer's re-run (Q + {T_=, T_<, T_Ind} added; T*-equivalent mass 2.2·10^-14) in the paper.",
       "The re-run is a reviewer scratch computation, not a source (code/results or a track record). The paper states "
       "the in-pool figure as in-pool and explains qualitatively, from prop:ident:spare, why a spare-slot equivalent "
       "would decay only polynomially (P-05).")
reject("MA-03", "Replacing the referee's r6 numbers by the reviewer's prefix-code bound (P_T(b) ≤ 2^-18, P_T'(b) ≥ 2^-5).",
       "The bound depends on a code the reviewer chose (2-bit rule tags, 2 bits per symbol), not on a source. The "
       "refutation is stated in the remark's own setting by an elementary inequality, and the r6 numbers are kept with "
       "the setting in which they were computed (M-03).")
reject("MA-04", "Adding the finite-χ² condition to model notes §10 open problem 2.",
       "The track notes are sources, not edited in this revision.")
reject("MA-04", "Stating that without finite χ² the decay lies between n^{-α_σ} and n^{-α_σ/2}.",
       "This is the reviewer's heuristic (a4), not in the sources; the paper adds the hypothesis and makes no claim "
       "about the other case (M-04).")
reject("C3", "Stating in general that 'with β_ax = β memorising wins for every β'.",
       "The general claim rests on the reviewer's argument; the paper states the computed fact for the six theorems "
       "of tab:pa:theorems at the default β (P-03).")
reject("C15", "Writing the tail-corrected mass 0.0737.",
       "The value is the reviewer's own sum; the source output (c5_euler.out) is 0.0727 for false k < 200, which the "
       "paper states with that truncation (P-15).")
reject("MB-04", "The quantitative alternatives ('for Kt-style penalties the change is at most logarithmic in |f| and |χ|' "
       "as a proof sketch).",
       "Not established in the sources; the summary now claims no quantitative bound and says that no time-penalised "
       "prior is defined (U-04).")
reject("R-02", "Reordering the sections of the paper (time and pa before the verifier section; readability review §3.1).",
       "Section order is unchanged: moving the trichotomy to §2 (M-10) removes the definitions-after-use problem, and "
       "reordering whole sections across groups adds risk (forward references, section ranges in the text) without "
       "shortening anything. R-02's reordering of the intro's answers is adopted (F-18).")
reject("R-04", "A figure (small plot) of the c2 posterior trajectories.",
       "Optional and not required: the running-example table tab:univ:c2 moves into §3 instead (U-11).")

# =====================================================================================================
# checks and output
# =====================================================================================================
covered = {}
for g, items in groups.items():
    ids = [i["id"] for i in items]
    assert len(ids) == len(set(ids)), (g, [x for x in ids if ids.count(x) > 1])
    for i in items:
        for s in i["sources"]:
            covered.setdefault(s, []).append("%s:%s" % (g, i["id"]))
rej_map = {}
for r in rejected:
    rej_map.setdefault(r["source"], []).append(r["id"])
missing = sorted(set(orig) - set(covered) - set(rej_map))
if missing:
    print("NOT COVERED:", missing)
    sys.exit(1)

os.makedirs(EDITS, exist_ok=True)
for g, items in groups.items():
    order = {"fatal": 0, "major": 1, "minor": 2}
    items.sort(key=lambda i: (order[i["severity"]], int(re.sub(r"\D", "", i["id"]) or 0), i["id"]))
    json.dump(items, open(os.path.join(EDITS, "%s-issues.json" % g), "w"), indent=1, ensure_ascii=False)
json.dump(rejected, open(os.path.join(EDITS, "rejected.json"), "w"), indent=1, ensure_ascii=False)

# counts
lines = []
tot = {"fatal": 0, "major": 0, "minor": 0}
for g, items in groups.items():
    c = {"fatal": 0, "major": 0, "minor": 0}
    for i in items:
        c[i["severity"]] += 1
        tot[i["severity"]] += 1
    lines.append("%-18s %3d issues: %d fatal, %d major, %d minor" % (g, len(items), c["fatal"], c["major"], c["minor"]))
lines.append("%-18s %3d issues: %d fatal, %d major, %d minor" % ("all groups", sum(tot.values()), tot["fatal"],
                                                                   tot["major"], tot["minor"]))
lines.append("rejected entries: %d (from %d reviewer issues); reviewer issues: %d; all covered" %
             (len(rejected), len(rej_map), len(orig)))
print("\n".join(lines))

# merge map into DECISIONS.md section 14
def keyf(s):
    m = re.match(r"([A-Z]+-?)(\d+)", s)
    return (m.group(1), int(m.group(2)))
mm = ["| reviewer id | review | sev | group issue(s) | rejected part(s) |", "|---|---|---|---|---|"]
for s in sorted(orig, key=keyf):
    mm.append("| %s | %s | %s | %s | %s |" % (s, orig[s]["_review"].replace("issues-", "").replace(".json", ""),
                                             orig[s]["severity"], ", ".join(covered.get(s, [])) or "—",
                                             ", ".join(rej_map.get(s, [])) or "—"))
dec = os.path.join(EDITS, "DECISIONS.md")
txt = open(dec).read()
# section 12: verdicts on fatal and major reviewer issues, generated from the group files
sevrank = {"minor": 0, "major": 1, "fatal": 2}
vshort = {A: "A", AM: "A*", P: "P"}
allitems = {}
for g, items in groups.items():
    for i in items:
        allitems["%s:%s" % (g, i["id"])] = i
v12 = ["| reviewer id | review | reviewer sev | final sev | verdict | group issue(s) | rejected part |",
       "|---|---|---|---|---|---|---|"]
nfm = {"fatal": 0, "major": 0}
for s in sorted(orig, key=keyf):
    if orig[s]["severity"] not in ("fatal", "major"):
        continue
    nfm[orig[s]["severity"]] += 1
    its = [allitems[k] for k in covered.get(s, [])]
    fin = max((i["severity"] for i in its), key=lambda x: sevrank[x])
    vs = sorted(set(vshort[i["verdict"]] for i in its))
    v = "P" if "P" in vs else ("A*" if ("A*" in vs or s in rej_map) else "A")
    v12.append("| %s | %s | %s | %s | %s | %s | %s |" % (s, orig[s]["_review"].replace("issues-", "").replace(".json", ""),
               orig[s]["severity"], fin, v, ", ".join(covered[s]), ", ".join(rej_map.get(s, [])) or "—"))
sec12 = ("## 12. Verdicts on the fatal and major issues\n\n"
         "Every fatal and major reviewer issue was checked against the sources (track notes-final.md, referee.md, check "
         "outputs, code/results); the group files give the evidence and, under `verdict_note`, what was verified. "
         "A = accepted; A* = accepted with a modified fix (an alternative or a part of the reviewer's fix not adopted, see `rejected.json`); P = partly accepted (part of the reviewer's claim or requested change rejected, see `rejected.json`). "
         "No fatal or major issue was rejected outright. Reviewer issues: %d fatal, %d major (generated table).\n\n"
         % (nfm["fatal"], nfm["major"]) + "\n".join(v12) + "\n\n")
pre12, rest = txt.split("## 12. Verdicts on the fatal and major issues", 1)
post12 = "## 13." + rest.split("## 13.", 1)[1]
txt = pre12 + sec12 + post12
head = txt.split("## 14. Merge map")[0]
sec14 = ("## 14. Merge map\n\nEvery reviewer issue appears in at least one group issue or in `rejected.json` "
         "(generated by `research/paper-review/scratch/lead_make_edits.py`, which fails if any id is uncovered).\n\n"
         "Counts:\n\n```\n" + "\n".join(lines) + "\n```\n\n" + "\n".join(mm) + "\n")
open(dec, "w").write(head + sec14)
