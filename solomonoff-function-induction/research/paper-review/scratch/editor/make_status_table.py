"""Write edits/status-rendering.md: every non-plain \\status of both papers with its group and required rendering."""
import json, os, re
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
GROUP_P1 = {}
for f in ['setting','versions','learn','app-setting','app-versions','app-learn']: GROUP_P1[f+'.tex']='p1-setting'
for f in ['hist','examples','app-hist','app-examples']: GROUP_P1[f+'.tex']='p1-hist-ex'
for f in ['ood','comp','nn','related','steeper','app-ood','app-comp','app-nn']: GROUP_P1[f+'.tex']='p1-ood'
SPECIAL = {
# ---------------- Paper 1
'rem:learn:positive': 'Remark titled "(informal)"; argument headed "Proof sketch."; Chater-Vitányi only as "cf."; delete "their exact model was not checked".',
'thm:comp:timebounded': 'Keep (a) only; (b) moves to rem:comp:runtime with "Proof sketch." (DECISIONS §F5); "(corrected)" disappears; toy-instance numbers after the proof idea with "A direct computation (code in the accompanying repository) ...".',
'prop:comp:round': 'Regret only; running-time sentence moves to rem:comp:runtime (§F5); "10.0 bits against the bound 20" introduced by "A direct computation ...".',
'prop:comp:history': 'Regret only; running-time clause moves to rem:comp:runtime (§F5).',
'thm:hist:minimax': 'Restrict case (b) to reveal laws that do not see f; new rem:hist:minimaxsketch with "Proof sketch." (§F3).',
'rem:ex:where': 'Plain remark; other direction "under Assumptions (LHG-even) and (LHG-odd)" (§F22).',
'prop:hist:lhg': 'Two assumption environments + "Under Assumption ..." (§F22).',
'conj:ex:raw': 'Becomes a question environment (same label), text of §F21.',
'conj:hist:algmi': 'Conjecture without "(untested)", followed by "We have neither a proof nor a counterexample."',
'conj:learn:loo': 'Conjecture (precise; keep); its heuristic in App C headed "Heuristic (not a proof)".',
'conj:ood:natural': 'Becomes a question environment (same label), text of §F21; delete the paragraph after it.',
'prop:hist:info': 'Plain proposition; (b) keeps "The natural strengthening ... is false"; numbers, if any, "A direct computation ...".',
'rem:learn:cesaro': 'Rewritten as "per-step versus averaged bounds" (§F26).',
'rem:comp:distinct': 'Title "distinct inputs are needed"; state the fact; 469 bits via "A direct computation ...".',
'thm:hist:randchain': 'Title "the randomised chain; the oracle reading fails".',
'prop:learn:freshnoise': 'Plain proposition; (c) "The natural strengthening ... fails" (§F16); numbers via "a direct computation"; delete the H7 sentence.',
'prop:ood:draftfalse': 'Title "the literal two-sided bounds fail"; literal bounds displayed first, "as stated in an earlier draft in [Hän26]".',
'rem:ood:lopsided': 'State the fact directly; delete the last sentence (P1O-06).',
'rem:setting:h1a': 'Title "weak and machine universality differ"; "one might expect" (by analogy with Zvonkin-Levin); random-function case points to q:setting:rpf (question).',
'prop:hist:operator': 'Title "the per-query mixture ignores the history"; stated for M_pq only (§A8).',
'lem:setting:realise': 'Heading "(for binary alphabets this is classical; see Zvonkin and Levin 1970)"; delete "(not checked against the source)".',
'rem:comp:selection': '"The first row (for the conjunction target) and the last row are proved here; the slides also state the other rows, which we do not prove" (§F19); table numbers via "An exact computation ...".',
'cor:hist:H4': 'Plain corollary; Hutter sentence of §A8 after it; no identification claim.',
'cor:learn:mistakes': 'Heading "(cf. the halving argument of [BF72, Lit88])".',
'prop:learn:occam': 'Heading "(standard; [BEHW87])"; "we include the union-bound proof for completeness".',
'rem:learn:hutterEX': 'Deleted from learn.tex; one sentence with this label in related work (p1-ood inserts): "Hutter (2007) lists supervised learning among the problem classes of the AIXI model."',
'rem:nn:slides': 'Remark "claims of the slides" (≤ 12 lines): "The slides state ...; of these, this paper proves ..." (§F18); exact caveat quotations.',
'rem:nn:literature': 'Moves to related work as prose with its label; abstract-level wording; delete "These descriptions follow the abstracts."',
'rem:related:new': 'Becomes \\paragraph{Novelty.}\\label{rem:related:new} with "To our knowledge ..." list of §A8.',
'rem:versions:operator': 'M_pq as the paper\'s own object; Solomonoff (2008) at abstract level; no product formula, no Özkural (§A8).',
'prop:setting:transfer': 'Plain; relativised coding theorem cited as standard; check ids deleted.',
'prop:comp:occam': '(a) "(Blumer et al. 1987)"; (b) proved in App G.',
'rem:comp:majority': 'Plain remark citing Littlestone (1988) and Littlestone-Warmuth (1994); "An informal argument in [Hän26] ..."; ends with "(\\cref{thm:comp:ladder})." (P1O-30).',
'thm:comp:ladder': 'Heading credits the construction to the slides\' Appendix K; tightness sentence (§F19); computation sentence "A direct computation (code in the accompanying repository) for d = 3, 4, 5 and seven tie rules confirms ...".',
'prop:learn:splits': 'Plain; one sentence "The exchangeability argument is standard \\citep{cesabianchi2004generalization}"; convention added (P1S-39).',
'prop:nn:typical': 'Heading "(standard)".',
'thm:nn:walsh': '(a) "cf. Yang and Salman (2019); also in the slides\' Appendix J"; (b) "the standard dimension argument; cf. Kamath et al. (2020)".',
'rem:nn:oddparity': '(a) "the Boolean-cube analogue of Basri et al. (2019)", abstract wording; (b),(c) proved; kernel accuracies "A direct computation ... gives ...; we do not prove this".',
'prop:ood:machine': '"(cf. Leike and Hutter 2015 for AIXI)".',
'rem:hist:exploit': 'Title "(informal)"; keep the informal/proved split.',
'rem:learn:relations': 'Plain remark.', 'rem:learn:interventions': 'Delete (grep: learn.tex, app-learn.tex).',
'rem:comp:apples': 'Title "like-for-like comparison"; cite prop:hist:orderfree; may move to App G.',
'rem:comp:gap': 'Plain; "For formulas on d = 3, an exhaustive computation (code in the accompanying repository) ..."; may move to App G.',
'rem:hist:H4verdict': 'Title "summary: hypotheses that see the previous inputs"; "conditionally on Assumptions (LHG-even) and (LHG-odd)".',
'rem:learn:ideal': 'Plain remark; items per P1S-31.', 'rem:nn:bridge': 'Plain remark.', 'rem:nn:rigorous': 'Delete (§F18).',
'rem:ood:answer': 'Title "summary of the positive statements"; (iii), (iv) per §F8.',
'rem:hist:thm1open': 'Title "open cases"; "a direct computation (code in the accompanying repository) certifies ...".',
'rem:versions:Wrate': 'Plain; the open rate points to q:versions:open.', 'prop:ex:orderfree': 'Plain; sharper weak case points to q:ex:depthweak.',
'rem:ex:email': 'Title "a heuristic argument for Eisenstat\'s example"; author\'s argument paraphrased (§A7); normalised case points to q:ex:normalised.',
'rem:learn:h2': 'Title "scope of dominance"; (iii) points to q:setting:rpf.',
'rem:learn:lastiterate': 'Plain; "A direct computation on 300 random finite instances (code in the accompanying repository) gives max (n+1)r_n/K = 0.873"; open bound points to the Open problems.',
'rem:setting:conventions': 'Plain; wording of P1S-30.', 'rem:ex:fresh': 'Plain.', 'prop:comp:samplers': 'Plain; P^samp_A (§E); may move to App G.',
'prop:ex:cychist': 'Plain.', 'cor:hist:thm1': 'Title "a dominance theorem for computable reveal laws"; sentence after it per §F4; (c) restricted per P1H-24.',
'prop:nn:functionspace': 'Plain proposition (no "(trivial)").', 'prop:nn:upper': 'Plain; Gaussian-weights part as a sentence "We only sketch this for Gaussian priors: ...".',
'prop:ood:relative': 'Plain; "posterior weight of p under W (up to a constant factor under M_F)".',
'rem:learn:increasing': 'Becomes \\begin{example}[learning curves can increase] (same label); "a direct calculation gives 0.255".',
'prop:ex:cycsi': 'Plain; finite numbers "A finite illustration (code in the accompanying repository) gives ..." or dropped.',
'rem:versions:hashing': 'Title "a hashing bound"; "\\cref{prop:versions:tape}(b) is stronger"; no quotation of the hashing hint.',
'tab:ex:cycle': 'Delete the \\status/\\src calls inside the float by hand; caption "simulation with a fixed seed; code in the accompanying repository".',
'tab:ex:eisenstat': 'Delete the \\status/\\src calls inside the float by hand; caption per P1H-25.',
'prop:ood:labelled': 'Plain; delete the computational confirmation of disjointness; sentence after it per §F7.',
'ex:ood:hanniexamples': 'Title "three examples"; (a), (c) per §F17; grammar numbers via "An exact computation ...".',
'lem:ex:behind': 'Plain lemma; exact values move after it ("A direct computation ... gives").',
# ---------------- Paper 2
'rem:absorb:reading': 'Plain; "a model of millions of bits is longer than ell_U for any reasonable reference machine".',
'rem:absorb:why': 'Plain; companion results by the titles of DECISIONS §A6 (numbers in phase 4).',
'rem:absorb:wyeth': 'Printed title "Answer to the absorption objection" (label kept); items per §F41; citations to hanni2026grokking.',
'prop:algstat:set': 'Refuted reading moves to a remark after the statement (§F43).',
'prop:algstat:coarse': 'Plain; delete the Vereshchagin-Shen "presumably" sentence (§A8); may move to App F.',
'rem:algstat:restricted': 'Plain; only the Hamming-ball sentence (§A8); Milovanov "see also".',
'rem:algstat:reading': 'Plain; author\'s voice with a citation; "1 bit paying for 1 bit" verbatim.',
'rem:limits:schedule': 'Plain; §F34 replacements; Zhu-Srebro citations at abstract level; "as anticipated in [grokking note]".',
'prop:limits:plain': 'Plain; (a) computed fraction moves after the statement (§F42/§F34); (b) last sentence per §F34.',
'prop:limits:envelope': 'Plain; "the extension ... is false" → "density and description length alone do not suffice"; parenthesis per §F45.',
'prop:limits:noident': 'Plain; (i) cites Gneiting-Raftery; (ii) losses move after the statement (§F42).',
'rem:limits:method': 'Plain; "looks within reach" sentence becomes part of q:limits:open; may move to App D.',
'prop:related:computable': 'Plain; examples paragraph becomes a remark after it; moves to computable.tex (§D2).',
'rem:related:cold': 'Prose paragraph in §2 Related work (label kept); Wenzel et al. at abstract level.',
'rem:related:nn': 'Moves to computable.tex; "the bridge question of the companion paper, which the slides motivate"; "deterministic parameter settings that reproduce the noisy labels".',
'rem:related:mdl': 'Prose in §2 (label kept); abstract-level descriptions; Grünwald-Langford by its title; P2M-20 wording.',
'rem:related:posteriors': 'Prose in §2 (label kept); §F46 wording; SafeBayes sentences deleted.',
'rem:related:t5': 'Prose in §2 (label kept); "the earlier report" after the single pinpointed citation.',
'rem:related:new': 'Prose "Novelty" paragraph in §2 (label kept): "To our knowledge ..." (§A8).',
'rem:setup:persample': 'Plain; "as noted in [grokking note]".',
'lem:setup:hull': 'Counterexample to the strengthening of (iv) moves to a remark after the lemma (§F43); "open horizontal ray" (P2B-50).',
'lem:split:ville': 'Plain; Ville (1939) cited.', 'prop:split:si': 'Plain; (iii) cites Li-Vitányi.', 'thm:split:private': 'Plain; Kakutani (1948) cited.',
'rem:split:reading': 'Plain; "the split asked for in Section 1"; add the fill-in threshold (P2B-49).',
'ex:split:noisyparity': 'Title already says "an illustration"; keep; may move to App E.',
'rem:teacher:hanni': 'Title "the three-hypothesis calculation" (computed numbers via "A direct computation ...").',
'rem:teacher:numbers': 'Title "numbers for the running example"; κ=0 rows marked as illustrations; δ_S stated (P2B-47); rounding convention (P2B-27).',
'rem:teacher:hypotheses': 'Plain remark.',
'cor:teacher:fulltable': 'Plain; (ii) hypotheses per §F44; d = 20 window after the statement, open at the right end (§F42).',
'cor:teacher:sampled': 'Title "finite samples".',
'ex:teacher:version1': 'Title "the total-bits version of the example"; "By \\cref{thm:teacher:main} with d=100, m=10, p=2^{-6}, ..."; may move to App C.',
'prop:teacher:concentration': 'Plain; add "with cn ≥ 1"; App C.7 arithmetic fix (§F39); may move to App C.',
'lem:teacher:sharpfloor': 'Plain; script named by content, not "c7_run2.py".',
}
def generic(st):
    s = st.lower()
    if re.search(r'computed|computation', s):
        return 'Plain environment. Any number from the computation that is quoted in the text: "A direct computation (code in the accompanying repository) gives ...", outside the statement (§A9); otherwise nothing to add.'
    if 'known' in s:
        return 'Cite the standard source plainly ("(standard; see ...)" or "cf."); no "unverified".'
    if 'remark' in s:
        return 'Plain remark.'
    return 'Plain (qualifier disappears).'
