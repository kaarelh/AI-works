"""Merge the findings of a second, independent pass of the Paper 2 arXiv-readiness review into the
deliverables written by the first pass (p2/review-p2-arxiv.md, p2/issues-p2-arxiv.json).
Additive only: existing issues and text are kept; new issues get ids P2X-46 onwards; an addendum
section is appended to the review, and the counts line is extended. Idempotent (refuses to run twice).
Usage: python3 -I merge_addendum.py <p2 dir>"""
import json, os, re, sys

P2 = sys.argv[1]
JS = os.path.join(P2, 'issues-p2-arxiv.json')
MD = os.path.join(P2, 'review-p2-arxiv.md')
issues = json.load(open(JS, encoding='utf8'))
md = open(MD, encoding='utf8').read()
if any(i['id'] == 'P2X-46' for i in issues) or '## 9. Addendum' in md:
    sys.exit('addendum already merged; nothing done')

new = []
def add(file, where, sev, problem, evidence, fix):
    new.append(dict(id='', file=file, label_or_line=where, severity=sev, problem=problem, evidence=evidence, fix=fix))

add('paper-steeper/sections/intro.tex', 'tab:intro:claims, row 3 (line 31): claim "the `good model\' could be a vertex of the convex hull", verdict "...; refuted for some error rules with the same density and description length"', 'fatal',
    'The verdict is stronger than anything the paper proves. "Refuted for some error rules" says that, for those rules, the good model cannot be a vertex (cannot be selected for any c). The body proves only that, for one constructed rule, no hypothesis that fits no better than the good model is near-optimal for c < c_env, about a third (kappa=0) or a quarter (kappa=30) of the window\'s logarithmic width. It says explicitly that nothing is proved above c_env. The source refutes a universal statement, not the statement for particular rules. (Section 1.2 of this review, row I18, rates the table\'s content OK; this pass disagrees on this row.)',
    'limits.tex:42-44: "c_env = 1.64e-5, which is 31% of the logarithmic width of the window ... at kappa=0 (25% at kappa=30)"; "above c_env nothing is proved for it". steeper notes-final §5, row on the example: "Refuted as a statement about every error rule with that density and description length". CLAIMS.md §3 R6: "refuted as a statement about every error rule with that density and description length (prop:limits:envelope); open in general".',
    'Replace the verdict by: "Confirmed for error rules incompressible relative to the model. Not true of every rule with the same density and description length: for one such rule, no hypothesis that fits no better than the good model is near-optimal on about a quarter to a third of the window\'s logarithmic width; the rest of the window is open." (This also fits the re-titled table proposed in P2X-12.)')

add('paper-steeper/sections/limits.tex; paper-steeper/sections/teacher.tex', 'prop:limits:plain (a) (limits.tex:12); cor:teacher:fulltable (teacher.tex:155); prop:limits:noident (ii) (limits.tex:78)', 'major',
    'Computed numbers, two of them with the machine constant set to 0, sit inside environments that are presented as proved. They are: "if all inputs are revealed, this is a fraction 1-9.6e-24 of the error inputs at Hänni\'s sizes (kappa=0)" (Prop. 5.1(a)); "At d=20 ... a direct computation gives the window lambda in (1,1.19e4] at kappa=0 and (1,6456] at kappa=30" (inside Cor. 4.10); and "in Hänni\'s example the losses are 1.0, 0.0112, 0.0112, 0 at c=1e-1,...,1e-7" (Prop. 5.8(ii)). The paper itself says kappa=0 numbers are illustrations, not results about any reference machine.',
    'OUTLINE.md binding note: "Computed results are stated as examples or remarks". teacher.tex:108 and intro.tex:48: rows with kappa=0 are illustrations. The conversion table of section 4.1 deletes the tags of these three environments but leaves the numbers inside the statements.',
    'Move each sentence out of the statement into a remark or example immediately after it, worded "For instance, a direct computation (code in the accompanying repository) gives ... with the machine constant set to 0."')

add('paper-steeper/sections/limits.tex', 'line 61 ("leaves a window of a factor of about 8000 (kappa=0) or 3800 (kappa=30)")', 'minor',
    'Wrong rounding. The incompressible rule\'s window ratio at kappa=0 is 8453, so "about 8000" is off; about 8000 (8037) is the ratio of the three-hypothesis window.',
    'teacher.tex:108: "(a ratio of 8453) ... (ratio 3837)". Independent arithmetic: scratch/p2-arxiv/numbers_check.out gives 8452 and 3838.',
    'Write "about 8500 (kappa=0) or 3800 (kappa=30)".')

