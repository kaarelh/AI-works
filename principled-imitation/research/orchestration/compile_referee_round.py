"""Compile verification/referee-round.md from the structured results of the editors of the referee round.

Usage (from the project folder):
    python3 research/orchestration/compile_referee_round.py DIR
where DIR holds one JSON file per part, apply_edit_KEY.json or apply_KEY.json, as returned by the
workflow research/orchestration/apply.js (fields: summary, decisions, unchecked, for_lead).
The lead's own decisions (Sections 0, 11, 12, 13, the reference lists) are in LEAD below.
"""
import json
import os
import sys

KEYS = [
    ("rehearsal-core", "Sections 1, 2, 3.1, 3.3 to 3.6"),
    ("hellinger-runs", "Sections 3.2 and 5.2"),
    ("lower-bounds", "Section 4; Theorem N3 and Proposition S2 in Section 6.1"),
    ("one-mind", "Section 5.1"),
    ("shift-abstain", "Sections 6 and 7"),
    ("property-batch", "Sections 8.1 to 8.3, 8.6, 8.7"),
    ("property-online", "Sections 8.4 and 8.5"),
    ("assumptions", "Section 1 (last paragraph), Section 3.7, Sections 9 and 10"),
]

LEAD = [
    ("reader", "F1", "applied", "Section 0, the answer on the property idea: Pr5 is stated with the human answering every question and the imitator committing first; Pr6 is stated as the form after the human has left, with its assumptions."),
    ("reader", "F2", "applied", "Section 0: the sentence that one program is impossible for a human who varies is gone. A separate answer \"Copy or predictor\" states R6(b) with its confidence, the failure of a posterior draw, R6(c) and H2, the steeper prior, and what does not make the program a copy. The answer on Solomonoff induction is separate and points to Sections 4.1, 6.1 and 11."),
    ("reader", "F3", "applied", "Section 0: \"Failing only obviously costs more than failing rarely\" is an answer of its own, in sentences that need no later section: the mixture's errors are not marked; the threshold rule on the rehearsed system (Ab1); the minimum rule and why a sound parameter makes it refuse (Ab2, N4); the rules for batches (Ab5, Ab6)."),
    ("reader", "F4", "applied in other words", "The counterpart of the published result on batches was worked out and proved (Proposition Ab5, Section 7.4), and extended to whole runs of a rehearsed scaffold (Theorem Ab6). Both were examined by two referees each (reports shift-abstain-ab5-*.md and shift-abstain-ab6-*.md). Section 0, Section 9.5, test 6 of Section 10 and open question 8 say what they give and what they do not."),
    ("reader", "F5", "applied", "Section 0, the answer on what the note does not give, has the sentence on the human reading what the imitator's runs wrote; the paragraph is in Section 9.5 (editor of assumptions)."),
    ("reader", "F6", "applied", "Section 0: the bet on a class without patches is said to change the rate and leave the factor K, with the number of rounds below which I1 says nothing; open question 2 likewise."),
    ("reader", "F7", "applied", "Section 0 opens with a paragraph \"In short\" that states the price, that every bound on imitation is empty for a person, what can be afforded, and that most statements are known; the answer on what the note does not give lists the further limits. The list of bets opens Section 9 (editor of assumptions)."),
    ("reader", "F8 to F12", "applied", "Section 0: the heading on lower bounds says \"in the worst case over classes\"; N2 with its class, range and the price of reuse (N2d); the heading on low stakes names the fixed fraction and says that the tolerance is assumed; S5 and the quantifiers of N7; the shift that decomposition produces (S4(i)) and the guard (R7)."),
    ("reader", "F13(c), F15, F18, F20 items 1 and 2, F24, F30 item 1, F33 items 4 and 7", "applied", "Section 0: \"A guarantee and a check\"; \"Every bound on imitation is in K\"; terms defined at first use (class, Bayes mixture, unfaithful calls, memorisers, open system, whitelist, class without patches); the qualifiers of the coin example and of Pr2; sentences in the place of fragments."),
    ("reader", "F22 item 4, F33 item 6", "applied", "Section 11: the column head of the table; the remark that for L = 16 the second system tolerates no fault."),
    ("reader", "F25, F26, F34", "applied", "R6(a) is cited in Section 11 in the form in which Section 5.1 now states it; the note has a list of references and `references.md` exists; README.md was rewritten from the new Section 0."),
    ("mathematics", "F1, F19, F22, F27, F37", "applied", "Section 0: no contradiction with R6(c); R6(b) with its confidence; N2 with its class and range and the condition for \"cheaper to let the human make the calls\"; \"Every bound on imitation is in K\"; N7 with the range of the number of questions."),
    ("mathematics", "F2, F20, F39(ii), (iii)", "applied", "Section 12 has 2.9642; Section 13, item 3, has the + 3 of the halved weights; Section 11 cites R6(a) as L·(i₀ − 1); the status of R6(c) is the same everywhere."),
    ("consistency", "N2, R6(b), N7 and the price of shifts in Section 0; 2.9641; R6(c); E1; the last round; additive work; letters of Section 12", "applied", "Sections 0, 12 and 13 as described in the report; the last round (Section 13, item 6) is now stated from Propositions 6.3 and 6.4 of `proofs/rehearsal-core.md`, which the lead read for this."),
    ("references", "its Section 3 for Sections 12 and the lists; findings 11 to 15", "applied", "The final Section 12 and the two lists are the referee's; the lead added the sentences on Ab5 with entries for Goldwasser et al. (2020) and Goel et al. (2023), and the corrections that the editors of the parts sent (letters of the cited bounds, the halving algorithm, Spencer's game, the term \"low stakes\")."),
    ("reproduction", "1 (the constant 2.9641), 2 to 6", "applied / noted", "The constant is corrected. The remarks on scripts that need an argument, `sympy`, more than ten minutes or more than 4 GB are recorded in README.md and in the proof files."),
]


