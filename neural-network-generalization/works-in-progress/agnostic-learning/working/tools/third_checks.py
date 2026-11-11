import re
V='../verification/'
def L(x,k): return "[`%s%s-revision-check-%d.md`](%s%s-revision-check-%d.md)"%(V,x,k,V,x,k)
def sub(s):
    return re.sub(r"@@([ACE])([123])@@", lambda m: L(m.group(1),int(m.group(2))), s)
def apply(p, reps, append=None):
    t=open(p).read()
    for a,b in reps:
        b=sub(b); n=t.count(a); assert n==1,(p,a[:80],n); t=t.replace(a,b)
    if append: t=t.rstrip('\n')+'\n\n'+sub(append).strip('\n')+'\n'
    open(p,'w').write(t)

apply('A-tight-conditioning-fails.md', [
("and the last two tables of the record answer two independent checks of this revision.",
 "and the last three tables of the record answer three independent checks of this revision."),
("* Checks of the revision: two independent checkers, not referees, each read this revision against revision 1 and the three second-round reports, the second after the first check's points had been answered. Each found every second-round issue answered and raised five minor points, answered in the last two tables below.",
 "* Checks of the revision: three independent checkers, not referees, each read this revision against revision 1 and the three second-round reports, each after the previous check's points had been answered: @@A1@@, @@A2@@ and @@A3@@, with their scripts in `../checks/revision-check-A-1/` to `../checks/revision-check-A-3/`. Each found every second-round issue answered. The first two raised five minor points each, answered in the tables \"First check of the revision\" and \"Second check of the revision\" below; the third raised three, which the lead editor resolved (last table)."),
("All six reports returned the verdict \"minor fixes\", and so did both checks of the revision.",
 "All six reports returned the verdict \"minor fixes\", and so did all three checks of the revision."),
("**First check of the revision.** One row per point raised by the first independent check.",
 "**First check of the revision** (@@A1@@). One row per point raised by the first independent check."),
("**Second check of the revision.** One row per point raised by the second independent check,",
 "**Second check of the revision** (@@A2@@). One row per point raised by the second independent check,"),
], append=r"""
**Third check of the revision** (@@A3@@). The third independent check found every second-round issue and every point of the second check resolved, found no mathematical error in a changed passage, and reproduced every new number. It raised three minor points; the lead editor resolved them as follows. None affects a theorem, lemma, proposition or corollary.

| point | resolution | where |
|---|---|---|
| 1. The sentence added to (U2) restricted only "the statements below that use (U2)" to priors whose outputs have prior mean $0$, but §0.2 item 6 and the remark after Lemma 6.2 come before §6.2; read alone, §0.2 item 6 still said that Proposition 6.6 gives the failure for any prior when $\rho(n)\le1$ | weakened: (U2) now says "the statements of this note that use (U2), including the summaries in §0.2 item 6, in the remark after Lemma 6.2 and in §10 item 6", and §0.2 item 6 carries the proviso itself | §6.2, (U2); §0.2 item 6 |
| 2. Row 5 of the second-check table said that the two width reports are linked where the status of `red-team.md` Proposition 6.1 is stated, but §5.4 "The heuristic" states that status without them | fixed: the two reports are linked there too | §5.4, "The heuristic", second paragraph |
| 3. (optional) §9 item 6 used a symbol $G$ that the note never defines | fixed: the bullet now gives the reduction of the data term, $(\Delta_0-\Delta)/c=(160.33-2.98)/16\approx9.8$ at $c=16$, and defines $\Delta$ and $\Delta_0$ as in `spc_small_d.py` | §9 item 6, "Larger $c$" |
""")