add('paper-steeper/sections/limits.tex; intro.tex; discussion.tex; app-limits.tex', 'Section 5 title "Limits of the trick" (limits.tex:4); subsection 5.2 "Which error rules defeat the trick" (limits.tex:24); App. D title "Proofs for the limits of the trick" (app-limits.tex:3); limits.tex:6,21,102; intro.tex:18; discussion.tex:9,19', 'minor',
    'Informal register. The proposal is called "the trick" in a section title, a subsection title, an appendix title and seven running-text places.',
    'Binding note: "Tone: formal academic register." The word comes from the request ("the trick idea", research/00-brief.md line 22).',
    'Use "the steeper objective" or "the proposal". Retitle Section 5 "Limits of steeper selection", 5.2 "Which error rules defeat steeper selection" and App. D "Proofs for Section 5".')

add('paper-steeper/sections/intro.tex', 'tab:intro:claims, row 8 (line 36): "confident wrong extrapolation"', 'minor',
    'The table lists "confident wrong extrapolation" among demonstrated pathologies. Prop. 5.10 proves only that the steeper posterior concentrates on the shortest hypotheses that fit the training data. Wrong extrapolation follows only if such a hypothesis is wrong on the unseen set, and the paper says no guarantee follows either way.',
    'limits.tex:95: "If the shortest one extrapolates well, steeper SFI is more reliable out of distribution than SFI; if a shorter one fits the training data and is wrong on Q, it is more confidently wrong. No guarantee about unseen properties follows."',
    'Write "possible confident wrong extrapolation off the training support".')

add('paper-steeper/sections/intro.tex', 'line 20 (Contributions, bullet "Computable classes")', 'minor',
    'Missing hypothesis. The bullet says that the private-randomness split holds "in every c.e. prefix-free product class", but Prop. 8.1(b) needs the class to contain a program for the sampler. (Section 1.2 of this review, row I17, rates this bullet OK.)',
    'related.tex:12, Prop. 8.1(b): "Theorem 6.6 holds in every countable product class with Kraft weights that contains a program for the sampler."',
    'Write "... hold in every c.e. prefix-free product class (for the split, one that contains the sampler), with the class\'s own constants".')

add('paper-steeper/sections/intro.tex', 'line 17 ("If S is incompressible ... and lambda = cn with c in an explicit window (2^{-m}, c_hi], every near-optimal product hypothesis knows the parity ...")', 'minor',
    'Endpoint. The identification conclusions of Thm 4.7(ii) need J_g(c)+epsilon < Phi_2(c). At c = c_hi with epsilon = 0 this is an equality, because c_hi is defined by J_g = Phi_2, so the conclusions are not established at the right endpoint that the introduction includes. This is the same point as P2X-31, but in the introduction.',
    'teacher.tex:72-74: {c>0 : J_g(c) <= Phi_2(c)} = (0, c_hi]; teacher.tex:83: (ii) assumes J_g(c)+epsilon < Phi_2(c).',
    'Write "with c in an explicit window (2^{-m}, c_hi)" where the identification conclusions are summarised. The window of part (i) can stay closed.')

add('paper-steeper/sections/app-verification.tex; paper-steeper/sections/teacher.tex', 'App. H.7, bullet "Rounding"; tab:teacher:numbers; rem:teacher:numbers', 'minor',
    'The internal record notes that the upper bounds of Table 2 are printed rounded to nearest, so the last digit is not guaranteed to be on the safe side. Section 4.4 of this review lists what must move out of App. H before it is deleted, but this caveat is not on that list, so deleting H would drop it silently.',
    'App. H.7: "The scripts print the upper bounds of Table 2 rounded to nearest, so their last digit is not guaranteed to be on the safe side." Example: c6_revision.out prints "e<=0.199 (g=9)"; a true value in [0.1990, 0.1995) prints the same, and only values above 0.199 would be unsafe.',
    'Either recompute Table 2 (and Table 3 and the App. C tables) with outward rounding (upper bounds rounded up, lower bounds down), or state the convention in the caption of Table 2 and in Remark 4.8.')

add('paper-steeper/sections/discussion.tex', 'Acknowledgements (lines 29-30); section 4.5 of this review (proposed text)', 'minor',
    'Two gaps in the acknowledgements, and in the text proposed in section 4.5. Nothing says that the author takes responsibility for the content, which arXiv\'s policy on generative-AI tools expects alongside a disclosure. And Sam Eisenstat\'s example is not marked as a personal communication, although the bibliography entry that reported it (hanni2026request) is to be dropped (P2X-07).',
    'discussion.tex:30 ends "The author thanks Sam Eisenstat for the coin example discussed in the companion paper and in Section 6.2." Binding note: Eisenstat is credited in the text and in the acknowledgements.',
    'Add "The author takes full responsibility for the content of this paper." and write "... for the coin example (personal communication) ...". The title-page footnote can stay word for word.')

