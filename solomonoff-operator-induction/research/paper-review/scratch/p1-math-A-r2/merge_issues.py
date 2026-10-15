"""Merge the two independent passes of reviewer p1-math-A into the final deliverables.

Inputs : pass1_issues-p1-math-A.json, pass1_review-p1-math-A.md (first pass, saved copies)
Outputs: ../../p1/issues-p1-math-A.json, ../../p1/review-p1-math-A.md
Pass 2 confirms every pass-1 issue (re-derived independently), upgrades P1A-27 to major, and adds
P1A-37 .. P1A-53.
"""
import json, os, re

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "p1"))
P = "paper/sections/"

issues = json.load(open(os.path.join(HERE, "pass1_issues-p1-math-A.json")))
by_id = {i["id"]: i for i in issues}

# ---- severity change after the second pass
i27 = by_id["P1A-27"]
i27["severity"] = "major"
i27["problem"] += (" The cell sits under 'gap: upper bound' in the table that answers the Kolmogorov-versus-semimeasure"
                   " question, so it states an upper bound on log(M_F/M_prod) that is not proved anywhere: on data with"
                   " inputs of length <= d, M_F may exceed nu_len by up to K^pad(L_{1/2}(M_F,D)) bits, and nothing bounds"
                   " that by K^pad(d+1). (Severity raised from minor to major in the second pass: a reader of the summary"
                   " table takes the cell as a proved bound on the M_prod-versus-M_F gap.)")
i27["evidence"] += (" The source row (foundations notes, Table 4.12, 'on sigma-type data: kappa(n+1)+O(1) (Remark 4.5a)') has"
                    " the same mismatch; Remark 4.5a there also bounds only sigma/M_prod.")

