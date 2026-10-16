# Thread `sfi`: Solomonoff axiom induction and Solomonoff operator induction, with time bounds

*Research record of the development round, 2026-10-15. Brief: `00-brief.md` (this folder). Binding notation: `../../NOTATION-draft.md` (function machines are $F$, theory machines $G$; "SAI" means the one-tape law $M_A$, "SOI" the one-tape law $M_F$). The name "Solomonoff axiom induction" is a working name; nothing below depends on it. Scripts are in `checks/`; each is seeded or deterministic and writes `<name>.out` next to itself. No git command that changes repository state was run.*

**Sources and how they are cited.**
* *AI-paper*: `../../../../axiom-induction/paper/` (`sections/time.tex`, `app-time.tex`), printed numbers from `main.aux` (e.g. AI-paper Thm 6.3 = `thm:time:equiv`). Its refereed records: **TF** = `research/tracks/time-followup/notes-final.md`, **SD** = `research/tracks/short-derivations/notes-final.md`, model §6.
* *P1* = SOI Paper 1, `../../../../solomonoff-operator-induction/paper/` (identical copy under `solomonoff-function-induction/paper/`), cited by printed number and label; *P2* = Paper 2.
* Scouts: **S** (`../../scouts/sfi/notes.md`), **F** (`../../scouts/fundamentals/notes.md`), **N1** (`../../scouts/novel-logic/notes.md`), **L** (`../../scouts/literature/notes.md`). Other threads by target number (`fundamentals` T6, `logic` T1, `shape` T5, `terms`).

**Statuses.** *proved* (full proof here, or a full proof in a cited refereed record that was re-read line by line for this record; then the record is named); *proved, given X* (X a cited known result or a result of another thread); *known* (exact reference, verification level stated); *known, unverified* (recalled; not checked in this run); *computed* (script and saved output named); *proof sketch* (missing steps named); *conjecture*; *open*; *refuted* (kept with its counterexample).

---

## 0. Summary

**The relation, version by version** (semimeasure convention; "$\asymp$" = within $2^{\pm c}$ on every data set, $c$ a machine constant).

| SAI | SOI | relation | here |
|---|---|---|---|
| coin-free $W_A$ (enumerators), $W_A^{\rm dec}$ (deciders; the AI-paper's AI) | coin-free consistent $W^{\rm cons}$ (the AI-paper's FIcons), and closed $W^{\rm cl}$ | $W_A\asymp W_A^{\rm dec}\asymp W^{\rm cons}\asymp W^{\rm cl}$, including the three-way (prove / refute / neither) weights against $W^{\rm cl}$ | Thm 2.1 |
| $K_A$ | $K_F^{\rm cons}$ | equal $\pm c$ | Thm 2.1 |
| one-tape $M_A$, random deciders $M_A^{\rm dec}$ | one-tape consistent $M_F^{\rm cons}$, closed $M_F^{\rm cl}$ | $\asymp$ on **every** finite $D$, tape by tape; three-way weights against $M_F^{\rm cl}$ | Thm 3.1, Cor 3.2 |
| one-tape with membership-time or generation-time penalties $M_A^{{\rm chk},t}$, $M_A^{{\rm gen},t}$ | $M_F^{\rm cons}$ | $\asymp$, also class by class (posterior odds of any two classes of theories move by $\le 2^{2c}$), under a tape version (S$_{\rm tape}$) of the AI-paper's self-simulation assumption | Thm 3.4, Prop 3.5 |
| any version on positive literals of a fresh predicate | P1's same version on strings | $\asymp$ / $\pm c$: **SAI is SOI there** | Thm 5.1, §5.5 |