def load(d, key):
    for name in (f"apply_edit_{key}.json", f"apply_{key}.json"):
        p = os.path.join(d, name)
        if os.path.exists(p):
            r = json.load(open(p))
            return r.get("edit", r)
    return None


def main():
    d = sys.argv[1]
    out = []
    out.append("# The referee round: what was found and what was done\n")
    out.append("Five referees read the note as assembled on 16 November 2026: `referee-reader.md` (a cold reading for the researcher), `referee-math.md` (the mathematics as printed), `referee-consistency.md`, `referee-references.md` and `reproduction.md`. None found a theorem wrong. The reader's report had six major findings, all on how Section 0 presented the results; the referee of the mathematics found six sentences false as printed (a contradiction between Section 0 and R6(c), one constant, three missing ranges, one misstated hypothesis) and three gaps (two definitions and one argument missing).\n")
    out.append("This file lists the decision on every finding. The lead decided the general questions (`research/orchestration/apply-notes.md` on the working branch) and the findings on Sections 0, 11, 12 and 13; one editor per part decided the findings on that part and recorded them, with the old and the new text, in the subsection \"Referee round\" of the section \"Checking\" of the proof file `../proofs/KEY.md`. The tables below are the editors' own lists, shortened to the decision; the proof files have the detail.\n")
    out.append("After the editors, a second reader examined each part's changes (`KEY-referee-round.md`), and a fixer decided those findings (recorded under \"Second reader\" in the same subsection of the proof file). Then the note was assembled again and read by four more referees (`final-section0.md`, `final-consistency.md`, `final-reader.md`, `reproduction-2.md`).\n")

    out.append("## The lead's decisions (Sections 0, 11, 12, 13, the lists of references, README)\n")
    out.append("| report | finding | decision | what was done |")
    out.append("|---|---|---|---|")
    for rep, f, dec, what in LEAD:
        out.append(f"| {rep} | {f} | {dec} | {what} |")
    out.append("")

    for key, where in KEYS:
        r = load(d, key)
        out.append(f"## Part `{key}` ({where})\n")
        if r is None:
            out.append("(No record was returned for this part; see the proof file.)\n")
            continue
        out.append(r["summary"].strip() + "\n")
        out.append("| report | finding | decision |")
        out.append("|---|---|---|")
        for x in r.get("decisions", []):
            fin = x["finding"].replace("|", "/").replace("\n", " ")
            dec = x["decision"].replace("|", "/").replace("\n", " ")
            out.append(f"| {x['report']} | {fin} | {dec} |")
        out.append("")
        un = r.get("unchecked", [])
        if un:
            out.append(f"*What only this editor had seen when the round ended* ({len(un)} items; each was then given to the second reader of the part): see `{key}-referee-round.md`.\n")
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "verification", "referee-round.md")
    open(path, "w").write("\n".join(out))
    print("written", os.path.normpath(path), len("\n".join(out).split()), "words")


if __name__ == "__main__":
    main()