apply('C-fixed-temperature-bayes.md', [
("and then how the points raised by two independent checks of the revised note were resolved.",
 "and then how the points raised by three independent checks of the revised note were resolved."),
("### Check of the revision\n\nAn independent checker compared",
 "### Check of the revision\n\nAn independent checker (@@C1@@; scripts in `../checks/revision-check-C-1/`) compared"),
("### Second check of the revision\n\nA second independent check read",
 "### Second check of the revision\n\nA second independent check (@@C2@@; scripts in `../checks/revision-check-C-2/`) read"),
], append=r"""
### Third check of the revision

A third independent check (@@C3@@; scripts in `../checks/revision-check-C-3/`) read the note as revised after the second check. It found every referee issue and every point of the two earlier checks resolved, re-ran the seven scripts with outputs identical to the recorded ones, and raised three minor points, two of them optional. The lead editor resolved them as follows. No result is affected.

| point | resolution | where |
|---|---|---|
| §C.1.2 said that $m_\nu\le1$ is used only in two places, but the first row of "Check of the revision" also uses it, to pass from $\eta\sigma^2n\le(2-\sqrt3)m_\nu/16$ and $\sigma^2>1$ to $\eta n<0.0168$ | weakened: "In the results and proofs of this note, the first fact is used only in two places" | §C.1.2, "Coordinate law" |
| (optional) Remark C.6.2 said that the prior tail $2e^{-m_\nu N^\gamma/8}$ matches the tube cost $A_LN^\gamma$ "up to the factor $A_L$"; the exponents differ by the factor $8A_L/m_\nu$ | weakened: "up to a factor $O(A_L/m_\nu)$ in the exponent" | Remark C.6.2 |
| (optional) C.8 item 2 said that the per-sequence inequality (C.2.3) had no violation in any run, but `check_oracle_mc.py` tests only its first inequality | weakened: the sentence now names the first inequality and says that the second was not tested per sequence | C.8 item 2 |
""")

apply('E-finite-prior-scale.md', [
("and the corrections made after two independent checks of the revised text.",
 "and the corrections made after three independent checks of the revised text."),
("### First check of the revision\n\nThe first independent check of the revised text found",
 "### First check of the revision\n\nThe first independent check of the revised text (@@E1@@; scripts in `../checks/revision-check-E-1/`) found"),
("### Second check of the revision\n\nA second independent check, of the text as revised after the first check, found",
 "### Second check of the revision\n\nA second independent check, of the text as revised after the first check (@@E2@@; scripts in `../checks/revision-check-E-2/`), found"),
], append=r"""
### Third check of the revision

A third independent check, of the text as revised after the second check (@@E3@@; scripts in `../checks/revision-check-E-3/`), found every referee issue and every problem of the two earlier checks resolved, and reproduced the outputs of all ten scripts byte for byte. It raised two minor problems and three optional points. The lead editor resolved them as follows. No result is affected.

| # | issue | resolution | where |
|---|---|---|---|
| 1 | §2.7 item 1 said that the repository's energy cover would only give $\theta<1/(4(L-1))$, for general $L$; at $L=2$, B-tempered-likelihood.md Lemma 4.2 and Theorem 6.2 give $\theta<1/2$ | fixed: "$\theta<1/(4(L-1))$ for $L\ge3$, and $\theta<1/2$ for $L=2$ (B-tempered-likelihood.md Lemma 4.2, Theorem 6.2)" | §2.7, item 1, third bullet |
| 2 | The paragraph after Lemma 2.4 quoted the condition of `paper.tex` Lemma `spectral` as $N^{\gamma-1}\ge256/(mb^2)$, with bare $m$, which in this note is the competitor's width | fixed: $256/(m_\nu b^2)$, with $m_\nu$ named as the constant $m$ of `paper.tex` eq. `law` | §2.4, paragraph after Lemma 2.4 |
| optional (i) | Lemma 2.4 step 2 wrote $\gamma(\mathcal B)$ for a Gaussian measure, inside a lemma in which $\gamma$ is the prior exponent | fixed: $\gamma_{N^2}(\mathcal B)$, with a pointer to the entry $\gamma_P$ of §1.6 | Lemma 2.4, step 2 |
| optional (ii) | §7 item 2 said "in all 200 draws", but `check_opnorm.py` takes 200 draws for each of five shapes | fixed: "in all 200 draws of each shape (1000 draws in all)" | §7 item 2 |
| optional (iii) | the open list of §8 omitted the endpoint $\theta=1/H$, which the §6 table and §0 row 7 treat as open | fixed: added | §8, "Not proved / open" |
""")
print('done')
