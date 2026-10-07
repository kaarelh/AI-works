# Review: mathematical correctness of `setting.tex`, `app-setting.tex`, `single.tex`, `app-single.tex`

Lens: theorem statements against the research record (hypotheses, quantifiers, constants), line-by-line
check of the appendix proofs, and independent computations. Sources read: the four section files,
`NOTATION.md`, `OUTLINE.md`, `writer-notes.txt`, `research/tracks/single/notes-final.md` and `referee.md`,
`research/tracks/experiments/notes-final.md` §1.3 and §3.1 (Prop E1-lit, E1-al), `research/prior/induction/
second-order-notes.md` (C1, C5, C6) and `second-order-referee.md` (A1, C8.3), and `code/dtrc/mincover.py`
(`AlignedMinCover`).

Scripts (all in `research/paper-review/scratch/`):
- `align_cex.py`, `align_cex2.py`: counterexamples to the alignment proposition, run with the project's own
  code (`dtrc`), so they test the implemented semantics as well as the paper's definitions.
- `mini_dt.py` and `checks_single.py`: my own implementation of de Bruijn terms, plugging, DT° matching,
  D-features and witness events. It imports no project code. `python3 -I checks_single.py` checks the
  claims listed under "Verified" below. Every check passed except one, and that one was my own wrong
  expectation: the C8.2 data have 8 Eq-features, which matches the paper's list (2+2+4).

## Summary

`single.tex` and `app-single.tex` are faithful to the refereed record. I re-derived every appendix proof and
found no invalid step in Theorems A–G or the propositions. The only problems there are minor: (Rich) is
dropped from three summary sentences, there is a misleading comparison with the earlier rate, a range is
wrong, a proof sentence is garbled, and some wording needs fixing.

`app-setting.tex` contains one false result: the alignment proposition (prop:setting:align). The writer
extended it from DT°_F to DT°, but it is false in both classes. It inherits a gap that is already in the
record's proof of experiments Prop E1-al. The faulty step is "by preservation, ρ_d(par(T)) ⊆ par(d)". The
preservation lemma only covers skeleton positions. A parameter that occurs only inside an argument of a
non-pattern occurrence disappears from every datum whose value does not use that argument. It then need
not occur in the reference datum r through which alignments are built. I give counterexamples, verified
with the project code, to (b), to the last clause of (c), and (for DT°) to the minimality clause of (c).
The remark that "Min^al = Min up to ≡~ when some datum is parameter-free" is also false, and it does not
describe the implementation. Experiments are not affected, because their targets are parameter-free. The
fix is a hypothesis: all parameters of T lie in skel(T).

## Issues

### 1. [fatal] app-setting.tex, prop:setting:align (b) and (c): false for templates with a parameter only inside a derived argument

**Problem.** In the proof of (b), "By \cref{lem:setting:preservation}, $\rho_d(\mathrm{par}(T))\subseteq\mathrm{par}(d)$" is
invalid. Preservation is about skeleton positions. A parameter c that occurs only in an argument t_m of a
non-pattern occurrence M(t̄) vanishes from every datum whose body θ_d(M) does not contain z_m. So
G := ρ_r(par(T)) need not be a subset of par(r), and (G, ι) need not be an alignment. The record's proof of
experiments Prop E1-al has the same gap, so the statement is false for DT°_F as well as for DT°.

**Counterexamples.** These were computed with `dtrc` (`align_cex.py`, `align_cex2.py`).
- DT°_F, Example 1. Let D = { 0=0 ∧ (∀x 0=0 ∧ 0=0), 0=0 ∧ (∀x x=x ∧ w0=w0), w0=w0 ∧ (∀x x=0 ∧ w1=0) }, each
  datum canonicalized on its own. Let T = Q ∧ (∀x P(x) ∧ P(c)).
  - T ∈ DT°_F covers D up to renaming.
  - The first datum is parameter-free, so there is exactly one alignment.
  - Min^al(D) = { f0=f0 ∧ (∀x P0(x) ∧ f1=f2) }, and T ⪰~ M fails for this only member. So (b) fails, and so
    does the last clause of (c) with T* := T.
- Example 3: the same failure with T* = (Q ∨ ¬Q) ∧ (∀x P(x) → P(c)), all of whose instances are logically
  valid. The only member has false instances. This also falsifies experiments.tex prop:exp:oracle(b),
  which uses (c) "with alignments". That proposition is outside this lens.
