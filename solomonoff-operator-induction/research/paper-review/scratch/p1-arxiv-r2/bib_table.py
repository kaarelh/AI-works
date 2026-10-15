"""Write the bibliography verification table (markdown) from bib_merged.txt plus overrides."""
import sys
rows = [l.rstrip('\n').split('|') for l in open('bib_merged.txt', encoding='utf8') if l.strip()]
OV = {  # key: (class, action)
'day2011increasing': ('fixable', 'Add volume = {363}, number = {10}, pages = {5577--5604} (AMS issue listing, Trans. Amer. Math. Soc. 363(10), 2011). Fix the .bib comment "CCC 2009" (conference version was CCR 2009).'),
'orseau2013universal': ('fixable', 'Add volume = {8139} (Springer: ALT 2013 proceedings, LNCS 8139, LNAI subseries; eds. Jain, Munos, Stephan, Zeugmann).'),
'wood2013non': ('fixable', 'Add volume = {7070}, editor = {Dowe, David L.} (same book as lattimore2013nofree; LNCS/LNAI 7070), pages 417--425 confirmed (ANU record).'),
'vovk1990aggregating': ('fixable', 'Add pages = {371--383} (Royal Holloway repository; one citing list gives 371--386) and editors Fulk and Case, or keep pages omitted.'),
'barzdin1972prediction': ('fixable', 'Add pages = {1224--1228} (English translation of Dokl. Akad. Nauk SSSR 206(3):521--524, Math-Net.Ru); the printed entry currently has volume only.'),
'case1983comparison': ('fixable', 'Add number = {2}.'),
'kleitman1973families': ('fixable', 'Optional: number = {3}.'),
'hoeffding1963probability': ('fixable', 'Add number = {301}; optional doi 10.1080/01621459.1963.10500830.'),
'grunwald2007suboptimal': ('fixable', 'Add number = {2--3}, doi = {10.1007/s10994-007-0716-7}.'),
'gacs1974symmetry': ('verified', 'Optional: number = {5}; Russian original Dokl. Akad. Nauk SSSR 218(6):1265--1267.'),
'ville1939etude': ('fixable', 'Numdam lists it as a thesis (Thèses de l\'entre-deux-guerres no. 218, 1939, 124 pp.); the Gauthier-Villars imprint was not confirmed by search. Either confirm the imprint (series Monographies des Probabilités) or cite as @phdthesis{..., school = {Université de Paris}, year = {1939}}.'),
'hanni2026notes': ('fixable', 'The repository exists (github.com/kaarelh/notes, "some of my notes from 2023-2026"); the SFI note is ai/learning/solomonoff induction/solomonoff function induction.md (and .pdf). Cite that note: title = {Solomonoff function induction}, howpublished = {Note in \\url{https://github.com/kaarelh/notes}, folder ai/learning/solomonoff induction}, year = {2026}. The current title "notes" is unacceptable.'),
'vaintrobhanni2026nnbayes': ('unverifiable', 'URL kaarelh.github.io/ai/nnbayes-generalization.pdf does not resolve from here and no search hit for the title or an ILIAD listing; a Fields Institute talk (21 Apr 2026) by Vaintrob on the joint work exists. Since the author is a co-author of the slides, he can confirm title/venue/date himself; until then keep only if the URL is live, else replace by vaintrob2026width where possible.'),
'hanni2026lesswrong': ('unverifiable / must change', 'Not reachable, no search hit, year "undated", author list "Hänni and Wyeth" is wrong for a comment thread (the post is Jonas Hallgren\'s shortform) and puts Wyeth\'s name next to the absorption objection. Drop it (the proposal is in hanni2026notes), or cite only Hänni\'s own comment (author = Hänni, with the comment date) in at most one neutral footnote, per the binding note.'),
'hanni2026request': ('unverifiable / must drop', 'A "personal communication to the author" from the sole author, pointing to research/00-brief.md (process file). Drop. Re-source each use: the author\'s ideas -> hanni2026notes or first person; Eisenstat\'s example -> "S. Eisenstat, personal communication" (in text and acknowledgements); the e-mail heuristic -> "a heuristic argument of the author (correspondence with S. Eisenstat)".'),
'claudeSFI2026steeper': ('fixable (self)', 'Companion paper. Replace "Companion paper, draft ... Folder ... of GitHub" by the arXiv identifier once posted (or "In preparation"). Key name is invisible and may stay.'),
'claudeSFI2026fundamentals': ('n/a (self; uncited in P1)', 'Not cited in Paper 1 (it is this paper). No action; ensure Paper 2 cites the arXiv identifier.'),
'claude2026whatfollows': ('unverifiable / internal (uncited in P1)', 'Author field "Claude (Anthropic)" and "unpublished report" -- cannot appear in an arXiv bibliography under the authorship rule. Uncited in Paper 1, so harmless here; Paper 2 must drop or re-attribute it.'),
'ozkural2015ultimate': ('verified (data) / replace as content source', 'arXiv:1504.03303 confirmed (later AGI 2016 version has a different title). Its abstract concerns physical measures of intelligence; the operator-induction formula attributed to it was seen only in a snippet. Cite Solomonoff [Sol08] for the formula after checking it, and drop this entry.'),
'ozkural2017ultimate': ('verified (data) / replace as content source', 'arXiv:1709.03879 confirmed. The product formula for operator induction is not confirmed by any search; replace by the primary source [Sol08] (check it) or drop.'),
'goldblum2023no': ('verified', 'ICML 2024, PMLR 235:15788--15808; title begins "Position:" (as in the entry). Key year differs, harmless.'),
'yang2019fine': ('verified', 'arXiv:1907.10599 (v4, 9 Apr 2020). Keep as arXiv; do not cite an ICLR 2020 version unless confirmed.'),
'basri2019convergence': ('verified', 'NeurIPS 32 (2019); pages differ between indexes (4761--4771 vs 4763--4772), so omitting pages is correct.'),
'schmidhuber2002speed': ('verified', 'COLT 2002, pp. 216--228, doi 10.1007/3-540-45435-7_15; series volume (LNAI 2375) not confirmed, correctly omitted.'),
'epstein2011sets': ('verified', 'arXiv:1107.1458; authorship (Epstein and Levin) as in citing literature ("Epstein-Levin theorem").'),
}
CITED_NOTE = {'yes': 'yes', 'no': 'no (shared core.bib; dropped by BibTeX)'}
out = ["| # | key | file | cited in P1 | class | data confirmed / corrected | action |", "|---|---|---|---|---|---|---|"]
order = sorted(rows, key=lambda r: (r[1], r[0]))
n = 0
counts = {}
for r in order:
    key, f, cited = r[0], r[1], r[2]
    log = '|'.join(r[3:]).strip()
    parts = [p.strip() for p in log.split('|')]
    cls0 = parts[0] if parts else ''
    data = ' '.join(parts[1:]).strip()
    if key in OV:
        cls, act = OV[key]
    else:
        cls = 'verified' if cls0.startswith('verified') else cls0
        act = 'none' if cls == 'verified' else (cls0 + ' ' + data)
    n += 1
    counts[cls.split()[0]] = counts.get(cls.split()[0], 0) + 1
    out.append(f"| {n} | `{key}` | {f} | {CITED_NOTE[cited]} | {cls} | {data.replace('|','/')} | {act.replace('|','/')} |")
print('\n'.join(out))
print('\nCounts by class (first word): ' + ', '.join(f'{k}: {v}' for k, v in sorted(counts.items())), file=sys.stderr)
