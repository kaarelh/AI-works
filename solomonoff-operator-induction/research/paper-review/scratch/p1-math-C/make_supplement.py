"""Builds p1/issues-p1-math-C-supplement.json from this reviewer's full list (reviewer2_full_issues.json):
keeps only issues not already in the concurrent run's p1/issues-p1-math-C.json (C-xx ids), revises three of them in
the light of C-01 and C-31, and records the duplicate mapping.  Usage: python3 -I make_supplement.py <full.json> <out.json>"""
import json, sys
full = {x["id"]: x for x in json.load(open(sys.argv[1]))}
keep = ["P1C-01", "P1C-03", "P1C-06", "P1C-09", "P1C-11", "P1C-12",
        "P1C-04", "P1C-17", "P1C-21", "P1C-23", "P1C-24", "P1C-27", "P1C-29", "P1C-32", "P1C-33",
        "P1C-34", "P1C-35", "P1C-37", "P1C-39", "P1C-41"]
out = []
for k in keep:
    x = dict(full[k]); out.append(x)
d = {x["id"]: x for x in out}
# P1C-01: correction of C-31 (and of app-ood.tex); add the 1.06 prior-sum note from P1C-25
d["P1C-01"]["problem"] = ("Correction to C-31 of the concurrent run, and to app-ood.tex. The 'tilted' extra program does NOT get 'prior mass equal to (or ten times) "
    "that of all plain programs' (app-ood.tex line 39; repeated in C-31's diagnosis and fix). It gets tilt times the mass of the plain programs consistent with "
    "the training data, i.e. of the single intended class |x|, which is 7.4 times smaller. The printed numbers 0.557/0.114 belong to that weighting; with the "
    "described weighting they would be 0.148/0.017. At x10 the one extra program carries 44% of the total prior mass (and the masses sum to 1.06, harmless because the "
    "predictive is a ratio). The main text's 'about 0.11 when one extra program tilts the grammar' hides all of this. This is a wrong description of a computation that "
    "a reader would act on, so major, not minor.")
d["P1C-01"]["fix"] = ("app-ood.tex: 'The tilted rows add one program \"if |x| even then 0 else |x|\" with prior mass equal to (or ten times) that of the intended program |x|, "
    "the only plain program consistent with the training data; with the factor ten it carries 44% of the prior mass (the predictive is computed after normalising).' "
    "ood.tex line 171: '... and about 0.11 when a single extra program with ten times the prior mass of the intended one is added'. tab:ood:hanni: '0.11 with a tilted prior'. "
    "Do NOT apply C-31's suggested wording ('ten times (resp. once) the prior mass of all plain programs'), which is wrong.")
# P1C-04: dependent on C-01
d["P1C-04"]["problem"] = ("Depends on C-01 (which this reviewer confirms independently, scratch/p1-math-C/c4_pointwise_e_check.py). rem:ood:answer(iii) bounds 'the error at a test point' "
    "from above by 2^{L_nu(f)-sep(x*;A|f)+O(1)}. In this section 'the error' is the semimeasure-convention e(x*), for which the paper proves no upper bound (prop:ood:labelled bounds e_norm "
    "and e^wr only) and at line 134 even asserts that none exists. If C-01 is fixed by the minimal option (deleting the sentence without adding the e(x*) bound), (iii) remains unproved as "
    "stated. The lower end also needs the -K(y) term (cf. C-39).")
d["P1C-04"]["fix"] = ("Either add the pointwise bound e(x*) <= 2^{L_nu(f)-K(x*|f)+c} to prop:ood:labelled with the waiting-sampler proof (C-01's full option), which makes (iii) true as "
    "written; or restrict (iii) to e_norm (upper end) and e^wr (lower end, with K(y)).")
# P1C-09: only the hedges not covered by C-11(i) and C-28
d["P1C-09"]["problem"] = ("Beyond C-11(i) and C-28 (which cover 'Each of these should be checked ...', '(we have seen only the abstract)' and the Vovk sentence), the following printed "
    "reading-status hedges remain non-standard: related.tex line 8 'according to their abstract', 'in their abstract', 'that it agrees with Hutter's construction up to constant factors "
    "is expected but was not checked against his texts'; line 10 'whether their random-selection result coincides with \\cref{prop:learn:splits} we have not checked'; line 18 'At the "
    "level of a search that saw abstracts and secondary sources only'; nn.tex line 91 'These descriptions follow the abstracts.' In addition related.tex ('is expected but was not "
    "checked') and hist.tex line 135 ('is known, but not checked against the sources') contradict each other on the Hutter identification.")
d["P1C-09"]["fix"] = ("Use one consistent formulation in related.tex and hist.tex, e.g. 'We expect, but do not prove, that \\SFIhist{} agrees with Hutter's universal chronological semimeasure up to "
    "constant factors (he works with finite alphabets).' Replace 'according to their abstract'/'in their abstract' by plain attribution ('X show that ...') or by 'X report that ...'; "
    "delete 'we have not checked' (or say 'we do not compare the two statements here'); delete the first clause of rem:related:new and 'These descriptions follow the abstracts.'")
d["P1C-23"]["problem"] = ("The OUTLINE requires every lower bound to say that it bounds the defined (wrong or abiding) mass and holds in both conventions; thm:ood:twosided (a)-(c) and "
    "ex:ood:easyhard never say so (the decidedness of x* in ex:ood:easyhard is C-33).")
d["P1C-23"]["fix"] = "Add after thm:ood:twosided: 'All lower bounds in this subsection are on defined outputs, so they hold in both conventions.' Repeat in ex:ood:easyhard."
mapping = {"P1C-02": "C-05", "P1C-05": "C-14", "P1C-07": "C-08", "P1C-08": "C-11(ii)", "P1C-10": "C-10", "P1C-13": "C-02",
           "P1C-14": "C-12", "P1C-15": "C-27", "P1C-16": "C-25", "P1C-18": "C-04", "P1C-19": "C-07", "P1C-20": "C-34",
           "P1C-22": "C-30", "P1C-25": "C-32 (+ P1C-01)", "P1C-26": "C-24", "P1C-28": "C-23", "P1C-30": "C-37", "P1C-31": "C-22",
           "P1C-36": "C-16", "P1C-38": "C-09", "P1C-40": "C-21"}
json.dump(out, open(sys.argv[2], "w"), indent=1, ensure_ascii=False)
json.dump(mapping, open("duplicate_mapping.json", "w"), indent=1)
from collections import Counter
print(len(out), Counter(x["severity"] for x in out))
