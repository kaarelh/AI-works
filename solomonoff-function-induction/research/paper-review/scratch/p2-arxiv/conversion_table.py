"""Build the arXiv conversion table for Paper 2: every theorem-like environment whose \\status is not plain
'proved', with the academic form it should take once \\status/\\src are stripped. Reads envs.json (from
extract_status_p2.py); the actions below are the reviewer's. Usage: python3 -I conversion_table.py envs.json out.md"""
import json, sys
envs = json.load(open(sys.argv[1]))
A = {
 'rem:absorb:reading': ('Remark', 'Drop the tag. Keep the citations (Poland--Hutter; earlier report). Replace "a dog classifier with millions of bits certainly is" by "a classifier with millions of parameters typically is" or delete; whether a model is longer than $\\ell_U$ depends on the machine, as the sentence before says.'),
 'prop:absorb:pricing': ('Proposition + proof (App. B.3)', 'Drop the tag. The 2.5431 example after the statement already reads "a direct computation (code in the accompanying repository) gives"; keep it as is.'),
 'rem:absorb:why': ('Remark', 'Drop the tag. Replace the named citation "[the chain theorem, the shared-coin proposition and the remark after it]" by numbered references to the companion paper (currently Thm 3.4, Prop 3.7, Rem 3.8).'),
 'prop:absorb:price': ('Proposition + proof (App. B.4)', 'Drop the tag; the computation paragraph in App. B.4 stays.'),
 'prop:absorb:history': ('Proposition + proof (App. B.5)', 'Drop the tag; the computation sentence in App. B.5 stays.'),
 'rem:absorb:wyeth': ('Remark "Answer to the absorption objection"', 'Drop the tag. Rename the label to rem:absorb:answer (the arXiv source is public). In (iii) replace the unsourced quotation "``nothing is lost at $\\lambda=1$\'\' holds only relative to the product class" by "so the restriction is costless at $\\lambda=1$ only relative to the product class, not relative to $\\MF$".'),
 'prop:algstat:set': ('Proposition + proof', 'Drop the tag. Move the two sentences "The two bounds trade off ... does not follow" out of the proposition into a remark after the proof, phrased as "The natural strengthening ... fails: ...", as the binding note prescribes.'),
 'prop:algstat:coarse': ('Proposition (computable rational hypotheses) + proof (App. F.1)', 'Drop the tag; the statement is already restricted to computable rational hypotheses. Replace "the thresholding above is presumably that translation" by a precise pointer to the section of Vereshchagin--Shen (2017) on distributions versus sets after checking it, or delete the sentence.'),
 'prop:algstat:parity': ('Proposition + proof (App. F.2)', 'Drop the tag. Move the sentence "A direct computation ... gives ... (Table 3)" out of the "Proof idea" paragraph into a short remark ("Numerical illustration ($\\kappa=0$)").'),
 'rem:algstat:restricted': ('Remark', 'Drop the tag. After reading Vereshchagin--Vitanyi (2010) and Milovanov (2016) in full, replace "As far as we can tell from the abstracts" and "A comparison with the full texts is left open" by a direct comparison; if that is not done, use "To our knowledge".'),
 'rem:algstat:reading': ('Remark', 'Drop the tag.'),
 'lem:split:hash': ('Lemma + proof (App. E.3)', 'Drop the tag.'),
 'lem:teacher:sharpfloor': ('Lemma + proof (App. C.2)', 'Drop the tag.'),
 'prop:limits:plain': ('Proposition + proof (App. D.1)', 'Drop the tag. Move "if all inputs are revealed, this is a fraction $1-9.6\\cdot10^{-24}$ of the error inputs at the original sizes ($\\kappa=0$)" out of part (a) into the remark or proof-idea paragraph that follows; a $\\kappa=0$ number is an illustration and does not belong in a proved statement.'),
 'rem:limits:schedule': ('Remark', 'Drop the tag; citations to Zhu--Srebro and Zhu--Ohannessian--Srebro present.'),
 'prop:limits:envelope': ('Proposition + proof (App. D.4)', 'Drop the tag. Rephrase the sentence after it as "Consequently the conclusion of Theorem 4.7 does not extend to every error rule with density $2^{-10}$ and description length about $10^4$ bits" and give the share as "about a quarter to a third of the window\'s logarithmic width ($\\kappa=30$ and $\\kappa=0$)".'),
 'prop:limits:rateblind': ('Proposition + proof (App. D.2)', 'Drop the tag.'),
 'lem:limits:robust': ('Lemma + proof (App. D.2)', 'Drop the tag; the $d_0$ numbers after it already read "a direct computation gives".'),
 'prop:limits:separable': ('Proposition + proof (App. D.3)', 'Drop the tag.'),
 'prop:limits:guard': ('Proposition + proof (App. D.3)', 'Drop the tag; numbers after it already in the right form.'),
 'prop:limits:noident': ('Proposition + proof (App. D.3)', 'Drop the tag; (i) cites Gneiting--Raftery. Move "in the original example the losses are 1.0, 0.0112, 0.0112, 0 at $c=10^{-1},\\dots,10^{-7}$" out of part (ii) into an example after the proposition.'),
 'prop:limits:inputlaw': ('Proposition + proof', '(plain proved) Drop the tag.'),
 'rem:limits:method': ('Remark', 'Drop the tag; write "a direct computation gives $p<0.123$". Move the last sentence ("A window for $p<0.123$ ... looks within reach but is not proved") to Open problems (2) as a question.'),
 'prop:related:computable': ('Proposition + proof (App. G)', 'Drop the tag. Either expand the "By inspection" proof into a short itemised proof that names, for each lemma, the property of the class it uses (the current text nearly does this) or label it "Proof (sketch)". Mark the claims in the paragraph after it ("$\\kappa_g$ is of order $d\\log d$ and $c_{\\rm hi}$ shrinks by a factor of order $\\log d$") as heuristic.'),
 'rem:related:cold': ('Remark', 'Drop the tag; Wenzel et al. cited.'),
 'rem:related:nn': ('Remark', 'Drop the tag.'),
 'rem:related:mdl': ('Remark', 'Drop the tag. Read the three papers (all freely available) and replace "As their abstracts describe them" and the final sentence ("whether their analysis covers some of this can only be settled from the full texts") by a direct statement of what they prove; until then "To our knowledge".'),
 'rem:related:posteriors': ('Remark', 'Drop the tag. Check the SafeBayes criterion in Grunwald (2012) and Grunwald--van Ommen (2017) and state the consequence plainly, or delete the SafeBayes sentence; delete "This is our reading, not checked against the papers\' precise criteria".'),
 'rem:related:t5': ('Remark', 'Drop the tag.'),
 'rem:related:new': ('Remark, or merge into the introduction\'s contributions and prior-work paragraphs', 'Drop the tag. Delete "though our search was limited to abstracts" once the literature has been read; keep "We do not claim ...".'),
 'rem:setup:persample': ('Remark', 'Drop the tag.'),
 'lem:setup:hull': ('Lemma + proof (App. A.2)', 'Drop the tag. Move the last paragraph of the statement ("The strengthening of the converse in (iv) ... is false: ...") into a remark after the lemma, in the form the binding note prescribes ("The converse in (iv) cannot be weakened to ...: ...").'),
 'lem:split:ville': ('Lemma + proof (App. E.1)', 'Drop the tag; Ville (1939) cited.'),
 'lem:split:stream': ('Lemma + proof (App. E.2)', 'Drop the tag.'),
 'prop:split:si': ('Proposition + proof (App. E.4)', 'Drop the tag; for (iii) cite the theorem number in Li--Vitanyi (2008) for $M\\ge2^{-K(\\nu)-O(1)}\\nu$.'),
 'thm:split:private': ('Theorem + proof (App. E.5)', 'Drop the tag; Kakutani (1948) cited.'),
 'rem:split:reading': ('Remark', 'Drop the tag.'),
 'thm:split:shared': ('Theorem + proof (App. E.6)', 'Drop the tag.'),
 'ex:split:noisyparity': ('Example (numerical illustration)', 'Drop the tag; the text already says "illustration" and "a direct computation (code in the accompanying repository)". Candidate for the appendix (length).'),
 'rem:teacher:hanni': ('Remark "The original calculation"', 'Drop the tag; "A direct computation (code in the accompanying repository) confirms this arithmetic" is already the right form.'),
 'rem:teacher:numbers': ('Remark', 'Drop the tag. State the rounding convention of Table 2 (see issue on rounding).'),
 'rem:teacher:hypotheses': ('Remark', 'Drop the tag.'),
 'lem:teacher:list': ('Lemma + proof (App. C.1)', 'Drop the tag.'),
 'lem:teacher:floor': ('Lemma + proof (App. C.2)', 'Drop the tag.'),
 'cor:teacher:fulltable': ('Corollary + proof (App. C.4)', 'Drop the tag. Move "At $d=20$ ... a direct computation gives the window $\\lambda\\in(1,1.19\\cdot10^4]$ at $\\kappa=0$ and $(1,6456]$ at $\\kappa=30$" out of the corollary into a remark, and write the window with an open right end, $(1,1.19\\cdot10^4)$, to match part (i).'),
 'cor:teacher:sampled': ('Corollary + proof (App. C.5)', 'Drop the tag.'),
 'ex:teacher:version1': ('Example', 'Drop the tag; the example is an instance of Theorem 4.7 with numbers; keep "a direct computation" wording in App. C.6.'),
 'prop:teacher:concentration': ('Proposition + proof (App. C.7)', 'Drop the tag. Move the numerical sentence ("With $\\hat J_g$ replaced by its population value ... at most $2^{-758}$") out of the proof-idea paragraph into a remark.'),
 'rem:absorb:examples': ('Proposition (it has a proof in App. B.1) or Remark', '(status "proved" on a remark) Promote to a Proposition "Classes with an absorbing member", since App. B.1 proves it; drop the tag.'),
 'rem:absorb:condsemi': ('Remark with inline argument', '(status "proved" on a remark) Drop the tag; the inline argument suffices.'),
 'rem:split:siprograms': ('Remark with inline argument', '(status "proved" on a remark) Drop the tag; replace $2^{-\\lambda|p|}$ by $2^{-\\lambda\\ell(\\pi)}$ (notation).'),
}
rows = []
for e in envs:
    st = e['status']
    lab = e['label']
    if st is None:
        continue
    if st.strip() == 'proved' and lab not in A:
        continue
    form, act = A.get(lab, ('?', 'NO ACTION DEFINED'))
    rows.append((e['file'].replace('sections/', ''), e['line'], e['env'], lab, st, form, act))
out = ['| # | file:line | env | label | current status | academic form | action |', '|---|---|---|---|---|---|---|']
for i, r in enumerate(rows, 1):
    out.append('| %d | %s:%d | %s | `%s` | %s | %s | %s |' % (i, r[0], r[1], r[2], r[3], r[4].replace('|', '/'), r[5], r[6].replace('|', '/')))
plain = [e['label'] for e in envs if e['status'] and e['status'].strip() == 'proved' and e['label'] not in A]
defs = [e['label'] for e in envs if e['status'] is None]
out.append('')
out.append('Plain `proved` items (tag removed, nothing else): ' + ', '.join('`%s`' % l for l in plain) + '.')
out.append('')
out.append('Definitions (no status; delete the `\\src` note only): ' + ', '.join('`%s`' % l for l in defs) + '.')
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
missing = [r[3] for r in rows if r[6] == 'NO ACTION DEFINED']
print(len(rows), 'rows; missing actions:', missing)