- DT° (`align_cex2.py`). Let D' = {∀x(0=0) ∧ 0=0, ∀x(x=x) ∧ w0=w0, ∀x(x=0) ∧ w0=0}.
  - Under the paper's definition, the only alignment renames the parameters apart.
  - Min^al_DT°(D') = { ∀x(f0(x)=f1(x)) ∧ f2=f1(u) }.
  - T = ∀x(g(x)=h(x)) ∧ g(c)=h(c) covers D' (even literally), and T ⪰~ M fails. So (b) fails.
  - M ≻~ T strictly (ρ: u↦c, f2 := g(c)). So the minimality clause of (c) fails too.

**Fix.** Add the hypothesis "every parameter of T lies in skel(T)" (this includes parameter-free targets).
Replace (b) and (c) with:

"\textup{(b)} Every $T\in\mathcal C$ that covers $D$ up to renaming and all of whose parameters occur in
$\mathrm{skel}(T)$ satisfies $T\gen^{\sim}M$ for some member $M$.
\textup{(c)} $\Min^{\mathrm{al}}_{\mathcal C}(D)$ is finite; no template as in (b) lies strictly below a member;
and if $D\subseteq\inst^{\sim}(T^*)$ with $T^*\in\mathcal C$ and every parameter of $T^*$ in $\mathrm{skel}(T^*)$
(in particular if $T^*$ is parameter-free), some member $M$ satisfies $T^*\gen^{\sim}M$."

Then make these changes to the proof:
- In the proof of (b), replace the faulty sentence with "Every parameter of $T$ lies in $\mathrm{skel}(T)$,
  so by \cref{lem:setting:preservation} $\rho_d(\mathrm{par}(T))\subseteq\mathrm{par}(d)$."
- In the proof of (c), write "If some $T$ as in (b) satisfied…".
- Change the sentence after the proposition to say that the record's E1-al has the same restriction.
- Add a remark with Example 1 above: "a parameter that occurs only inside an argument of a non-pattern
  occurrence need not occur in the reference datum; a complete version would let alignments identify
  parameters across all data rather than through $r$".
- Tell the experiments writer that prop:exp:oracle(b) and the sentence at experiments.tex:44 inherit the
  restriction.

An alternative is to redefine alignments as partial injective identifications across all data, not
anchored at r. With that definition (b) holds in general. It would require a code change.

### 2. [fatal] app-setting.tex l.111: "If some datum has no parameter there is one alignment, and Min^al_C(D) is Min_C(D) up to ≡~"

**Problem.** Under the paper's definition, the single alignment (G = ∅) renames every parameter apart, so
Min^al(D) = Min(α(D)). This can differ from the literal Min(D).

Take D = {∀x(0=0) ∧ 0=0, ∀x(x=x) ∧ w0=w0, ∀x(x=0) ∧ w0=0}. In DT°_F:
- Min(D) = {∀xP0(x) ∧ f0=f1, ∀xP0(x) ∧ P0(w0)};
- Min(α(D)) = {∀xP0(x) ∧ f0=f1} (computed).

The writer's justification ("no covering template can then have a rigid parameter") overlooks parameters in
derived arguments. The implementation also does not match the definition: `AlignedMinCover.minimal()`
returns the literal `MinCover(D)` when there is at most one alignment, not Min(α(D)).

experiments' prop:exp:numerals proof cites this sentence. It is still fine there, because its data are
parameter-free.

**Fix.** Replace the sentence with: "If some datum has no parameter there is exactly one alignment
($G=\emptyset$); it renames all parameters apart, so no member has a parameter in its skeleton. It can differ
from the literal $\Min_{\mathcal C}(D)$ of the canonicalized data: for
$D=\{\forall x(0{=}0)\wedge0{=}0,\ \forall x(x{=}x)\wedge w_0{=}w_0,\ \forall x(x{=}0)\wedge w_0{=}0\}$ the literal set
also contains $\forall xP(x)\wedge P(w_0)$. (The implementation uses the literal set in this case.)"

### 3. [major] setting.tex l.205 (sec:setting:params): "proves that it has the properties of $\Min(D)$"

**Problem.** This is an overclaim, given issue 1.

**Fix.** Replace it with "proves that it has the properties of $\Min(D)$ for templates all of whose parameters
occur in their skeleton, in particular for parameter-free targets (\cref{prop:setting:align}); a parameter
that occurs only inside an argument of a non-pattern occurrence is not covered".

### 4. [major] single.tex l.19, l.253, l.267: (Rich) dropped in three claims

**Problem.**
- l.19 says "D is an anchor iff three witness events hold". The "only if" direction needs (Rich).
- l.253 says "whether D is an anchor for a given T* is polynomial (… each decided by forcing)". This
  decides the events, which characterize anchors only under (Rich). Without (Rich) the anchor condition is
  open (Example D.7 and Open problems).
- l.267 says "and an anchor always has one [lgg]". This is cor:single:anchor-lgg, which assumes (Rich).
  The record's summary was corrected for exactly this omission (referee item G3–G4).

**Fix.**
- l.19: "that, under a richness assumption that always holds with parameters, $D$ is an anchor iff three
  witness events hold".
- l.253: "and, under \Rich, whether $D$ is an anchor for a \emph{given} $T^*$ is polynomial (…)".
- l.267: "and, under \Rich, an anchor always has one (\Cref{cor:single:anchor-lgg})".

### 5. [minor] single.tex l.116: "\Rich\ holds for arithmetic and set theory"

**Problem.** The record says "for set theory with parameters". Without parameters it fails, which is the
paper's own remark at l.153.

**Fix.** "\Rich\ holds for arithmetic, and for set theory with parameters (always available in closure-normal
form); pure set theory without parameters violates it (see below)."