lines = ['# Status rendering table (lead editor; binding with DECISIONS.md §A1-A2)', '',
 'Every `\\status{...}` whose value is not plain `proved`, with the group that renders it and the required rendering. Generated by `scratch/editor/make_status_table.py` from the lead editor\'s extraction (`scratch/editor/status_p1.json`, `status_p2.json`). Each group records "rendered as: ..." for each of its rows in its log; the front groups check completeness before the final redefinition of `\\status` and `\\src` (§A2.5).', '']
for tag, group_of in [('p1', lambda f: GROUP_P1.get(f, '?')), ('p2', lambda f: 'p2-body')]:
    r = json.load(open(os.path.join(HERE, f'status_{tag}.json')))
    rows = [x for x in r if x['status'].strip() != 'proved']
    lines += [f'## Paper {tag[1]} ({len(rows)} non-plain statuses of {len(r)})', '', '| # | group | file:line | label | current status | required rendering |', '|---|---|---|---|---|---|']
    for k, x in enumerate(rows, 1):
        lab = x['label'] or '(inline, no environment)'
        if x['label'] is None:
            rend = 'Delete the inline \\status call by hand (§A2.2) and reduce the sentence to a plain citation ("cf. [X]"), with no "unverified" or "not checked".'
        else:
            rend = SPECIAL.get(x['label'], generic(x['status']))
        st = x['status'].replace('|', '/')
        lines.append(f"| {k} | {group_of(x['file'])} | {x['file']}:{x['line']} | `{lab}` | {st} | {rend} |")
    lines.append('')
lines += ['Plain `proved` environments (Paper 1: 73; Paper 2: 17) need nothing beyond the final redefinition; definitions carry only `\\src`.', '']
open(os.path.join(ROOT, 'edits', 'status-rendering.md'), 'w').write('\n'.join(lines))
print('written', len(lines))
