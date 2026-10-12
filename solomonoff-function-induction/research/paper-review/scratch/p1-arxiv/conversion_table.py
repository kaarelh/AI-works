"""Build the arXiv-conversion table for Paper 1: every theorem-like environment whose \\status is not
plain "proved", with the academic form it needs. Input: envs.json from extract_status.py."""
import json, re, sys
envs = json.load(open(sys.argv[1]))
CODE = 'add, where the number is quoted in the text: "A direct computation (code in the accompanying repository) gives/confirms ..."; otherwise drop the computation from the paper and list it in the Code-and-data table'
SPECIAL = {
 # proof sketches / partial sketches
 'thm:comp:timebounded': ('Theorem (a) only', 'Keep part (a) as Theorem 8.2 (drop "(corrected)"). Move (b) to a new remark directly after the theorem, "Remark (running time)", that begins "We sketch the cost per round; we do not fix a machine model (RAM versus multitape) or analyse the clocks." Label the appendix argument "Proof sketch of the running-time remark". Keep the toy check as "A direct computation on a toy instance (code in the accompanying repository) matches the brute-force mixture to 2.5e-16 and gives regret 132.4 bits against the bound 184."'),
 'prop:comp:round': ('Proposition (regret) + remark (cost)', 'Keep the regret bound as Proposition 8.4. Replace the last sentence of the statement by a sentence after it: "The learner performs #{i : k_i <= k} simulations of g(k)t(|x_k|) steps in round k, plus as many arithmetic operations; see the running-time remark after Theorem 8.2 (sketch)." Numbers from the stream test: "A direct computation (code in the accompanying repository) gives regret 10.0 bits against the bound 20."'),
 'prop:comp:history': ('Proposition (regret) + remark (cost, sketch)', 'State only the regret bound in the proposition. Move "round k costs O(...) steps plus the replay memory" into a sentence "We only sketch the running time: ..." after the proof idea.'),
 'thm:hist:minimax': ('Theorem restricted + remark', 'Restrict (b) to reveal laws that do not see f (all that Corollary 5.14 uses) and delete "and possibly f|_{A_n}" from the hypotheses of (b). Add, after the theorem, "Remark (reveal laws that see f). For reveal laws that may see f|_{A_n} the argument of case (b) goes through if C_dir(Delta,n) can be computed to within one bit from (P,Delta,n,A); we do not carry this out." Delete "not written out" from the proof idea.'),
 'rem:learn:positive': ('Remark (informal)', 'Title "Remark C.5 (positive examples; informal)". Drop "known (snippet)". Either read Chater and Vitanyi (2007) (open access at CWI) and state the relation precisely, or delete the sentence "It appears to be the object of ... their exact model was not checked."'),
 # conditional
 'prop:hist:lhg': ('Assumption + Proposition', 'Introduce "Assumption (LHG-even)" and "Assumption (LHG-odd)" with the present wording, preceded by "Lattimore, Hutter and Gavane (2011) show that unnormalised Solomonoff induction can fail on simple recursive sub-patterns; we do not verify that their construction gives the following." Then "Proposition 5.22. Under Assumption (LHG-even), ...; under Assumption (LHG-odd), ...". Remove the status. (Use the existing assumption environment.)'),
 'rem:ex:where': ('Remark + pointer to Assumption', 'Keep the proved part. Rephrase the last sentence: "Conversely, under Assumption (LHG-even) (with X=Y={0,1} and y_i=x_i) SI\'s unnormalised label loss is unbounded while L_SFI <= c (Proposition 5.22)."'),
 'prop:hist:operator': ('Proposition about M_pq', 'Title "Proposition D.12 (the per-query mixture ignores the history)". State it for M_pq. In the text: "If operator induction is read as M_pq (Remark 3.2), this applies to it." Remove "given the unverified description".'),
 # known / unverified / literature
 'rem:versions:operator': ('Remark (literature)', 'Obtain the full text of Solomonoff (2008) (PDF on raysolomonoff.com) and quote the operator-induction formula from it, with section number; cite Ozkural only if needed. Then "Remark 3.2 (operator induction). Solomonoff (2008, Sec. x) predicts ... by sum_j a_j prod_i O^j(A_i|Q_i). This is M_pq; on distinct inputs it equals M_prod (proof: ...)." Delete "(abstract only seen)" and "(search snippet only)". If the formula cannot be checked, write "We read operator induction as the per-query mixture M_pq" and make no attribution claim.'),
 'rem:learn:hutterEX': ('Related-work prose', 'Move into Section 11: "Hutter (2000, 2005, 2007) lists supervised learning from examples among the problem classes of AIXI (Hutter 2007, Sec. x)." Check the section in the arXiv version cs/0701125 first. Delete "A table-of-contents snippet shows" and "We have not read these sections".'),
 'rem:nn:slides': ('Related-work paragraph', 'Replace the remark by a paragraph "Claims of Vaintrob and Hanni (2026b)" in Section 9 or 11: "Vaintrob and Hanni (2026b) state the following (we do not reproduce their proofs): (i)...(vi)." Replace "We re-checked ... the rest is unchecked" by "Claim (i), the character argument of their Appendix J and the construction of their Appendix K are proved here as Theorem 9.7(a) and Theorem 8.14." Keep their own caveats.'),
 'rem:nn:literature': ('Related-work prose', 'Move to Section 11 as plain prose with citations; delete "These descriptions follow the abstracts" and "known (snippets; unverified)".'),
 'rem:related:new': ('Delete / novelty sentence', 'Delete the remark. After checking Hutter (2005), Lattimore and Hutter (2013), Solomonoff (2008) and the decision-complexity literature, add one sentence to the contributions: "To our knowledge the following are new: ...", or say nothing about novelty. Never print "Each of these should be checked ... before any claim of novelty".'),
 'rem:comp:selection': ('Remark (computation + cited claims)', 'Title "Remark 8.15 (the selection rule matters)". "An exact computation (code in the accompanying repository; ties count 1/2) gives ... Vaintrob and Hanni (2026b, App. K) also state ...; we prove only the first and last rows (Theorem 8.14, Remark 8.13)." Replace "we have not checked them" by "we do not prove them here".'),
 'cor:learn:mistakes': ('Corollary with citation', 'Heading "Corollary 4.4 (mistake bound; cf. the halving bound of Barzdin and Freivalds 1972 and Littlestone 1988)". Drop "content unverified".'),
 'prop:learn:occam': ('Proposition (standard)', 'Heading "Proposition 4.15 (Occam bound in description-length form; Blumer et al. 1987)". Add "The proof is the standard union bound; we include it for completeness." Drop "references known, unverified".'),
 'lem:setting:realise': ('Lemma with attribution', 'Heading "Lemma A.5 (realisation; the binary case is due to Zvonkin and Levin 1970)". Delete "(not checked against the source)" in the proof.'),
 'prop:setting:transfer': ('Proposition', 'Plain proposition; in the proof cite the relativised coding theorem as "(Li and Vitanyi 2008, Sec. 4.3, relativised)". Replace "(c10(b) checks this exactly on 16,200 cases ...)" by nothing or by the Code-and-data table.'),
 'prop:comp:occam': ('Proposition with citation', '"Proposition 8.12. (a) (Blumer et al. 1987) ... (b) ..." and "We prove (b) in Appendix G".'),
 'rem:comp:majority': ('Remark with citation', 'Plain remark citing Littlestone (1988), Littlestone and Warmuth (1994). Rephrase "Hanni\'s physicist\'s proof" as "An informal argument in Hanni (2026b, circuit notes) ..."'),
 'thm:comp:ladder': ('Theorem with attribution', 'Heading "Theorem 8.14 (conjunction ladder; the construction is from Vaintrob and Hanni 2026b, App. K)". Replace "A direct computation (d=3,4,5, seven tie rules) finds ..." by "A direct computation (code in the accompanying repository) for d=3,4,5 and seven tie rules confirms ...".'),
 'prop:nn:functionspace': ('Proposition or observation', 'Either "Proposition 9.1" without "(trivial)", or turn into a sentence "Grouping the parameter integral by f_theta shows that ...". '),
 'prop:nn:upper': ('Proposition', 'Plain proposition (the coding theorem is a cited standard fact). Move the Gaussian-weights lower-semicomputability argument into a new "Remark (Gaussian weights; sketch)" and say it is a sketch.'),
 'prop:nn:typical': ('Proposition (standard)', 'Heading "Proposition 9.3 (standard; cf. Li and Vitanyi 2008)".'),
 'thm:nn:walsh': ('Theorem with attribution', '"Theorem 9.7. (a) (Yang and Salman 2019; also in Vaintrob and Hanni 2026b, App. J) ... (b) (the standard dimension argument; cf. Kamath et al. 2020)." Check the attribution against arXiv:1907.10599 before posting.'),
 'rem:nn:oddparity': ('Proposition (a)-(c) + numerical remark', 'Make (a)-(c) "Proposition 9.9"; heading of (a) "(the Boolean-cube analogue of Basri et al. 2019)". Move the kernel-ridge accuracy numbers to a following sentence "A direct computation (code in the accompanying repository) gives sign accuracy 0.05-0.07 at n=900, d=10; we do not prove this."'),
 'prop:ood:machine': ('Proposition with citation', '"(cf. Leike and Hutter 2015 for the analogous dependence of AIXI)". Drop "analogue known".'),
 'prop:learn:splits': ('Proposition', 'Drop "technique known"; one sentence in the text: "The exchangeability argument is standard (Haussler et al. 1994; Cesa-Bianchi et al. 2004)." Check Haussler et al. first or drop that citation (currently "(not checked)").'),
 'cor:hist:H4': ('Corollary + sentence on Hutter', 'Plain corollary. Before posting, check Hutter (2005, the chapter on chronological semimeasures) and state either "M_H coincides up to constant factors with Hutter\'s universal chronological semimeasure xi (Hutter 2005, Sec. x)" or "We do not use any identification with Hutter\'s xi". Delete "identification known (unverified)".'),
 # refuted
 'rem:setting:h1a': ('Remark (failed expectation)', '"Remark 2.14 (weak and machine universality differ). By analogy with sequences (Zvonkin and Levin 1970) one might expect lsc function semimeasures and laws of function machines to agree up to a constant factor. For weak semimeasures this fails: ... For laws of random partial functions it is open (q:setting:rpf)." Replace "a natural conjecture" by "a natural expectation".'),
 'prop:ood:draftfalse': ('Proposition (counterexample)', 'Title "Proposition 7.6 (the literal bounds fail)". Text before it: "Read literally, both bounds stated in Hanni (2026b, draft) fail:". Remove "draft\'s" from headings; cite the draft as its own bibliography entry.'),
 'rem:ood:lopsided': ('Remark', 'Plain remark; first sentence "One might read Theorem 7.7 and Proposition 7.8 as saying ... ; this reading is wrong:".'),
 'rem:comp:distinct': ('Remark (counterexample + computation)', '"Remark 8.3 (distinct inputs are needed). Theorem 8.2(a) does not extend to streams with repeated inputs: ... A direct computation (code in the accompanying repository) on 4000 rounds that repeat 12 short inputs gives regret 469 bits, growing linearly. Proposition 8.4 removes the restriction."'),
 'rem:learn:cesaro': ('Delete or rewrite', 'Delete: it records an internal correction ("An earlier version of the context notes"). If kept: "Remark C.3. Proposition 4.13 is a per-step lower bound and cannot be compared with the O(1/n) Cesaro bound of Theorem 4.5: since sum_k E e_k <= (ln 2)(K(f)+c), liminf_k k E e_k = 0. Corollary 4.14 gives the per-step comparison."'),
 'prop:learn:freshnoise': ('Proposition', 'Plain proposition. Delete "refuted (the brief\'s fresh-noise claim, as stated)" and, in the text after it, "This refutes the fresh-noise form of the supervised-learning hypothesis H7 ... (Table 1)". Replace "(foundations c5)" by "(a direct computation; code in the accompanying repository)".'),
 'prop:hist:info': ('Proposition', 'Plain proposition; (b) already reads "The natural strengthening ... is false". Remove status.'),
 'thm:hist:randchain': ('Theorem', 'Title "Theorem 5.12 (the randomised chain; Reading B fails)". Remove "refutes Reading B" status.'),
 'prop:hist:sketchfails': ('Proposition', 'Title "Proposition 5.8 (a simulator with separate randomness per input fails)". Replace "the proof sketch" in the title by "the simulation argument of Hanni (2026b)".'),
 # remark statuses / open
 'rem:hist:thm1open': ('Remark (open cases)', 'Title "Remark D.6 (open cases)". Fine otherwise; replace "a direct computation certifies" by "a direct computation (code in the accompanying repository) certifies".'),
 'rem:hist:H4verdict': ('Remark (summary)', 'Title "Remark 5.23 (summary: hypotheses that see the previous inputs)". Replace "Verdict on Hanni\'s conjecture" and "H4".'),
 'rem:hist:exploit': ('Remark (informal)', 'Title "Remark D.17 (what SFI can and cannot exploit; informal)". Keep the "Informally"/"Proved" split.'),
 'rem:learn:h2': ('Remark', 'Title "Remark 4.2 (scope of dominance)"; item (iii) points to the open question q:setting:rpf. Remove status "proved; open part".'),
 'rem:learn:lastiterate': ('Remark', 'Plain remark; "A direct computation on 300 random finite instances (code in the accompanying repository) gives max (n+1)r_n/K = 0.873." Delete "(foundations r12)".'),
 'rem:learn:increasing': ('Example', 'Make it "Example C.2 (learning curves can increase)". The loss formula is an exact calculation: state it as such; the number 0.255 as "a direct calculation gives".'),
 'rem:learn:relations': ('Remark', 'Plain remark (no status).'),
 'rem:learn:interventions': ('Delete', 'Delete ("Nothing specific to SFI is proved here").'),
 'rem:learn:ideal': ('Remark', 'Plain remark; drop "(each item cited)".'),
 'rem:comp:apples': ('Remark', 'Plain remark; rephrase "Hanni\'s apples to oranges caveat" as "a caveat raised in Hanni (2026b)".'),
 'rem:comp:gap': ('Remark', 'Plain remark; "For formulas on d=3, an exhaustive computation (code in the accompanying repository) ..."; rephrase "Hanni\'s sketch".'),
 'rem:nn:bridge': ('Remark', 'Plain remark.'),
 'rem:nn:rigorous': ('Delete or merge', 'Delete (it repeats the section summary); fold one sentence into the Discussion.'),
 'rem:ood:answer': ('Remark', 'Plain remark; title "Remark 7.14 (summary of the out-of-distribution results)".'),
 'rem:versions:Wrate': ('Remark', 'Plain remark; the open rate goes to the open question q:versions:open.'),
 'rem:versions:prediction': ('Remark', 'Plain remark.'),
 'rem:versions:answer': ('Remark (summary)', 'Title "Remark 3.14 (summary: Kolmogorov versus semimeasure versions)"; delete "Answer to Hanni\'s request" and "which Hanni\'s draft names as the tool" (say "the coding theorem").'),
 'rem:versions:hashing': ('Remark', 'Title "Remark B.3 (a hashing bound)"; delete "superseded"; say "weaker than Proposition 3.6 but of independent interest" if kept at all.'),
 'rem:ex:email': ('Remark', 'Title "Remark 6.17 (an informal argument)". "The argument of Hanni (2026b) [or: an e-mail argument of the author, quoted in Appendix E.3] is correct in the semimeasure convention ...". Drop "normalised open" status; the open part points to the open question q:ex:normalised.'),
 'rem:ex:fresh': ('Remark', 'Plain remark; drop "(citing)".'),
 'rem:setting:conventions': ('Remark', 'Plain remark; drop "(as a list); transfer open where stated".'),
 'prop:ex:orderfree': ('Proposition + question', 'Plain proposition; the "sharper weak case" is the open question q:ex:depthweak.'),
 'prop:ex:cychist': ('Proposition', 'Plain proposition (its proof uses Corollary 5.18, which is proved).'),
 'prop:ex:cycsi': ('Proposition', 'Plain proposition; any numbers from e6(f) go in a sentence "A finite illustration (code in the accompanying repository) ..." or are dropped.'),
 'prop:ood:relative': ('Proposition', 'Plain proposition; drop "(corrected)".'),
 'prop:comp:samplers': ('Proposition', 'Plain proposition; drop "(corrected)".'),
 'cor:hist:thm1': ('Corollary', 'Title "Corollary 5.14 (Theorem 1 of Hanni (2026b) in Reading C)"; drop the status.'),
 'conj:hist:algmi': ('Conjecture', 'Plain conjecture; drop "(untested)"; optionally "Proposition D.8 is its Shannon analogue."'),
 'conj:learn:loo': ('Conjecture', 'Keep; it is precise. Keep the heuristic in the appendix under "Heuristic (not a proof)".'),
 'conj:ex:raw': ('Conjecture (make precise) or open question', 'Make precise: "Conjecture E.5. With raw blocks, E L^y_M(1) >= K(d) - K_tail(d) - c for all d", or move to the open problems; "for typical d" is not a mathematical statement.'),
 'conj:ood:natural': ('Open problem (informal)', 'Remove the conjecture environment ("This is not a precise statement"). In Section 12, Open problems: "Is there a natural class of universal machines for which the intended answers of Example 7.16 receive posterior probability close to 1? By Proposition 7.4 no such statement holds for every universal machine."'),
}
def category(s):
    s = s or ''
    if 'sketch' in s: return 'proof sketch'
    if 'conditional' in s: return 'conditional'
    if 'conjecture' in s: return 'conjecture'
    if 'refut' in s: return 'refuted'
    if 'unverified' in s or 'snippet' in s: return 'known; unverified'
    if 'known' in s or 'standard' in s or 'from the slides' in s: return 'known/cited'
    if s.strip().startswith('remark'): return 'remark'
    if s.strip() == 'open': return 'open'
    if 'open' in s: return 'proved + open part'
    if s.strip().startswith('computed ('): return 'computed'
    if 'computed' in s or 'proxy' in s or 'illustrat' in s: return 'proved + computed'
    return 'proved (qualified)'
