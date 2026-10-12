"""Build the arXiv-conversion table for Paper 1: every theorem-like environment whose \\status is not plain
'proved', with the academic form it needs. Usage: python3 -I conversion_table.py envs.json > conversion_table.md"""
import json, re, sys
envs = json.load(open(sys.argv[1]))
ENV = {'theorem': 'Theorem', 'proposition': 'Proposition', 'lemma': 'Lemma', 'corollary': 'Corollary',
       'conjecture': 'Conjecture', 'definition': 'Definition', 'example': 'Example', 'remark': 'Remark'}
CHK = "replace every check identifier nearby by \"a direct computation (code in the accompanying repository) confirms ...\""
S = {
# setting
'lem:setting:realise': "Lemma [Realisation]; first proof sentence: \"For binary sequences this is due to Zvonkin and Levin [ZL70]; the proof below covers countable alphabets.\" (delete \"not checked against the source\").",
'thm:setting:weakvsmachine': "Theorem, unchanged; delete \"(c1)\" etc. in `ex:setting:weaknotrpf` and the proof (" + CHK + ").",
'rem:setting:h1a': "Remark [Weak and machine universality differ]: \"By analogy with sequences [ZL70] one might expect lsc function semimeasures to coincide, up to constant factors, with laws of function machines. For weak semimeasures this fails: by Theorem 2.13 (`thm:setting:weakvsmachine`), $\\Mw$ and $\\MF$ agree up to $2^{K(\\dom D)+O(1)}$ but not up to a constant. For laws of random partial functions the question is open (the numbered Open Problem in Section 12).\"",
'ex:setting:weaknotrpf': "Example, unchanged; replace \"($\\nutri$ is weak (c1))\" by \"($\\nutri$ is weak, by a direct check of the 18 inequalities)\".",
'prop:setting:normalise': "Proposition, unchanged; following paragraph: \"A direct computation (code in the accompanying repository) on a random mixture over six inputs gives semimeasure loss 10.919980315195 bits in all 720 orders and normalised loss between 7.33 and 10.64 bits.\" (drop \"(c3)\", \"(context c3)\").",
'rem:setting:conventions': "Remark [Lower bounds and the two conventions]; delete tag; in the first list add \"(whether these hold normalised is open; see the numbered Open Problem in Section 12)\".",
'ex:setting:swap': "Example, unchanged; delete \"(c9(c))\".",
'prop:setting:twopoint': "Proposition, unchanged; replace \"(c10(a4))\" and \"Check c10 found agreement ... (r13: 300 of 300)\" by \"A direct computation found agreement between $(\\star)$ and order independence on all 400 random laws with positive two-point cells tested (code in the accompanying repository).\"",
'prop:setting:transfer': "Proposition; in (b) write \"by the coding theorem relative to $\\emptyset'$ [LV08, \\S4.3]\"; replace \"(c10(b) checks this exactly on 16,200 cases ...)\" by \"a direct computation confirms (a) exactly on 16,200 cases\".",
# versions
'rem:versions:operator': "DO NOT merely delete the hedges (that would assert an unverified identification). Either (preferred) check Solomonoff [Sol08, \\S on operator induction] and write \"Solomonoff's third kind of induction [Sol08] predicts the second element of a new pair from the first, given an unordered set of pairs; its predictor is the mixture $\\sum_ja_j\\prod_iO^j(A_i\\mid Q_i)$ over all pairs, repeats included [Sol08]. This is $\\Mpq$ ...\"; or, if [Sol08] is not checked, write \"We read operator induction [Sol08] as the per-query mixture $\\Mpq$; under this reading it equals $\\Mprod$ on distinct inputs and differs with repeats (Proposition 4.7, `prop:learn:perquery`).\" and drop the Özkural snippet citation.",
'rem:versions:Wrate': "Remark [Growth of the gap of $W$]; replace \"rate open\" by a pointer to the numbered Open Problem in Section 12 (exact rate).",
'prop:versions:tape': "Proposition, unchanged.",
'rem:versions:hashing': "Remark [A hashing bound] (drop \"superseded\" from the title; say \"Proposition 3.6(b) is stronger\"); replace \"(c2 checks this exhaustively ...)\" by \"(a direct computation confirms this for $(q,k)\\in\\{(3,2),(3,3),(4,2),(4,3)\\}$)\". Candidate for deletion to save space.",
'prop:versions:shared': "Proposition, unchanged (the counting step is proved in Appendix B.4; mention the computation only as a sanity check, without the identifier r9(c)).",
'thm:versions:nocoding': "Theorem, unchanged; in App. B.5 replace \"(c8(a) checks the arithmetic ...)\" by \"(the inequality $3^{2^g}<2^d$ is elementary; a direct computation confirms it for $d\\le2\\cdot10^5$)\" or delete.",
'prop:versions:covering': "Proposition, unchanged; App. B.5: replace \"(c8(d))\", \"Check c8(c) computes ...\", \"(c8(b), $N\\le14$)\", \"(r11)\" by \"a direct computation (code in the accompanying repository)\"; replace \"reported to be optimal \\status{known; unverified}; we did not check optimality ...\" by \"[KS73] (we use only the construction, not its optimality)\".",
# learn
'rem:learn:h2': "Remark [Scope of Theorem 4.1 (`thm:learn:dominance`)]; (iii) \"is open\" -> \"is open (the numbered Open Problem in Section 12)\".",
'thm:learn:merging': "Theorem, unchanged. Text after it: \"This is the function analogue of Solomonoff's convergence theorem [Sol78].\" (delete \"(source not checked)\"); \"(summed KL 12.5 bits against a bound of 1 in a finite example; code in the accompanying repository)\" (delete \"foundations r6\").",
'cor:learn:mistakes': "Corollary, unchanged; the attribution sentence \"This is the halving bound [Lit88, BF72] with $K(\\varphi)$ in place of $\\log|H|$\" stays (both references verified).",
'thm:learn:batch': "Theorem, unchanged; \"[HLW94] use a permutation argument of this kind\" (delete \"(not checked)\").",
'prop:learn:freshnoise': "Proposition, unchanged; (c) already has the standard form \"the natural statement ... is false\". Delete the sentences \"(foundations c5)\" -> \"(a direct computation)\" and \"This refutes the fresh-noise form of the supervised-learning hypothesis H7 ...\" (delete entirely).",
'prop:learn:perquery': "Proposition, unchanged.",
'prop:learn:curve': "Proposition, unchanged; \"63 of 300 random finite instances had non-monotone curves (code in the accompanying repository)\" (drop \"foundations r12\").",
'rem:learn:lastiterate': "Remark [Last iterate and leave-one-out]: keep the identity (proved); \"Whether ... is open (the numbered Open Problem in Section 12). In 300 random finite instances the largest value of $(n+1)r_n/K$ was 0.873 (code in the accompanying repository).\"",
'prop:learn:splits': "Proposition [Random splits]; add after it \"The exchangeability argument is standard; cf. [HLW94].\" (status 'technique known' becomes this sentence).",
'prop:learn:loo': "Proposition, unchanged.",
'conj:learn:loo': "Conjecture (keep the environment); move the heuristic of App. C.7 directly after it as \"Heuristic.\"; list as the numbered Open Problem in Section 12 in the discussion.",
'prop:learn:typical': "Proposition, unchanged.",
'cor:learn:perstep': "Corollary, unchanged.",
'prop:learn:occam': "Proposition [Occam bound]; add \"This is the standard Occam bound [BEHW87] in description-length form.\" (status 'references known, unverified' disappears; BEHW87 verified).",
'rem:learn:ideal': "Remark, unchanged (delete tag).",
'rem:learn:hutterEX': "Remark [Prior work]: \"Hutter [Hut00, Hut07] lists supervised learning from examples among the problem classes of the AIXI model, and [Hut07] contains a section 'Supervised Learning from Examples (EX)'; [Hut05] is the book-length treatment. In this sense the use of a universal mixture as an ideal learner from examples is not new.\" Delete \"A table-of-contents snippet shows\" and \"We have not read these sections\". Better: move into Section 11 (Related work).",
'prop:learn:active': "(plain proved) -",
'rem:learn:increasing': "Remark [Learning curves can increase]: \"A direct computation (code in the accompanying repository) gives ...\"; delete \"(context c3 Part 2)\".",
'rem:learn:cesaro': "Delete as a remark about an earlier version of the notes. If kept: Remark [Per-step versus averaged rates]: \"Proposition 4.13 (`prop:learn:typical`) should not be read as matching the $O(1/n)$ Cesàro bound up to $\\log^2 n$: it is a per-step lower bound, while Theorem 4.5 (`thm:learn:batch`) bounds an average; indeed $\\sum_k\\Ex e_k\\le(\\ln2)(K(f)+c)$, so $\\liminf_k k\\,\\Ex e_k=0$. Corollary 4.14 (`cor:learn:perstep`) gives the per-step comparison.\" Remove \"An earlier version of the context notes\".",
'rem:learn:relations': "Remark, unchanged (delete tag).",
'rem:learn:positive': "Remark [Positive examples] with the derivation marked \"Sketch.\"; last sentence: \"A related ideal learner from positive evidence is studied by Chater and Vitányi [CV07].\" Delete \"their exact model was not checked\" and the status words 'known (snippet)'.",
'rem:learn:interventions': "Remark, unchanged (delete tag). Candidate for deletion.",
# hist
'prop:hist:normchain': "Proposition, unchanged.",
'prop:hist:sketchfails': "Proposition [An earlier proof sketch fails] (or \"The simulation argument needs shared randomness\"); the example is proved by hand (two inputs), so call it proved; no 'computed'.",
'thm:hist:directed': "Theorem, unchanged.",
'thm:hist:randchain': "Theorem [The randomised chain]; drop \"Reading B is false\" from the title; the sentence after it already says it refutes Reading B.",
'thm:hist:minimax': "Split. Theorem (proved): the statement for (a) rational values, and for (b) computable real values when the reveal law does not see $f$. Then: \"Remark (reveal laws that see $f$, real-valued case). The same bound should hold in case (b) for reveal laws that see $f|_{A_n}$; we give only a proof sketch (Appendix D.2): the search must approximate $C_{\\rm dir}$ to within one bit, which we do not write out.\" Delete the tag.",
'cor:hist:thm1': "Corollary [A dominance theorem for computable reveal laws]; delete \"under the stated hypotheses\" tag; the statement already lists (A1), (A2). Drop \"Hänni's\" from the title (sole author).",
'conj:hist:algmi': "Conjecture, unchanged; delete \"The algorithmic form is untested:\" and introduce with \"We conjecture the following algorithmic form.\"",
'thm:hist:representation': "Theorem, unchanged; following text: \"The proof allocates dyadic intervals as in [ZL70]. For sequences, [WSH13] show that machine-based and mixture-based universal priors define the same class.\" Delete \"(abstract seen only)\" and \"we have not checked whether ... and claim no novelty\" (novelty is discussed once in Section 11).",
'cor:hist:H4': "Corollary [Universality of $\\SFIhist$]. Following text: replace \"Agreement with Hutter's universal chronological semimeasure ... is known, but not checked against the sources ... and is not used\" by \"Universal chronological semimeasures were introduced by Hutter [Hut00, Hut05] for the AIXI model (with finite alphabets); nothing below depends on comparing his construction with $\\MH$.\" Do NOT write \"agrees with Hutter's $\\xi$ up to constants\" unless the author checks [Hut05].",
'prop:hist:strict': "Proposition, unchanged.",
'prop:hist:inputloss': "Proposition, unchanged.",
'prop:hist:lhg': "Proposition (conditional statement; the hypotheses (LHG-even), (LHG-odd) are stated explicitly, so it is a proved implication). Rename the hypotheses (E) and (O); preceding sentence: \"Lattimore, Hutter and Gavane [LHG11] show that the unnormalised version can fail to predict very simple recursive sub-patterns, such as ...\" (delete \"(abstract seen only)\").",
'rem:hist:H4verdict': "Remark [Summary: \\SFIhist{} and SI]; delete \"Verdict on Hänni's conjecture\" title.",
'thm:hist:gf': "Theorem, unchanged; \"A direct computation (code in the accompanying repository) gives ...\" already in standard form.",
'rem:hist:thm1open': "Move to the Open Problems list (Section 12) as a numbered Open Problem \"(Removing $K(n)+K(A)$ in Corollary 5.14.)\" with items (i)-(iv); the numerical evidence becomes \"a direct computation on one small instance suggests ...\".",
'prop:hist:shannon': "Proposition, unchanged.",
'prop:hist:operator': "Proposition stated for $\\Mpq$ (definitional): \"\\SFIhist{} dominates $\\Mpq$ ...\"; the identification with operator induction goes into one sentence citing [Sol08] under the reading fixed in Remark 3.x. Delete \"given the unverified description\".",
'prop:hist:programs': "Proposition, unchanged; replace check identifiers in App. D by \"a direct computation\".",
'lem:hist:charsum': "Lemma, unchanged; \"Exhaustive search gives $\\max_GN(G)=8$ ($q=2$) and $22$ ($q=3$); for $q=4$ it lies in $[56,80]$.\" stays (standard form).",
'prop:hist:info': "Proposition [An individual-sequence bound and its limit]; (b) already reads \"The natural strengthening ... is false\": standard form. Delete tag.",
'rem:hist:exploit': "Remark; the informal sentence starts with \"Informally,\" and the proved bounds follow with references (already so); delete tag.",
# ex
'thm:ex:cycle': "Theorem, unchanged; `tab:ex:cycle` caption: delete the in-table \\status{computed}\\src{...} line; caption begins \"Exact finite mixtures (code in the accompanying repository):\".",
'thm:ex:ksteps': "Theorem, unchanged.",
'prop:ex:orderfree': "Proposition, unchanged; the 'sharper weak case open' becomes the existing Open Question (move to Open Problems, item 'depth count for weak semimeasures').",
'prop:ex:normalised': "Proposition, unchanged.",
'prop:ex:cychist': "Proposition, unchanged (its proof cites Corollary 5.18 (`cor:hist:H4`); 'given cor:hist:H4' is just the dependency).",
'prop:ex:cycsi': "Proposition, unchanged; the finite illustration: \"An exact Bayes mixture ... gives full-cycle label loss 0.13-0.26 bits (code in the accompanying repository).\"",
'prop:ex:asymp': "Proposition, unchanged.",
'thm:ex:expected': "Theorem, unchanged.",
'prop:ex:law': "Proposition, unchanged.",
'rem:ex:email': "Remark [A heuristic argument for Eisenstat's example]: \"The heuristic argument of [Hän26 / the author's correspondence with S. Eisenstat] (quoted in Appendix E.3) is correct in the semimeasure convention ...; for the normalised predictor the lower bound is open (the numbered Open Problem in Section 12).\" Remove \"Hänni's e-mail\" from the title.",
'prop:ex:burnin': "Proposition, unchanged.",
'prop:ex:rulestats': "Proposition, unchanged.",
'ex:ex:parity': "Example, unchanged.",
'ex:ex:threshold': "Example, unchanged.",
'prop:ex:frozen': "Proposition, unchanged.",
'lem:ex:depth': "Lemma, unchanged.",
'conj:ex:raw': "Conjecture, unchanged; \"Heuristic, not proved.\" -> \"Heuristic.\"",
'rem:ex:where': "Remark; the 'other direction' sentence is a conditional statement: \"if unnormalised $M$ has unbounded loss on ... (as [LHG11] show for related sub-patterns), then ...\" -- keep the conditional explicit; delete tag.",
'lem:ex:behind': "Lemma, unchanged.",
'lem:ex:pstar': "Lemma, unchanged.",
'rem:ex:fresh': "Remark, unchanged (delete tag).",
# ood
'prop:ood:relative': "Proposition, unchanged (\"corrected\" is internal; delete).",
'prop:ood:machine': "Proposition; after it: \"This is a supervised analogue of the dependence of AIXI on the reference machine [LH15b].\" (status 'analogue known' becomes this sentence; already present).",
'prop:ood:draftfalse': "Proposition [The literal two-sided bounds fail]: state the two literal bounds in the paper's notation first (one displayed formula each, citing [Hän26] once), then (a), (b) as counterexamples. Remove \"the draft\" from section and statement titles.",
'rem:ood:lopsided': "Remark [The novelty bound is lopsided]: already in the form \"Reading ... as ... is wrong: ...\" -- acceptable; delete tag.",
'prop:ood:labelled': "Proposition, unchanged; the disjointness check in the proof: \"(A direct computation on a finite mixture confirms the disjointness; code in the accompanying repository.)\" (already in this form).",
'rem:ood:answer': "Remark, unchanged (delete tag); candidate for merging into the Discussion.",
'ex:ood:hanniexamples': "Example [Three examples from the author's notes] (drop the possessive); computation sentence already in standard form.",
'conj:ood:natural': "Not a precise statement, so not a Conjecture environment. Replace by an item of the Open Problems list: \"Formulate and prove a version of 'natural universal machines generalise as intended on natural training sets' (e.g. for proof-search labels); by Proposition 7.4 (`prop:ood:machine`) any such statement must restrict the reference machine.\"",
# comp
'thm:comp:timebounded': "Split. Theorem (time-bounded SFI) = part (a) only. Part (b) becomes \"Remark (running time; proof sketch). With $n_i=2^{2^i}$ and $g(n)=\\lceil\\log\\log(n+4)\\rceil$, round $k$ costs at most ... A proof sketch is in Appendix G; the machine model and the cost of the clocks are not written out.\" Also move the toy computation (regret 132.4 vs 184) into a sentence \"A direct computation on a toy instance ...\".",
'rem:comp:distinct': "Remark [Distinct inputs are a real restriction]: already in the form \"One might hope ... For noisy labels it does not\"; numbers: \"a direct computation gives regret 469 bits\".",
'prop:comp:round': "Split: Proposition = the regret bound (proved). The last sentence (per-round cost) moves to a Remark \"(running time; proof sketch)\" or is prefixed \"Moreover, by a proof sketch in Appendix G, round $k$ costs ...\" and the theorem statement keeps only the regret.",
'rem:comp:apples': "Remark [Like-for-like comparison]; delete tag; replace \"Hänni's 'apples to oranges' caveat\" title.",
'prop:comp:history': "Split as for Proposition 8.4 (`prop:comp:round`): regret bound = Proposition; per-round cost = Remark with \"Proof sketch\".",
'prop:comp:samplers': "Proposition, unchanged (delete \"corrected\").",
'thm:comp:circuitbayes': "Theorem, unchanged; \"A grid computation gives the largest ratio 10.85 in place of 16\" -> \"A direct computation over a grid of $(\\mathcal E,d)$ values ...\".",
'rem:comp:gap': "Remark [Relation to the circuit sketch in [Hän26]]; computation sentence in standard form.",
'prop:comp:occam': "Proposition: \"(a) [BEHW87] ...; (b) ...\" -- the citation inside (a) is the 'known' status; delete tag.",
'rem:comp:majority': "Remark; \"known\" is carried by the citations [Lit88, LW94]; delete tag.",
'thm:comp:ladder': "Theorem [The conjunction ladder]; add \"The construction is from [VH26]; we give a complete proof for formulas and circuits and every tie rule.\" (already in text).",
'rem:comp:selection': "Remark [Selection rule versus prior]: keep the exact computations (\"An exact computation (code in the accompanying repository) gives ...\"); the slides' table: \"Vaintrob and Hänni [VH26] state the following further bounds, which we do not prove: ...\" Delete \"and we have not checked them\".",
'rem:comp:uniformties': "(plain proved) -",
'lem:comp:mobius': "Lemma, unchanged; the computation for $d\\le4$ in standard form.",
'rem:comp:adversary': "Remark (proved); \"A direct computation under seven tie rules ($d=3,4,5$) confirms this.\" (already).",
'rem:comp:constant': "(plain proved) -",
# nn
'prop:nn:functionspace': "Proposition (or Observation); delete \"(trivial)\".",
'prop:nn:upper': "Proposition, unchanged; the following text marks the Gaussian case explicitly: \"for Gaussian priors on real weights with sign outputs we only sketch why $P_A$ is lsc\" (already), so the statement keeps its hypothesis \"if $P_A$ is lower-semicomputed by $a$\".",
'prop:nn:typical': "Proposition; after it \"This is the standard fact that $-\\log P\\approx K$ on $P$-most objects [LV08].\" (already).",
'rem:nn:bridge': "Remark, unchanged (delete tag).",
'thm:nn:walsh': "Theorem; after the proof idea: \"Part (a) is known (see [YS19]); (b) is the standard dimension argument (cf. [KMS20]).\" Delete \"(as summarised in its abstract and in the slides)\".",
'cor:nn:separation': "Corollary, unchanged.",
'rem:nn:oddparity': "Remark; \"This is the cube analogue of the observation of Basri et al. [BJKK19] that two-layer networks without bias cannot learn odd frequencies on the sphere.\" (delete \"as stated in their abstract\"); \"this is computed, not proved\" -> \"(a direct computation; not proved)\".",
'rem:nn:slides': "Remark [Results stated in [VH26]]: \"The slides [VH26] state the following results, with the caveats that ... We do not use them. (i) ... (vi) ... We verify the warm-up computation of (i), the character argument of their Appendix J (Theorem 9.7(a)) and the ladder of their Appendix K (Theorem 8.14).\" Delete \"the rest is unchecked\" and the status words.",
'rem:nn:rigorous': "Remark; delete tag; candidate for deletion (it repeats the section).",
'rem:nn:literature': "Move into Section 11 (Related work) as a paragraph; delete \"These descriptions follow the abstracts\" and the status words; keep neutral one-line descriptions of verified papers.",
# related
'rem:related:new': "Not a remark: replace by a short paragraph \"Novelty\" at the end of Section 11 stating, without process vocabulary, what is believed new; BEFORE that, the author must check [Sol08], [Hut05, Ch. on supervised learning] and [LH13] (all three are obtainable) -- the remark itself says this must be done 'before any claim of novelty'. If not checked, delete the novelty list entirely and keep only \"We are not aware of earlier uses of the name 'Solomonoff function induction'.\"",
}
EXTRA_DEFAULT = "Keep as {env}; delete the tag. " 
ORDER=['setting','versions','learn','hist','examples','ood','comp','nn','related','app-setting','app-versions','app-learn','app-hist','app-examples','app-ood','app-comp','app-nn']
envs=sorted(envs,key=lambda r:(ORDER.index(r['file'].replace('sections/','').replace('.tex','')),r['line']))
rows = []
for r in envs:
    st = (r['status'] or '').strip()
    if st == 'proved':
        continue
    lab = r['label']; env = ENV[r['env']]
    loc = f"{r['file'].replace('sections/','')}:{r['line']}"
    if not st:
        act = "No tag (definition/remark); delete \\src only." if lab not in S else S[lab]
    elif lab in S:
        act = S[lab]
    elif re.fullmatch(r'remark.*', st):
        act = f"Keep as {env}; delete the tag."
    elif 'computed' in st and not re.search(r'known|sketch|refuted|open|conditional|conjecture|unverified', st):
        act = f"Keep as {env}; delete the tag; {CHK}."
    else:
        act = "TODO"
    rows.append((loc, lab, env, st or '(none)', act))
print("| # | label | env | file:line | current status | arXiv form |")
print("|---|---|---|---|---|---|")
for i, (loc, lab, env, st, act) in enumerate(rows, 1):
    st = st.replace('|', '\\|'); act = act.replace('|', '\\|')
    print(f"| {i} | `{lab}` | {env} | {loc} | {st} | {act} |")
todo = [r for r in rows if r[4] == 'TODO']
print(f"\n<!-- rows: {len(rows)}; TODO: {[t[1] for t in todo]} -->", file=sys.stderr)