### 6. [minor] single.tex l.178: "for induction this is the earlier exact rate $\sum_fp_f^N+(1-q)^N-\sum_fr_f^N$ up to its inclusion–exclusion term"

**Problem.** The bound (1−ρ)^{N−1}+(1−q)^N is exactly prior C5(b)'s upper bound p_max^{N−1}+(1−q)^N. It
differs from the exact value by more than the inclusion–exclusion term, because Σ_f p_f^N is replaced by
p_max^{N−1}.

**Fix.** "for induction it is exactly the earlier bound $p_{\max}^{N-1}+(1-q)^N$, which dominates the earlier
exact value $\sum_fp_f^N+(1-q)^N-\sum_fr_f^N$".

### 7. [minor] single.tex l.298 (Open problems): "templates of size $\le11$ make the cautious verifier accept a false induction-shaped sentence after any anchor"

**Problem.** Prior C6.2 proves this only for 7 ≤ s ≤ 11. For s < 7 not even the anchor characterization
is stated. setting.tex l.161 has the correct range.

**Fix.** "for size bounds $7\le s\le11$ the cautious verifier accepts a false induction-shaped sentence after
any anchor, while $s\ge12$ suffices for soundness".

### 8. [minor] single.tex l.209 (prop:single:quadratic(i)): "(it violates a Scope feature)", and "the same with the $j$-th left-hand side"

**Problem.** d_2 violates a Sym feature, not a Scope feature. "The same" is ambiguous between d_1 and d_2;
the proof uses d_1. Either reading works.

**Fix.** "$q_{j,k}$ is $d_1$ with the $j$-th left-hand side replaced …" and "($d_2$ violates a Sym feature,
each $q_{j,k}$ a Scope feature)".

### 9. [minor] app-single.tex l.125, proof of thm:single:rates(b)

**Problem.** "Each failure event has positive probability for some $N$ iff some support element, or some pair
of support elements, witnesses it." As written this is wrong: "all roots at σ equal" has positive
probability for every N, whatever the support. What is needed is the characterization of ρ, ν, κ > 0.

**Fix.** "$\rho_\sigma>0$ iff two support elements have different roots at $\sigma$; $\nu_{M,m}>0$ iff some support
element uses $z_m$; $\kappa_{\sigma,r}>0$ iff some pair of support elements has no common $\bar u$, which by
\Cref{lem:single:basic}(d) (pairwise; finiteness not used) holds iff the support has no coincidence at
$(\sigma,r)$."

### 10. [minor] app-setting.tex l.106: preorder parenthetical "$\rho'\rho$ is injective on $\mathrm{par}(T)$ because $\mathrm{par}(T')\supseteq\rho(\mathrm{par}(T))$ by \cref{lem:setting:preservation}"

**Problem.** The intermediate claim is false. Take T = ∀xP(x) ∧ P(a) ∧ b=b and σ(P) = λz.R. Then a vanishes
from T', and ρ' : b ↦ a is allowed. The conclusion (⪰~ is a preorder) still holds.

**Fix.** Replace it with: "after changing $\rho'$, on the parameters of $\rho T$ that do not occur in $T'$, to fresh
distinct names (such parameters occur only inside arguments whose holes $\sigma$ discards, so $T''$ is unchanged),
$\rho'\rho$ is injective on $\mathrm{par}(T)$".

### 11. [minor] app-setting.tex l.132, proof of prop:setting:align(a)

**Problem.** "The rigid parameters of $M$ occur in … So $\alpha_d^{-1}$ is injective on $\mathrm{par}(M)$". A member M can
have parameters in derived arguments that do not occur in α_d(d); the member in issue 1's DT° example has
u. On such parameters α_d^{-1} is undefined. The conclusion is still true.

**Fix.** "Extend $\alpha_d^{-1}$ injectively to $\mathrm{par}(M)$ by sending the parameters of $M$ that do not occur
in $\alpha_d(d)$ to fresh distinct names; they occur in $M$ only inside arguments that $\theta_d$ discards. Then
$d=(\alpha_d^{-1}M)(\alpha_d^{-1}\theta_d)$."

### 12. [minor] setting.tex l.135, def:setting:protocol: the verifier is inconsistent when VS(D,N) = ∅