new = [
 {
  "id": "P1A-37", "file": P + "versions.tex",
  "label_or_line": "caption of tab:versions:compare, line 123 (sentence 'by rem:versions:noncomputable no computable family exhibits a gap larger than K(k)+O(1) in any row')",
  "severity": "major",
  "problem": "The caption says that no computable family exhibits a gap larger than K(k)+O(1) 'in any row'. This is false for the last row of the same table, 'M_prod vs M_pq': along the computable family of length-2 sequences ((x_k,0),(x_k,1)), M_prod gives 0 (the sequence is not a data set) while M_pq > 0 (prop:learn:perquery(a)), an infinite gap, as the row itself says. rem:versions:noncomputable, which the caption cites, covers only the five quantities of thm:versions:chain on data sets. For the row 'M_F vs every lsc random-function law' the claim holds by the same argument (log(nu(D_k)/M_F(D_k)) <= -log M_F(D_k) <= K_F(D_k)+O(1) <= K(k)+O(1)), but the remark does not say so.",
  "evidence": "versions.tex l.120 (last row: 'M_pq > 0 = M_prod on inconsistent sequences'); l.99 (rem:versions:noncomputable: 'the five quantities of thm:versions:chain'); learn.tex l.92 (prop:learn:perquery(a): 'positive on inconsistent sequences'). Second-pass script scratch/p1-math-A-r2/a4_realise.py, item (2). The foundations notes (after Table 4.12) contain the same over-general sentence.",
  "fix": "Write: 'By rem:versions:noncomputable (and, for the sixth row, the bound log(nu/M_F) <= K_F+O(1)), along a computable family k -> D_k of data sets no gap in the first six rows exceeds K(k)+O(1). The last row compares objects on sequences; with repeated inputs M_pq and M_prod differ completely, also along computable families.'"
 },
 {
  "id": "P1A-38", "file": P + "versions.tex, learn.tex (and bib/all.bib entry hanni2026request)",
  "label_or_line": "versions.tex l.4 ('He later asked that the paper ...'), l.123 (caption '(Hänni's later request)'), l.137 (title 'Answer to Hänni's request'); learn.tex l.7 ('Hänni describes SFI as ... \\citep{hanni2026request}')",
  "severity": "major",
  "problem": "The visible text refers conversationally to a request for this paper: 'He later asked that the paper \"include an equivalence ...\" (Hänni, 2026c)', the caption '(Hänni's later request)', and the remark title 'Answer to Hänni's request'. The paper's sole author is Hänni, so the paper reports that its author asked the paper for something, and cites the request as 'Personal communication to the author' (bib entry hanni2026request), i.e. a communication from the author to himself. The bib entry's howpublished field also names the internal file 'research/00-brief.md'. learn.tex l.7 cites the same entry for the phrase 'just ideal supervised learning'. The binding note forbids conversational references to 'his request' and the word 'brief', and requires a formal register.",
  "evidence": "OUTLINE.md binding note ('Tone: formal academic register. No conversational references to \"his request\"'; no 'brief'). bib/all.bib l.73-79 (hanni2026request: 'Personal communication to the author, 11 October 2026; quoted verbatim in .../research/00-brief.md'). main.tex: author line 'Kaarel Hänni' alone.",
  "fix": "versions.tex l.4: 'The author's notes contain a section headed \"Equivalence between Kolmogorov version and universal semimeasure version\", whose text is \"need coding theorem\" [hanni2026notes]. We show that the versions are not equivalent: Table 2 summarises ...'. Drop '(Hänni's later request)' from the caption; retitle rem:versions:answer 'The versions are not equivalent'. learn.tex l.7: 'SFI can be viewed as ideal supervised learning. This section states the guarantees behind that view and where they stop.' Do not cite hanni2026request in these sections; if the entry is kept elsewhere, remove the pointer to research/00-brief.md. Throughout these sections prefer 'the author's notes' to third-person 'Hänni's draft' and 'his setting' (the binding note allows ideas to be described as the author's)."
 },
 {
  "id": "P1A-39", "file": P + "versions.tex",
  "label_or_line": "q:versions:open, line 147 ('L_{1/2} is not computably bounded in (d,|D|)')",
  "severity": "minor",
  "problem": "The claim is asserted without proof; the foundations notes (Problem 4.6(b)) and their referee report assert it without proof too. For the default label set Y = {0,1}^* it is true for a trivial reason, which the paper should give: a tape prefix omega_{1:L} that certifies (x,y) determines y given x and L (enumerate T_U until a triple with input x and certificate a prefix of omega_{1:L} appears; consistency fixes its label), so K(y|x) <= L + K(L) + O(1), and L_{1/2}(M_F,{(x,y)}) >= K(y|x) - 2 log K(y|x) - O(1), which is unbounded over y for fixed (d,|D|) = (d,1). For finite Y (binary labels, where the open question is most natural) no proof is given and none is in the sources.",
  "evidence": "versions.tex l.147; foundations notes Problem 4.6(b) and referee.md l.111 (both unproved). Argument above.",
  "fix": "Write: 'For Y = {0,1}^* the tape length L_{1/2} is unbounded in (d,|D|), because a certificate of a label determines it (K(y|x) <= L_{1/2} + K(L_{1/2}) + O(1)); for finite Y we know no computable bound.'"
 },
 {
  "id": "P1A-40", "file": P + "app-learn.tex",
  "label_or_line": "line 94 ('The following proposition is stated here rather than in sec:learn, for the page cap.')",
  "severity": "minor",
  "problem": "Process vocabulary in visible text: 'for the page cap' refers to the internal page budget of OUTLINE.md.",
  "evidence": "app-learn.tex l.94; OUTLINE.md binding note (no process vocabulary).",
  "fix": "Delete the sentence, or write 'We state one further result on chosen inputs.'"
 },
 {
  "id": "P1A-41", "file": P + "app-versions.tex",
  "label_or_line": "proof of thm:versions:chain, step (2), line 17",
  "severity": "minor",
  "problem": "'P_e(y|x) := 1[phi_e(x)=y] ... let g be computable with P_{g(e)} = P_e'. The letter P with a subscript denotes both the deterministic law of program e and the i-th element of the enumeration (P_i) of def:versions:variants, so 'P_{g(e)} = P_e' reads as a tautology. The argument is right once the two objects are distinguished.",
  "evidence": "def:versions:variants (versions.tex l.9) fixes (P_i); app-versions.tex l.17 reuses the symbol.",
  "fix": "Write 'delta_e(y|x) := 1[phi_e(x)=y] ... let g be computable with P_{g(e)} = delta_e', and use delta_e in the rest of step (2)."
 },
 {
  "id": "P1A-42", "file": P + "learn.tex",
  "label_or_line": "proof idea of cor:learn:perstep, line 151 ('the normaliser is at least 2^{-K(f)-c}')",
  "severity": "minor",
  "problem": "'Normaliser' is defined in def:setting:sfi as Z(D,x) = sum_y M_F(D+(x,y)). Here it means nu(D_n), the denominator of the posterior. A reader who looks up the term gets the wrong quantity.",
  "evidence": "setting.tex l.104 (definition of the normaliser); app-learn.tex l.83 (the proof uses nu(D_n)).",
  "fix": "Write 'the posterior denominator nu(D_n) is at least 2^{-K(f)-c}'."
 },
 {
  "id": "P1A-43", "file": P + "learn.tex",
  "label_or_line": "line 134 ('For general prior weights prop:learn:loo is tight within a factor of about 2 (rem:learn:increasing; heuristic in app:learn:remarks)')",
  "severity": "minor",
  "problem": "The parenthesis attaches 'heuristic in app:learn:remarks' to the tightness claim, but that heuristic supports conj:learn:loo (one-exception hypotheses have small total weight), not tightness. The tightness claim rests on rem:learn:increasing alone (LOO errors 1/2 each, sum |B|/2 against the bound |B|).",
  "evidence": "app-learn.tex l.110 (heuristic for conj:learn:loo) and l.112-115 (rem:learn:increasing). Second-pass script a3_learning.py, item (3): LOO sum 8 against bound 16 at |B| = 16.",
  "fix": "Write 'For general prior weights prop:learn:loo is tight within a factor of about 2 (rem:learn:increasing).' and move 'A heuristic for the conjecture is in app:learn:remarks.' after conj:learn:loo."
 },
 {
  "id": "P1A-44", "file": P + "learn.tex",
  "label_or_line": "paragraph 'Errors.', line 115",
  "severity": "minor",
  "problem": "e(x*) is set to 0 for x* in A, but e^wr(x*) and e_norm(x*) are defined through D+(x*,y), which is not a data set when x* is in dom D; the chain e^wr <= e_norm <= e is then stated without covering that case.",
  "evidence": "learn.tex l.115; def:setting:data l.9 (D+(x,y) only for x not in dom D).",
  "fix": "Add '(all three errors are 0 if x* is in A, by the repeated-input convention)'."
 },
 {
  "id": "P1A-45", "file": P + "learn.tex",
  "label_or_line": "cor:learn:mistakes, lines 53-58",
  "severity": "minor",
  "problem": "y_hat_t := argmax_y M_F(y|D_{t-1},x_t) is used with Y countably infinite by default, but the existence of a maximiser and a tie-breaking rule are not stated. The source (foundations Cor 6.6) states existence: the conditionals are positive and sum to at most 1, so only finitely many exceed any positive threshold.",
  "evidence": "foundations notes Cor 6.6 proof ('The maximum exists because only finitely many labels have conditional above any positive threshold'); learn.tex l.53-58 omits it.",
  "fix": "Add '(the maximum exists because the conditionals are positive and sum to at most 1; ties are broken arbitrarily)'."
 },
 {
  "id": "P1A-46", "file": P + "setting.tex",
  "label_or_line": "prop:setting:normalise, line 116",
  "severity": "minor",
  "problem": "L_bar_SFI is defined with Mbar_F, but parts (b) and (c) are statements about laws of random partial (total) functions in general, and the example for (b) is not M_F. Read literally, (b) says that SFI's own normalised loss can depend on the order, which q:setting:normorder says is open.",
  "evidence": "setting.tex l.116 versus l.119 (example law on two inputs) and l.132 (q:setting:normorder).",
  "fix": "Define L_bar_nu for every weak nu, state (b) and (c) for L_bar_nu, and add 'for nu = M_F, (b) is open (q:setting:normorder)'."
 },
 {
  "id": "P1A-47", "file": P + "setting.tex",
  "label_or_line": "rem:setting:conventions, line 127 (ex:setting:swap and thm:setting:coding(a) listed as semimeasure-only)",
  "severity": "minor",
  "problem": "The remark lists ex:setting:swap, and thm:setting:coding(a) beyond single points, as holding 'in the semimeasure convention only'. Part of each transfers by prop:setting:transfer(a): the first revealed pair is a single point, so in every order the normalised loss is at least K(y_first|x_first) - O(1). For the swap data this gives L_bar >= min{K(x_2|x_1), K(x_1|x_2)} - O(1) in every order, and for pairs with K(x_1) >= d and K(x_2|x_1) >= d (which exist for every d) it gives d - O(log d), by symmetry of information. The remark understates what is proved.",
  "evidence": "prop:setting:transfer(a) (app-setting.tex l.158, Z_1 >= 2^{-c}); setting.tex l.156 (swap tight case). Symmetry of information: K(x_1|x_2) >= K(x_1) + K(x_2|x_1) - K(x_2) - O(log d).",
  "fix": "After the swap entry add: '(normalised: at least min{K(x_2|x_1),K(x_1|x_2)} - O(1) in every order, by the single-point transfer)'."
 },
 {
  "id": "P1A-48", "file": P + "setting.tex, versions.tex, learn.tex",
  "label_or_line": "all \\paragraph{Open question.}\\label{q:...} (q:setting:rpf l.99, q:setting:normorder l.132, q:setting:twosided l.161, q:setting:level l.175, q:versions:explicit l.102, q:versions:open l.147) and every \\cref to them",
  "severity": "minor",
  "problem": "A label after an unnumbered \\paragraph refers to the enclosing subsection, so every cross-reference to an open question prints a section number. Inside Section 2.3, rem:setting:h1a says 'For random-function laws it is open (Section 2.3)'; rem:learn:h2(iii) also prints '(Section 2.3)'; the 'open' column of Table 2 prints '§ 2.3' and '§ 3.4'. A reader cannot locate the question from the reference.",
  "evidence": "pdftotext of paper/main.pdf, p. 10 ('it is open (Section 2.3)'), p. 16 (Table 2), p. 17 (Remark 4.2(iii)).",
  "fix": "Give open questions their own counter (e.g. \\newcounter{oq}[section] with \\refstepcounter{oq} inside the paragraph heading 'Open question \\theoq.' and \\crefname{oq}{Open question}{Open questions}). This keeps them out of theorem environments, as OUTLINE.md requires, and makes \\cref print 'Open question 2.1'."
 },
 {
  "id": "P1A-49", "file": P + "setting.tex",
  "label_or_line": "def:setting:data, line 9 ('any infinite decidable X and countable Y, |Y| >= 2, will do')",
  "severity": "minor",
  "problem": "Lower semicomputability of laws, the effective enumeration (P_i) of conditional semimeasures, computable injections beta: Y -> Y' (thm:setting:invariance), the enumeration 'Y_bot with bot last' (proof of prop:setting:includes(c)) and the alphabet enumeration of lem:setting:realise all need a fixed effective presentation of Y. 'Countable' alone does not supply one.",
  "evidence": "setting.tex l.9; app-setting.tex l.77 and l.97; setting.tex l.142.",
  "fix": "Write 'countable Y with a fixed computable enumeration (for example a decidable set of strings)'."
 },
 {
  "id": "P1A-50", "file": P + "learn.tex",
  "label_or_line": "rem:learn:ideal, item (1), line 165 ('the prior \"a random lower-semicomputable labeller\"')",
  "severity": "minor",
  "problem": "M_F is the Bayes mixture over machine laws. Whether every lower-semicomputable law of a random function is a machine law is open (q:setting:rpf), so 'a random lower-semicomputable labeller' suggests a larger prior class than the one for which universality is proved. This is the learning-section counterpart of P1A-25.",
  "evidence": "thm:setting:universal; q:setting:rpf (setting.tex l.99); rem:learn:h2(iii).",
  "fix": "Write 'the prior \"a random labeller computed by a probabilistic machine with one shared random tape\" (machine laws weighted by m(i))'."
 },
 {
  "id": "P1A-51", "file": P + "learn.tex",
  "label_or_line": "prop:learn:splits, line 119",
  "severity": "minor",
  "problem": "The proposition names no loss convention, against the paper's own rule (setting.tex l.14). The equality 'expected test loss = -log(nu(f|_B)/nu(empty))/|B|' uses the order-free total of prop:setting:order and holds only in the semimeasure convention; in the normalised convention only the upper bound follows (prop:setting:normalise(a)). The error bound holds in both.",
  "evidence": "app-learn.tex l.61 (proof uses prop:setting:order). Second-pass script a3_learning.py, item (4): the semimeasure identity holds exactly in 200 random mixtures.",
  "fix": "Add '(semimeasure convention; in the normalised convention the expected test loss is at most this)'."
 },
 {
  "id": "P1A-52", "file": P + "app-setting.tex",
  "label_or_line": "line 154 ('Check c10 found agreement between (star) and order independence on 400 of 400 random laws with positive two-point cells (r13: 300 of 300)')",
  "severity": "minor",
  "problem": "Besides the script names (P1A-10), the sentence overstates the evidence. In the cited runs (star) and order independence hold in none of the random laws, so the agreement confirms only '(star) fails and the law is order-dependent'. The direction '(star) implies order independence' was tested only on laws built to satisfy (star) (c10(a2)).",
  "evidence": "research/tracks/foundations/checks/c10_normalised_convention.out.txt (a1): 'criterion true in 0; order-free in 0'; (a2): 400 built laws. Second-pass a1_semimeasures.py, item (5): 300/300 random positive laws agree with (star) true in 0; 200/200 laws with label-independent definedness satisfy both.",
  "fix": "Write: 'A direct computation confirms both directions: random laws with positive two-point cells violate (star) and are order-dependent (400 of 400), and laws constructed to satisfy (star) are order-independent (400 of 400).'"
 },
 {
  "id": "P1A-53", "file": P + "setting.tex",
  "label_or_line": "prop:setting:includes(a), line 69 ('K(nu_P) <= K(P)+O(1)')",
  "severity": "minor",
  "problem": "K(P) for a conditional semimeasure P is used in Section 2 but defined only in learn.tex l.7, through the enumeration (P_i) introduced in def:versions:variants (Section 3). Section 2's definition of K(nu) presupposes an enumeration that has not yet been given for conditional semimeasures. This is in addition to the undefined symbols listed in P1A-23.",
  "evidence": "setting.tex l.12 and l.69; versions.tex l.9; learn.tex l.7.",
  "fix": "Move the enumeration of lsc conditional semimeasures (trimming each P(.|x)) and the definition K(P) := min{K(i): P_i = P} to sec:setting:data."
 },
]
issues.extend(new)
SEV = {"fatal": 0, "major": 1, "minor": 2}
issues.sort(key=lambda i: (SEV[i["severity"]], int(i["id"].split("-")[1])))
keys = ["id", "file", "label_or_line", "severity", "problem", "evidence", "fix"]
issues = [{k: i[k] for k in keys} for i in issues]
json.dump(issues, open(os.path.join(OUT, "issues-p1-math-A.json"), "w"), indent=1, ensure_ascii=False)