add('paper-steeper/sections/abstract.tex', 'line 3; section 7.1 of this review (proposed abstract)', 'minor',
    'The abstract, and the replacement proposed in section 7.1, leave out the algorithmic-statistics result: for a noisy random parity, product sophistication exceeds set sophistication by d-O(log d). OUTLINE.md item 0 lists this result. The proposed abstract\'s last clause ("for lambda > 1, private randomness selects a sampler, shared randomness a universal mixture") also drops the long-sampler condition that P2X-03 asks for.',
    'OUTLINE.md §0: "the model-randomness split (lambda = 1 similar posterior; lambda > 1 private: sampler wins; shared: no split; product vs set sophistication)". Prop. 7.6(iii). Thm 6.8(i) needs (lambda-1)k > lambda*l_U + kappa_0.',
    'If the 200-word limit allows, add "For a noisy random parity, the product analogue of Kolmogorov\'s structure function keeps the parity in the model, where set models treat it as noise." End with "shared randomness a universal mixture, against every sufficiently long sampler".')

add('paper-steeper/sections/absorb.tex; paper-steeper/sections/app-related.tex', 'rem:absorb:examples (absorb.tex:14; proof in App. B.1); proof of prop:related:computable (app-related.tex:5, "By inspection.")', 'minor',
    'Two environment types do not match their content. Remark 3.1 is a proved statement with its own appendix proof, so the binding note makes it a proposition (section 3 of this review calls the remark form acceptable; this pass prefers a proposition). The proof of Prop. 8.1 begins "By inspection" and lists, for each lemma, what it uses: that is a proof sketch unless expanded.',
    'App. B.1: "We prove Remark 3.1." Binding note: "Proved results are theorems, propositions, lemmas or corollaries, with proofs. Proof sketches are labelled \'Proof sketch\'."',
    'Make Remark 3.1 "Proposition 3.1 (Classes with an absorbing member)". Expand the proof of Prop. 8.1 into one item per lemma, naming the property of the class used and the constant that changes, or label it "Proof (sketch)".')

add('paper-steeper/sections/discussion.tex', 'line 7 ("near-optimal product hypotheses are the simple model with noise for 2^{-m} < c <= c_hi")', 'minor',
    'A qualifier is dropped. Theorem 4.7 shows that near-optimal hypotheses are the simple model with noise only up to explicit slack: u > 3/4, R_B >= H(p) - O(.), l <= d + Delta_l, I <= Delta_l + Lambda_3, and e <= 1 - u + gamma_g + 2^{-g}. (Section 1.3 of this review, row D3, rates the line OK.) The same endpoint point as in the introduction applies to "<= c_hi".',
    'teacher.tex:6: "every near-optimal hypothesis is, up to explicit slack, the simple model with noise"; Table 2: e <= 0.199 to 0.287.',
    'Write "near-optimal product hypotheses are, up to explicit slack, the simple model with noise for 2^{-m} < c < c_hi".')

start = len(issues) + 1
for k, it in enumerate(new):
    it['id'] = 'P2X-%02d' % (start + k)
issues.extend(new)