**Problem.** With ∩∅ = all sentences, the verifier both accepts and rejects every q.

**Fix.** "rejects iff $\mathrm{VS}(D,N)\neq\emptyset$ and $q\notin\bigcup\mathrm{VS}(D,N)$".

### 13. [minor] single.tex l.296, caveat (5): incomplete list of post-referee additions

**Problem.** The encoded bound $(\lfloor(N-1)/k\rfloor-1)^k$ over $=,+,S,0$ in cor:single:unions(iii) is missing.
Its proof was written in the revision (record Cor F.4, "made explicit in revision"), and the referee only
asked for it.

**Fix.** Add "the encoded lower bound over $=,+,S,0$ in \Cref{cor:single:unions}(iii)" to the list.

### 14. [minor] single.tex l.135 (cor:single:special(c)): Separation notation

**Problem.** Separation is written ∀a∃b∀x(…P(x,a)), with events (N_x), (N_a) that are never defined.
setting.tex uses T_Sep = ∀z∃y∀x(…P(x,z)).

**Fix.** Use $T_{\Sep}$ from \cref{sec:setting}. Write "\evN$_x$, \evN$_z$ (\evN\ for the argument place of $x$, resp. $z$)"
and "$y$ cannot occur in $P$".

### 15. [minor] single.tex l.168: lower bound "$\max_{(\sigma,r)}\chi_{\sigma,r}^N$"

**Problem.** The index set is not stated. It must be U(T*): for a valid pair the event is not a failure.

**Fix.** Write $\max_{(\sigma,r)\in U(T^*)}$.

## Verified (no issue)

Each item was checked against the record and re-derived. Items marked † were also computed
independently with `mini_dt.py`.

- Matching theorem (a)–(d).
  - Uniqueness, correctness and the linear-time accounting: the visited body nodes number at most
    |s|_q|+1, and the occurrence subtrees are disjoint.
  - Freezing.
  - SO° projection/imitation.
  - 2^k matchers for P(0)†.
  - Lemma R, steps 1–3, including ρ∘π = id ⇒ arity equal.
- ex:setting:classes(4)†: covers 0+0=0 and S0+0=S0 but misses SS0+0=SS0. Size of T_Ind = 14.
- lem:setting:closed (a)–(c), lem:setting:onesided, and the nested-arguments remark (T_k cover; f := z+0
  separates them).
- Theorem B.
  - Steps V and H preserve DT° and coverage.
  - The lexicographic measure decreases.
  - The saturated-template count.
  - The minimality argument via Lemma R.
- Theorem C (both inclusions) and Cor C.1.
- Theorem D (both directions; I checked each (Rich) use). Cor D.1–D.3.
  - D.4, D.5, D.6: events and violating instances†.
  - 400 random small arithmetic targets: (R*)(N)(U) agreed with pool-based anchor status (198 anchors),
    with 0 disagreements†.
- Theorem E.
  - The union bound and the pair-splitting step.
  - The algebra of (b).
  - (c): 1−e^{−a} ≥ 3a/4 on [0,1/2]† and (1−λ)^{⌊n/2⌋} ≤ √e·e^{−λn/2}†.
  - Lower bounds under (Rich).
  - Ground conventions.
- Prop E.2 (i)–(iii).
- Worked laws†:
  - law 1: exact 0.057714 = 0.7^8+0.3^8 by feature-based anchor status; bound 0.059942; χ^8 = 0.057648;
  - law 2: 1−κ = 1/6; coincidence probability 1.536·10⁻⁴.
- Lemma F.1 and Theorem F (the never-returns argument for E-pairs).
  - The linear chain for N = 5, 6, 8†.
  - Prop F.8(i) for m = 1..4 and (ii) for m = 2, 3: sizes 5m−1 and 20m+1, every step outside Acc†. The
    C11 arithmetic.
  - Prop F.9 and Lemma F.10 (a)–(c).
- Cor F.2 (elasticity and thickness)†. Cor F.4(iii): the k = 2, N = 9 chain gives 9 escalations by my own
  partition-based union verifier†.
- Prop F.5 (nonemptiness) and Prop F.6.
- Prop G.2: sizes 8n+8; Acc(D_n) = D_n; 2+4n Eq-features for n = 1..3†.
- Prop G.3 (both directions) and Cor G.4.
- C8.2 feature list (8 Eq-features, as described)†.
- All quoted counts against the record and referee:
  - 103 = 81+22 cases; 7621 = 5804+1817 queries;
  - 248/248, 149/144, 540/540, 519/519;
  - 27/17 and 45/29 of the wrong candidates;
  - 115/63 for the lgg criterion;
  - 2749 and 35 templates;
  - chain lengths 6, 18, 38, 66;
  - escalation counts 5, 10, 17, 26.
- No undefined references in these sections; cross-labels resolve.