**What is new in this round** (beyond re-verifying and restating the earlier results).
1. The one-tape equivalence holds on every finite data set, the empty one included, and for the three-way outcome weights against closed one-tape labellers (Thm 3.1, Cor 3.2). [proved]
2. The penalised one-tape versions: padding by the work counter works tape by tape (Thm 3.4, Prop 3.5). [proved, under the stated assumption (S$_{\rm tape}$), which is the AI-paper's (S) for machines that read a tape]
3. The gap between the one-tape and the coin-free version on literal data is at most the randomness deficiency of the labels plus $K^{\rm pad}(2^{d+1})$ (Prop 5.3). Scout S had restricted its bound to two points; the general form is P1's own remark `rem:versions:answer`(2), transferred. [proved]
4. On the lottery stream of `logic` T1, *plain* coin-free SOI on sentences has bounded loss while coin-free *consistent* SOI and $W_A$ do not (Cor 4.2). [proved, given N1 Thm E1 and Prop E2(b)]
5. Consistent SOI never becomes certain of a logical consequence: for every $D$ and every sentence $\chi\notin\dom D$, the posterior probability that the sampled labeller is undefined at $\chi$ is at least $2^{-K(\chi)-c}$, uniformly in $D$ (Prop 6.1(c)). [proved; computed]
6. The independent-label separation (an observed "independent" label separates theories from labellers by an unbounded amount on one datum) holds for every decidable $\Sigma_1$-sound $B\supseteq\Q$ (Prop 6.3), **also for the one-tape versions** (Prop 6.5, via the Lebesgue density theorem), and its witnesses cannot form a computable, or even r.e., family (Prop 6.4). [proved; finite mechanism computed]
7. None of $W_A$, $W^{\rm cons}$, $M_A$, $M_F^{\rm cons}$ is lower semicomputable when consistency of finite sets is not r.e. (Prop 6.7): the support of an lsc function is r.e. [proved]
8. Pathwise and machine-wise consistency (scout S's Rem 2.14): $M_F^{\rm cons}\asymp M_F^{C}$ whenever consistency of finite sets of sentences with $B$ is decidable, by a global-schedule filter (Prop 6.8(c)); general bounds proved; the general case **open**. [proved; computed]
9. Presburger arithmetic: (i) the coin-free and the exponential-clock one-tape separations are re-verified (Props 9.1, 9.2); (ii) derivation-charged SAI with any budget below doubly exponential fails too, by Fischer–Rabin's *nondeterministic* bound and AI-paper Thm 6.9 (Prop 9.4), so the proof-length clause of Fischer–Rabin is not needed; (iii) the doubly exponential one-tape case is proved **conditionally** on two recalled, unverified results, a $\Sigma_2$-time lower bound for Presburger arithmetic of Berman's type and the time-bounded Sipser–Gács–Lautemann inclusion (Prop 9.3).
10. The circuit sandwich (T10): finite axiom sets in a **fixed** finite language with short derivations and nondeterministic verifier circuits are polynomially related in both directions (Thm 10.1), with a gate-indexing scheme by terms; P1's circuit-Bayes theorem holds for verifier circuits (Cor 10.2). [proved, given the standard circuit simulation of Turing machines; computed for tiny $d$] For a prior over all finite axiom sets the mistake-to-size direction is a proof sketch (Rem 10.3).
11. The table of equivalences and separations (§11).

**Qualifications of earlier slogans** (all from the earlier report, which is Claude-authored; none concerns a claim of the author's).
* "Axiom induction $\equiv$ consistent function induction" (AI-paper §6) holds for every version separately: coin-free (Craig), one-tape (no Craig needed), Kolmogorov. Its proof via Hänni's schema needs two sorts or a sound assigner; the conclusion does not (Prop 2.2).
* The equivalence controls semimeasure losses, not the meaning of "undefined": SOI's $\bot$ mixes logical independence with laziness (Prop 6.1), and with "independent" as an *observed* label the equivalence is one-sided, with unbounded gaps (Props 6.3–6.5).
* The diagonal separations under time bounds come from free deduction, not from axioms (Prop 7.6); on a natural theory (Presburger) the separation is real and non-diagonal but again disappears when deduction is charged (Prop 9.4).

**Possible error in the author's view.** None arises in this thread. The author's conjectured equivalence of SAI with consistent SOI is true, in the coin-free, one-tape and Kolmogorov versions (Thms 2.1, 3.1); the schema route fails in one sort, which is already recorded and agreed (AI-paper Prop 6.5).

---

## 1. Setting and dictionary (T1)

### 1.1 Objects

Throughout, $\mathcal L$ is a countable first-order language with computable syntax, $B\subseteq\Sent_{\mathcal L}$ a decidable consistent background, $V$ the universal prefix machine, $\Omega_V:=\sum_{p\in\dom V}2^{-|p|}<1$. A data set $D$ is a finite partial function $\Sent_{\mathcal L}\rightharpoonup\{0,1\}$; $D^\pm$, $\psi_D$ as in NOTATION §3.2. $\mathsf U$ is the fair-coin measure on tapes.

* **Theory machines** (NOTATION §4.1). A c.e. set $G\subseteq\{0,1\}^*\times\Sent_{\mathcal L}$; $A^G_\omega$; $\nu_G(D):=\mathsf U\{\omega:B\cup A^G_\omega\text{ consistent and}\vdash\psi_D\}$; $G_U:=\{(pw,\chi):p\in\dom V,(w,\chi)\in G_{V(p)}\}$; $M_A:=\nu_{G_U}$, $A_\omega:=A^{G_U}_\omega$.
* **Function machines** (P1 Def 3.6, letter $F$ here). A c.e. consistent set $F\subseteq\Sent_{\mathcal L}\times\{0,1\}^*\times Y$; $f^F_\omega$; $\nu_F(D):=\mathsf U\{\omega:f^F_\omega\supseteq D\}$; $F_U$ the universal one (P1 Thm 3.8), $M_F:=\nu_{F_U}$, $f_\omega:=f^{F_U}_\omega$. Here $Y=\{0,1\}$ unless three-valued labels are stated.
* **Definition 1.1 (consistent and closed labellers; scout S Def 2.1).** For a partial $f:\Sent_{\mathcal L}\rightharpoonup\{0,1\}$, $\Gamma_f:=\{\varphi^{f(\varphi)}:\varphi\in\dom f\}$. $f$ is *consistent* if $B\cup\Gamma_f$ is consistent, and *closed* if moreover $f(\varphi)=b\iff B\cup\Gamma_f\vdash\varphi^b$ for all $\varphi,b$.
* **Consistent and closed one-tape SOI.** $\nu^{\rm cons}_F(D):=\mathsf U\{\omega:f^F_\omega\supseteq D,\ f^F_\omega\text{ consistent}\}$, $\nu^{\rm cl}_F$ likewise with "closed and consistent"; $M_F^{\rm cons}:=\nu^{\rm cons}_{F_U}$, $M_F^{\rm cl}:=\nu^{\rm cl}_{F_U}$.
* **Random deciders.** Function machines $F$ with outputs in $\{0,1\}$ such that $f^F_\omega$ is total for every $\omega$; $A^{\rm dec}_F(\omega):=\{\chi:f^F_\omega(\chi)=1\}$; $\mu^{\rm dec}_F(D):=\mathsf U\{\omega:B\cup A^{\rm dec}_F(\omega)\text{ consistent},\vdash\psi_D\}$; $M_A^{\rm dec}(D):=\sum_{p\in\dom V,\ F_{V(p)}\text{ a random decider}}2^{-|p|}\mu^{\rm dec}_{F_{V(p)}}(D)$.
* **Coin-free and Kolmogorov versions.** $W_A$, $K_A$ over enumerators (indices of r.e. sets $\mathsf W_{V(p)}$), $W_A^{\rm dec}$, $K_A^{\rm dec}$ over deciders; $W^{\rm cons}$, $W^{\rm cl}$, $K_F^{\rm cons}$, $K_F^{\rm cl}$ over the partial computable labellers $\{V(p)\}$ (Kleene bracket, NOTATION §2) that are consistent, resp. closed and consistent; plain $W$, $M_F$, $K_F$ on sentences are P1's objects with $X=\Sent_{\mathcal L}$ (the AI-paper's FIall is $W$).

*Measurability.* $\{\omega:f_\omega\supseteq D\}$ is open. "$f_\omega$ inconsistent" is open: an inconsistency uses finitely many labels, each certified under a prefix of $\omega$, and these prefixes are comparable. "$f_\omega$ closed" is a countable intersection of Borel conditions. For theory machines $\{\omega:B\cup A_\omega\vdash\psi\}$ is open and consistency is closed (F1(a)). All events below are Borel.

### 1.2 The decompositions

**Lemma 1.2 (mixture decompositions) [proved].** For every finite $D\neq\emptyset$,
$$M_F^{\rm cons}(D)=\sum_{p\in\dom V}2^{-|p|}\nu^{\rm cons}_{F_{V(p)}}(D),\tag{1.1}$$
and the same for $\nu^{\rm cl}$ and for $\nu$ (P1 eq. (setting:mixture)); for $D=\emptyset$ add $1-\Omega_V$ on the right (for $\nu^{\rm cl}$: add $(1-\Omega_V)\cdot[\text{the empty labeller is closed}]$). For every finite $D$, the empty one included,
$$M_A(D)=\sum_{p\in\dom V}2^{-|p|}\nu_{G_{V(p)}}(D)+(1-\Omega_V)\,[B\vdash\psi_D].\tag{1.2}$$

*Proof.* $\dom V$ is prefix-free, so every tape has at most one prefix $p\in\dom V$. On a tape $p\omega'$, $f^{F_U}_{p\omega'}=f^{F_{V(p)}}_{\omega'}$ and $A^{G_U}_{p\omega'}=A^{G_{V(p)}}_{\omega'}$, with $\omega'$ uniform given $p$. On the tapes with no prefix in $\dom V$ (measure $1-\Omega_V$), $f_\omega$ is nowhere defined, so it extends $D$ only if $D=\emptyset$ (and it is consistent, $B$ being consistent); and $A_\omega=\emptyset$, so the theory is $B$, consistent, and proves $\psi_D$ iff $B\vdash\psi_D$. $\square$

The weight on index $i$ is $\mm(i)=\sum_{V(p)=i}2^{-|p|}$, so (1.1) reads $M_F^{\rm cons}=\sum_i\mm(i)\nu^{\rm cons}_{F_i}$ on nonempty $D$.

### 1.3 The four maps

Every proof of an equivalence below uses one or more of four constructions. For a computable map $h$ on indices, universality of $V$ gives a string $r_h$ with $V(r_hs)=h(V(s))$ for all $s\in\dom V$ (the prefix machine $s\mapsto h(V(s))$ is simulated with prefix $r_h$). So $p\mapsto r_hp$ is injective, maps $\dom V$ into $\dom V$, and adds $|r_h|$ to the length. "Tape by tape" means: the stated relation holds for every tape $\omega$.

**Lemma 1.3 (the maps) [proved].**
* **(PS) Proof search.** For a theory machine $G$ let $F_G$ answer a query $\varphi$ as follows: in stages $s=1,2,\dots$ read the tape up to bit $s$, run $s$ steps of the enumeration of $G$ restricted to pairs $(w,\chi)$ with $w$ a prefix of the bits read, and test all derivations of size $\le s$ from $B$ together with the sentences emitted so far; halt with $1$ at the first derivation of $\varphi$, with $0$ at the first derivation of $\neg\varphi$ (within a stage $\varphi$ is tested first). Then $F_G$ is a function machine, and on every tape $\omega$ with $B\cup A^G_\omega$ consistent, $f^{F_G}_\omega$ is consistent and closed and decides every sentence exactly as the theory $B\cup A^G_\omega$ does. In particular $\{\omega:G\text{ compatible with }D\}\subseteq\{\omega:f^{F_G}_\omega\supseteq D,\ f^{F_G}_\omega\text{ closed and consistent}\}$.
* **(EM) Emission.** For a function machine $F$ let $G_F:=\{(w,\varphi):(\varphi,w,1)\in F\}\cup\{(w,\neg\varphi):(\varphi,w,0)\in F\}$. Then $A^{G_F}_\omega=\Gamma_{f^F_\omega}$ for every $\omega$. So if $f^F_\omega$ is consistent and extends $D$, then $G_F$ is compatible with $D$ on $\omega$; if $f^F_\omega$ is closed and consistent, the theory $B\cup A^{G_F}_\omega$ decides every sentence exactly as $f^F_\omega$ does.
* **(CR) Craig.** For a function machine $F$ (presented as a machine that reads the tape one-way) let $C_F$ answer a query $\chi$: find the at most two decompositions $\chi=\psi^{\wedge m}$ (right-nested $m$-fold conjunction; $m=1$, or $\psi$ the left conjunct of $\chi$ and $m$ fixed by $|\chi|$); for each, if $\psi=\varphi$ (or $\psi=\neg\varphi$), run $F$ on $\varphi$ for exactly $m-1$ steps, reading the tape as $F$ does, and answer $1$ iff $F$ halts at step $m-1$ with label $1$ (label $0$); answer $0$ otherwise. Then $C_F$ is a random decider and $A^{\rm dec}_{C_F}(\omega)$ is Craig's set of $f^F_\omega$, with $\Cn(B\cup A^{\rm dec}_{C_F}(\omega))=\Cn(B\cup\Gamma_{f^F_\omega})$.
* **(CL) Closure.** For a partial computable labeller $f$ let $\bar f$ be "search for proofs of $\varphi$ and of $\neg\varphi$ from $B\cup\Gamma_f$ (dovetailing the enumeration of $\Gamma_f$)". If $f$ is consistent, $\bar f$ extends $f$, is consistent and closed, and $\Cn(B\cup\Gamma_{\bar f})=\Cn(B\cup\Gamma_f)$.

*Proof.* (PS) The run on query $\varphi$ is a deterministic function of the bits read, and a halting run that has read $w$ runs identically on every tape extending $w$; so the triples $(\varphi,w,y)$ of halting runs are consistent, and the set is c.e. Let $B\cup A^G_\omega$ be consistent. If it proves $\varphi^b$, a derivation uses finitely many axioms, each emitted under a prefix of $\omega$; at a late enough stage they have all been enumerated and the derivation has size $\le s$, so the run halts; it cannot find a derivation of $\varphi^{1-b}$ first, because none exists. If the theory decides neither, no derivation is ever found and $f(\varphi)=\bot$. So $f^{F_G}_\omega(\varphi)=b$ iff $B\cup A^G_\omega\vdash\varphi^b$. Then $\Gamma_f\subseteq\Cn(B\cup A^G_\omega)$ is consistent with $B$, and $f$ is closed: $B\cup\Gamma_f\vdash\varphi^b$ implies $B\cup A^G_\omega\vdash\varphi^b$ (as $\Gamma_f\subseteq\Cn(B\cup A^G_\omega)$), which implies $f(\varphi)=b$; the converse holds as $\varphi^b\in\Gamma_f$.
(EM) $G_F$ is c.e. and emits $\varphi^y$ exactly under the prefixes that certify $f(\varphi)=y$; so $A^{G_F}_\omega=\Gamma_{f^F_\omega}$. If $f$ is closed, $B\cup\Gamma_f\vdash\varphi^b$ iff $f(\varphi)=b$.
(CR) Every run is bounded by $m-1$ simulated steps, so $C_F$ halts on every query and every tape: a random decider. Its answer depends only on the tape bits read by the simulated run, so its triples are consistent. Its accepted set on $\omega$ is $\{\varphi^{\wedge(k+1)}:F\text{ halts on }\varphi\text{ with }1\text{ in exactly }k\text{ steps}\}\cup\{(\neg\varphi)^{\wedge(k+1)}:\dots\text{ with }0\dots\}$. Each member is equivalent to a member of $\Gamma_{f_\omega}$, and each member of $\Gamma_{f_\omega}$ has one. (This is AI-paper Thm 6.3's construction with the tape added; re-checked against `app-time.tex`, proof of Thm 6.3, and TF Lemma 2.1(b) for the "at most two decompositions".)
(CL) As (PS), with the r.e. set $\Gamma_f$ in place of $A^G_\omega$; $f(\varphi)=b$ puts $\varphi^b\in\Gamma_f$, so $\bar f(\varphi)=b$. $\square$

**Remark 1.4 (only inclusions are claimed).** The (PS) inclusion can be strict: on a tape on which the theory is inconsistent the labeller may still have committed to a consistent set of labels before the inconsistency appeared. In the finite propositional analogue this happens often (`checks/c1_onetape_finite.out`, item (1): $F_G$ strictly larger in 40635 and 50267 machine–data–tape triples; item (5a): 135 and 167 tapes with an inconsistent theory but a closed consistent $F_G$). Scout S's toy reported equality in its item (1); nothing below needs equality.

---

## 2. The coin-free equivalence (T2)

**Theorem 2.1 (coin-free equivalence) [proved; Craig 1953 known].** There is $c$, depending only on $V$, the coding of syntax and $B$, such that for every finite $D$:
(a) $2^{-c}W_A(D)\le W^{\rm cons}(D)\le2^cW_A(D)$, $\;2^{-c}W_A(D)\le W_A^{\rm dec}(D)\le2^cW_A(D)$, and $2^{-c}W^{\rm cons}(D)\le W^{\rm cl}(D)\le W^{\rm cons}(D)$;
(b) $K_A$, $K_A^{\rm dec}$, $K_F^{\rm cons}$ and $K_F^{\rm cl}$ agree up to $\pm c$, and all are finite iff $B\cup D^\pm$ is consistent;
(c) for every $\varphi\notin\dom D$ and each outcome $o\in\{1,0,\bot\}$, with $W_A(D;\varphi\mapsto o)$ the weight of the compatible enumerators whose theory proves $\varphi$ ($o=1$), proves $\neg\varphi$ ($o=0$), or decides neither ($o=\bot$), and $W^{\rm cl}(D;\varphi\mapsto o)$ the weight of the closed consistent labellers extending $D$ with $f(\varphi)=o$:
$2^{-c}W_A(D;\varphi\mapsto o)\le W^{\rm cl}(D;\varphi\mapsto o)\le2^cW_A(D;\varphi\mapsto o)$.
Hence the semimeasure losses of all four coin-free inducers agree within $2c$ on every $D$ in every order.

*Proof.* Coin-free versions of the maps of Lemma 1.3 (deterministic machines ignore the tape).
* *Enumerators to labellers* (PS): $p\mapsto r_{\rm ps}p$; if $p$ is compatible, the proof-search labeller is closed and consistent, extends $D$, and decides each $\varphi$ as the theory does.
* *Labellers to enumerators* (EM): $p\mapsto r_{\rm em}p$, the enumerator of $\Gamma_{\{V(p)\}}$; if the labeller is consistent and extends $D$, the theory is consistent and proves $D^\pm$; if it is closed, it decides as the labeller does.
* *Labellers to deciders* (CR without tape): the decider of Craig's set; it halts on every input even when the labeller is partial, since every run is bounded by the exponent of the candidate power.
* *Deciders to enumerators*: enumerate the decided set (same theory).
* *Consistent to closed* (CL).
All maps are injective on programs and add a constant to the length, so summing $2^{-|p|}$ over compatible programs gives (a) and (c), and taking shortest programs gives (b). (c) uses (PS) and (EM) restricted to closed labellers, which preserve the decision of every sentence. Finiteness in (b): if $B\cup D^\pm$ is consistent, the lookup table of $D$ is a consistent labeller and the decider of the finite set $D^\pm$ is compatible; if not, no consistent theory proves $D^\pm$ and no consistent labeller extends $D$. Losses: each of the two terms of $\ell(D)=-\log W(D)+\log W(\emptyset)$ changes by at most $c$. $\square$

*What was re-checked in the source* (AI-paper Thm 6.3 and its proof in `app-time.tex`): the decider of $A^C_f$ halts on all inputs (bounded runs); each member is equivalent to its literal and each literal has a member, so $\Cn$ is preserved; both maps are a fixed wrapper followed by the program, hence injective with constant overhead; $W(D)$ depends on $D$ only as a set. All correct. The AI-paper states the theorem for *deciders* (its AI is $W_A^{\rm dec}$ in U-program format) and FIcons ($=W^{\rm cons}$); the change of program format (U-programs reading their input against $V$-programs printing an index) costs a constant.

**Remarks 2.1′.**
(i) *Enumerators need no Craig.* $W_A\asymp W^{\rm cons}$ uses only (PS) and (EM). Craig's trick is needed only when hypotheses must be deciders.
(ii) *Steeper priors (P2).* With weights $2^{-\lambda|p|}$, $\lambda\ge1$, the same maps give the equivalence within $2^{\pm\lambda c}$; for every $\lambda>0$ the two-part scores $\lambda|p|$ of the best compatible theory and of the best compatible consistent labeller differ by at most $\lambda c$. [proved]
(iii) *The constant* depends on $V$, the syntax coding and the decider of $B$ (and on the decidability of $B$, which (PS) uses).

**Proposition 2.2 (Hänni's schema; status restated, proofs re-checked).** Let $\mathrm{Acc}_f,\mathrm{Rej}_f$ be $\Sigma_1$ formulas for "$f$ accepts / rejects", written without $<$, and $A_f:=\{\mathrm{Acc}_f(\gn\varphi)\to\varphi\}\cup\{\mathrm{Rej}_f(\gn\varphi)\to\neg\varphi\}$.
(a) *Two sorts* (AI-paper Prop 6.4; TF Prop 2.4(b1)): with $B=B_A\cup B_L$, $\Q\subseteq B_A\subseteq\Th(\mathbb N)$ on the arithmetic sort, no mixed axioms: if $B_L\cup\Gamma_f$ is consistent, so is $B\cup A_f$, and $\Cn(B\cup A_f)\cap\Sent_{\mathcal L}=\Cn(B_L\cup\Gamma_f)\cap\Sent_{\mathcal L}$. [proved; $\Sigma_1$-completeness of $\Q$ known]
(b) *One sort over $\PA$* (AI-paper Prop 6.5): assuming $\Con(\PA)$, the $f$ that accepts $\neg\Con(\PA)$ and, on $\Con(\PA)$, searches for a $\PA$-proof of $\bot$ has $\Gamma_f=\{\neg\Con(\PA)\}$ consistent with $\PA$ while $\PA\cup A_f$ is inconsistent. [proved; the argument via the schema is refuted in this reading, the conclusion of Thm 2.1 is not]
(c) *Bounded witnesses* (AI-paper Prop E.17; TF Prop 2.5): one sort, $B\supseteq\Q$ decidable, true or not: with $\mathrm{Acc}^{\le k}_f$ the binary-numeral-bounded form, $\Cn(B\cup A^{\rm bd}_f)=\Cn(B\cup\Gamma_f)$ for every assigner, and membership is polynomial-time without running $f$. [proved, given MRDP (known)] Each axiom is $\Q$-equivalent to a member of $\Gamma_f$ or is a $\Q$-theorem (re-checked: the bounded lemma TF Lemma 1.4(d) places each witness among $0,\dots,S^k0$, and each case is a closed equation that $\Q$ decides). In substance this is Craig's idea, the bound $k$ playing the padding.
(d) *Templates* (AI-paper Props 6.6, 6.7): no non-ground DT° template (the AI-paper's template class) has all its instances in the acceptance part of $A_f$; but one ground reflection sentence $\rho_{f,n}$ of length $\le a|f|+b_n$ reproduces every $\Sigma_n$-sound assigner on $\Sigma_n$ sentences over $\PA$. [proved, given partial truth predicates (known)]
*How the one-tape version avoids the schema.* A theory machine is an enumerator reading a tape, so it may emit $\Gamma_{f_\omega}$ itself (map (EM)); neither decidability, nor arithmetic, nor a schema is needed (scout F, remark after F8). The schema, and Craig's trick, matter only for the decider format.

---

## 3. The one-tape equivalence (T3)

**Theorem 3.1 (one-tape equivalence; scout S Thm 2.5, scout F's F8) [proved; computed: `checks/c1_onetape_finite.out`, items (1)–(3)].** There is $c$, depending only on $V$, the coding and $B$, such that for every finite $D$, the empty one included:
(a) $2^{-c}M_A(D)\le M_F^{\rm cons}(D)\le2^cM_A(D)$;
(b) $2^{-c}M_A(D)\le M_A^{\rm dec}(D)\le2^cM_A(D)$;
(c) tape by tape: $\{\omega:G\text{ compatible with }D\}\subseteq\{\omega:f^{F_G}_\omega\supseteq D,\ f^{F_G}_\omega\text{ consistent}\}$ for every theory machine $G$; $\{\omega:f^F_\omega\supseteq D,\text{ consistent}\}\subseteq\{\omega:G_F\text{ compatible with }D\}$ and $\subseteq\{\omega:C_F\text{ compatible with }D\}$ for every function machine $F$.

*Proof.* (c) is Lemma 1.3 (PS), (EM), (CR). (a) for $D\neq\emptyset$: by (1.2), (c) and (1.1), with the maps $p\mapsto r_{\rm ps}p$ (an index of $F_{G_{V(p)}}$) and $p\mapsto r_{\rm em}p$ (an index of $G_{F_{V(p)}}$),
$$\sum_p2^{-|p|}\nu_{G_{V(p)}}(D)\le\sum_p2^{-|p|}\nu^{\rm cons}_{F_{V(r_{\rm ps}p)}}(D)\le2^{|r_{\rm ps}|}M_F^{\rm cons}(D),\qquad M_F^{\rm cons}(D)\le2^{|r_{\rm em}|}\sum_p2^{-|p|}\nu_{G_{V(p)}}(D)\le2^{|r_{\rm em}|}M_A(D).$$
The remaining term $(1-\Omega_V)[B\vdash\psi_D]$ of (1.2) is at most $[B\vdash\psi_D]$; if $B\vdash\psi_D$, the deterministic proof-search labeller of $B$ is closed and consistent and extends $D$ on every tape, so $M_F^{\rm cons}(D)\ge2^{-c_B}$. Hence $M_A\le(2^{|r_{\rm ps}|}+2^{c_B})M_F^{\rm cons}$. For $D=\emptyset$ both $M_A(\emptyset)$ and $M_F^{\rm cons}(\emptyset)$ lie in $[1-\Omega_V,1]$ (tapes without a program give the consistent theory $B$ and the empty labeller), so their ratio is at most $1/(1-\Omega_V)$.
(b) A random decider is a theory machine (emit $\chi$ under the prefix that certifies the answer $1$), so $M_A^{\rm dec}\le2^cM_A$; and $C_{F_{V(p)}}$ with (CR) gives $M_A^{\rm dec}\ge2^{-c}M_F^{\rm cons}\ge2^{-2c}M_A$ on $D\neq\emptyset$; for $D=\emptyset$ the decider of $\emptyset$ gives $M_A^{\rm dec}(\emptyset)\ge2^{-c}$. $\square$

*Overhead.* Three wrappers (proof search over emitted axioms; emission; Craig) and the proof search of $B$. Nothing uses lower semicomputability. *Re-check of scout S's proof:* its $T_G$ tests "derivations of size $\le s$ from $B$ together with the sentences emitted so far", which needs $B$ decidable (assumed); its argument for (a) handles the $(1-\Omega_V)$ term exactly as above. Correct. The extension to $D=\emptyset$ is new and trivial.

*Finite analogue.* `c1_onetape_finite.py` (written independently of scout S's `s1`): 4 atoms, 24 sentences (12 formulas and their syntactic negations), 64 tapes, 25 random theory machines and 25 random function machines, all 1153 data sets with $|\dom D|\le2$, two backgrounds. Items (1), (2): 0 violations of the tape-wise inclusions in $2\times1{,}844{,}800$ machine–data–tape triples each. Items (3a), (3b): the two mixture inequalities of the proof (against the image families) hold on all data sets. Scout S's toy (`s1`, 3 atoms, 16 tapes) also reported 0 violations; the ratios differ because the families differ.

**Corollary 3.2 (closed one-tape labellers and the trichotomy) [proved; computed: c1 items (5a), (5b)].** For every finite $D$, $\varphi\notin\dom D$ and $o\in\{1,0,\bot\}$, let $M_A(D;\varphi\mapsto o)$ be the measure of the tapes on which the theory is consistent, proves $\psi_D$, and proves $\varphi$ ($o=1$), proves $\neg\varphi$ ($o=0$) or decides neither ($o=\bot$), and $M_F^{\rm cl}(D;\varphi\mapsto o)$ the measure of the tapes on which $f_\omega$ is closed, consistent, extends $D$ and has $f_\omega(\varphi)=o$. Then $2^{-c}M_A(D;\varphi\mapsto o)\le M_F^{\rm cl}(D;\varphi\mapsto o)\le2^cM_A(D;\varphi\mapsto o)$, and $2^{-c}M_A\le M_F^{\rm cl}\le M_F^{\rm cons}$.

*Proof.* (PS) maps tapes with a consistent theory to tapes on which $F_G$ is closed and decides as the theory; (EM) maps tapes with a closed consistent labeller to tapes on which the theory decides as the labeller. The program-less tapes (theory $B$) are covered by the closed deterministic labeller "proof search from $B$", of weight $2^{-c_B}$, which decides as $B$ does. Sum as in Thm 3.1. $\square$
So the trichotomy of SAI (true / false / independent of the sampled theory) is the three-way split of SOI over *closed* labellers; over all consistent labellers it is not (Prop 6.1).

### 3.3 Penalised one-tape versions

The AI-paper's axiom-side penalties (TF Def 1.1) bound the time to check or to generate axioms. For the one-tape version the natural objects are random deciders and random enumerators that meet the bound on every tape. We use U-program format, as TF does: programs of the universal prefix machine $U$, read to their end before the input, now with access to a one-way read-only random tape.

**Assumption (S$_{\rm tape}$).** There are constants $\alpha,a\ge1$ with the properties of TF's (S) (`app-time.tex`, paragraph "Machines"), where the dovetailing schedule is run on a tape-reading program $q$: at stage $s$ it starts $q$ on the $s$-th sentence and advances every unfinished run by one simulated step, all runs reading the same tape $\omega$ one-way from its start; the work counter $T$ counts the simulated steps (tape reads included), the lengths of the sentences started, and $|q|$; up to work $T$ the schedule costs at most $\alpha(T+1)^a$ steps and reads at most $T$ tape bits. [assumed, like (S); *justification sketch:* keep the bits read so far on a work tape and one pointer per run; a simulated read copies a stored bit or reads the next tape bit, at cost $O(T)$; so the exponent of (S) grows by at most $1$. Not written out for a concrete $U$.] Put $a':=\max(a,2)$, $a^*:=\max(a,3)$.

**Definition 3.3 (penalised one-tape SAI).** A *random decider program* $q$ halts on every $(\chi,\omega)$ with yes or no; $A^q_\omega$ is its yes-set on $\omega$. A *random enumerator program* $e$ (no input) writes $a_1(\omega),a_2(\omega),\dots$, completing $a_i$ at step $e_i(\omega)$. For time-constructible $t$:
* $M_A^{{\rm chk},t}(D):=\sum_q2^{-|q|}\mu^{\rm dec}_q(D)$ over random decider programs with $\sup_{\chi,\omega}{\rm time}_q(\chi,\omega)/t(|\chi|)<\infty$;
* $M_A^{{\rm gen},t}(D):=\sum_e2^{-|e|}\mathsf U\{\omega:B\cup\{a_i(\omega)\}_i\text{ consistent},\vdash\psi_D\}$ over random enumerator programs meeting the delay form $\sup_{\omega,i}(e_i-e_{i-1})/t(|a_i|)<\infty$ (strict form: $e_i/t(|a_i|)$; cumulative form: $e_i/t(|a_1|+\dots+|a_i|)$).

In U-program format, the unpenalised one-tape laws $M_A^U:=\sum_q2^{-|q|}\nu_{G_q}$ (all tape-reading programs read as theory machines) and $M_F^{{\rm cons},U}$ agree with $M_A$ and $M_F^{\rm cons}$ within constant factors (each universal mixture contains the other's universal machine with a constant prefix; F5, P1 "The choice of universal machine"). [proved]

**Theorem 3.4 (axiom-side penalties are vacuous for the one-tape version) [proved, under (S$_{\rm tape}$)].** Let $t(m)\ge m^{a^*}$ be time-constructible. There is $c$ such that for every finite $D\neq\emptyset$
$$2^{-c}M_F^{\rm cons}(D)\le M_A^{{\rm chk},t}(D)\le2^cM_A(D),\qquad2^{-c}M_F^{\rm cons}(D)\le M_A^{{\rm gen},t}(D)\le2^cM_A(D)$$
(strict, delay and cumulative forms). With Thm 3.1, all of $M_A^{{\rm chk},t}$, $M_A^{{\rm gen},t}$, $M_A$, $M_F^{\rm cons}$ agree within constant factors on nonempty data sets, and their semimeasure losses within a constant.

*Proof.* *Lower bounds.* Let $p$ be a tape-reading program for a function machine $F$. Let $q_F$ say yes on $\chi$ if $F$ labels $\chi$ with $1$, or if $\chi=\neg\varphi$ and $F$ labels $\varphi$ with $0$ (dovetailing the two runs, on the same tape). On every tape its yes-set is $\Gamma_{f^F_\omega}$, and $|q_F|\le|p|+c$. The padded random decider $d:=W_{\rm dec}{}^\frown q_F$ answers $\chi$ as TF Lemma 2.1(b) prescribes: at most two candidates $\chi=\psi^{\wedge m}$; reject if $m-1<|q_F|$; otherwise run the schedule of $q_F$ on the tape, without writing, until the counter exceeds $m-1$, and accept iff $q_F$ is first detected saying yes on $\psi$ exactly at counter $m-1$. Under (S$_{\rm tape}$) this takes at most $\alpha(|q_F|+1)+3\alpha(|\chi|+1)^{a'}$ steps on *every* tape (TF Lemma 2.1(b), verbatim with the tape), and the bound is uniform in $\omega$. The answer depends only on the tape bits read by the schedule, so $d$ is a random decider. On each tape its yes-set is $\mathrm{Pad}_\omega:=\{\psi^{\wedge(T+1)}:q_F\text{ first detected saying yes on }\psi\text{ at counter }T\text{ on }\omega\}$; distinct detections have distinct counters, so each $\psi\in\Gamma_{f^F_\omega}$ has exactly one padded copy and $\Cn(B\cup\mathrm{Pad}_\omega)=\Cn(B\cup\Gamma_{f^F_\omega})$ (TF Lemma 2.1(a) per tape). So on every tape where $f^F_\omega$ is consistent and extends $D$, $d$ is compatible with $D$. The padded enumerator $e:=W_{\rm enum}{}^\frown q_F$ writes $\psi^{\wedge(T+1)}$ at each detection; TF Lemma 2.1(c) gives, per tape, delay $\le2\alpha|a_i|^a$, strict completion $\le5\alpha|a_i|^{a^*}$ and cumulative completion $\le2\alpha(|a_1|+\dots+|a_i|)^a$, uniformly in $\omega$. Both maps are injective and add a constant to the length. Summing over $p$ (with $M_F^{{\rm cons},U}\asymp M_F^{\rm cons}$) gives the lower bounds.
*Upper bounds.* A random decider or enumerator program is a theory machine with the same theory on every tape, so $M_A^{{\rm chk},t},M_A^{{\rm gen},t}\le M_A^U\le2^cM_A$. $\square$

**Proposition 3.5 (class posteriors, one tape; the one-tape form of TF Prop 5.1) [proved, under (S$_{\rm tape}$)].** Let $X$ be $M_A^{{\rm chk},t}$ or $M_A^{{\rm gen},t}$ (any form), $t\ge m^{a^*}$. For a class $\mathcal C$ of deductively closed theories let $X(\mathcal C,D)$ be the measure, under $X$'s mixture, of the tapes on which the hypothesis is compatible with $D$ and $\Cn(B\cup\text{its axioms})\in\mathcal C$. Then $2^{-c}M_A(\mathcal C,D)\le X(\mathcal C,D)\le2^cM_A(\mathcal C,D)$ for all $\mathcal C$ and $D$. So posterior odds between any two classes of theories ("genuine" axiom systems and "disguised" assigners alike) differ between $X$ and $M_A$ by a factor at most $2^{2c}$.

*Proof.* Lower bound: for a theory machine $G$ (program $p$), let $q_G$ say yes on $\chi$ iff $G$ emits $\chi$ on the tape; pad as in Thm 3.4. The padded hypothesis has, on every tape, the same $\Cn$ as $B\cup A^G_\omega$, so it lies in $\mathcal C$ and is compatible with $D$ exactly when $G$'s theory is. The program-less tapes of $M_A$ (theory $B$) are matched by the decider of $\emptyset$. Upper bound: a penalised hypothesis is its own theory machine, with the same theory. Divide by $X(\text{all},D)$ and $M_A(\text{all},D)$. $\square$

**Remark 3.6 (what remains).** (S$_{\rm tape}$) for a concrete $U$ (as (S) in TF, it is assumed). A one-tape form of TF Prop 2.3 (Kt penalties) was not attempted: TF's normalisation uses ${\rm time}_p\ge|p|$ for U-programs, which needs restating for tape-reading programs. Content-relative penalties (TF's P3) on one tape were not attempted.

---

## 4. The chain and the random tape (T4)

**Proposition 4.1 (chain for the consistent versions; scout S Prop 2.6) [proved, given P1 Thm 3.21(a) and the construction of P1 Prop 4.6(a)].** For every $D\neq\emptyset$ with $B\cup D^\pm$ consistent,
$$2^{-K_F^{\rm cons}(D)}\le W^{\rm cons}(D)\le2^cM_F^{\rm cons}(D)\le2^{K(\dom D)+c}\,2^{-K_F^{\rm cons}(D)},$$
and $\log(M_F^{\rm cons}(D)/W^{\rm cons}(D))\le K^{\rm pad}(L^{\rm cons}_{1/2}(D))+c$, where $L^{\rm cons}_{1/2}(D)$ is the least $L$ with $\mathsf U\{\omega:D\text{ is certified within }\omega_{1:L}\text{ and }f_\omega\text{ is consistent}\}\ge M_F^{\rm cons}(D)/2$. By Thms 2.1 and 3.1 the same holds for $K_A$, $W_A$, $M_A$ with a larger $c$.

*Proof.* (i) A shortest consistent program is a term of $W^{\rm cons}$. (ii) A consistent deterministic labeller, read as a function machine that ignores the tape, is consistent on every tape; with (1.1) and the wrapper "treat $\{V(p)\}$ as a machine", $W^{\rm cons}\le2^cM_F^{\rm cons}$. (iii) $M_F^{\rm cons}\le M_F\le2^{-K(D\mid\dom D)+c}$ (P1 Thm 3.21(a), which holds for $X=\Sent_{\mathcal L}$, an infinite decidable set of strings); the lookup table of $D$ is consistent, so $K_F^{\rm cons}(D)\le K(D)+c\le K(\dom D)+K(D\mid\dom D)+c$. (iv) The $K^{\rm pad}$ bound: for $L'\ge L$ with $K(L')=K^{\rm pad}(L)$ and $w\in\{0,1\}^{L'}$, the stored-prefix labeller $\varphi_{F,w}(x):=y$ iff some $(x,w',y)\in F$ has $w'\sqsubseteq w$ is a sub-function of $f^F_\omega$ for every $\omega\sqsupseteq w$; so it is consistent whenever some extension of $w$ is a consistent tape. P1's count (proof of Prop 4.6(a), re-read in `app-versions.tex`) restricted to such $w$ gives $W^{\rm cons}(D)\ge2^{-|r|-K(F)-K^{\rm pad}(L)}\mathsf U\{\omega:D\text{ certified within }\omega_{1:L},\ f^F_\omega\text{ consistent}\}$; take $F=F_U$ and $L=L^{\rm cons}_{1/2}(D)$. $\square$

*Remark.* On the axiom side the slack $K(\dom D)$ can be replaced by $K(S)$ for any set $S$ of pairwise $B$-incompatible sentences containing $\psi_D$ (scout F's F10(c), `fundamentals` T6); by Thm 3.1 this transfers to $M_F^{\rm cons}$: $M_F^{\rm cons}(D)\le2^{-K(\psi_D\mid S)+c}$. [proved, given F10(a)]

**Corollary 4.2 (the lottery separates the versions of consistent SOI; plain SOI is not separated) [proved, given N1 Thm E1 and Prop E2(b) (re-read; under re-verification in `logic` T1)].** On N1's lottery stream $D_\infty$:
(a) $M_F^{\rm cons}(D_n)$ is bounded below, so one-tape consistent SOI has bounded loss (Thm 3.1 with E1(a));
(b) $W^{\rm cons}(D_n)\to0$, so coin-free consistent SOI has unbounded loss (Thm 2.1 with E1(c)), consistently with Prop 4.1, since $K(\dom D_n)\to\infty$ and $L^{\rm cons}_{1/2}(D_n)\to\infty$;
(c) plain coin-free SOI on sentences has bounded loss: $M_F(D_n)\ge M_F^{\rm cons}(D_n)$ is bounded below, so by N1 Prop E2(b) some partial computable $f$ extends $D_\infty$, and $W(D_n)\ge\mm(f)>0$. Such an $f$ (N1's majority vote at a density point) is necessarily inconsistent: a consistent one would give $W^{\rm cons}(D_n)\ge\mm(f)>0$, against (b).
So "bounded one-tape loss, unbounded coin-free loss on one stream" is a phenomenon of the consistency constraint, which plain SOI cannot exhibit (N1 E2(b)) and consistent SOI shares with SAI. The lottery machine is consistent on every tape, so this separation holds already for machine-wise consistent random labellers (§6.5, Prop 6.8).

---

## 5. SAI is SOI on positive literals (T5)

**Theorem 5.1 (transfer principle; scout S Thm 2.7, scout F's F9) [proved].** Let $X\subseteq\{0,1\}^*$ be P1's (infinite, decidable) input set and $x\mapsto t_x$ a computable injective map from $X$ to closed $\mathcal L$-terms with decidable range and computable inverse. Let $R$ be a unary relation symbol not occurring in $B$, and suppose some model of $B$ interprets the terms $t_x$ as pairwise distinct elements (e.g. $B=\emptyset$ with the word terms $t_w$ of NOTATION §3.4, or $B=\Q$ with binary numerals of $1w$). For a data set $D$ with $\dom D\subseteq\{R(t_x):x\in X\}$ put $D^{\rm str}:=\{(x,b):(R(t_x),b)\in D\}$. Then there is $c$ with
$$|K_A(D)-K_F(D^{\rm str})|\le c,\qquad W_A(D)\asymp W(D^{\rm str}),\qquad M_A(D)\asymp M_F(D^{\rm str})\ (D\neq\emptyset),$$
where $K_F,W,M_F$ are P1's objects over $X$ with labels $\{0,1\}$; the same for $K_A^{\rm dec}$, $W_A^{\rm dec}$, $M_A^{\rm dec}$, and for the three-way weights on a literal query $R(t_y)$ (prove / refute / neither on the SAI side, $1$ / $0$ / undefined at $y$ on P1's side).

*Proof.* By Thms 2.1 and 3.1 it suffices to compare consistent SOI on sentences with plain SOI on $X$. *Strings to sentences:* for a partial computable $g$ on $X$ let $g^P(R(t_x)):=g(x)$, undefined off the literals; for a function machine on $X$ likewise (decode $x$ from $t_x$). $\Gamma_{g^P}$ is a set of literals $\pm R(t_x)$, at most one per $x$; it is consistent with $B$, because in a model of $B$ with distinct $t_x$ the symbol $R$, which $B$ does not mention, can be interpreted as $\{t_x:g(x)=1\}$. So $g^P$ (and the machine version, on every tape) is consistent, extends $D$ iff $g$ extends $D^{\rm str}$, and costs a constant. *Sentences to strings:* $f^{\rm str}(x):=f(R(t_x))$, at a constant cost; $f\supseteq D$ implies $f^{\rm str}\supseteq D^{\rm str}$; consistency is not needed. Sum over the injective maps and take shortest programs. For the three-way weights on $R(t_y)$: by (Lit) below, the theory $\Cn(B\cup\Gamma_{g^P})$ decides $R(t_y)$ iff $g(y)$ is defined, with the same value; and the proof-search labeller of a theory, restricted to literals, labels $y$ exactly as the theory decides $R(t_y)$. $\square$

The hypothesis implies scout F's condition (Lit) (a consistent set of such literals proves exactly its members): for $R(t_y)^b$ not in the set, reinterpret $R$ at $t_y$. Without distinct terms the transfer can fail: if $B\vdash t_x=t_y$, the data $(R(t_x),1),(R(t_y),0)$ are inconsistent for SAI while $D^{\rm str}$ is fine for SOI (scout S self-check 6).

**Corollary 5.2 (what transfers) [proved, by Thm 5.1 and the cited P1 results].** On positive literal data:
(a) *No coding theorem for axiom systems* (P1 Thm 4.9): for every $d\ge2$ there are distinct $x_1,x_2\in\{0,1\}^d$ with $D=\{(R(t_{x_1}),0),(R(t_{x_2}),1)\}$, $K_A(D)\ge\log d-2-c$, $-\log W_A(D)\le2+K(\lceil\log(d+1)\rceil)+c$, $-\log M_A(D)\le2+c$. (`fundamentals` T6 proves (i)–(iii) directly with theory machines.)
(b) *Random theories beat deterministic ones* (P1 Props 4.5(a), 4.6): $\sup_DM_A(D)/W_A(D)=\infty$ on two-point literal data; $W_A(D)\ge2^{-|D|-K^{\rm pad}(2^{d+1})-c}$ for every literal data set over words of length $\le d$.
(c) *The chain and the covering bound* (P1 Thm 4.4, Prop 4.11) for $K_A$, $W_A$, $M_A$; the two-point rate (P1 Cor 4.10): $\log d-c\le\max_D(K_A(D)-L_A(D))\le\log d+O(\log\log d)$ over two-point literal data; large gaps have no computable witnesses (P1 Rem B.4).
(d) *Solomonoff induction* (P1 Prop 3.24): with unary numerals $t_i:=S^i0$ and $B\in\{\emptyset,\Q\}$, $M_A(\{(R(S^i0),x_{i+1}):i<n\})\asymp M(x)$ for $x\in\{0,1\}^n$. So SI $\subset$ binary SOI $\subset$ SAI on atomic data $\subset$ consistent SOI on sentences, each up to constant factors.

**Proposition 5.3 (the price of the coin on literal data) [proved, by Thm 5.1, P1 Prop 4.6(b) and Thm 3.21(a)].** For every literal data set $D$ over words of length $\le d$,
$$\log\frac{M_A(D)}{W_A(D)}\le\delta_D+K^{\rm pad}(2^{d+1})+c\le\delta_D+K(\lceil\log(d+1)\rceil)+c',\qquad\delta_D:=|D|-K(D^{\rm str}\mid\dom D^{\rm str}).$$
*Proof.* $W_A(D)\ge2^{-c}W(D^{\rm str})\ge2^{-|D|-K^{\rm pad}(2^{d+1})-c'}$ and $M_A(D)\le2^cM_F(D^{\rm str})\le2^{-K(D^{\rm str}\mid\dom D^{\rm str})+c''}$. $\square$
On two points $\delta_D\le2+O(1)$, which is scout S's corrected Cor 2.8(b). Scout S's correction (second run, self-check 8) was right that P1 Prop 4.6(b) alone does not bound the ratio for all $D$; but the general bound holds with the randomness deficiency $\delta_D$ added, and it is P1's own Rem 4.12(2), transferred. In words: on literal data whose labels are algorithmically random given the inputs, the coin-free version loses at most $K^{\rm pad}(2^{d+1})+O(1)$ bits against the one-tape version, however many labels are predicted.

**Remark 5.4 (AI-paper Prop E.1 is an encoding effect) [proved].** Prop E.1: literals $R(w_i)$ or $\neg R(w_i)$ by independent fair coins, all labelled true; FIall ($=W$ on sentences) has bounded loss, SAI and consistent SOI lose $\ge n$ bits in expectation. The re-encoding $(\neg R(w),1)\mapsto(R(w),0)$ maps these data sets bijectively to fair-coin labels on positive literals and leaves $M_A$, $W_A$ unchanged ($M_A(D)$ depends on $D$ only through $\Cn(\psi_D)$, F1(c)). On positive literals SAI is SOI on strings (Thm 5.1), which loses $\ge n-c$ bits in expectation on fair coins (P1 Thm 3.21(a) and Gibbs). FIall's constant loss comes from treating $\neg R(w)$ as an input unrelated to $R(w)$ ("always accept" is inconsistent); consistency is what ties them. The proof of Prop E.1 (re-read in `app-time.tex`: $a+a'\le1$ for the two predictive probabilities, then convexity) is correct and applies tape by tape to $M_A$ and $M_F^{\rm cons}$.

### 5.5 The transfer table

"Transfers" means: the statement holds for SAI on positive literal data of a fresh predicate (inputs encoded by distinct terms), with the same quantities up to additive constants in $K$, $-\log W$, $-\log M$. Reasons a statement does not transfer: **(Y)** labels from a set larger than $\{0,1\}$ (a fresh unary predicate carries one bit; multi-valued labels would need questions with several answers and a functionality background, not treated); **(n)** a *cumulative* normalised-convention statement (each normalised conditional transfers only within $2^{\pm2c}$, so $n$ steps cost $2cn$); single-step normalised quantities do transfer up to a constant factor; **(p)** private randomness per input or per query, or repeated inputs with fresh noise (on literals, private coins give theory machines with a coin per atom, so statements about $M_{\rm prod}$ transfer to that class; $M_{\rm pq}$ has no SAI analogue, since conflicting labels on one sentence are inconsistent data); **(h)** history-aware SOI$^{\rm hist}$ (no SAI analogue is defined); **(w)** the weak semimeasure $M_w$ (no SAI analogue); **(c)** computability statements (not "up to constants"; $M_A$ is not lsc, Prop 6.7); **(o)** other objects (time-bounded mixtures, circuits, networks).

| P1 item | transfers? | note |
|---|---|---|
| Thm 3.8 universal mixture, dominance $M_F\ge2^{-K(\nu)}\nu$ | yes | also direct: F4 (`fundamentals` T4) |
| Ex 3.5, Thm 3.11, Thm 3.12 (weak semimeasures; $M_w$ vs $M_F$) | no (w) | |
| Prop 3.16 order independence | yes | direct: F1(d) |
| Prop 3.17 normalisation; (b) order dependence normalised | no (n) | |
| Thm 3.20 invariance | yes | direct: F5, F7 |
| Thm 3.21 coding-theorem bounds (a), (b) | yes (binary labels) | (c) is trivial for one bit |
| Ex 3.22 swap data | no (Y) | labels are strings |
| Prop 3.24 SI is SOI on initial segments | yes | Cor 5.2(d) |
| Prop A.10 computability of $M_F$ | no (c) | $M_A$ not lsc (Prop 6.7); on literal data $M_A\asymp M_F$, an lsc function, but $M_A$ itself is not lsc |
| Thm 4.4 chain | yes | the $M_{\rm prod}$ link: (p) |
| Prop 4.5 $W$-gap: (a) two points | yes | (b) long labels: no (Y) |
| Prop 4.6 tape-length bound (a), (b), (c) | yes | (a) holds for all $D$ (Prop 4.1); Prop 5.3 |
| Prop 4.7 shared vs private randomness | yes, to coin-per-atom theory machines (p) | |
| Thm 4.9 no coding theorem; Cor 4.10; Prop 4.11 covering | yes | Cor 5.2(a), (c) |
| Rem B.4 non-computable witnesses; Q B.5 | yes | |
| Prop B.6 structured outputs | no (Y) | |
| Rem 4.2, Prop 5.7 per-query $M_{\rm pq}$ | no (p) | |
| Thm 5.1 dominance (a) samplers, (b) deterministic | yes ((a) via coin-per-atom theory machines) | (c) weak comparators: no (w) |
| Thm 5.3 merging; Cor 5.4 mistakes; Thm 5.5 online-to-batch (a)–(c) | yes | (b): stamps are part of the encoding $x\mapsto t_x$; mistake counts via the telescoping identity |
| Prop 5.6 fresh label noise fails | yes | in SAI conflicting labels on one sentence are inconsistent data |
| Props 5.8, 5.9, Cor 5.10, Prop 5.11 (splits, typical errors, per-step error, Occam) | yes | single-step errors transfer within $2^{\pm2c}$ |
| §6 (SOI$^{\rm hist}$, all items) | no (h) | |
| §7 cyclic permutation (Def 7.2–Prop 7.10) | no (Y) | labels are strings |
| §7 Eisenstat's example (Def 7.11–Prop 7.22), semimeasure-convention items | yes | inputs $\mathbb N$ as numerals; normalised parts: (n) |
| Prop 7.24, Exs 7.25 (parity), 7.26 (thresholds) | yes | Exs 7.27 (sorting), 7.28 (polynomials): no (Y) |
| Prop 7.29 frozen noise | yes | |
| §8 OOD: Props 8.1, 8.2, Thms 8.3, 8.4, Props 8.5, 8.7, 8.8, 8.11 | yes for binary labels | single-step quantities within a constant factor |
| §9 time-bounded mixtures $M_{\rm len}$, $M_{\rm rd}$; circuits $\Wcirc$; Occam ladder | no (o) | compared directly: Thm 7.8 (time), §10 (circuits) |
| §10 networks | no (o) | |

So **the content of SAI beyond SOI lies entirely in logically structured data.** Every result of P1 that concerns binary labels and holds up to additive constants is a result about SAI on the simplest such data; what SAI adds appears only when sentences entail, exclude or leave open one another (§6, `logic`).

---

## 6. What breaks (T6)

### 6.1 Logical closure and the trichotomy

**Proposition 6.1 (logical closure; scout S Prop 2.11, extended by (c)) [proved; computed: c1 item (4)].** Let $B\cup D^\pm$ be consistent and $\chi\notin\dom D$.
(a) If $B\cup D^\pm\vdash\chi$, every SAI hypothesis compatible with $D$ proves $\chi$: $M_A(1\mid D,\chi)=1$, $M_A(0\mid D,\chi)=0$, $\Indep_D(\chi)=0$; the same for $W_A$.
(b) If $B\cup D^\pm\vdash\chi$, no consistent labeller extending $D$ labels $\chi$ false, so $W^{\rm cons}(0\mid D,\chi)=0$; and $W^{\rm cons}(1\mid D,\chi)\ge2^{-2c}$. The same for $M_F^{\rm cons}$.
(c) *(new)* For **every** $\chi\notin\dom D$ (entailed or not), the posterior probability that the sampled labeller is undefined at $\chi$ is at least $2^{-K(\chi)-c}$: $W^{\rm cons}(D;\chi\mapsto\bot)\ge2^{-K(\chi)-c}W^{\rm cons}(D)$ and $M_F^{\rm cons}(D;\chi\mapsto\bot)\ge2^{-K(\chi)-c}M_F^{\rm cons}(D)$, uniformly in $D$.
(d) Over closed labellers all three predictive probabilities agree with SAI's within $2^{\pm2c}$ (Thm 2.1(c), Cor 3.2).

*Proof.* (a) A consistent theory proving $\psi_D$ proves $\chi$; F1(c). (b) $f\supseteq D$ with $f(\chi)=0$ puts $D^\pm\cup\{\neg\chi\}\subseteq\Gamma_f$, inconsistent with $B$. By Thm 2.1, $W^{\rm cons}(D+(\chi,1))\ge2^{-c}W_A(D+(\chi,1))=2^{-c}W_A(D)\ge2^{-2c}W^{\rm cons}(D)$; for one tape use Thm 3.1. (c) Let $q_\chi$ be a shortest $V$-program for $\chi$. The prefix machine that reads $q_\chi$, then $s\in\dom V$, and outputs an index of "$\{V(s)\}$, made undefined at $V(q_\chi)$" is simulated by $V$ with a prefix $r$. The map $s\mapsto rq_\chi s$ is injective; removing one label preserves consistency, and the restricted labeller still extends $D$ because $\chi\notin\dom D$. So the consistent labellers extending $D$ and undefined at $\chi$ have weight at least $2^{-|r|-K(\chi)}W^{\rm cons}(D)$. For one tape, apply the same map to function machines and use (1.1); on the program-less tapes the empty labeller is undefined at $\chi$ already. $\square$
So consistent SOI never becomes certain of a logical consequence in the semimeasure convention: for a fixed simple $\chi$ the undefined mass stays above $2^{-K(\chi)-c}$ whatever the data. In the normalised convention its prediction on an entailed $\chi$ is $1$ (by (b)). The equivalence of Thms 2.1 and 3.1 controls the semimeasure *losses* (each entailed datum costs consistent SOI at most $2c$ bits and SAI nothing), not the size of the $\bot$ mass: SOI's $\bot$ mixes logical independence with laziness. Scout S's version of (b) used the lookup table of $D$ for the $\bot$ mass, $2^{-K(D)-c}$, which degrades with the data; (c) does not.
*Computed* (c1 item (4)): on 412 and 476 (data set, entailed sentence) cases, SAI gives $(1,0,0)$ every time; consistent SOI gives $P(0)=0$, $P(1)>0$, and $\bot$-mass at least $2^{-k}$ times the weight of the base machines in every case (with abstention variants of weight $2^{-k}$, $k=6$); the smallest $P(\bot)$ is $0.0115$.

**Remark 6.2 (the three outcomes are a measure for SAI) [proved; computed: c1 item (6)].** $M_A(D+(\varphi,1))+M_A(D+(\varphi,0))+M_A^3(D+(\varphi,\iota))=M_A(D)$ for $\varphi\notin\dom D$ (F1(b), (f)); likewise for $W_A$. Each consistent theory proving $\psi_D$ falls in exactly one class. For SOI the corresponding third mass is the defect (abstention or divergence).

### 6.2 An observed "independent" label

Three-valued data map sentences to $\{1,0,\iota\}$. A partial three-valued labeller $f$ is *consistent* if $B\cup\Gamma_f$ is consistent ($\Gamma_f$ from the $1/0$ labels) and $B\cup\Gamma_f$ decides none of the sentences $f$ labels $\iota$. $W_A^3$: enumerators whose theory is consistent, proves the $1/0$ data and decides no $\iota$-labelled sentence; $W^{3,\rm cons}$: consistent three-valued labellers extending $D$; one-tape: $M_A^3=\nu^3_{G_U}$ (NOTATION §4.1) and $M_F^{3,\rm cons}(D):=\mathsf U\{\omega:f_\omega\supseteq D,\ f_\omega\text{ consistent}\}$ for P1's universal function machine with $Y=\{1,0,\iota\}$. $\mathrm{Ind}_B$ is the set of sentences that $B$ decides neither way. $B$ is *$\Sigma_1$-sound* if it proves no false $\Sigma_1$ sentence (then it is consistent).

**Lemma 6.3′ (productivity) [proved, given MRDP (known; AI-paper Lemma E.14(a)) and Kleene's recursion theorem (known)].** Let $\mathcal L=\mathcal L_{\rm ar}$ and $B$ decidable, $\Q\subseteq B$ (or $\Q\subseteq\Cn(B)$), $B$ $\Sigma_1$-sound. From an index of an r.e. set $\mathsf W\subseteq\mathrm{Ind}_B$ one computes a sentence $\sigma\in\mathrm{Ind}_B\setminus\mathsf W$.
*Proof* (scout S's construction, re-checked line by line). $\Out(e,x,y)$ is the $\Sigma_1$ formula $\exists\bar c\,(E(e,x,y,\bar c)=E'(e,x,y,\bar c))$ of AI-paper Lemma E.14(a). By the recursion theorem (in the parametrised form, uniformly in the index of $\mathsf W$) take a program $e$ that on input $0$ searches simultaneously for $\sigma_e:=\Out(\num e,\num0,S0)$ in $\mathsf W$ and for a $B$-proof of $\neg\sigma_e$ ($B$ is decidable, so its proofs are r.e.), and halts with output $1$ when either search succeeds; on other inputs it loops. Suppose a search succeeds. Then $e$ outputs $1$ on $0$, so $\sigma_e$ is a true sentence of the form $\exists\bar y(s=s')$ and $\Q\vdash\sigma_e$ (Lemma E.14(c)), hence $B\vdash\sigma_e$. Then $\sigma_e\in\mathsf W\subseteq\mathrm{Ind}_B$ is impossible, and $B\vdash\neg\sigma_e$ would make $B$ inconsistent. So no search succeeds: $e$ does not output $1$ on $0$, $\sigma_e$ is a false $\Sigma_1$ sentence, $B\nvdash\sigma_e$ ($\Sigma_1$-soundness), $B\nvdash\neg\sigma_e$ (search (ii) fails), and $\sigma_e\notin\mathsf W$ (search (i) fails). $\square$

**Proposition 6.3 (coin-free; scout S Prop 2.12, with a weaker hypothesis on $B$) [proved, given Lemma 6.3′].** In the setting of Lemma 6.3′:
(a) $2^{-c}W^{3,\rm cons}(D)\le W_A^3(D)$ for every three-valued $D$;
(b) for every $n$ there is $\sigma_n\in\mathrm{Ind}_B$ with $W^{3,\rm cons}(\{(\sigma_n,\iota)\})\le\Omtail{n+1}\to0$ (P1's tail $\Omtail{\ell}:=\sum\{2^{-|p|}:p\in\dom V,|p|\ge\ell\}$) and $W_A^3(\{(\sigma_n,\iota)\})\ge2^{-c}$;
(c) $W_A^3(\{(\sigma,\iota)\})/W^{3,\rm cons}(\{(\sigma,\iota)\})\le2^{K(\sigma)+c}$ for every $\sigma\in\mathrm{Ind}_B$.
*Proof.* (a) Map $f$ to the enumerator of $\Gamma_f$ (1/0 part): its theory $\Cn(B\cup\Gamma_f)$ proves the $1/0$ data and, by the consistency of $f$, decides none of $f$'s $\iota$-sentences, which include $D$'s. (b) Let $F_n$ be the finite (non-computable) set of $p\in\dom V$, $|p|\le n$, for which $\{V(p)\}$ is a consistent three-valued labeller, and $I_n$ the union of their $\iota$-sets: a finite union of r.e. sets, hence r.e., and $I_n\subseteq\mathrm{Ind}_B$, since $f(\sigma)=\iota$ implies $B\cup\Gamma_f\nvdash\sigma,\neg\sigma$. Let $\sigma_n\in\mathrm{Ind}_B\setminus I_n$ (Lemma 6.3′). Every consistent labeller compatible with $\{(\sigma_n,\iota)\}$ labels $\sigma_n$ with $\iota$, so its program is not in $F_n$ and is longer than $n$. The enumerator of $\emptyset$ (theory $B$) is compatible. (c) The labeller "$\iota$ at $\sigma$, undefined elsewhere" is consistent for $\sigma\in\mathrm{Ind}_B$. $\square$
The mechanism: "the theory decides neither" is a $\Pi_1$ property that a theory has without committing to anything, while a labeller must output $\iota$ after finitely many steps; the sentences it can safely label $\iota$ form an r.e. subset of the productive set $\mathrm{Ind}_B$. Scout S's statement had $B=\Q$; only $\Sigma_1$-soundness of $B$ and $\Q\subseteq\Cn(B)$ are used.

**Proposition 6.4 (large gaps have no r.e. witnesses) [proved].** (a) For every r.e. $S\subseteq\mathrm{Ind}_B$, $W^{3,\rm cons}(\{(\sigma,\iota)\})\ge2^{-K(S)-c}$ for all $\sigma\in S$ ($K(S)$ for an index of $S$), and the same for $M_F^{3,\rm cons}$; so the gap of Prop 6.3(b) is bounded on $S$. In particular no computable sequence of sentences $\sigma_n\in\mathrm{Ind}_B$ has $W^{3,\rm cons}(\{(\sigma_n,\iota)\})\to0$. (b) More precisely, with $n(\sigma)$ the length of a shortest program of a consistent three-valued labeller that labels $\sigma$ with $\iota$, $2^{-n(\sigma)}\le W^{3,\rm cons}(\{(\sigma,\iota)\})\le\Omtail{n(\sigma)}$.
*Proof.* (a) The labeller "$\iota$ on every member of $S$ (enumerate $S$), undefined elsewhere" has $\Gamma=\emptyset$ and labels only $B$-independent sentences, so it is consistent; it has length $K(S)+c$. (b) Every program counted has length $\ge n(\sigma)$, and one has length $n(\sigma)$. $\square$
This answers scout S's "next step" for Prop 2.12: there is no computable family of witnesses, as for P1's gap witnesses (P1 Rem B.4), and for the stronger reason that an r.e. family of independent sentences is labelled $\iota$ by a single consistent labeller.

**Proposition 6.5 (one tape: the observed independent label still breaks the equivalence) [proved, given Lemma 6.3′ and the Lebesgue density theorem on Cantor space (known; N1 Lemma E0 gives a proof); computed: `checks/c2_independent_label.out`, density lemma].** In the setting of Lemma 6.3′:
(a) $M_F^{3,\rm cons}(D)\le2^cM_A^3(D)$ for every three-valued $D\neq\emptyset$;
(b) there are $\sigma_n\in\mathrm{Ind}_B$ with $M_F^{3,\rm cons}(\{(\sigma_n,\iota)\})\le2^{1-n}+\Omtail{n+1}\to0$ while $M_A^3(\{(\sigma_n,\iota)\})\ge2^{-c}$;
(c) Prop 6.4(a) holds for $M_F^{3,\rm cons}$, and $M_F^{3,\rm cons}(\{(\sigma,\iota)\})\ge2^{-K(\sigma)-c}$ for $\sigma\in\mathrm{Ind}_B$.

*Proof.* (a) Map (EM): on a tape where $f^F_\omega$ is consistent and extends $D$, the emitted theory $\Cn(B\cup\Gamma_{f_\omega})$ proves the $1/0$ data and decides no sentence that $f_\omega$ labels $\iota$, in particular none of $D$'s. Sum with (1.1).
(b) Fix $n$ and $\varepsilon:=2^{-n}$. For $p\in\dom V$ with $|p|\le n$ let $F_p:=F_{V(p)}$ and $C_p$ the set of tapes on which $f^{F_p}_\omega$ is consistent (a Borel set: §1.1). If $\mathsf U(C_p)=0$, $p$ contributes nothing. Otherwise, by the Lebesgue density theorem almost every $\omega\in C_p$ has a prefix $w$ with $\mathsf U(C_p\cap[w])>(1-\varepsilon)2^{-|w|}$. Let $\mathcal W_p$ be the set of minimal such prefixes: a prefix-free set with $\mathsf U(C_p\setminus\bigcup_{w\in\mathcal W_p}[w])=0$. Choose a finite $\mathcal W'_p\subseteq\mathcal W_p$ with $\sum_{w\in\mathcal W_p\setminus\mathcal W'_p}2^{-|w|}\le\varepsilon$. For $w\in\mathcal W'_p$ put
$$J_w:=\{\sigma:\mathsf U([w]\cap\{\omega:f^{F_p}_\omega(\sigma)=\iota\})>\varepsilon2^{-|w|}\}.$$
*$J_w$ is r.e.*, uniformly in $(p,w)$ and the rational $\varepsilon$: the measure of the open set $[w]\cap\{f(\sigma)=\iota\}$ is lower semicomputable. *$J_w\subseteq\mathrm{Ind}_B$:* if $\sigma\in J_w$, the set $[w]\cap\{f(\sigma)=\iota\}$ has measure larger than $\varepsilon2^{-|w|}>\mathsf U([w]\setminus C_p)$, so it meets $C_p$: some tape on which $f_\omega$ is consistent labels $\sigma$ with $\iota$, hence $B\cup\Gamma_{f_\omega}$, and so $B$, decides neither $\sigma$ nor $\neg\sigma$. Let $I_n:=\bigcup_{|p|\le n}\bigcup_{w\in\mathcal W'_p}J_w$, a finite union of r.e. subsets of $\mathrm{Ind}_B$, and $\sigma_n\in\mathrm{Ind}_B\setminus I_n$ (Lemma 6.3′). For $|p|\le n$,
$$\nu^{3,\rm cons}_{F_p}(\{(\sigma_n,\iota)\})\le\sum_{w\in\mathcal W'_p}\mathsf U([w]\cap\{f(\sigma_n)=\iota\})+\sum_{w\in\mathcal W_p\setminus\mathcal W'_p}2^{-|w|}+\mathsf U\Big(C_p\setminus\bigcup_{\mathcal W_p}[w]\Big)\le\sum_{w\in\mathcal W'_p}\varepsilon2^{-|w|}+\varepsilon\le2\varepsilon,$$
since $\sigma_n\notin J_w$. By (1.1), $M_F^{3,\rm cons}(\{(\sigma_n,\iota)\})\le\sum_{|p|\le n}2^{-|p|}2\varepsilon+\Omtail{n+1}\le2^{1-n}+\Omtail{n+1}$. The deterministic theory machine that emits nothing (theory $B$) is compatible with $\{(\sigma_n,\iota)\}$ on every tape.
(c) Deterministic labellers are function machines that ignore the tape. $\square$
The coin-free Prop 6.3 is the special case of machines that ignore the tape ($J_w$ is then the labeller's $\iota$-set and no density argument is needed). Scout S had not treated the one-tape case; the obstacle is that the set of sentences a random machine labels $\iota$ on *consistent* tapes is not r.e. in general (positivity of the measure of a $\Pi_1$ class), and the density point restores an r.e. subset of $\mathrm{Ind}_B$ that carries almost all of the consistent $\iota$-mass.
*Computed* (c2): the finite analogue of the lemma ($J_w\subseteq\mathrm{Ind}$, and consistent $\iota$-mass $\le\varepsilon$ in $[w]$ off $J_w$) holds in all 4174 dense prefixes of 20 random three-valued machines ($\varepsilon=0.25,0.1$); the coin-free diagonal of Prop 6.3 (finite analogue: $\sigma_n$ the first independent sentence outside $I_n$) satisfies (b) and (c) at every length until the finite set of independent sentences is exhausted.

### 6.3 Shared versus private randomness

**Remark 6.6 (scout S Rem 2.13) [proved].** If a product law (private coins per input, P1 Prop 3.9(a)) gives positive probability to labelling $\varphi$ true and $\psi$ true, with $B\cup\{\varphi,\psi\}$ inconsistent, the sampled labeller is inconsistent with probability at least their product. The consistent part of a product law is not a product law: on the two inputs $\varphi,\neg\varphi$ with fair independent labels, the consistent outcomes are $(1,0)$ and $(0,1)$, each of mass $\frac14$, and a product would need $P(1,1)P(0,0)=P(1,0)P(0,1)\neq0$. The shared tape is what makes a random labeller a random *theory*; private randomness is harmless on logically independent inputs such as positive literals (Thm 5.1). Product laws are machine laws, so $M_F^{\rm cons}$ dominates their consistent parts.

### 6.4 Computability

**Proposition 6.7 (no lower semicomputability) [proved].**
(a) Suppose the set of finite data sets $D$ with $B\cup D^\pm$ consistent is not r.e. (for instance $B$ decidable and $\Sigma_1$-sound with $\Q\subseteq\Cn(B)$, $\mathcal L\supseteq\mathcal L_{\rm ar}$: then $\{(\neg\mathrm{Halt}_e,1)\}$ is consistent iff program $e$ does not halt; or $B=\emptyset$ and $\mathcal L$ with a binary relation symbol, by Church's theorem). Then none of $W_A$, $W_A^{\rm dec}$, $W^{\rm cons}$, $W^{\rm cl}$, $M_A$, $M_A^{\rm dec}$, $M_F^{\rm cons}$, $M_F^{\rm cl}$ is lower semicomputable.
(b) In every setting, $M_A(\emptyset)$ and $M_F^{\rm cons}(\emptyset)$ are not left-c.e., so $M_A$ and $M_F^{\rm cons}$ are not lsc (scout F's F3(b) for $M_A$; the same construction for $M_F^{\rm cons}$).
(c) All of them are computable relative to $\emptyset'$, uniformly in $D$.
*Proof.* (a) For a function $\nu$ that is lsc uniformly in $D$, the support $\{D:\nu(D)>0\}$ is r.e. Each object listed has support exactly the consistent data sets: positive weight needs a consistent hypothesis proving or extending $D$, and the lookup table of a consistent $D$ (as a labeller, a finite theory, a decider, or a machine ignoring the tape) has positive weight. (b) For $M_F^{\rm cons}$: for a left-c.e. $\alpha$ with approximations $\alpha_s\uparrow\alpha$, the function machine $F_\alpha$ labels the sentence $\exists x\,x\neq x$ with $1$ under a prefix $w$ as soon as some stage $s$ has $0.w+2^{-|w|}\le\alpha_s$, and is undefined elsewhere; its labelling is inconsistent with probability $\mathsf U\{\omega:0.\omega<\alpha\}=\alpha$. With $p_\alpha$ a $V$-program for $F_\alpha$, the inconsistency probability of $F_U$ is $2^{-|p_\alpha|}\alpha+\gamma$ with $\gamma$ left-c.e.; if $M_F^{\rm cons}(\emptyset)=1-(\text{that})$ were left-c.e., the inconsistency probability would be computable and $\alpha$ right-c.e.; take $\alpha=\Omega_V$. (c) Each object is a sum of $\Delta_2$ indicators (support conditions are $\Sigma_1$, consistency is $\Pi_1$) with weights whose tails are $\emptyset'$-computable; for one tape, $\mathsf U(O\cap C)=\mathsf U(O)-\mathsf U(O\setminus C)$ with $O$ open and $C$ closed effectively, a difference of left-c.e. reals. $\square$
*Open:* whether $W_A$ (coin-free) can be lsc when consistency of finite sets is decidable (propositional or monadic $\mathcal L$, $B=\emptyset$): the support argument then says nothing, and the coin-free analogue of F3(b) does not go through directly, because the weight of the inconsistent programs is not separated from $\Omega_V$ by a computable amount.

### 6.5 Pathwise versus machine-wise consistency (scout S Rem 2.14)

$M_F^{\rm cons}$ conditions on the event that the *sampled* labeller is consistent. The machine-wise alternative is $M_F^{C}(D):=\sum_{p\in\dom V}2^{-|p|}[F_{V(p)}\text{ consistent on every tape}]\,\nu_{F_{V(p)}}(D)$ (and $M_A^C$ likewise over theory machines consistent on every tape).

**Proposition 6.8 [(a)–(c) proved; computed: c1 item (7); (d) open].**
(a) $W^{\rm cons}\le2^cM_F^C\le2^cM_F^{\rm cons}$ on nonempty $D$, and $M_F^C\asymp M_A^C$.
(b) $M_F^{\rm cons}(D)\le2^{\min\{K^{\rm pad}(L^{\rm cons}_{1/2}(D)),\,K(\dom D)\}+c}\,M_F^C(D)$.
(c) If consistency of finite sets with $B$ is decidable (uniformly: an algorithm decides, for finite $\Lambda\subseteq\Sent_{\mathcal L}$, whether $B\cup\Lambda$ is consistent; e.g. $\Cn(B)$ decidable, as for a decidable complete $B$ such as Presburger arithmetic, or propositional and monadic languages with $B=\emptyset$), then $M_F^{\rm cons}\asymp M_F^C$ and $M_A\asymp M_A^C$.
(d) In general (e.g. $B=\Q$, or $B=\emptyset$ with a binary relation symbol) whether $M_F^{\rm cons}/M_F^C$ is bounded is **open**.

*Proof.* (a) A deterministic consistent labeller is consistent on every tape; a machine consistent on every tape has $\nu=\nu^{\rm cons}$. The maps (PS) and (EM) preserve "consistent on every tape" (on each tape, PS of a consistent theory is consistent; EM of a consistent labelling is consistent). (b) Prop 4.1 with (a). (c) *The global-schedule filter.* For a function machine $F$ (as a machine reading the tape one-way), let $F'$ answer a query $\varphi$ by running the *global schedule* of $F$: stage $s$ reads tape bit $s$, starts $F$ on the $s$-th sentence and advances every started run by one step; certification events (a run halting with a label) are ordered by stage, ties by sentence index. When $\varphi$'s event occurs, $F'$ checks whether the set of labels certified up to and including it is consistent with $B$ (decidable by hypothesis); if so it outputs $\varphi$'s label, otherwise it diverges. The answer is a deterministic function of the bits read, so $F'$ is a function machine, and $K(F')\le K(F)+c$. On a tape $\omega$ let $\lambda_1,\lambda_2,\dots$ be the labels in event order. $F'$ outputs $\lambda_i$ iff $\{\lambda_1,\dots,\lambda_i\}$ is consistent; consistency of these prefixes is monotone, so the outputs are an initial segment all of whose finite subsets are consistent, hence consistent by compactness. So $F'$ is consistent on every tape, and on every tape on which $F$ is consistent, $F'=F$. Hence $\nu_{F'}(D)\ge\nu^{\rm cons}_F(D)$ for every $D$, and summing over $p$ with (1.1) gives $M_F^C\ge2^{-c}M_F^{\rm cons}$. The theory-machine version filters emissions the same way. $\square$
*Computed* (c1 item (7)): in the propositional analogue (where consistency is decidable) the filter is consistent on every tape, equals $F$ on $F$'s consistent tapes, and has $\nu_{F'}\ge\nu^{\rm cons}_F$ on all 28825 machine–data pairs, for 25 random machines each inconsistent on some tape.
*Why (d) is hard.* An always-consistent machine must avoid inconsistency, which is only semi-decidable; its support $\{D:\nu_F(D)>0\}$ is an r.e. family of consistent data sets. A pathwise-conditioned machine can exploit the $\Pi_1$ event "nothing inconsistent ever happens". Every attempt at a separation made here was absorbed by machine-wise consistent machines that are told a small finite amount of information (an edge count or a window index), at a cost that a simple random machine pays as well. The lottery (Cor 4.2) does not separate them: $G_{\rm lot}$ is consistent on every tape.

---

## 7. Time bounds with free deduction (T7)

All results of this section are the AI-paper's, from the refereed TF record, restated in this paper's notation; their proofs were re-read in `app-time.tex` and TF and are correct as stated there. Scout S's Thm 2.9 (one-tape transfers) is re-proved.

**Conventions** (AI-paper `app-time.tex`, "Machines"; TF §1.2). Hypotheses are programs of a universal prefix machine $U$, read to the end before the input, so ${\rm time}_p(x)\ge|p|$. Assumption (S): efficient self-simulation with a dovetailing schedule and a work counter, constants $\alpha,a$; $a':=\max(a,2)$, $a^*:=\max(a,3)$; assumed, not checked for a concrete $U$. *Clocked strings:* $f^\tau(\varphi):=U_0(f,\varphi)$ if $U_0$ halts within $\tau(|\varphi|)$ steps with a label, abstain otherwise; weight $w(f):=2^{-|E(f)|}$ (Elias-$\delta$ prefix code, $\sum_fw(f)=1$, computable tails). Translation (NOTATION §5): $W^{{\rm cons},\tau}$ = FIcons$^\tau$, $W^{{\rm all},\tau}$ = FIall$^\tau$, $W^{{\rm cons},\rm poly}$ = FIcons$^{\rm poly}$; $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$, $W_A^{{\rm Kt},t}$ = AI$^{\rm chk}_t$, AI$^{\rm gen}_t$, AI$^{\rm Kt}_t$ (deciders, resp. enumerators, in U-format); $c_1$ the clock wrapper, $c_\bot:=-\log w(\text{always abstain})$.

**Theorem 7.1 (axiom-side penalties leave the equivalence intact; AI-paper Thm 6.14(a), TF Thm 2.2) [proved, under (S)].** For time-constructible $t(m)\ge m^{a^*}$ there is $c$ with, for every finite $D$,
$2^{-c}W^{\rm cons}\le W_A^{{\rm chk},t}\le W_A^{\rm dec}\le2^cW^{\rm cons}$ and $2^{-c}W^{\rm cons}\le W_A^{{\rm gen},t}\le2^cW^{\rm cons}$ (strict, delay and cumulative forms).
*Re-check.* The padded set $\mathrm{Pad}(q)$ (AI-paper Lemma E.12): one padded copy $\chi^{\wedge(T+1)}$ per detection, at most two parsing candidates, the decider replays the schedule up to counter $m-1\le|\chi|$, so membership costs $\alpha(|q|+1)+3\alpha(|\chi|+1)^{a'}$; delay $\le2\alpha|a_i|^a$; strict $\le5\alpha|a_i|^{a^*}$ via $\sum_{j\le i}|a_j|\le4|a_i|^3$; cumulative by superadditivity. Correct. The one-tape form is Thm 3.4.

**Proposition 7.2 (a Kt penalty costs a logarithm; AI-paper Prop E.13, TF Prop 2.3) [proved, under (S)].** With $m_0$ the least sentence length and $W^{1}(D):=\sum_f2^{-|f|}/(|f|+1)$ over consistent labellers extending $D$: $W_A^{{\rm Kt},t}(\emptyset)\le t(m_0)$ and $2^{-c}W^1\le W_A^{{\rm Kt},t}\le2^ct(m_0)W^1$; an assigner pays $\log(|f|+1)+O(1)$ bits beyond its unpenalised weight. (TF records the refutation of the earlier claim $W_A^{{\rm Kt}}(\emptyset)\le1$, with a computed counterexample of total weight $3.45$.)

**Theorem 7.3 (domination lemma; TF Thm 3.1) [proved].** Let $X$ satisfy $W_X(D)\ge2^{-c_X}\sum_{g\text{ consistent},\,g\supseteq D}u(g)$ and $W_X(\emptyset)\le\Omega_X$; let $Y$ have $W_Y(D)=\sum_{h\text{ compatible}}v(h,D)$ with an injective map $h\mapsto g_h$ to consistent labellers computing **the same partial map** as $h$, $v(h,D)\le K\,u(g_h)$, and $W_Y(\emptyset)\ge\kappa>0$. Then $\ell_X(D)\le\ell_Y(D)+c_X+\log(K\Omega_X/\kappa)$ for every $D$. (TF refuted the weaker hypothesis $\Gamma_{g_h}=\Gamma_h$: an assigner rejecting $\psi$ and one accepting $\neg\psi$ and abstaining on $\psi$ have the same $\Gamma$ but differ on the datum $(\psi,0)$.)
**Corollary 7.3′ (AI-paper Thm 6.14(b)).** The losses of $W_A$, $W_A^{\rm dec}$, $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$ exceed that of $W^{{\rm cons},\tau}$ by at most $c_\tau:=c+c_1+c_\bot$, on every $D$. [proved, under (S) for the penalised variants]

**Theorem 7.4 (diagonal separation; AI-paper Thm 6.15, TF Thm 3.2, Cor 3.3) [proved, given Kleene's recursion theorem and MRDP (known)].** Let $\mathcal L\supseteq\mathcal L_{\rm ar}$ and $B$ decidable and true in an expansion of $\mathbb N$. For every computable predictor $P$ (pairs $q_0+q_1\le1$, approximable to any precision) there is a program $e$ such that, with $s_n:=\Out(\num e,\num n,S0)$ labelled by truth: $e$ is total with values in $\{0,1\}$; $H_0:=\Q\cup\{\mathrm{DET}\}$ ($\mathrm{DET}$ the true $\Pi_1$ sentence "a program has at most one output") decides every $s_n$; $\ell_P(D_n)\ge n-\sum_j\log(1+2^{-j-2})\ge n-1/(4\ln2)\ge n-0.361$ ($\ge n$ with exact outputs); and $W_A$, $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$ lose at most $\log(1/\omega)$, $\omega$ the weight of $H_0$'s decider or enumerator, independent of $P$. $W^{{\rm all},\tau}$ loses $\ge n-1.37$ and $W^{{\rm cons},\tau}$ loses $\ge n-1.37-c_\bot$.
*Re-check.* The fixed point $e(n)=G(e,n)$; the history passed to $P$ is the true one; the tie rule gives $q_{b_j}\le\frac12+2^{-j-3}$; $H_0\vdash\neg s_n$ when $b_n=0$ via $\Out(\num e,\num n,0)$, $\mathrm{DET}$ and Q1; $W^{{\rm all},\tau}$ is turned into a computable predictor by mixing in $2^{-|D|}$. Correct.

**Proposition 7.5 (incomparability with time-bounded predictors that may be inconsistent; TF Prop 3.4) [proved].** On the fair-coin literals of AI-paper Prop E.1 (all labelled true), Hänni's polynomial-time predictor $S$ (read on labelled sentences) and $W^{{\rm all},\tau}$ have bounded loss, while every consistent inducer (SAI, consistent SOI, coin-free or one-tape) loses $\ge n$ bits in expectation; on their diagonal sequences (Thm 7.4) they lose $\ge n-O(1)$ and SAI a constant. "Axiom induction is strictly stronger than every time-bounded function inductor" is **refuted** (TF); what holds is strict superiority over time-penalised *consistent* SOI.

**Proposition 7.6 (the separation comes from free deduction; AI-paper Prop E.15, TF Prop 4.1) [(a), (b) proved; (c) proof sketch].** (a) The constant-size assigner $u$: on $\Out(\num e,\num n,S0)$ run $e$ on $n$ and accept iff the output is $1$; abstain on other inputs. $\Gamma_u\subseteq\Th(\mathbb N)$. (b) On every diagonal sequence of Thm 7.4, *unpenalised* $W^{\rm cons}$ (and $W$) has loss $\le|u|$. (c) Under a time bound the defeating sequence is computable within a slightly larger bound (a time-hierarchy effect), resting on Hänni's construction of $S$.

**Proposition 7.7 (disguised assigners keep their weight; AI-paper Prop E.16, TF Prop 5.1) [proved, under (S)].** Under membership-time and generation-time penalties ($t\ge m^{a^*}$), and two-sorted content-relative penalties with a true arithmetic background, posterior odds of any two classes of theories differ from the unpenalised ones by at most $2^{2c}$; a slow consistent assigner keeps prior weight $2^{-|f|-c}$. One-tape form: Prop 3.5.

**Theorem 7.8 (one-tape transfers and P1's time-bounded mixtures; scout S Thm 2.9) [proved, given Thms 3.1, 7.3, 7.4, AI-paper Prop E.1 and P1 Prop 9.4].** Let $M_F^{{\rm cons},\tau}:=\sum_fw(f)\nu^{\rm cons}_{F^\tau_f}$, where $F^\tau_f$ runs $f$ on $U_0$ with a tape-reading instruction for at most $\tau(|\varphi|)$ steps and abstains otherwise; $M_F^{{\rm all},\tau}$ without the consistency restriction.
(a) $\ell_{M_A}(D)\le\ell_{M_F^{{\rm cons},\tau}}(D)+c_\tau$ for every $D$.
(b) On a computable sequence of arithmetic sentences, $\ell_{M_F^{{\rm all},\tau}}\ge n-1.37$, $\ell_{M_F^{{\rm cons},\tau}}\ge n-1.37-c_\bot$, while $\ell_{M_A}\le\log(1/\omega)$.
(c) $M_{\rm len}$ and $M_{\rm rd}$ (P1 Def 9.1, Prop 9.4), with computable weights whose tails are computable, are computable predictors, so each loses $\ge n-0.361$ on a computable sequence on which SAI loses $O(1)$; conversely on the coin literals all labelled true $M_{\rm rd}$ has bounded loss (its comparator "label true with probability 1" is in $\mathcal C_t$) while SAI and consistent SOI lose $\ge n$ in expectation. So P1's time-bounded SOI and SAI are incomparable.
(d) Unpenalised $W^{\rm cons}$ and $M_F^{\rm cons}$ have bounded loss on the sequences of (b) and (c), through $u$.
*Proof.* (a) $F^\tau_f$ is a function machine whose $V$-program is a fixed wrapper followed by $E(f)$, injectively ($E$ is a prefix code), so (1.1) gives $M_F^{\rm cons}\ge2^{-c_1}M_F^{{\rm cons},\tau}$ on $D\neq\emptyset$; Thm 3.1 gives $M_A\ge2^{-c}M_F^{\rm cons}$; with $M_A(\emptyset)\le1$ and $M_F^{{\rm cons},\tau}(\emptyset)\ge2^{-c_\bot}$ the bound follows. (b) Each query of $F^\tau_f$ reads at most $\tau(|\varphi|)$ bits, so $\nu_{F^\tau_f}(D)$ is a finite union of cylinders, computable exactly; with computable tails $M_F^{{\rm all},\tau}$ is a computable weak semimeasure with value $1$ at $\emptyset$, and $P(D):=(M_F^{{\rm all},\tau}(D)+2^{-|D|})/2$ is a computable predictor; run Thm 7.4 against $P$. The theory machine emitting $H_0$ is compatible with every $D_n$ on every tape. (c) Thm 7.4 needs only computability; the converse is P1 Prop 9.4 with the constant comparator, and AI-paper Prop E.1 applied tape by tape (Rem 5.4). (d) Prop 7.6. $\square$

**Remark 7.9 (what the time results say).** Penalising the axiom side (checking or generating axioms) does not change which theories win: the equivalence survives, also class by class (Thm 7.1, Props 7.7, 3.5). Penalising the labeller side makes the equivalence one-sided, and the gap is the free deduction of SAI, which unpenalised consistent SOI also has through one constant-size evaluator (Prop 7.6). So the time-bounded separations do not show that axioms are better hypotheses than programs; they show that free deduction is a free computation.

---

## 8. Charged deduction (T8)

**Setting** (AI-paper Def E.18; SD Defs 1.2, 1.3, 1.6; TF Def 1.3). $\mathcal L$ finite, $B$ decidable in polynomial time, Mendelson-style calculus $\mathsf K$ with sizes counting nodes. A hypothesis decides $A_p$ in time $O(t)$ and satisfies **(F1)**: $B\cup A_p$ is closed under permutations of the parameters. Readings of "every datum has a short derivation": $W_A[t,d]$ (derivation size $\le d(|\varphi|)$); $W_A^{a1}[t,h]$ (every axiom instance, logical ones included, $\le h$); $W_A^{a2}[t,h]$ (nonlogical instances only); $W_A^{b}[t,g]$ (material, the total size of the distinct instances, $\le g$); $W_A^{b2}[t,g]$ (nonlogical material). Certificate SOI $W^{\rm cert}[t',d']$: consistent labellers $f_V$ defined by verifiers $V$ with time $O(t')$ and certificates of length $\le d'$.

**Theorem 8.1 (the sandwich; AI-paper Thm 6.16, Lemma E.19, Prop E.21; SD Lemma 2.2, Cor 2.3, Thm 3.1; TF Thm 4.2) [proved, under (F1); the correspondence of proof systems with NP (Cook–Reckhow 1979) known].**
(a) In a normal derivation every line sits at its own node of an instance used or of the conclusion, up to abstracting parameters; so ${\rm size}\le(M+|\varphi|)(M+|\varphi|+1)/2$ with $M$ the material, and the $\frac12$ is attained.
(b) With $G(m):=(g+m+1)(g+m+2)/2$, $t^+(m):=m^{k_0}(t(m)+1)$, $t'^\#(m):=m^{k_0}+t'(m)$: $W_A[t,g]\le W_A^b[t,g]\le W_A[t,G]$ hypothesis by hypothesis; $W_A^b[t,g]\le2^cW^{\rm cert}[t^+,\beta G\log(G+2)]$; and $W^{\rm cert}[t',d']\le2^c$ times each of $W_A^b[t'^\#,2d'+m+31]$, $W_A^{a1}[t'^\#,d'+m+16]$, $W_A[t'^\#,2d'+2m+31]$.
*Re-check of the constants.* $\theta_c:=Z\to(C_c\to Z)$ with $Z=\forall(\#0=\#0)$ (size 4) and $C_c$ of size $|c|+4$ has size $|c|+14$; the derivation $\theta_c$, $\theta_c\to\varphi^b$, $\varphi^b$ has material $2|c|+29+|\varphi^b|$, largest instance $|c|+15+|\varphi^b|$ and size $2|c|+29+2|\varphi^b|$, with $|\varphi^b|\le|\varphi|+1$: the stated budgets. Correct.

**Corollary 8.2 (fit classes; AI-paper Cor 6.17; SD Cor 3.2, Prop 3.4, Thm 4.2, Cor 4.4, Props 4.5, 4.12; TF Cor 4.3) [proved, under (F1); conditional parts as stated; hierarchy theorems and APSPACE = EXPTIME known].** On literal sequences $D^X$, at polynomial budgets with the degrees charged in the prior:
(a) reading (b) fits exactly $X\in\mathsf{NP}\cap\mathsf{coNP}$; it beats $W^{{\rm cons},\rm poly}$ on some sequence if $\mathsf{NP}\cap\mathsf{coNP}\ne\mathsf P$ and fits the same sequences if $\mathsf P=\mathsf{NP}$; with degrees uncharged, $W^{{\rm cons},\rm poly}$ fails to dominate it unconditionally (regret $\ge2^r-O(\log r)$); against $W^{{\rm cons},\tau}$ it wins unconditionally at a budget a hierarchy gap above $\tau$;
(b) reading (a1) fits exactly $X\in\mathsf{EXPTIME}$; at any computable budgets some decidable $X$ defeats it; every predictor computable in time polynomial in the number of data loses $\ge n-0.361$ where (a1) at a linear budget loses $O(1)$;
(c) readings (a2), (b2) fit every decidable $X$, by a finite set of universally closed Horn sentences.

**Proposition 8.3 (soft charges; AI-paper Prop E.26; SD Thm 5.2, Prop 5.3) [proved].** With a factor $2^{-\kappa\ell}$ per datum ($\ell$ the bit length of a shortest derivation), soft SAI and soft certificate SOI correspond only up to a constant factor in the rate ($r=31b_s+26$); no pair of rates gives two-sided constant regret; every soft loss diverges on every infinite sequence, so there are no soft fit classes.

**Remark 8.4 (the role of (F1); AI-paper Prop E.27, Lemma E.28; SD §7) [proved there].** Without (F1) the index of one parameter, which costs one symbol, can carry a certificate of any length; the coarse statements (AI-paper Thm 6.9; the inclusion of reading (b)'s fit class in $\mathsf{NP}\cap\mathsf{coNP}$) survive in the node-count reading by truncating parameter indices; the fine bounds ($2^{O(h\log h)}$ for (a1), certificate lengths) are not claimed.

**Remark 8.5 (what is charged).** Every reading bounds the size of a derivation that *exists*; none charges *finding* it. The nondeterminism is free: derivation-charged SAI is certificate SOI, an $\mathsf{NP}\cap\mathsf{coNP}$-type notion, not deterministic time-bounded SOI. For the textbook point (written theories are not sufficient for a simple reasoner) this means that the AI-paper's charged deduction cannot express it; a deterministic bounded reasoner can (`shape` T5).

**Remark 8.6 (one tape) [proof sketch].** The maps of Thm 8.1(b) act tape by tape: a random decider with time $O(t)$ on every tape gives a verifier that reads the tape to answer membership queries; certificate axioms $\theta_c\to\varphi^b$ can be emitted from a random verifier. So a one-tape form of the sandwich holds with the same budgets. Not written out (the tape-reading verifier needs (S$_{\rm tape}$)-style bookkeeping).

---

## 9. A natural separation: Presburger arithmetic (T9)

$\mathcal L_{\rm Pr}:=\{0,1,+,=\}$, $B=\emptyset$, $D^{\rm Pres}$ lists all $\mathcal L_{\rm Pr}$-sentences in length-lexicographic order, labelled by truth in $(\mathbb N,0,1,+)$; $\mathrm{PrA}:=\Th(\mathbb N,0,1,+)$.

**Facts used.**
* (F$_{\rm P}$) *Presburger 1929* [known; standard, not re-checked in this run]: the axioms for successor and addition with the induction schema for $\mathcal L_{\rm Pr}$-formulas form a decidable, consistent and complete axiomatisation of $\mathrm{PrA}$, with membership decidable in polynomial time.
* (F$_{\rm FR}$) *Fischer and Rabin 1974*, "Super-exponential complexity of Presburger arithmetic", SIAM-AMS Proc. 7, 27–41 [known: bibliographic data and abstract checked by scout S and re-confirmed by scout L; the precise quantifier form not re-checked in this run, because web search was unavailable]: there is a constant $c_{\rm FR}>0$ such that every (also every nondeterministic) decision procedure for $\mathrm{PrA}$ runs more than $2^{2^{c_{\rm FR}m}}$ steps on some sentence of length $m$, for all large $m$. *Only the following weaker form is used:* no procedure decides $\mathrm{PrA}$ within $2^{2^{c_{\rm FR}m}}$ steps on all sentences of length $m$ for all large $m$; with $c_{\rm FR}$ independent of the procedure. Sentence lengths in our syntax and in Fischer–Rabin's differ by a constant factor $\kappa$, absorbed below by writing $c:=c_{\rm FR}/\kappa$.

**Proposition 9.1 (coin-free; scout S Prop 2.10) [proved, given F$_{\rm P}$ and F$_{\rm FR}$].** (a) $W_A$, $W_A^{\rm dec}$, $M_A$, and the penalised $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$, $M_A^{{\rm chk},t}$ ($t$ a large enough polynomial) have bounded loss on $D^{\rm Pres}$. (b) For time-constructible $\tau$ with $\tau(m)\le2^{2^{c'm}}$ for large $m$ and $c'<c$: $\ell_{W^{{\rm cons},\tau}}(D^{\rm Pres}_n)\to\infty$ and $\ell_{W^{{\rm all},\tau}}(D^{\rm Pres}_n)\to\infty$.
*Proof.* (a) The decider of Presburger's axioms is compatible with every prefix (complete and consistent), runs in polynomial time, and is a deterministic theory machine; the losses are at most $-\log$ of its weight. (b) The clocked mixtures are mixtures in the sense of AI-paper Lemma E.11 (compatibility inherited by prefixes), so a bounded loss would give one $\tau$-clocked $f$ labelling every sentence correctly. By TF's overhead (i) it yields a multitape decision procedure in time $q(C_f\tau(m)+m)\le2^{2^{cm}}$ for large $m$ (c3, table (A), gives the thresholds for illustrative constants), contradicting F$_{\rm FR}$. $\square$

**Proposition 9.2 (one tape, exponential clocks; scout S Prop 2.10′) [proved, given F$_{\rm P}$, F$_{\rm FR}$ and the Lebesgue density theorem].** If $\tau(m)\le2^{c'm}$ for large $m$, $c'<c$, then $\ell_{M_F^{{\rm cons},\tau}}(D^{\rm Pres}_n)\to\infty$ and $\ell_{M_F^{{\rm all},\tau}}(D^{\rm Pres}_n)\to\infty$, while $M_A$ has bounded loss.
*Proof* (re-checked). Write $M:=\sum_fw(f)\nu_f$, each $\nu_f(D^{\rm Pres}_n)$ non-increasing in $n$. Bounded loss gives $\inf_nM(D_n)>0$; by dominated convergence some $f$ has $\lim_n\nu_f(D_n)>0$, which by continuity from above is $\mathsf U(G)$ for $G:=\{\omega:F^\tau_f\text{ labels every sentence correctly on }\omega\}$ (and consistently). By Lebesgue density there is $u$ with $\mathsf U(G\cap[u])>\frac34\,2^{-|u|}$, so for every sentence the tapes in $[u]$ on which $F^\tau_f$ answers correctly have conditional measure $>\frac34$. A query of length $m$ reads at most $\tau(m)$ tape bits, so the procedure "for every $v$ of length $\max(0,\tau(m)-|u|)$ run $F^\tau_f$ with tape $uv$ and output the majority answer" ($u$ hard-coded) decides $\mathrm{PrA}$ deterministically within $2^{\tau(m)}q(C_f\tau(m)+m)\le2^{2^{cm}}$ steps for large $m$ (c3, table (B)): a contradiction. $\square$
The argument applies to every mixture of machines whose tape use per query is bounded by $\tau$.

**Proposition 9.3 (one tape, doubly exponential clocks) [conditional: proved, given (B*) and (SGL), both known, unverified].** Assume
* (B*) there is $c_B>0$ such that no alternating machine with at most two alternations ($\Sigma_2$) decides $\mathrm{PrA}$ within $2^{2^{c_Bm}}$ steps on all sentences of length $m$, for all large $m$. *Source (recalled, unverified):* L. Berman, "The complexity of logical theories", *Theoretical Computer Science* 11 (1980), shows that $\mathrm{PrA}$ needs alternating time $2^{2^{cn}}$ even with $n$ alternations (and is complete for alternating time $2^{2^{n^{O(1)}}}$ with $O(n)$ alternations); since $\Sigma_2$-time $T$ is contained in alternating time $T$ with $n\ge2$ alternations, this implies (B*).
* (SGL) for time-constructible $T(m)\ge m$, $\mathsf{BPTIME}(T)\subseteq\Sigma_2\text{-}\mathsf{TIME}(T^{\kappa})$ for an absolute constant $\kappa$ (Sipser 1983; Gács; Lautemann 1983: amplify to error $<1/(2r)$ with $r$ random bits and use $r$ shifts; recalled, unverified).

If $\tau(m)\le2^{2^{c'm}}$ for large $m$ with $c'<c_B/\kappa'$ ($\kappa'$ absorbing $\kappa$, $q$ and the length conversion), then $\ell_{M_F^{{\rm cons},\tau}}(D^{\rm Pres}_n)\to\infty$ and likewise for $M_F^{{\rm all},\tau}$.
*Proof.* As in Prop 9.2 obtain $u$ with conditional correctness probability $>\frac34$ on $[u]$ for every sentence. The algorithm "draw $v$ of length $\tau(m)$ at random, run $F^\tau_f$ with tape $uv$, output its answer" errs with probability $<\frac14$ on every sentence and runs in time $T(m):=q(C_f\tau(m)+m)$, so $\mathrm{PrA}\in\mathsf{BPTIME}(T)\subseteq\Sigma_2\text{-}\mathsf{TIME}(T^\kappa)$ by (SGL). Since $T(m)^\kappa\le2^{2^{c_Bm}}$ for large $m$ when $c'<c_B/\kappa'$ (c3, table (C), shows the thresholds for illustrative constants), this contradicts (B*). $\square$
*What would finish it unconditionally:* verifying (B*) (a $\Sigma_2$-time lower bound $2^{2^{cn}}$ for $\mathrm{PrA}$, which Berman's alternating lower bound with linearly many alternations implies) and the time-bounded form of Sipser–Gács–Lautemann. A nondeterministic lower bound alone (Fischer–Rabin) does not suffice by this route: separating $\mathsf{NTIME}(2^{2^n})$ from $\Sigma_2$-time below it is not known in general.

**Proposition 9.4 (charged deduction fails on Presburger too) [proved, given F$_{\rm FR}$ and the proof of AI-paper Thm 6.9].** Let a hypothesis $p$ decide its axiom set in time $O(m^e)$ and be compatible with every prefix of $D^{\rm Pres}$ under $W_A[t,d]$ (every datum has a derivation of size $\le d(|\varphi|)$). Then $d(m)>2^{2^{c''m}}$ for infinitely many $m$, with $c''>0$ depending only on $e$. The same holds under readings (a1), (b) (Thm 8.1(a): size $\le$ a polynomial of the material).
*Proof.* The proof of AI-paper Thm 6.9 applies to any data whose labels are consistent with the hypothesis: guess a derivation of $\varphi$ or of $\neg\varphi$ of size $\le d(m)$ (with parameter numbers truncated, AI-paper Lemma E.28) and check it in time polynomial in $d(m)$ of a degree depending on $e$; output the label it proves. The theory is consistent and proves every true sentence, so this nondeterministic procedure decides $\mathrm{PrA}$ within $d(m)^{c_e}$ steps. By F$_{\rm FR}$, $d(m)^{c_e}>2^{2^{cm}}$ for infinitely many $m$, so $d(m)>2^{2^{cm}/c_e}\ge2^{2^{cm/2}}$ for large such $m$. $\square$
So on a natural theory the picture of §7–§8 recurs: with free deduction SAI wins against every doubly exponential (coin-free) or exponential (one-tape) clocked consistent SOI; once derivations are charged below doubly exponential size, SAI fails too. The separation is free deduction. Fischer and Rabin's own proof-length clause ("easily recognised" axiomatisations) is not needed: AI-paper Thm 6.9 turns their nondeterministic decision bound into a derivation-size bound for every polynomial-time axiom set.

**Computed thresholds** (`checks/c3_presburger_constants.out`; $q(x)=x^k$, constant $C$; illustrative, since $c_{\rm FR}$ and $c_B$ are not known explicitly here). The least $m_0$ from which each contradiction bites, for example with $c=1$: (A) coin-free, $c'=0.5c$: $m_0=4$–$8$; $c'=0.9c$: $11$–$26$. (B) one tape, exponential clock: $c'=0.9c$: $6$–$9$. (C) one tape, doubly exponential, $\Sigma_2$ route, $c_B=1$, $c'=0.9$: $26$–$42$. With $c=0.05$ and $c'=0.9c$ the thresholds grow to $203$–$517$ (A), $117$–$172$ (B), $517$–$834$ (C). The separations are asymptotic: below $m_0$ a clocked hypothesis may label every short sentence correctly.

---

## 10. The circuit analogue of the sandwich (T10)

Fix $d\ge1$. Data are the literals $\varphi_x:=R(t_x)$, $x\in\{0,1\}^d$, labelled by a partial $f:\{0,1\}^d\rightharpoonup\{0,1\}$.

**Definition 10.0.**
* A *verifier circuit* $V$ of size $s$ is a list of $s$ two-input gates (any of the 16 Boolean functions) over the inputs $x_1,\dots,x_d$, certificate bits $z_1,\dots,z_k$ ($k\le2s$ without loss of generality), the constants and earlier gates; its last two gates are the outputs $\mathsf a,\mathsf r$. It is *consistent* if no $x$ has certificates $c,c'$ with $\mathsf a(x,c)=1$ and $\mathsf r(x,c')=1$. It defines $f_V(x):=1$ if some $c$ has $\mathsf a(x,c)=1$, $0$ if some $c$ has $\mathsf r(x,c)=1$, undefined otherwise. $s_N(f)$ is the least size of a consistent verifier circuit with $f_V\supseteq f$. (These are $\mathsf{NP}\cap\mathsf{coNP}$-type circuits; $s_N(f)\le\csize(f)+O(1)$, P1 Def 9.7.)
* *The fixed language* $\mathcal L_{\rm circ}:=\{\mathtt e,\mathtt s_0,\mathtt s_1,\mathrm{Bit},\mathrm{Gate},R\}$ with $\mathrm{Bit}$ binary, $\mathrm{Gate}$ ternary. Index terms $n_i$ and gate terms $g_j$ are word terms $t_{\beta(i)}$, $\beta(i)$ the binary expansion of $i+1$ without its leading $1$; so $|n_i|=O(\log i)$ and the language does not grow with the circuit.
* $a_\ell(f)$ is the least total size of a finite set $T$ of $\mathcal L_{\rm circ}$-sentences (or of sentences of any fixed finite language $\supseteq\{\mathtt e,\mathtt s_0,\mathtt s_1,R\}$) with $T\cup\Gamma_f$ consistent such that every datum $\varphi_x^{f(x)}$, $x\in\dom f$, has a $\mathsf K$-derivation from $T$ of size $\le\ell$.

**The translation $T_V$.** All sentences universally closed; $\leftrightarrow$ abbreviates $\neg((A\to B)\to\neg(B\to A))$.
* Bit: $\forall y\,\mathrm{Bit}(n_0,\mathtt s_1y)$, $\forall y\,\neg\mathrm{Bit}(n_0,\mathtt s_0y)$, and $\forall y\,(\mathrm{Bit}(n_{i+1},\mathtt s_ay)\leftrightarrow\mathrm{Bit}(n_i,y))$ for $i<\max(d,k)-1$, $a\in\{0,1\}$. (So $\mathrm{Bit}(n_i,t_w)$ holds iff the $(i+1)$-st symbol of $w$ is $1$.)
* Gates: for an input gate $j$ reading $x_i$ (resp. $z_i$): $\forall x\forall z\,(\mathrm{Gate}(g_j,x,z)\leftrightarrow\mathrm{Bit}(n_{i-1},x))$ (resp. $z$); for an internal gate $j$ with operation $\mathrm{op}$ on gates $a,b$: $\forall x\forall z\,(\mathrm{Gate}(g_j,x,z)\leftrightarrow\mathrm{op}(\mathrm{Gate}(g_a,x,z),\mathrm{Gate}(g_b,x,z)))$.
* Outputs: $\forall x\forall z\,(\mathrm{Gate}(g_{\mathsf a},x,z)\to R(x))$, $\forall x\forall z\,(\mathrm{Gate}(g_{\mathsf r},x,z)\to\neg R(x))$.

**Theorem 10.1 (circuit sandwich).**
(i) [proved; computed: `checks/c4_circuit_axioms.out`] For every consistent verifier circuit $V$ of size $s$ with $k$ certificate bits, $T_V$ has total size at most $C_1(s+d+k)\log_2(s+d+k+2)$, $T_V\cup\Gamma_{f_V}$ is consistent, and every $x\in\dom f_V$ has a derivation of $\varphi_x^{f_V(x)}$ from $T_V$ of size at most $\ell_V:=C_2\big(s\,(\log_2(s+2)+d+k)+(d+k)^3\big)$, with absolute constants $C_1,C_2$. Hence $a_{\ell}(f)\le C_1'(s_N(f)+d)\log_2(s_N(f)+d+2)$ for $\ell=C_2'(s_N(f)\,(\log s_N(f)+d)+(d+s_N(f))^3)$, using $k\le2s$.
(ii) [proved, given the standard simulation of a time-$T$ Turing machine on inputs of a fixed length by Boolean circuits of size $O(T^2)$ (known)] Conversely $s_N(f)\le P(a_\ell(f),\ell,d)$ for a fixed polynomial $P$ depending only on the language and $\mathsf K$.

*Proof.* (i) *Size.* There are $O(d+k)$ Bit axioms of size $O(\log(d+k))$, and one axiom of size $O(\log(s+d+k))$ per gate (two or three gate terms and at most two index terms), plus two output axioms.
*Consistency.* Take the free term algebra on $\mathtt e,\mathtt s_0,\mathtt s_1$ with equality the identity. Read off the bits of any element $y$ (the symbols of the word it spells, $0$ beyond its length; a term is a word); let $\mathrm{Bit}(t,y)$ hold iff $t=n_i$ for some $i<\max(d,k)$ and bit $i$ of $y$ is $1$; let $\mathrm{Gate}(t,x,z)$ hold iff $t=g_j$ and gate $j$ of $V$ outputs $1$ on the first $d$ bits of $x$ and the first $k$ bits of $z$; let $R(x)$ hold iff some $c$ has $\mathsf a(\text{bits}_d(x),c)=1$. The Bit and gate axioms hold by construction (the $n_i$ and $g_j$ are pairwise distinct). The first output axiom holds by the definition of $R$; the second holds because $V$ is consistent: $\mathsf r(\text{bits}_d(x),z)=1$ excludes $\mathsf a(\text{bits}_d(x),c)=1$ for every $c$. On word terms of length $d$, $R(t_x)$ iff $f_V(x)=1$, and $f_V(x)=0$ forces $\neg R(t_x)$; so the structure satisfies $T_V\cup\Gamma_{f_V}$.
*Derivations.* For $x\in\dom f_V$ take a certificate $c$ for its label. Instantiate every gate axiom with $x:=t_x$, $z:=t_c$ (two A4 instances and two MP steps per axiom, each line of size $O(\log s+d+k)$). Derive each needed bit: $\mathrm{Bit}(n_i,t_w)$ or its negation from a Bit0 instance and $i$ BitS instances (each $O(d+k)$ in size), with a fixed propositional derivation for biconditional elimination substituted at each step: $O((d+k)^2)$ per bit, $O((d+k)^3)$ in all. Then, gate by gate in order, derive $\mathrm{Gate}(g_j,t_x,t_c)$ or its negation from the ground biconditional and the literals of its inputs, by a substitution instance of a fixed propositional derivation (the propositional fragment of $\mathsf K$ is complete; substitution instances of derivations are derivations, of size linear in the substituted formulas: TF Thm 4.2(b), referee script r3 Part D). Finish with the output instance and MP. The total is $O(s(\log s+d+k)+(d+k)^3)$.
(ii) A certificate is the code of a derivation of size $\le\ell$; since $T$ is a set of sentences, (F1) holds and parameters can be renamed to $p_0,\dots,p_{\ell-1}$, so the code has $O(\ell\log\ell)$ bits (AI-paper Prop E.21(b)). The checker (with $T$ hard-wired) verifies each line (logical axioms by matching, A4 by first-order matching, members of $T$ by comparison, MP, Gen) and the last line against $\varphi_x$ or $\neg\varphi_x$, in time polynomial in $\ell+|T|+d$; accept if it is a derivation of $\varphi_x$, reject if of $\neg\varphi_x$. Simulating it by circuits gives a verifier circuit of size $P(|T|,\ell,d)$. It is consistent because $T$ is ($T\cup\Gamma_f$ is), and $f_V\supseteq f$ because every datum has a derivation within $\ell$ and $T$ proves no wrong label. $\square$

*Computed* (c4): for 24 random consistent verifier circuits with $d\in\{2,3\}$, $k\in\{1,2\}$, every axiom of $T_V$ is true in the intended structure on a finite fragment (all words of length $\le\max(d,k)+2$ and all index and gate terms), $R$ agrees with $f_V$, and forward propagation through the ground instances derives the right label for every $x\in\dom f_V$ (nonlogical material $\le1682$ symbols); as a negative control, every corruption of one gate operation that changes $f_V$ makes the translated theory derive a wrong label or change its domain (95 of 95; corruptions that leave $f_V$ unchanged are skipped). Sizes: $|T_V|/((s+d)\log_2(s+d))$ stays between $7.9$ and $9.0$ for $s$ from 33 to 1099 gates.

**Corollary 10.2 (P1's circuit-Bayes theorem for verifier circuits) [proved, by the proof of P1 Thm 9.8 with the changes stated].** Let $W_N$ be the mixture over consistent verifier circuits with prior $w(V):=2^{-s}\cdot\frac1{2s+1}\cdot N_{s,k}^{-1}$ (size $s$, $k\le2s$ uniform, $N_{s,k}=\prod_{j=1}^s16(d+k+1+j)^2$ gate lists), and for a nonempty $B'\subseteq\{0,1\}^d$, an ordering of $B'$ and the labels of $f$, let $L:=-\log W_N(f|_{B'})$, $\ell_\emptyset:=-\log W_N(\emptyset)$, and $\mathcal E:=\sum_iP_i$ with $P_i$ the posterior mass at step $i$ that is wrong **or undefined** at $x_i$. Then:
(a) some consistent verifier circuit of size $\le\lceil L\rceil$ agrees with $f$ on $B'$, and $L\le s_N+\log(2s_N+1)+\log N_{s_N,2s_N}=O(s_N\log(s_N+d))$ with $s_N:=s_N(f|_{B'})$;
(b) $\mathcal E\le(\ln2)(L-\ell_\emptyset)$ and $L-\ell_\emptyset\le2\mathcal E(\Gamma_N(\lceil L\rceil)+3)$ with $\Gamma_N(s):=\gamma(5+2\log_2(d+3s+\gamma+1))+\log_2(\gamma+1)$, $\gamma:=2d+2$.
*Proof.* (a) The prior has an exponential tail in $s$ (total weight of sizes $>S$ is $\le2^{-S}$), and the verifier with no active output disagrees with $f$ at every size, so P1's argument applies. (b) The first inequality is $P_i\le-\ln(1-P_i)$ and telescoping (now $W_N(\emptyset)<1$, hence $\ell_\emptyset$). For the second, the *exception gadget* for verifiers: given $V$, a point $a$ and a label $b$, append $\mathrm{eq}_a(x)=[x=a]$ ($\le2d-1$ gates), its negation, and new outputs $\mathsf a':=\mathsf a\vee\mathrm{eq}_a$, $\mathsf r':=\mathsf r\wedge\neg\mathrm{eq}_a$ if $b=1$ (symmetrically if $b=0$): $\gamma\le2d+2$ gates. $V'$ is consistent (at $a$ only the $b$-output can fire; elsewhere as $V$), defined at $a$ with label $b$, agrees with $V$ off $a$, and $V\mapsto V'$ is injective; $w(V')/w(V)\ge2^{-\Gamma_N(s)}$. It maps the hypotheses of size $\le S$ that are wrong *or undefined* at $x_i$ injectively to hypotheses that are right at $x_i$ and still compatible with $D_{i-1}$ (earlier inputs differ from $x_i$). The rest of P1's proof is unchanged. $\square$
So Bayes over nondeterministic verifier circuits makes few posterior mistakes on $f$ exactly when $f$ has a small consistent verifier circuit, and, by Thm 10.1, exactly when $f$ has a small finite axiomatisation in a fixed language whose data have polynomially short derivations, up to polynomial changes.

**Remark 10.3 (the axiom-set prior itself) [proof sketch].** For a mixture over finite axiom sets with a derivation budget, the upper bound $L=O(a\log a)$ and $\mathcal E\le(\ln2)L$ hold directly (Thm 10.1(i); telescoping). The converse needs an exception gadget for *every* hypothesis $T$: replace $R$ by a fresh unary predicate $R'$ in $T$ and add $\forall x\,(x\neq t_a\to(R(x)\leftrightarrow R'(x)))$ and $R(t_a)^b$. This works if the language supplies fresh predicate symbols (so $\mathcal L$ is not fixed finite; the symbol index costs $O(\log)$ bits), if $B$ contains the free-algebra axioms needed to derive $t_x\neq t_a$ (size $O(d^2)$), and if the budget is charged in the prior so that the gadget's extra $O(d^2)$ derivation size moves a hypothesis to a nearby budget at $O(\log)$ bits. Not written out.

---

## 11. The table of equivalences and separations (T11)

Semimeasure convention throughout unless stated; "$\asymp$" within $2^{\pm c}$ on every data set, $c$ a machine constant; "status" is after the verification of this round; "source" names the first proof and this record's item. Rows 33–38 belong to `terms` and are cited from scout S §3 as the `terms` thread will revise them.

| # | pair | relation | overhead | hypotheses | status | source |
|---|---|---|---|---|---|---|
| 1 | $W_A^{\rm dec}$ (the AI-paper's AI) — $W^{\rm cons}$ (FIcons) | $\asymp$; losses within $2c$ ($2c$ per step normalised) | proof search; Craig | $B$ decidable, consistent | proved; Craig known | AI-paper Thm 6.3; Thm 2.1 |
| 2 | $W_A$ (enumerators) — $W^{\rm cons}$ | $\asymp$, no Craig needed | proof search; emission | same | proved | F8; Thm 2.1 |
| 3 | $K_A$, $K_A^{\rm dec}$ — $K_F^{\rm cons}$, $K_F^{\rm cl}$ | equal $\pm c$; finite iff $D$ consistent | same | same | proved | Thm 2.1(b) |
| 4 | $W_A$ — $W^{\rm cl}$ (closed labellers) | $\asymp$ including the three-way weights (prove / refute / neither) | closure | same | proved | Thm 2.1(c) |
| 5 | $M_A$, $M_A^{\rm dec}$ — $M_F^{\rm cons}$ | $\asymp$ on every finite $D$, tape by tape | three wrappers | same | proved; computed (c1) | F8, S Thm 2.5; Thm 3.1 |
| 6 | $M_A$ — $M_F^{\rm cl}$ | $\asymp$ including three-way weights | same | same | proved; computed (c1) | Cor 3.2 |
| 7 | $M_A^{{\rm chk},t}$, $M_A^{{\rm gen},t}$ (one tape, axiom-side penalties) — $M_A$, $M_F^{\rm cons}$ | $\asymp$ ($D\ne\emptyset$), and class by class | padding by the work counter, per tape | $t\ge m^{a^*}$, (S$_{\rm tape}$) | proved under (S$_{\rm tape}$) | Thm 3.4, Prop 3.5 |
| 8 | $W^{\rm cons}$ — $M_F^{\rm cons}$ (and $W_A$ — $M_A$) | $W\le2^cM$; gap $\le\min\{K^{\rm pad}(L^{\rm cons}_{1/2}),K(\dom D)\}+c$; on the lottery stream $M$ bounded, $W$ unbounded | — | lottery: $\mathcal L$ with a binary relation | proved; lottery given N1 E1 | S Prop 2.6; Prop 4.1, Cor 4.2 |
| 9 | $W$ (plain, on sentences) — $W^{\rm cons}$ on the lottery stream | $W$ bounded, $W^{\rm cons}$ unbounded | — | as row 8 | proved, given N1 E1, E2(b) | Cor 4.2(c) |
| 10 | any SAI version on positive literals — P1's version on strings | $\asymp$ / $\pm c$: SAI is SOI there | encoding wrapper | $R$ not in $B$; terms distinct in a model of $B$ | proved | S Thm 2.7, F9; Thm 5.1 |
| 11 | $W_A$ — $M_A$ on literal data, words of length $\le d$ | gap $\le\delta_D+K^{\rm pad}(2^{d+1})+c$, $\delta_D$ the label deficiency | — | as row 10 | proved | P1 Rem 4.12(2); Prop 5.3 |
| 12 | $2^{-K_A}$ — $W_A$ | no coding theorem: gap $\ge\log d-K(\lceil\log(d+1)\rceil)-c$ on two literals | — | as row 10 | proved | P1 Thm 4.9, F11; Cor 5.2(a) |
| 13 | SAI — $W$ on sentences (FIall) | FIall wins by $n$ bits on coin literals: an encoding effect | — | — | proved | AI-paper Prop E.1; Rem 5.4 |
| 14 | entailed $\chi$: SAI — consistent SOI | SAI predicts $(1,0,0)$; consistent SOI $P(0)=0$, $P(1)\ge2^{-2c}$, $P(\bot)\ge2^{-K(\chi)-c}$ uniformly in $D$ | — | — | proved; computed (c1) | S Prop 2.11; Prop 6.1 |
| 15 | $W_A^3$ — $W^{3,\rm cons}$ (independence observed) | one-sided; unbounded gap on one datum; $\le K(\sigma)+c$; bounded on every r.e. family | — | $\mathcal L_{\rm ar}$, $B$ decidable, $\Sigma_1$-sound, $\Q\subseteq\Cn(B)$ | proved, given recursion theorem, MRDP | S Prop 2.12; Props 6.3, 6.4 |
| 16 | $M_A^3$ — $M_F^{3,\rm cons}$ (one tape) | as row 15 | — | as row 15 | proved, given also Lebesgue density | Prop 6.5 |
| 17 | $M_F^{\rm cons}$ — $M_F^C$ (pathwise vs machine-wise consistency) | $\asymp$ if finite consistency is decidable; in general gap $\le\min\{K^{\rm pad},K(\dom D)\}+c$; boundedness open | global-schedule filter | — | proved / open | Prop 6.8 |
| 18 | $W_A^{{\rm chk},t}$, $W_A^{{\rm gen},t}$ — $W^{\rm cons}$ | $\asymp$ (unpenalised!) | padding; $t\ge m^{a^*}$ | (S) | proved under (S) | AI-paper Thm 6.14(a), TF Thm 2.2; Thm 7.1 |
| 19 | $W_A^{{\rm Kt},t}$ — $W^1$ (weights $2^{-|f|}/(|f|+1)$) | within $2^c$ and $2^ct(m_0)$ | $\log(|f|+1)+O(1)$ bits | (S) | proved under (S) | TF Prop 2.3; Prop 7.2 |
| 20 | SAI ($W_A$, penalised, $M_A$) — $W^{{\rm cons},\tau}$, $M_F^{{\rm cons},\tau}$ | one-sided: regret $\le c_\tau$; reverse $\ge n-1.37-c_\bot$ on a computable sequence | — | $\mathcal L\supseteq\mathcal L_{\rm ar}$, $B$ true | proved | AI-paper Thms 6.14(b), 6.15; TF Thms 3.1, 3.2; Thms 7.3, 7.4, 7.8(a,b) |
| 21 | SAI — every computable predictor ($S$, $W^{{\rm all},\tau}$, $M_{\rm len}$, $M_{\rm rd}$) | incomparable | — | same | proved | TF Prop 3.4; Prop 7.5, Thm 7.8(c) |
| 22 | unpenalised $W^{\rm cons}$, $M_F^{\rm cons}$ — rows 20, 21 | match SAI through a constant-size evaluator | constant | same | proved | TF Prop 4.1; Prop 7.6 |
| 23 | $W_A[t,d]$, $W_A^b[t,g]$ — $W^{\rm cert}$ | $\asymp$ up to constant description length and polynomial budget changes | $t^+$, $\beta G\log(G+2)$; $2d'+m+31$ | (F1) | proved; Cook–Reckhow known | AI-paper Thm 6.16; TF Thm 4.2; SD Thm 3.1; Thm 8.1 |
| 24 | $W_A^b[\rm poly,poly]$ — $W^{{\rm cons},\rm poly}$ | fit classes $\mathsf{NP}\cap\mathsf{coNP}$ vs $\mathsf P$ (conditional parts); non-domination with uncharged degrees | — | (F1) | proved | SD Cor 3.2, Prop 3.4; Cor 8.2(a) |
| 25 | $W_A^{a1}[\rm poly,poly]$ — $W^{{\rm cons},\rm poly}$ | $\mathsf{EXPTIME}$ vs $\mathsf P$, unconditional | — | (F1) | proved | SD Cor 4.4; Cor 8.2(b) |
| 26 | $W_A^{a2}$, $W_A^{b2}$ — $W^{\rm cons}$ | every decidable $X$ fitted: no time limit | finite Horn theory | — | proved | SD Prop 4.12; Cor 8.2(c) |
| 27 | soft SAI — soft $W^{\rm cert}$ | correspondence up to a constant factor in the rate; no two-sided constant regret | rate $31b_s+26$ | — | proved | SD Thm 5.2, Prop 5.3; Prop 8.3 |
| 28 | SAI — $W^{{\rm cons},\tau}$ on Presburger arithmetic | SAI bounded; clocked coin-free consistent SOI unbounded for $\tau\le2^{2^{c'm}}$ | — | $B=\emptyset$ | proved, given Fischer–Rabin, Presburger | S Prop 2.10; Prop 9.1 |
| 29 | SAI — $M_F^{{\rm cons},\tau}$, $M_F^{{\rm all},\tau}$ on Presburger | unbounded for $\tau\le2^{c'm}$; for $\tau\le2^{2^{c'm}}$ conditional | — | $B=\emptyset$ | proved, given Fischer–Rabin and density; doubly exponential: conditional on (B*), (SGL) | S Prop 2.10′; Props 9.2, 9.3 |
| 30 | $W_A[t,d]$ ($t$ polynomial) on Presburger | unbounded unless $d(m)>2^{2^{c''m}}$ infinitely often | — | — | proved, given Fischer–Rabin, AI-paper Thm 6.9 | Prop 9.4 |
| 31 | finite axiom sets (fixed language, derivation budget) — verifier ($\mathsf{NP}\cap\mathsf{coNP}$-type) circuits | polynomially related both ways | $O((s+d)\log(s+d))$ symbols; poly derivations | literal data, fixed $d$ | (i) proved, computed (c4); (ii) proved, given TM-to-circuit simulation | Thm 10.1 |
| 32 | Bayes over verifier circuits — nondeterministic circuit size | P1's circuit-Bayes theorem holds | gadget $O(d\log(d+s))$ | — | proved; axiom-set prior: proof sketch | Cor 10.2, Rem 10.3 |
| 33 | $W_A^{\mathcal L}$ — $W_A^{\mathcal L_O}$ (all vs observational axioms), free deduction | $\asymp$, also class posteriors | Craig / padding | — | proved (scout S) | S Thm 3.1; `terms` T1 |
| 34 | Craig-type (run-padded) observational axioms, charged deduction | fit class $\mathsf P$ at polynomial budgets | — | literal data | proved (scout S) | S Thm 3.3; `terms` T2 |
| 35 | $W_A^{\mathcal L}[t,d]$ — $W_A^{\mathcal L_O}$ with certificate axioms, reading (b) | $\ge2^{-c}$ at polynomially larger budgets | $O(1)$ bits | (F1) | proved (scout S) | S Prop 3.5; `terms` T3 |
| 36 | observational vs all hypotheses, (a1); finite observational vs all finite, (a2), (b2) | same fit classes ($\mathsf{EXPTIME}$; every decidable $X$) | pairing gadget | (F1), literal data | proved (scout S) | S Prop 3.10; `terms` T3 |
| 37 | finite theories about the named objects (with unary theoretical predicates) | fit class REG under every reading | — | literal data | proved, given Rabin 1969 (scout S) | S Thm 3.12; `terms` T4 |
| 38 | finite theories about the named objects + one polyadic relation | every decidable $X$ under (a2), (b2) | linear size | — | proved (arity 8); arity 2 sketch (scout S) | S Rem 3.11; `terms` T4 |

---

## 12. Notation requests

* **New global symbols used here** (for NOTATION §4): $M_F^{\rm cl}$ and $\nu^{\rm cl}_F$ (closed one-tape labellers; macro `\MFcl`); $K_F^{\rm cl}$, $K_A^{\rm dec}$; $M_A^{{\rm chk},t}$, $M_A^{{\rm gen},t}$ (one-tape penalised SAI, matching §5's $W_A^{{\rm chk},t}$); $M_F^C$, $M_A^C$ (mixtures over machines consistent on every tape); $M_F^{3,\rm cons}$ (one-tape three-valued consistent SOI, beside $W^{3,\rm cons}$); $\mathrm{Ind}_B$ (sentences $B$ decides neither way); the assumption name (S$_{\rm tape}$).
* **Local to this record:** $\mathcal L_{\rm Pr}$, $\mathrm{PrA}$, $D^{\rm Pres}$, $c_{\rm FR}$, $c_B$ (§9); $\mathcal L_{\rm circ}$, $n_i$, $g_j$, $s_N(f)$, $a_\ell(f)$, $W_N$, $\Gamma_N$ (§10); the maps (PS), (EM), (CR), (CL).
* **Clashes found.** (1) N1's lottery uses $W$ as a binary relation symbol, which clashes with the coin-free $W$, $W_A$; NOTATION §6.2 renamed the lottery sentences but not the relation symbol. Suggest $\mathrm{Win}$. (2) P1's $\Omtail{\ell}$ sums over $|p|\ge\ell$; scout S wrote $\Omega_V^{>n}$ for $|p|>n$. This record uses P1's convention ($\Omtail{n+1}$). (3) "SAI" for the family and $M_A$ for the one-tape law: where this record says "SAI loses $O(1)$" it means every listed version.

---

## 13. Checks

| script | what it checks | result |
|---|---|---|
| `checks/c1_onetape_finite.py` → `.out` (seed 20261015; 43 s) | Independent finite analogue (scout S's `s1` not read): 4 atoms, 24 sentences (12 formulas + syntactic negations), 64 tapes, 25 random theory machines, 25 random function machines, all 1153 data sets with $|\dom D|\le2$, two backgrounds. (1), (2) tape-wise inclusions of (PS), (EM); (3a), (3b) the two mixture inequalities of Thm 3.1's proof; (4) Prop 6.1 incl. the new abstention bound; (5a), (5b) closed labellers decide as theories (Cor 3.2); (6) trichotomy identity; (7) Prop 6.8(c) filter | (1), (2): 0 violations in $1{,}844{,}800$ triples each (per background); (3a), (3b): 0 violations; (4): SAI $(1,0,0)$ in 412/412 and 476/476 cases, consistent SOI $P(0)=0$, $P(1)>0$, abstention bound in every case, min $P(\bot)=0.0115$; (5a), (5b): 0 mismatches (732/768 and 867/935 tapes); (6): 0 violations; (7): filter consistent on every tape, equals $F$ on consistent tapes, $\nu_{F'}\ge\nu^{\rm cons}_F$ on all 28825 pairs |
| `checks/c2_independent_label.py` → `.out` (seed 20261015; 1 s) | Finite toy of Props 6.3–6.5: 16 valuations, 64 sentences (32 independent of $B$), 160 random three-valued labellers, lookup and list labellers, theories with images; diagonal $\sigma_n$; one-tape density lemma on 40 random machines | (a) 0 violations; diagonal rows all satisfy $W^{3,\rm cons}\le\Omega^{>n}$, $W_A^3\ge2^{-3}$, $W^{3,\rm cons}\ge2^{-\ell(\text{lookup})}$ until $\mathrm{Ind}$ is exhausted (the finite end of productivity); (d) list labeller keeps its sentences at weight $\ge2^{-5}$; density lemma: 0 violations of (e1), (e2) in 4174 dense prefixes |
| `checks/c3_presburger_constants.py` → `.out` (deterministic) | Thresholds $m_0$ for the contradictions of Props 9.1–9.3 with $q(x)=x^k$, illustrative $c$, $c'$, $C$, $k$; conservative estimates $\log_2(C2^a+m)\le a+\log_2C+1$ | every row has a finite $m_0$; e.g. $c=1$, $c'=0.9$: (A) 11–26, (B) 6–9, (C) 26–42; $c=0.05$, $c'=0.045$: (A) 203–517, (B) 117–172, (C) 517–834 |
| `checks/c4_circuit_axioms.py` → `.out` (seed 20261015; 15 s) | Thm 10.1(i): the translation $T_V$ in the fixed language; truth of every axiom in the intended structure on a finite fragment; $R$ agrees with $f_V$; derivability by forward propagation through ground instances; negative control by gate corruption; sizes up to $s=1099$ | 24/24 circuits pass every check; 95/95 corruptions that change $f_V$ detected; $|T_V|/((s+d)\log_2(s+d))\in[7.86,9.03]$ |

The scripts check constructions on finite analogues; the theorems are asymptotic or logical and are proved in the text.

---

## 14. References and their verification status

* W. Craig, "On axiomatizability within a system", *J. Symbolic Logic* 18 (1953) 30–32. [known; as cited in the AI-paper; bibliographic data checked there]
* S. A. Cook, R. A. Reckhow, "The relative efficiency of propositional proof systems", *J. Symbolic Logic* 44(1) (1979) 36–50. [known; bibliographic data confirmed by the earlier report's referee; used only as the classical form of Thm 8.1]
* M. J. Fischer, M. O. Rabin, "Super-exponential complexity of Presburger arithmetic", *Complexity of Computation*, SIAM-AMS Proceedings 7, AMS 1974, 27–41; MIT LCS TM-43. [known: bibliographic data and abstract checked by scout S and re-confirmed by scout L (`refs.bib`, `fischer1974super`); the exact quantifier form of the theorem (universal $c$, "for all large $m$") **not re-checked in this run**; only the weaker form stated in §9 is used]
* M. Presburger (1929), completeness and decidability of the theory of $(\mathbb N,0,1,+)$. [known, standard; not re-checked in this run]
* L. Berman, "The complexity of logical theories", *Theoretical Computer Science* 11 (1980). [**known, unverified** in this run: recalled statement used only in the conditional Prop 9.3]
* M. Sipser, "A complexity theoretic approach to randomness", STOC 1983; C. Lautemann, "BPP and the polynomial hierarchy", *Inform. Process. Lett.* 17 (1983); P. Gács (attributed in Sipser 1983). [**known, unverified** in this run; used only in the conditional Prop 9.3]
* A. K. Chandra, D. C. Kozen, L. J. Stockmeyer, "Alternation", *J. ACM* 28 (1981). [known, unverified; enters only through SD Cor 4.4 (APSPACE = EXPTIME), as recorded there]
* S. C. Kleene's recursion theorem; the MRDP theorem (Matiyasevich 1970; Davis 1973). [known; as cited in TF Lemma 1.4 and AI-paper Lemma E.14 ("not checked" there)]
* Lebesgue density theorem on Cantor space. [known; N1 Lemma E0 gives a proof for the form used]
* Church's theorem (undecidability of first-order validity). [known, standard; used only to instantiate Prop 6.7(a)]
* Circuit simulation of Turing machines: a time-$T$ machine on inputs of a fixed length has circuits of size $O(T^2)$ (textbook; $O(T\log T)$ by Pippenger–Fischer 1979). [known, unverified in this run; used only for the existence of a polynomial in Thm 10.1(ii)]
* R. J. Solomonoff, "Three kinds of probabilistic induction", *Computer J.* 51(5) (2008) 566–570; "Two kinds of probabilistic induction", *Computer J.* 42(4) (1999) 256–259. [known; read in full for `RENAME.md`; used here only for the name SOI]
* L. A. Levin (1973) universal search; J. Schmidhuber (2002) speed prior. [listed in the brief; not used in a proof here; the AI-paper's Kt penalty (Prop 7.2) is Levin-style and TF notes that its time-weighted variant is not the speed prior]
* P1, P2, the AI-paper and its records TF, SD, model, as in the header.

---

## 15. Status of every claim

| claim | status |
|---|---|
| Lemma 1.2 (decompositions (1.1), (1.2)) | proved |
| Lemma 1.3 (maps PS, EM, CR, CL) | proved |
| Rem 1.4 (only inclusions) | computed (c1) |
| Thm 2.1 (a)–(c) | proved; Craig known |
| Rem 2.1′ (i)–(iii) | proved |
| Prop 2.2 (a)–(d) (Hänni's schema) | as in the AI-paper: (a) proved; (b) proved, schema argument refuted in one sort; (c) proved, given MRDP; (d) proved, given partial truth predicates; proofs re-read |
| Thm 3.1 (a)–(c), including $D=\emptyset$ | proved; computed (c1) |
| Cor 3.2 | proved; computed (c1) |
| (S$_{\rm tape}$) | assumption; justification sketch |
| Thm 3.4, Prop 3.5 | proved, under (S$_{\rm tape}$) |
| Rem 3.6 (one-tape Kt, P3) | not attempted |
| Prop 4.1 | proved, given P1 Thm 3.21(a), Prop 4.6(a) construction |
| Remark after 4.1 ($K(S)$ slack) | proved, given F10 (`fundamentals` T6) |
| Cor 4.2 (a)–(c) | proved, given N1 Thm E1, Prop E2(b) |
| Thm 5.1 | proved |
| Cor 5.2 (a)–(d) | proved, by Thm 5.1 and P1 |
| Prop 5.3 | proved |
| Rem 5.4 | proved |
| §5.5 transfer table | proved for "yes" rows by Thm 5.1; "no" rows are reasons, not theorems |
| Prop 6.1 (a), (b), (d) | proved; computed (c1) |
| Prop 6.1 (c) (abstention bound) | proved; computed (c1) |
| Rem 6.2 | proved; computed (c1) |
| Lemma 6.3′ | proved, given MRDP and the recursion theorem |
| Prop 6.3 (a)–(c) | proved, given Lemma 6.3′; finite mechanism computed (c2) |
| Prop 6.4 (a), (b) | proved |
| Prop 6.5 (a)–(c) | proved, given Lemma 6.3′ and Lebesgue density; density lemma computed (c2) |
| Rem 6.6 | proved |
| Prop 6.7 (a)–(c) | proved |
| lsc-ness of $W_A$ with decidable consistency | open |
| Prop 6.8 (a)–(c) | proved; (c) computed (c1) |
| Prop 6.8 (d) ($M_F^{\rm cons}/M_F^C$ bounded in general?) | open |
| Thm 7.1, Prop 7.2, Thm 7.3, Cor 7.3′, Prop 7.7 | proved, under (S) where stated (TF; re-read) |
| Thm 7.4 | proved, given recursion theorem and MRDP (TF; re-read) |
| Prop 7.5 | proved; "strictly stronger than every time-bounded function inductor" refuted (TF) |
| Prop 7.6 | (a), (b) proved; (c) proof sketch |
| Thm 7.8 (a)–(d) | proved, given Thms 3.1, 7.3, 7.4, AI-paper Prop E.1, P1 Prop 9.4 |
| Thm 8.1, Cor 8.2, Prop 8.3, Rem 8.4 | proved, under (F1), with the conditions stated (AI-paper, TF, SD; re-read) |
| Rem 8.5 | interpretation |
| Rem 8.6 (one-tape sandwich) | proof sketch |
| F$_{\rm P}$, F$_{\rm FR}$ | known (verification levels in §14) |
| Prop 9.1, Prop 9.2 | proved, given F$_{\rm P}$, F$_{\rm FR}$ (and Lebesgue density for 9.2) |
| Prop 9.3 | conditional: proved, given (B*) and (SGL), both known, unverified |
| Prop 9.4 | proved, given F$_{\rm FR}$ and AI-paper Thm 6.9's proof |
| c3 thresholds | computed |
| Thm 10.1 (i) | proved; computed (c4) |
| Thm 10.1 (ii) | proved, given the circuit simulation of Turing machines |
| Cor 10.2 | proved, by P1 Thm 9.8's proof with the stated changes |
| Rem 10.3 | proof sketch |
| §11 table | each row as stated there |

---

## 16. Verification log

**Reading (in full unless stated).** The brief `00-brief.md` of the project and of this thread; `NOTATION-draft.md`; `select.md`; scout S §0–§2, §4–§9 (§3 skimmed: it belongs to `terms`); scout F §1, §2, §3.1–§3.4 (F1–F12); scout N1 §3 (E0–E3) and §8; the AI-paper's `time.tex` and `app-time.tex` (all 471 lines) with printed numbers from `main.aux`; TF §1–§5 (lines 42–648); SD §0, §1, §3 (Thm 3.1, Cor 3.2, Prop 3.4), and the statements of §2, §4–§7 via the AI-paper's appendix, which transcribes them; P1 `setting.tex`, `versions.tex`, `app-versions.tex`, `learn.tex`, `comp.tex`, the proof of Thm 9.8 in `app-comp.tex`, the statements of `examples.tex`, `ood.tex`, `nn.tex`, and the label list of `main.aux`; `RENAME.md` (§1–§3).

**Re-verification of transcribed results.** Read line by line and found correct as stated: AI-paper Thm 6.3 (maps, injectivity, halting of Craig's decider on partial assigners), Props 6.4, 6.5, E.1, E.17, Lemmas E.11, E.12, E.14, Thms 6.14, 6.15, Props E.13, E.15, E.16, E.21, Lemma E.19 (statement and proof outline), Cor 6.17's proofs, Props E.23, E.24, E.26, E.27; TF Thms 2.2, 3.1, 3.2, Cor 3.3, Props 2.3, 3.4, 4.1, 5.1, Thm 4.2, Cor 4.3; SD Thm 3.1, Cor 3.2, Prop 3.4; scout S Thms 2.4, 2.5, 2.7, 2.9, Props 2.6, 2.10, 2.10′, 2.11, 2.12, Rems 2.13–2.15; scout F's F8, F9; N1's E1 and E2 (proofs read; their re-verification belongs to `logic` T1). P1 Props 4.6, 4.5, Rem B.2, Thm 9.8 proofs re-read for the transfers and Cor 10.2.

**Self-checks that changed this record.**
1. *Scout S's Cor 2.8(b).* Its second-run correction restricted the coin bound to two points. P1 Prop 4.6(b) together with Thm 3.21(a) gives the bound for all literal data with the label deficiency added (Prop 5.3), which is P1's Rem 4.12(2). Restated in the general form.
2. *Scout S's Prop 2.12* assumed $B=\Q$. The proof uses only that $B$ is decidable, $\Sigma_1$-sound and contains $\Q$ in its consequences; restated (Lemma 6.3′, Prop 6.3).
3. *Witnesses of Prop 2.12.* Scout S left open whether a computable family of witnesses exists. A list labeller labels any r.e. family of independent sentences $\iota$ at once, so none exists (Prop 6.4).
4. *One-tape Prop 2.12.* A first attempt transferred the coin-free argument directly; it fails because the sentences that a random machine labels $\iota$ on *consistent* tapes need not form an r.e. set. The Lebesgue density decomposition into cylinders on which consistency has density $>1-\varepsilon$ restores r.e. subsets of $\mathrm{Ind}_B$ (Prop 6.5).
5. *Non-lsc of $W_A$.* A first attempt imitated F3(b) (a machine whose programs are inconsistent with probability $\alpha$) in the coin-free setting; it does not separate the inconsistent weight from $\Omega_V$ by a computable amount, so no contradiction follows. Replaced by the support argument (Prop 6.7(a)), which needs consistency of finite sets to be non-r.e.; the decidable case is left open.
6. *Rem 2.14.* Several candidate separations of $M_F^{\rm cons}$ from $M_F^C$ (random windows of $\Pi_1$-hard sentences; random graphs of pairwise inconsistencies) were each matched, up to a few bits, by machine-wise consistent machines told a small count. What was proved instead: the decidable-consistency case (Prop 6.8(c)) and the general bounds. The general question stays open.
7. *Scout S's equality in its toy.* S's `s1` item (1) reported $\mu_G=\nu^{\rm cons}_{T_G}$. Thm 3.1 needs only inclusion, and in c1 the inclusion is often strict (finite-language artefact: all labels fixed before the theory becomes inconsistent). Recorded as Rem 1.4; no equality is claimed.
8. *c1, first version of item (3)*: compared the two mixtures over the union families and reported 8 "violations" of $M_F^{\rm cons}\le2^{2}M_A$. The union family is not closed under the maps (the images of the proof-search labellers were not in the theory family), so the inequality was not what the proof claims. Replaced by the proof's two inequalities against the image families (3a), (3b): 0 violations. The union-family ratio is still printed for information.
9. *c1, first version of item (5)*: compared three-way weights of theories and of closed labellers as mixtures and found differences up to 9.9, again from tapes on which the theory is inconsistent while $F_G$ is closed (artefact of item 7). Replaced by the tape-wise statements of Cor 3.2's proof (5a), (5b): 0 mismatches; the artefact is counted separately. Item (5b) first tested only random labellers, none of which was closed on any tape; the closed labellers $F_G$ were added.
10. *c1 item (4)*: the first bound printed, $P(\bot)\ge2^{-k}/(1+24\cdot2^{-k})$, is not what the proof gives once abstention variants of inconsistent machines are counted; replaced by the proof's statement ($\bot$-mass $\ge2^{-k}\times$ the weight of the base machines extending $D$ consistently).
11. *c2, first version*: all 64 random sentences were independent of $B$ and no random machine had a consistent tape, so the checks were vacuous; redesigned with entailed and refuted sentences and sparser machines whose labels mostly follow a model of $B$.
12. *c3*: the first version overflowed and used a non-conservative estimate of $\log_2(C2^X+m)$; rewritten in log form with the conservative bound $X+\log_2C+1$ and a window up to $m=3000$.
13. *c4*: the first version estimated the material of internal-gate instances; replaced by the exact size of each ground instance.
14. *Prop 9.4* was first planned via Fischer–Rabin's proof-length clause (which scout S could not check: "easily recognised"); AI-paper Thm 6.9's proof gives it from the nondeterministic decision bound alone.
15. *$\Omtail{}$ convention*: an intermediate draft used $\Omtail{n}$ for $|p|>n$; aligned with P1 ($|p|\ge\ell$).
16. *Gadget constant of Cor 10.2*: the prior factor for $k$ contributes $\log_2((2(s+\gamma)+1)/(2s+1))\le\log_2(\gamma+1)$, not $1$; corrected.

**Checks run.** c1 (43 s), c2 (1 s), c3 (under 1 s), c4 (15 s); outputs saved next to the scripts. At the end all four were rerun from scratch; every output was byte-identical to the saved one. c1 was written without reading scout S's `s1_onetape_toy.py`; only S's saved output was read afterwards for the comparison in §3.

**Web verification.** Not possible in this run: the WebSearch budget of the turn was exhausted (shared across agents), and direct access to reference pages (e.g. Wikipedia) is blocked by the proxy. The reference statuses in §14 reflect this: Fischer–Rabin rests on the bibliographic and abstract checks of scouts S and L; Berman 1980 and Sipser–Gács–Lautemann are unverified and enter only the conditional Prop 9.3. A follow-up run should verify (i) the exact form of Fischer–Rabin's theorem (universal constant; "for all large $m$"), (ii) Berman's alternating lower bound and whether it gives (B*), (iii) the time-bounded Sipser–Gács–Lautemann inclusion.

**Not done.** No referee and no proof assistant. Not written out: (S$_{\rm tape}$) for a concrete machine; the one-tape Kt and content-relative penalties; the one-tape charged-deduction sandwich (Rem 8.6); the exception gadget for a prior over all finite axiom sets (Rem 10.3); explicit values of the absolute constants $C_1,C_2$ of Thm 10.1 (they depend on fixed propositional template derivations in $\mathsf K$, of the size of TF's 287-line derivation of $(B\wedge C)\to B$).