counts = {s: sum(1 for i in issues if i["severity"] == s) for s in SEV}
print("counts", counts, "total", len(issues))

# ---------------- review markdown ----------------
p1 = open(os.path.join(HERE, "pass1_review-p1-math-A.md")).read()
sec2 = p1[p1.index("## 2. What I checked"):p1.index("## 3. Independent computations")]
sec3 = p1[p1.index("## 3. Independent computations"):p1.index("## 4. Remarks that are not issues")]
sec4 = p1[p1.index("## 4. Remarks that are not issues"):p1.index("## 5. Numbered issue list")]
sec3 = sec3.replace("## 3. Independent computations", "### 3.1 First pass")
sec3 = sec3.replace("* `scratch/p1mathA_issues.py` generates `p1/issues-p1-math-A.json` and the list below from one source.\n", "")
sec2 = sec2.replace("## 2. What I checked, item by item", "## 2. What was checked, item by item")
ROWS = [
 ("| verified; matches F §1 (repeated-input convention) |", "| verified; matches F §1 (repeated-input convention) (P1A-49: effective presentation of Y) |"),
 ("| `prop:setting:normalise` (a)–(c) and its example (2/3, 1/2, 1/4) | verified + code |",
  "| `prop:setting:normalise` (a)–(c) and its example (2/3, 1/2, 1/4) | verified + code (P1A-46: notation of (b), (c)) |"),
 ("(iii) law: criterion false, order-free true) |", "(iii) law: criterion false, order-free true) (P1A-52: how the evidence is reported) |"),
 ("(P1A-28: wording, \"in expectation\") |", "(P1A-28: wording, \"in expectation\"; P1A-47: the swap entry partly transfers) |"),
 ("| `thm:versions:chain`, steps (1)–(5) | verified |", "| `thm:versions:chain`, steps (1)–(5) | verified (P1A-41: notation in step (2)) |"),
 ("| `rem:versions:noncomputable`, `q:versions:explicit` | verified |",
  "| `rem:versions:noncomputable`, `q:versions:explicit` | verified |\n| `q:versions:open` | consistent with F Problem 4.6(b) (P1A-39: the L_{1/2} sentence) |"),
 ("(P1A-27: row M_prod vs M_F; P1A-11: caption) |", "(P1A-27: row M_prod vs M_F; P1A-37 and P1A-11: caption; P1A-38: caption register) |"),
 ("| `rem:versions:answer` | verified |", "| `rem:versions:answer` | verified (P1A-38: title and register) |"),
 ("| `cor:learn:mistakes` | verified |", "| `cor:learn:mistakes` | verified (P1A-45: existence of the maximiser) |"),
 ("| error definitions and e^wr ≤ e_norm ≤ e | verified + code |", "| error definitions and e^wr ≤ e_norm ≤ e | verified + code (P1A-44: case x* ∈ A) |"),
 ("LOO bound on all 31 subsets) |", "LOO bound on all 31 subsets) (P1A-51: convention; P1A-43: misattached reference) |"),
 ("| P1A-30 (computability of P); P1A-15 (hedges) |", "| P1A-30 (computability of P); P1A-50 (prior class); P1A-15 (hedges) |"),
]
for a, b in ROWS:
    assert a in sec2, a
    sec2 = sec2.replace(a, b)

