"""Build the arXiv conversion table for Paper 2 (review B): every theorem-like environment whose \\status is
not plain 'proved', with its academic form and rewording. Reads envs.json (from extract_status.py in this
folder); the per-label actions are this reviewer's. Writes conversion_table.md.
Usage: python3 -I conversion_table.py envs.json conversion_table.md"""
import json, sys
envs = json.load(open(sys.argv[1]))
ACT = {
 'rem:absorb:reading': ('Remark', 'Delete tag. Keep the citation of Poland and Hutter (2005). Replace "a dog classifier with millions of bits certainly is" by "a model of millions of bits is longer than $\\ell_U$ for any reasonable reference machine".'),
 'prop:absorb:pricing': ('Proposition (proof in App. B.3)', 'Delete tag. The value 2.5431 already reads "a direct computation (code in the accompanying repository) gives"; keep.'),
 'rem:absorb:why': ('Remark', 'Delete tag; cite the companion paper\'s results by number, not by informal name (P2X-24).'),
 'prop:absorb:price': ('Proposition (proof in App. B.4)', 'Delete tag; the computed check (24,732 cases) stays in App. B.4. Add "(semimeasure convention)" to (iv) (P2X-35).'),
 'prop:absorb:history': ('Proposition (proof in App. B.5)', 'Delete tag; the block-identity check stays in App. B.5.'),
 'rem:absorb:wyeth': ('Remark "Answer to the absorption objection"', 'Delete tag. Rename the label to rem:absorb:answer (arXiv distributes the source). In (ii) cite the grokking note, which contains the quoted sentence, instead of the LessWrong thread. In (iii) remove the quotation marks around "nothing is lost at $\\lambda=1$" (P2X-33).'),
 'prop:algstat:set': ('Proposition + Remark', 'Delete tag. Move the refuted reading out of the statement into a short Remark: "The bounds do not show that $\\lambda$ slightly above $1$ selects an approximately minimal sufficient statistic: as $\\lambda\\to1$ the length bound becomes vacuous."'),
 'prop:algstat:coarse': ('Proposition (computable rational hypotheses)', 'Delete tag. Check Vereshchagin and Shen (2017; arXiv 1607.08077) for the set/distribution equivalence and cite the section, or delete "the thresholding above is presumably that translation" (P2X-19).'),
 'prop:algstat:parity': ('Proposition (proof in App. F.2)', 'Delete tag; numbers already in academic form (Table 3).'),
 'rem:algstat:restricted': ('Remark', 'Delete tag. Read Vereshchagin and Vitanyi (2010) and Milovanov (2016) and rewrite without "As far as we can tell from the abstracts" and "A comparison with the full texts is left open" (P2X-16).'),
 'rem:algstat:reading': ('Remark', 'Delete tag; replace "Hanni\'s \'1 bit paying for 1 bit\'" and "as Hanni expected" by a citation of the note in the author\'s voice.'),
 'lem:split:hash': ('Lemma (App. E.3)', 'Delete tag.'),
 'lem:teacher:sharpfloor': ('Lemma (App. C.2)', 'Delete tag; replace "(script c7_run2.py, part (C), seed 7)" by the content-named script (P2X-39).'),
 'prop:limits:plain': ('Proposition (proof in App. D.1)', 'Delete tag.'),
 'rem:limits:schedule': ('Remark', 'Delete tag. Keep the citations of Zhu and Srebro (2025) and Zhu, Ohannessian and Srebro (2026) after checking the full texts (P2X-15); replace "This confirms Hanni\'s remark" by "as anticipated in [grokking note]".'),
 'prop:limits:envelope': ('Proposition (proof in App. D.4)', 'Delete tag. "the extension of Hanni\'s example ... is false" becomes "density and description length alone do not suffice"; keep the counterexample.'),
 'prop:limits:rateblind': ('Proposition (proof in App. D.2)', 'Delete tag.'),
 'lem:limits:robust': ('Lemma (proof in App. D.2)', 'Delete tag; rename the constants a, b (clash with the parity a and the behaviour b) to alpha_0, beta_0 (P2X-34).'),
 'prop:limits:separable': ('Proposition (proof in App. D.3)', 'Delete tag.'),
 'prop:limits:guard': ('Proposition (proof in App. D.3)', 'Delete tag; candidate for the appendix (P2X-26).'),
 'prop:limits:noident': ('Proposition (proof in App. D.3)', 'Delete tag; (i) keeps the citation of Gneiting and Raftery (2007).'),
 'rem:limits:method': ('Remark', 'Delete tag. Replace "A window for p<0.123 and c well above 2^{-m} looks within reach but is not proved" by an open question (P2X-43).'),
 'prop:related:computable': ('Proposition + Remark', 'Delete tag. Move the paragraph of examples (time-bounded classes, circuits) into a Remark after the proposition; it already says "constants not computed".'),
 'rem:related:cold': ('Remark', 'Delete tag. Check the definition of the cold posterior in Wenzel et al. (2020) (PMLR, open access).'),
 'rem:related:nn': ('Remark', 'Delete tag; attribute the "bridge question" to the companion paper (P2X-42).'),
 'rem:related:mdl': ('Remark (Related work)', 'Delete tag. Read the three papers and state their results precisely; delete "As their abstracts describe them" and "can only be settled from the full texts" (P2X-15).'),
 'rem:related:posteriors': ('Remark (Related work)', 'Delete tag. Check the SafeBayes criterion in Grunwald (2012) and either state the consequence with its reason or delete the two sentences (P2X-18).'),
 'rem:related:t5': ('Remark (Related work)', 'Delete tag; cite the report once as [Cla26, Section 8], then "the earlier report" (P2X-23).'),
 'rem:related:new': ('Paragraph "Novelty" (Related work)', 'Delete tag; delete "though our search was limited to abstracts"; after the check of P2X-15/P2X-16 write "To our knowledge the following are new" (P2X-20).'),
 'lem:setup:hull': ('Lemma + Remark', 'Delete tag. Move the counterexample out of the statement into a Remark: "The converse in (iv) cannot be weakened to \'on the boundary of C\': ...". The computed check stays in App. A.2.'),
 'rem:setup:persample': ('Remark', 'Delete tag; replace "Hanni\'s remark that ..." by "as noted in [grokking note]".'),
 'lem:split:ville': ('Lemma (proof in App. E.1)', 'Delete tag; Ville (1939) is already cited.'),
 'lem:split:stream': ('Lemma (proof in App. E.2)', 'Delete tag.'),
 'prop:split:si': ('Proposition (proof in App. E.4)', 'Delete tag; (iii) already cites Li and Vitanyi (2008).'),
 'thm:split:private': ('Theorem (proof in App. E.5)', 'Delete tag; Kakutani (1948) is already cited.'),
 'rem:split:reading': ('Remark', 'Delete tag; "the split Hanni hoped for" becomes "the split asked for in Section 1".'),
 'thm:split:shared': ('Theorem (proof in App. E.6)', 'Delete tag.'),
 'ex:split:noisyparity': ('Example', 'Delete tag; the title already says "an illustration".'),
 'rem:teacher:hanni': ('Example "The three-hypothesis calculation"', 'Delete tag; retitle without the author\'s name (P2X-12).'),
 'lem:teacher:list': ('Lemma (proof in App. C.1)', 'Delete tag.'),
 'lem:teacher:floor': ('Lemma (proof in App. C.2)', 'Delete tag.'),
 'rem:teacher:numbers': ('Remark "Numbers for the running example"', 'Delete tag; retitle (P2X-12).'),
 'rem:teacher:hypotheses': ('Remark', 'Delete tag.'),
 'cor:teacher:fulltable': ('Corollary (proof in App. C.4)', 'Delete tag; print the computed window as an open interval at the right end (P2X-31).'),
 'cor:teacher:sampled': ('Corollary "Finite samples"', 'Delete tag; retitle without the author\'s name.'),
 'ex:teacher:version1': ('Example "The total-bits version of the example"', 'Delete tag and "(instance of Theorem 4.7)"; write "By Theorem 4.7 with d=100, m=10, p=2^{-6}, ..." in the text.'),
 'prop:teacher:concentration': ('Proposition (proof in App. C.7)', 'Delete tag; in App. C.7 correct "-1000+242.3" to "-1000+241.7" (P2X-32).'),
}
rows = [e for e in envs if e['status'] is not None and e['status'].strip() != 'proved']
out = ['| # | label | file:line | env | current \\status | arXiv form | action |', '|---|---|---|---|---|---|---|']
for i, e in enumerate(rows, 1):
    form, act = ACT.get(e['label'], ('(same)', 'NO ACTION DEFINED'))
    st = e['status'].replace('|', '/').replace('\\cref{thm:teacher:main}', 'Thm 4.7')
    out.append(f"| {i} | `{e['label']}` | {e['file'].replace('sections/','')}:{e['line']} | {e['env']} | {st} | {form} | {act} |")
plain = [e['label'] for e in envs if e['status'] is not None and e['status'].strip() == 'proved']
defs = [e['label'] for e in envs if e['status'] is None]
out.append('')
out.append(f'Plain "proved" ({len(plain)}; delete the tag and the \\src note only): ' + ', '.join(f'`{l}`' for l in plain) + '.')
out.append('')
out.append(f'Definitions ({len(defs)}; no status; delete the \\src note only): ' + ', '.join(f'`{l}`' for l in defs) + '.')
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
print(len(rows), 'rows; no action:', [e['label'] for e in rows if e['label'] not in ACT])