# ---- addendum text
L = []
L.append('\n---\n\n## 9. Addendum: second independent pass\n')
L.append('A second reviewer ran the same assignment independently and in parallel, with its own scripts in `research/paper-review/scratch/p2-arxiv/` (sections 0-8 use `scratch/p2-arxiv-B/`). This addendum keeps sections 0-8 as they are and adds what that pass found and they lack. The %d new issues are P2X-%02d to P2X-%02d (1 fatal, 1 major, %d minor). The pass otherwise agrees with sections 0-8, including the Wyeth count (16 occurrences in an arXiv-mode build, 17 in the current PDF), the bibliography findings and the conversion steps.\n' % (len(new), start, start + len(new) - 1, len(new) - 2))
L.append('**Disagreements with sections 1-3.**\n')
L.append('* Row I18 (Table 1 "content OK"): row 3\'s verdict "refuted for some error rules with the same density and description length" is stronger than the body and than the source, which refutes only the universal statement (P2X-%02d, fatal).' % start)
L.append('* Row I17 (intro bullet "Computable classes" OK): the bullet omits the hypothesis that the class contains the sampler (P2X-%02d).' % (start + 5))
L.append('* Row D3 (discussion line 7 OK): "are the simple model with noise" drops "up to explicit slack" (P2X-%02d).' % (start + 11))
L.append('* Section 3, last paragraph (remarks with status "proved" acceptable): `rem:absorb:examples` has its own proof in App. B.1 and should be a proposition (P2X-%02d).' % (start + 10))
L.append('* Section 7.1 (proposed abstract): its last clause drops the long-sampler condition that P2X-03 asks for, and it omits the sophistication result (P2X-%02d).\n' % (start + 9))
L.append('**Independent checks of the second pass** (in `scratch/p2-arxiv/`):\n')
L.append('* `extract_status_p2.py`, `compare_status_p2.py` → `envs.json`, `compare_status.out`. All 73 environments; the 17 differences from `CLAIMS.md` are wording only, and every ledger id has an environment. This agrees with section 3.')
L.append('* `process_vocab_p2.py` → `process_vocab.out`. Process vocabulary in the visible text; the same passages as section 4.2.')
L.append('* `quote_check.py` → `quote_check.out`. Every ``...\'\' quotation in the visible text checked against `research/prior/` and `00-brief.md`, up to whitespace, case and markup. Every quotation attributed to Hänni occurs verbatim. Two have small differences: Version 1 of the example (teacher.tex:13) drops the inner quotation marks around "a simple model" and "systematic error model", and the sampler question (intro.tex:12, split.tex:5) comes from `00-brief.md` (the request), which supports P2X-07. Of the 27 quotation instances that occur in the LessWrong thread, 22 also occur in the grokking note\'s "messy notes" (lines 37-70), which supports the replacement map of section 4.3.')
L.append('* `numbers_check.py` → `numbers_check.out`. Independent arithmetic for every number that appears in more than one place: L_S (11,710.273; 187,457.2 at m=24; 115.58 for Version 1); the three-hypothesis window (1.119e-6, 8.989e-3) and its ratio 8037; the lambda=1 switch at 894,054; the window ratios 8452 and 3838; the Version 1 window (9.77, 58.0]; c_hi = 0.01139 at d=20; the guard factor 67.5; the envelope shares 0.315, 0.475 and 0.249; the noisy-parity threshold 1.311; the fraction 9.57e-24; the crossover p = 0.05596. All agree with the paper except the "about 8000" of limits.tex:61 (P2X-%02d).' % (start + 2))
L.append('* `build-norecord/`. Build with `\\sfirecordfalse` and `\\status`, `\\src` emptied: 58 pages, 0 LaTeX errors, 0 undefined references or citations; "Wyeth" 16 times (pp. 3, 5, 7, 8, 9, 12, 13, 19, 20, 31, 33).')
L.append('* `conversion_table.py` → `conversion_table.md`. A second conversion table (51 rows). It agrees with section 4.1, except for the three statements of P2X-%02d whose numbers should move out of the environments.' % (start + 1))
L.append('* Bibliography. WebSearch confirmed, independently of section 5, the data of `antunes2009sophistication`, `barron1991minimum` (doi 10.1109/18.86996), `bhattacharya2019fractional` (doi 10.1214/18-AOS1712), `bissiri2016general` (doi 10.1111/rssb.12158), `gacs2001algorithmic`, `gneiting2007strictly` (doi 10.1198/016214506000001437), `goldreich1989hard` and `grunwald2012safe` (doi 10.1007/978-3-642-34106-9_16). The session\'s shared search budget then ran out. `claude2026whatfollows` exists on the public main branch (`inferential-learning/paper/main.pdf`, author line "Claude (Anthropic)"), with Section 8 "Simplicity and normativity from imitation".')
L.append('* The second pass\'s own standalone report (36 issues, ids P2A-xx) is `scratch/p2-arxiv/issues-p2-arxiv-A-standalone.json` and `scratch/p2-arxiv/issues_list.md`. Every P2A issue not listed below is covered by an issue of section 8.\n')
L.append('### 9.1 Added issues\n')
for it in new:
    L.append('**%s (%s)**: `%s`, %s.  ' % (it['id'], it['severity'], it['file'], it['label_or_line']))
    L.append('*Problem.* ' + it['problem'] + '  ')
    L.append('*Evidence.* ' + it['evidence'] + '  ')
    L.append('*Fix.* ' + it['fix'] + '\n')
md = md.rstrip('\n') + '\n' + '\n'.join(L) + '\n'

# extend the counts line, if present
counts_old = re.search(r'\*\*Counts\.\*\*[^\n]*', md)
nf = sum(1 for i in issues if i['severity'] == 'fatal'); nM = sum(1 for i in issues if i['severity'] == 'major'); nm = sum(1 for i in issues if i['severity'] == 'minor')
if counts_old:
    md = md.replace(counts_old.group(0), counts_old.group(0).rstrip() + ' With the addendum of section 9 (second independent pass): %d issues, %d fatal, %d major, %d minor.' % (len(issues), nf, nM, nm), 1)
json.dump(issues, open(JS, 'w', encoding='utf8'), indent=1, ensure_ascii=False)
open(MD, 'w', encoding='utf8').write(md)
print('merged', len(new), 'issues; totals', len(issues), nf, nM, nm, '; counts line found:', bool(counts_old))