head = f"""# Paper 1: mathematical review A (setting, versions, learning, Appendices A–C)

Reviewer: p1-math-A. Scope: `paper/sections/setting.tex`, `versions.tex`, `learn.tex`, `app-setting.tex`, `app-versions.tex` and `app-learn.tex`, as compiled into `paper/main.pdf` (build of 12 Oct 2026, 16:59). Sources checked against: `research/tracks/foundations/notes-final.md` (with `referee.md`, `checks/`, `referee_code/`), `research/tracks/context/notes-final.md` §§1, 2.4, 5 (with checks c3, c4, c7), history notes Prop 2.4 and Prop 4.10, examples notes Prop 2.9, Hänni's notes in `research/prior/` (quotations checked verbatim against `hanni-sfi-notes.md` and `hanni-sfi-draft-2025-09.txt`) and `research/00-brief.md`.

This report merges two independent passes over the same files. Each pass read every statement and proof line by line, against the sources and on its own, and wrote its own code. Pass 1 code: `research/paper-review/scratch/p1mathA_s{{1,2,3}}_*.py`. Pass 2 code: `research/paper-review/scratch/p1-math-A-r2/a{{1,2,3,4}}_*.py`. All outputs are saved next to the scripts. The second pass confirms every issue of the first (P1A-01 to P1A-36), raises P1A-27 from minor to major, and adds P1A-37 to P1A-53. The machine-readable list is `p1/issues-p1-math-A.json`.

## 1. Verdict

The mathematics of these sections is sound and follows the foundations and context final notes closely. No theorem, proposition, lemma or corollary is false as stated, and every proof is complete except where a sketch is labelled as such. Both passes recomputed every number they could (Section 3); all agree with the paper to the printed precision. Neither pass found a step that fails.

The defects are of five kinds.

1. **One unsupported claim (P1A-01, fatal).** `rem:versions:prediction`(3) says the single shortest program "can exceed SFI's loss … by about log(k(d+2)) on k incompressible binary labels". Only the upper bound (`prop:versions:covering`) is proved; the only lower bound is log d − O(1) at k = 2. The same sentence is in the foundations notes, also unproved. Replacing "by about" with "by at most", and giving the bound, fixes it.
2. **One wrong formula in a proof (P1A-02).** The proof of `prop:learn:freshnoise`(b) sums from j = 0, where Σ_y P(y|x₀)⁰ counts labels. The statement is right; the transcription from the source is not.
3. **Summary statements that say more than is proved, or drop a hypothesis (P1A-03 to P1A-08, P1A-27, P1A-37).**
   * `rem:versions:prediction`(2) compares W with SFI where only the comparison with the fair-coin law is proved (P1A-03); (4) says the M^w-versus-M_F gap lives on "data no random function produces", which is false (P1A-04).
   * After the swap example, the history-aware lower bound needs "lower-semicomputable" and a predictor-dependent constant (P1A-05). The loss form of the invariance theorem holds only in the semimeasure convention (P1A-06). The recommendation's "agree up to K(dom D)" fails for M_pq on inconsistent sequences (P1A-07). `rem:versions:hist` drops the maximum over labels (P1A-08).
   * In Table 2, the M_prod-versus-M_F upper-bound cell cites a bound on ν_len/M_prod, not on M_F/M_prod (P1A-27); and the caption's "no computable family exhibits a gap larger than K(k)+O(1) in any row" is false for the table's own last row (P1A-37).
4. **arXiv-standard violations a reader would notice (P1A-09 to P1A-15, P1A-38).** Track and script names in running text ("foundations r6", "(context c3)", "Source: foundations Table 4.12", a "Computations" paragraph listing referee scripts); an internal-correction remark (`rem:learn:cesaro`); "hypothesis H7"; printed hedges ("search snippet only", "not checked against the source"); and conversational references to "Hänni's request", including a citation of a personal communication from the sole author to himself whose bibliography entry points to the internal brief (P1A-38). The conversion pass that strips `\\status`/`\\src` will not catch these.
5. **Minor issues ({counts['minor']}).** Quantifiers, undefined or overloaded notation, statements that use objects defined only in proofs, cross-references to open questions that print section numbers, and register.

**Counts:** {counts['fatal']} fatal, {counts['major']} major, {counts['minor']} minor ({len(issues)} issues).

"""