rows = []
for e in envs:
    st = e['status']
    if st is None or st.strip() == 'proved':
        continue
    lab = e['label']
    cat = category(st)
    if lab in SPECIAL:
        form, fix = SPECIAL[lab]
    elif cat == 'proved + computed':
        form, fix = ('%s (status removed)' % e['env'].capitalize(), CODE)
    else:
        form, fix = ('%s (status removed)' % e['env'].capitalize(), 'Delete the qualifier; no other change.')
    rows.append((e['file'].replace('sections/', ''), e['line'], lab, st.replace('|', '/'), cat, form, fix))
order = {'proof sketch':0,'conditional':1,'conjecture':2,'refuted':3,'known; unverified':4,'known/cited':5,'remark':6,'open':7,'proved + open part':8,'proved (qualified)':9,'computed':10,'proved + computed':11}
rows.sort(key=lambda r: (order.get(r[4], 99), r[0], r[1]))
out = ['| # | file:line | label | current \\status | category | academic form | exact rewording / action |', '|---|---|---|---|---|---|---|']
for i, r in enumerate(rows, 1):
    out.append(f'| {i} | {r[0]}:{r[1]} | `{r[2]}` | {r[3]} | {r[4]} | {r[5]} | {r[6]} |')
open(sys.argv[2], 'w').write('\n'.join(out) + '\n')
from collections import Counter
print(len(rows), Counter(r[4] for r in rows))
missing = [k for k in SPECIAL if k not in {r[2] for r in rows}]
print('special not in non-plain rows (plain proved or none):', missing)