sec_pass2 = """### 3.2 Second pass

All scripts are deterministic (seed 20261012), use exact rationals where cheap, and were run with `python3 -I`. Outputs are in `*.out.txt` next to each script in `research/paper-review/scratch/p1-math-A-r2/`.

* `a1_semimeasures.py`: `ex:setting:weaknotrpf` (a) weak, ∇ = −1; (b) ν_tri weak (27 inequalities), P₁ ≥ (2/3)ν_tri on all 10 support points; an LP over **all** laws of random partial functions gives the best domination constant 0.666666666667 for k = 1 and 0.444444444444 for k = 2 (100 support data sets, 729 outcomes), i.e. exactly (2/3)^k as `thm:setting:weakvsmachine`(v) says; Möbius identities on 30 random laws (1920 identities, 0 failures); the `prop:setting:normalise`(b) law (2/3 against 1/2, (⋆) false) and the (iii) law ((⋆) false, order-independent); (⋆) against order independence on 300 random laws with positive cells (agreement 300/300, (⋆) true in 0) and on 200 laws with label-independent definedness (both hold in 200/200; this is the positive direction that P1A-52 asks the paper to report); `prop:setting:transfer`(a),(b) on 3240 input lists with repeats (normalised products sum to exactly 1; |L̄ − (L − Σ log 1/Z_t)| ≤ 8.9·10⁻¹⁶); the swap XOR machine (probability exactly 2^{−d}, d ≤ 5).
* `a2_versions.py`: ℓ_d = ⌈log(d/log 3)⌉ − 1 is the largest ℓ with 3^{2^ℓ} < 2^d (floating check for d ≤ 2·10⁵, exact integer check for d < 2000) and g ≥ log d − 2; the arithmetic of `thm:versions:nocoding`'s last clause; every inequality in the proof of `prop:versions:covering` (padding, count, union bound, log N_cov) for d < 3000 and k ∈ {1,2,3,5,10,40}; exact minimum covering families by brute force (2, 2, 4, 2 for (d,k) = (0,1), (1,1), (1,2), (2,1), all below N_cov); the Kleitman–Spencer family for N ≤ 12 and "at most d + 6 functions for d ≤ 40" (maximum excess exactly 6); k-wise uniformity of lowest-bit polynomial hashing over GF(2³), GF(2⁴) for k ≤ 3 (960 point sets, all uniform); the counting step of `prop:versions:shared`; max j(x) = 2^{d+1} − 2.
* `a3_learning.py`: `prop:learn:curve` closed forms against brute force (w ∈ {1/2, 1/4, 1/5, 1/16, 1/100}; r₀ = 0.9125, r₁ = 1.5437 at w = 1/16; crossing of (1+w)³ = 8w at √5 − 2 ≈ 0.2361; r₀ + 2r₁ = log(1/w)); fresh-noise consistency probabilities 0.950000, 0.112864, 0.000498 at n = 2, 10, 20 (exact dynamic programme) and the bound of (b) on a grid; `rem:learn:increasing` (last step 1 bit, split mean 0.2555, LOO sum 8 against bound 16); `prop:learn:loo` and the `prop:learn:splits` identity on 200 random mixtures of partial and shared-tape hypotheses (0 violations); `cor:learn:perstep` (a) and (b) exactly for n ≤ 4 (0 violations); a finite analogue of `thm:learn:merging` with 7 laws and 200 random past-only adaptive rules each (largest Σ E d_t / (−log w) = 0.61 ≤ 1); a finite analogue of `thm:learn:batch`(a) (0 violations of either bound); `prop:learn:perquery`(a) on a 6-law class (0 violations of the chronological inequality or multiset invariance, M_pq ≤ M_prod on consistent sequences, strict at repeats in 32 cases, M_pq > 0 on all 40 inconsistent sequences); the constants of `prop:learn:typical` for n ≤ 2·10⁵; the active-learning mean; Pinsker for sub-probabilities (20 000 random pairs).
* `a4_realise.py`: the sequential realisation in the proof of `thm:setting:weakvsmachine`(ii) on 300 random weak semimeasures over three inputs: equality on domain S in every case, "≤" on every nonempty proper subset (strict in 2667 cases); and the computable family behind P1A-37.
* `merge_issues.py` builds `p1/issues-p1-math-A.json` and Section 6 of this report from one source.

The second pass also re-derived by hand every proof in the six files (the list in Section 2 applies to both passes). Points it found that the first pass did not are P1A-37 to P1A-53. The most consequential are P1A-37 (a false caption sentence in the main summary table) and P1A-38 (conversational and self-referential citation of "Hänni's request", which the binding note forbids).

"""

sec5 = """## 5. Notes on the second pass's additions

* **P1A-39.** The open question says L_{1/2} is not computably bounded. For the default Y = {0,1}^* this has a one-line proof (a certificate determines the label, so L_{1/2} ≥ K(y|x) − O(log K(y|x)) on one-point data), which the paper should give; for finite Y it is unproved.
* **P1A-47.** `rem:setting:conventions` lists the swap example as semimeasure-only. Part of it transfers: the first revealed pair is a single point, so `prop:setting:transfer`(a) gives min{K(x₂|x₁), K(x₁|x₂)} − O(1) in every order, which is d − O(log d) for pairs with K(x₁), K(x₂|x₁) ≥ d.
* **Checked and not an issue.** The quotations of Hänni's notes in these sections ("you have a bunch of input-output pairs …", "use different bits of randomness …", "input-output pairs from a function", "Thm 1 (template)" with "at most a constant (depending on P but not the distribution)", the headings of §§2.1–2.2 of the draft, "need coding theorem") match `research/prior/` verbatim. The numbers quoted from the track checks (12.5 against 1 for r6; 63/300 and 0.8731 for r12; 0.95, 0.113, 5·10⁻⁴ for c5; 10.919980315195, 7.33 and 10.64 for context c3; d + 6 for d ≤ 40; 400/400 and 16 200 for c10) match the saved outputs. The full build has no undefined references or citations.

"""

def fmt(i, n):
    return (f"**{i['id']}** [{i['severity']}] `{i['file']}`, {i['label_or_line']}\n\n"
            f"* *Problem.* {i['problem']}\n* *Evidence.* {i['evidence']}\n* *Fix.* {i['fix']}\n")

lst = "## 6. Numbered issue list (most severe first)\n\n" + "\n".join(fmt(i, n) for n, i in enumerate(issues, 1))
md = head + sec2 + "## 3. Independent computations\n\n" + sec3 + sec_pass2 + sec4 + sec5 + lst
open(os.path.join(OUT, "review-p1-math-A.md"), "w").write(md)
print("wrote", os.path.join(OUT, "review-p1-math-A.md"), len(md))
