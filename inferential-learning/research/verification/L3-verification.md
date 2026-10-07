# Verification record: L3-learning-to-reason-and-limit-inquiry.md

Target file: `../lit/L3-learning-to-reason-and-limit-inquiry.md`. Project context: `../00-brief.md`.

This record holds two things:
1. A faithful copy of the independent adversarial referee report, rendered from JSON to Markdown with the content unchanged.
2. The author-repairer's verification log. For each reported issue it says whether the issue is genuine and what action was taken.

The same log is appended to the theory file as `## Verification log`.

---

## Part 1. Referee report

### Referee (Lemma A, Prop C, Thms D/D′/G, Lemmas E′/K, Prop H, Cor F, §4.5)

**Items checked.**
* Lemma A (i)-(iii), commitment-order lemma (lines 146-163), and its corollaries/glosses: Bottom line #2, Upshot, Sec.8 L3-T1, Sec.9 #2
* Prop C (i)-(iii) (lines 200-217); re-ran lit/L3-scripts/axiom_induction_coherence.py; extra randomized check
* Theorem D (lines 227-238), Sawin-Demski-style trilemma
* Theorem D' (lines 248-250), including the claim that incoherent credences gradually verify Pi3
* Theorem G success table and proof sketch (lines 427-445)
* Thm G 'Credences' remark (line 447) and Sec.8 L3-T2 headline 'ceiling Pi3 -> Delta2'
* Lemma K (lines 449-454)
* Prop H (lines 457-461)
* Lemma E' (lines 340-347), plus its use in Sec.0 #5 and Sec.9 #7
* Corollary F (lines 367-371) and its dependence on affine provability induction (Sec.4.2 line 294)
* Sec.4.5 'Detection of invalid rules' claims that back Cor F's gloss and Sec.0 #6

**Issues.**

#### R1. Thm G 'Credences' remark (line 447) and Sec.8 L3-T2 headline ('Coherence lowers the truth-tracking ceiling from Pi3 (incoherent) to Delta2 with dogmatic Pi2 errors'); also Sec.0 #3 and Sec.9 #4 restate it — severity: fatal
* *Description.* The memo says 'Row (f) is achievable only incoherently: Theorem D forbids it for weakly coherent credences. The coherent row is (g)', and L3-T2 says the coherent ceiling is Delta2. Both are false as stated for the memo's own notion of weak coherence. Theorem D only rules out row (f) on classes that contain Pi1 and all of Pi2, i.e. the Pi2 and Pi3 columns. Weakly coherent computable credences can gradually verify the Sigma1, Pi1 and B(Sigma1) columns. They can also gradually verify the Sigma2 column, and Th_Sigma2 is Sigma2-complete, so it is not Delta2. Theorem D itself and D' as literally stated in Sec.3.4 are unaffected. Only this derived 'ceiling' claim is wrong.
* *Evidence.* Counterexample for the Sigma2 column, satisfying Pi1-convergence and weak coherence as defined in Thm D. For sigma = Ex Ay R(x,y), let x_t(sigma) be the least x<=t with no counterexample y<=t. Let a_t(sigma) = t - max(index(sigma), last stage at which x_t(sigma) changed). Let I_t be the set of pairs (sigma,sigma') of Sigma2 sentences with index<=t that have a PA-proof of ~(sigma & sigma') with code <=t. Define P_t(sigma) = min(1-2^-a(sigma), min{2^-a(sigma') : (sigma,sigma') in I_t, a(sigma')>=a(sigma)}), and P_t = 0 on all non-Sigma2 sentences. (1) Stagewise, every pair in I_t has sum <=1: if a(s)<=a(s') then P(s)<=2^-a(s') and P(s')<=1-2^-a(s'). Every PA-incompatible pair enters I_t eventually, so weak coherence holds. (2) A false sigma changes witness infinitely often, so P_t(sigma)=0 infinitely often. (3) For a true sigma that stabilizes at T0, the competitors with index > T0 have age < t-T0. The finitely many competitors with index <= T0 are false, by soundness of PA, so each changes after T0 and then stays younger. Hence P_t(sigma) -> 1. An abstract simulation (scratchpad sigma2_weakcoh.py; 60 sentences, adversarial long stable runs for false ones) found 0 pairwise violations, all true sentences at credence ~1, and all false ones hitting 0. For Pi1, B(Sigma1): put the limit-decider value on the class and 0 elsewhere. Limits are truth values and PA is sound, so weak coherence holds. The Pi3 entry of row (f) also needs credences that oscillate. If lim_t P_t(phi) exists for every phi in C, then {phi : lim = 1} = {phi : AqAsEt>=s P_t(phi) > 1-q} is Pi2. So any convergent credences, coherent or not, have a Pi2 ceiling. The 'Pi3 -> Delta2' comparison therefore mixes the cost of convergence with the cost of coherence.
* *Suggested fix.* Replace line 447 and L3-T2 with correct statements. (a) Weak coherence plus computability forbids row (f) exactly on classes containing Pi1 and all of Pi2 (the Pi2 and Pi3 columns). The Sigma2 column remains achievable, by the construction above. (b) Among convergent credences: incoherent ones gradually verify Pi2 (G(f)'s Pi2 construction converges), and weakly coherent ones cannot (Thm D). (c) With full limit coherence and existing limits, Sigma2 is also excluded, because {phi : P_inf(phi)<1} = {phi : P_inf(~phi)>0} is Sigma2. Whether the coherent ceiling is exactly Delta2 is unproven. For example, Pi2-complete subclasses such as {'W_e is infinite'} are not ruled out. Either state that as open or drop the 'Delta2' slogan.

#### R2. Theorem D (Sawin-Demski-style trilemma) — severity: ok
* *Description.* Statement precise and proof correct line by line. Step 1: a false Pi2 sentence has a true Pi1 refuter pi = Ay ~R(x0,y), and limsup P(phi) <= 1 - lim P(pi) = 0. Step 2: S = {liminf>0} = {EqEsAt>=s P_t>=q} is Sigma2 because P_t is computable. Step 4: Th_Pi2 is Pi2-complete, so it is not Sigma2. Step 5: finite variants of Sigma2 sets are still Sigma2. The hypotheses are non-vacuous: Popperian Pi1 credences with 0 elsewhere satisfy them. One ambiguity: the weak-coherence clause uses the letter pi. The proof only uses Pi1 pi, so restricting pi to Pi1 gives a stronger theorem.
* *Evidence.* Checked each step. Hypotheses are satisfied, for example, by P_t(phi) = [phi is Pi1 and has no counterexample <= t] and P_t = 0 otherwise. The conclusion is liminf = 0, not lim = 0, which is correctly stated as 'if limits exist'.
* *Suggested fix.* Optionally state that pi ranges over Pi1 in the weak-coherence clause. That is all the proof needs, and it makes the theorem stronger.

#### R3. Theorem D' (coherence has a truth-tracking cost; incoherent credences gradually verify Pi2 and Pi3) — severity: minor
* *Description.* Correct as literally stated. G(f)'s constructions do gradually verify Pi2 and Pi3, and by D no computable weakly coherent credences converge to 1 on all true Pi2 sentences. Four gaps. (i) 'By Theorem D' needs Pi1-convergence. That follows only under the convention Pi1 is a subset of Pi2. Under strict prenex syntax, redo step 1 of D with pi' = Ay Ez ~R(x0,y) (vacuous z). (ii) The Pi3 credences cannot converge on all false sentences: with limits, the success set is Pi2. So 'Pi3' is bought by oscillation, and the 'cost of coherence' is cleanly Pi2 (convergent incoherent) versus 'not Pi2' (weakly coherent). (iii) Sec.3.4 says 'The Popperian learner of T2 Thm 3.10(c) keeps Pi1-convergence, and is therefore dogmatically wrong somewhere in Pi2'. T2's learner outputs 0/1 only on Sigma1 and Pi1 sentences. D applies only to a weakly coherent credence extension of it to all sentences. (iv) Sec.7 Q4 says 'credence 0'. D gives liminf 0.
* *Evidence.* Gradual verification for Pi3: the credence is 1-2^-j_t, where j_t is the least k<=t with V_k(t)=0. True: every V_k eventually stays at 1, so j_t -> infinity. False: some V_k0 outputs 0 infinitely often, so the credence is <= 1-2^-k0 infinitely often. Verified. With limits existing, {lim=1} = {AqAsEt>=s P_t>1-q} is Pi2, and Th_Pi3 is not Pi2.
* *Suggested fix.* Add the remark on the syntactic convention. State that the Pi3 credences do not converge on false sentences, and compare convergent with convergent. Reword the Popperian sentence as 'any weakly coherent credence extension of the Popperian learner is ...'. Change 'credence 0' to 'liminf credence 0' in Sec.7 Q4.

#### R4. Theorem G (success table) and proof sketch — severity: ok
* *Description.* All entries verified. Necessity: success sets have the stated arithmetical complexity, and Post's theorem gives the 'no' entries; for B(Sigma1) in row (b), a c.e. Th_B(Sigma1) would make Th_Pi1 c.e. Sufficiency constructions work: for B(Sigma1), at most k mind changes; for (d), the 'least unrefuted x' verifier; for (e), refutation through a stalled witnessed prefix; for (f), as above. The results are standard (Kelly 1996, Shoenfield), as the memo says. Small gaps: x_t is undefined in (d) when every x <= t is refuted (set it to t+1 so that it 'changes'), and j_t is undefined in (f) when no k <= t outputs 0 (set it to t+1).
* *Evidence.* (d), Sigma2 Ex Ay R. True: the least true witness x* is eventually x_t forever, so the output is eventually always 1. False: every x is refuted eventually, so x_t changes infinitely often and the output is 0 infinitely often. (e) Pi2 Ax Ey R: k(t) is nondecreasing and bounded iff the sentence is false.
* *Suggested fix.* Define the undefined cases explicitly. Label it a 'proof sketch of standard results' rather than 'proved here'.

#### R5. Lemma A (commitment-order lemma) and corollaries — severity: minor
* *Description.* (i), (ii) and (iii) are correct as stated. Five overstatements or gaps. (1) Sec.0 #2 says 'survives ... iff the randomness is drawn after the rules are fixed', and L3-T1 says 'exactly when the world is random and the rules fixed first'. The lemma proves sufficiency plus one failing regime. (iii) itself is a sound regime with a fixed world, so 'exactly when' is not established. (2) (ii) only treats eps>0. With eps=0, a schema can still have false instances off the support of the instance distribution, which is the same failure. (3) (i) needs validity in the per-scene universal form (all instances hold in x). Many PAC guarantees are per random (scene, instance) pair, and an adversary choosing the instance within a scene is then in regime (ii). (4) The truth-preservation induction needs rules stated at sequent level, with 'holds in x' meaning the sequent is true in x. Plain 'premises true => conclusion true' fails for rules that discharge assumptions or introduce eigenvariables, which matters for the project's contexts and reductio. (5) In (iii), 'uniformly over adaptive provers' needs the verifier to enforce the degree bound d. A prover writing x^(2^k) compactly defeats d/|S|. The polynomial must be nonzero over the field actually used: (a+b)^p - a^p - b^p vanishes over F_p. N must be fixed in advance; a time-uniform version needs |S_k| growing.
* *Evidence.* The proof of (i) is the union bound on the event {all rho_i hold in x}. On that event, induction on derivations preserves truth. The bound correctly sums over the whole library, not over the rules used. (iii) follows from Schwartz-Zippel plus a union bound and holds for fixed N and degree <= d.
* *Suggested fix.* Weaken 'iff/exactly when' to 'sufficient, and fails in the fixed-world/prover-chosen-instance regime'. Define validity per scene and rules at sequent level. Add the degree-bound, field and fixed-N conditions to (iii).

#### R6. Prop C (axiom induction as Dempster-Shafer pair; script re-run) — severity: minor
* *Description.* (i), (ii) and (iii) are correct, and the script reproduces both counterexamples. The renormalized read-out gives P(p)=1, P(q)=1/2, P(p&q)=0, and half-splitting gives P(p)=P(p&q)=P(p&~q)=1/2. The implicit assumptions should be stated. (a) mu must be a normalized probability. A Solomonoff-style semimeasure gives Bel(T)<1. (b) Every A must be consistent. An inconsistent A gives the empty focal set and Bel(bottom)>0, an unnormalized belief function. In arithmetic, consistency of A is Pi1, so a computable scheme cannot enforce it. (c) Either A includes the data, or lambda_A must live on completions of A plus the data. (d) 'Essentially Demski 2012 conditioned on the data' is loose. The mixture sum_A mu(A) lambda_A is not in general equal to the Demski prior conditioned on the data, nor to the Demski process started from the data.
* *Evidence.* Re-ran axiom_induction_coherence.py: R1 and R2 are incoherent in the stated examples, R3 is coherent, and Bel<=R3<=Pl holds. A randomized check over 400 random hypothesis sets on 3 atoms with random lambda_A (scratchpad propC_rand.py) found 0 violations of Bel<=P<=Pl and 0 negative Moebius masses. R1 was coherent in only 41/400 cases and R2 in 33/400. With an inconsistent A of weight 1/2, Bel(bottom)=1/2.
* *Suggested fix.* Add the hypotheses 'mu a probability on countably many consistent A (each including the data)'. Replace 'essentially Demski 2012 conditioned on the data' with 'a mu-mixture of Demski-type priors, one per hypothesis'.

#### R7. Lemma E' (coherentizing improves Brier iff constraints are sound) — severity: minor
* *Description.* The math is correct. The projection inequality gives ||x-w||^2 >= ||x-x*||^2 + ||x*-w||^2 > ||x*-w||^2 for every w in K and x not in K. The unsound example is right: Brier goes from 0.01 to 1. The converse also holds, though it is not stated: if the actual world is outside W, take x = its indicator, and projection strictly hurts. So 'guaranteed improvement iff sound' is true. Two issues. (a) 'Improves by at least the squared incoherence' uses Euclidean distance to K, not the Arb of Prop E. (b) Accuracy dominance holds only for the Euclidean (Bregman) projection, not for an arbitrary move to zero arbitrage. Sec.9 #7 says 'the arbitrage form ... has the accuracy-dominance property', which is false as stated. The result is standard (de Finetti, Joyce 1998, Predd et al. 2009), which the memo acknowledges.
* *Evidence.* Numeric check (scratchpad proj_check.py, 300 random W, x, SLSQP projection): the only 'violation' was -1.2e-7, which is solver tolerance. Counterexample for Sec.9 #7: S={phi,~phi}, x=(0.6,0.6), Arb=0.2. Moving to the coherent point (1,0) gives Brier 2.0 in world (0,1), against 0.52 before.
* *Suggested fix.* Say 'squared Euclidean distance to K'. In Sec.9 #7, say that the dominance property belongs to the Euclidean projection for Brier, or the Bregman projection for other proper scores, not to arbitrary arbitrage-minimizing corrections.

#### R8. Corollary F (rule traders; dependence on affine provability induction) — severity: ok
* *Description.* Correct given Garrabrant et al. 2016, Theorem 4.5.4 (Affine Provability Induction): if A is a bounded combination sequence (BCS(P)) and W(A_n) >= b for all consistent worlds W and all n, then P_n(A_n) >~_n b. A web search confirmed the theorem number and the form with a constant b; the full text was not reachable. A_n = phi_n - gamma_n has constant coefficients and ||A_n||_1 = 2, and it is e.c., hence P-generable. Every completion of Gamma satisfies W(phi_n) >= W(gamma_n). So liminf(P_n(phi_n) - P_n(gamma_n)) >= 0. The paraphrase in Sec.4.2 ('Gamma proves A_n >= b_n', with a sequence b_n) is slightly off: an affine inequality is not a sentence, and the theorem has a constant b. This is harmless here since b=0. Cor F is per-sequence. Uniformity over the poly(n) instances a trader checks per day needs P-generable weights, which BCS allows. 'Valid' means Gamma-provable instances, not merely true ones.
* *Evidence.* WebSearch snippet: 'Theorem 4.5.4 (Affine Provability Induction) ... if A in BCS(P) and b in R, and for all consistent worlds W and all n, W(A_n) >= b, then P_n(A_n) >~_n b'; Definition 4.5.3 BCS = P-generable R-combination sequences with ||A_n||_1 bounded.
* *Suggested fix.* Cite Thm 4.5.4 explicitly with the constant b and the BCS/consistent-worlds hypothesis. Replace 'valid' with 'Gamma-provable instances'.

#### R9. Sec.4.5 'Detection of invalid rules' (claims surrounding Cor F; Sec.0 #6 'it punishes rules whose failures are efficiently settled') — severity: minor
* *Description.* Four problems. (1) Reversed inequality: if the conclusions are true with frequency 1-p, then P(phi_n) -> 1-p. A threshold 1-delta never certifies them iff 1-delta > 1-p, i.e. delta < p. The memo writes '1-delta < 1-p'. (2) 'T_r realizes losses on each settled instance until its budget is exhausted' is unproven and doubtful. Once provability induction makes P(gamma_n) ~ 1 and P(phi_n) ~ 0, T_r's per-instance loss is P_n(phi_n) + (1 - P_n(gamma_n)), which goes to 0 and may be summable, so bankruptcy is not guaranteed. Sec.8 lists this as conjecture L3-T6(b), but Sec.0 #6 states it as fact. (3) The threshold trading rule 'buy phi when P(phi) < P(gamma) - eps' is discontinuous in prices, so it is not an LI trader; a continuous ramp is needed. (4) 'Never settled: Sigma1-unsound or Pi2-unsound rules' overgeneralizes. Many false Sigma1 or Pi2 conclusions are refutable in the trusted base B and so are settled. Only failures not refutable in B are invisible, for example ~Con(PA) when D = PA.
* *Evidence.* Loss accounting: buying 1 share of a refuted phi_n at price p costs p, and selling a proved gamma_n at price q costs 1-q. Provability induction gives p, 1-q -> 0, with no rate. Example of a settled Sigma1 failure: 'Ex (x+1=0)' is refuted by Q.
* *Suggested fix.* Fix the inequality to delta < p. Mark bankruptcy as conjecture in Sec.0 #6 too, or prove a bound in terms of the convergence rates. Use continuous trading features. Restrict 'invisible' to failures that B does not refute.

#### R10. Lemma K (no computable modulus) — severity: ok
* *Description.* Correct and immediate: output M(phi, tau(phi)). The fact is standard folklore (a computable modulus makes a limit computation computable), so 'proved here' is fine but not novel.
* *Evidence.* If tau bounds the stage of the last mind change, M(phi, tau(phi)) equals the limit, so Th intersected with C is decidable.
* *Suggested fix.* Optionally mark it [std].

#### R11. Prop H (oracle feedback reaches Delta_{n+2}) — severity: ok
* *Description.* Correct. Th_Sigma_n is Sigma_n-complete, hence Turing-equivalent to 0^(n) for n>=1. Relativized Shoenfield says limit-computable in X iff <=_T X'. And <=_T 0^(n+1) is the same as Delta_{n+2} (Post). The example 'a Sigma1 oracle limit-decides B(Sigma2)' is correct. The result needs genuine query access to both truths and falsehoods: a computable positive-only stream of Sigma_n truths adds nothing. One gloss is misleading: 'a trusted community that settles Sigma1 questions, which in effect means trusting stronger theories'. Any r.e. stronger theory is computable feedback, so by Prop H itself it adds no limit power, only speed. Only settling all Sigma1 questions (a 0' oracle), which no consistent r.e. theory does, adds power.
* *Evidence.* With X = 0^(n), sets limit-computable in X are exactly those <=_T 0^(n+1), which is Delta_{n+2}.
* *Suggested fix.* State that the world must answer arbitrary queries. Replace 'which in effect means trusting stronger theories' with 'which no r.e. theory provides; stronger r.e. theories add speed (Godel speed-up), not limit power'.

**Overall assessment (verbatim).**

All the core claims in scope survive, and one derived claim is false. Lemma A, Prop C, Theorem D, Theorem D' as literally stated, Lemma E', Cor F, the Theorem G table, Lemma K and Prop H are correct. Cor F holds given Garrabrant et al. Thm 4.5.4 (Affine Provability Induction, constant b), whose form I confirmed. The Prop C script re-runs and matches the stated counterexamples, and a randomized check confirms Bel <= P <= Pl.

The false claim is the remark after Theorem G (line 447), echoed in the Sec.8 L3-T2 headline. It says row (f), gradual verification, is achievable only incoherently and that the coherent ceiling is Delta2. Theorem D does not support this. A concrete computable construction that satisfies Pi1-convergence and the memo's weak coherence gradually verifies all of Sigma2 (simulated, 0 violations). Weakly coherent credences also handle Sigma1, Pi1 and B(Sigma1). The Pi3 result requires credences that oscillate. Any convergent credences, coherent or not, can only gradually verify Pi2 sets. So the fair statement of D' is: convergent incoherent credences reach Pi2, and weakly coherent ones cannot.

Minor issues:
* A reversed inequality in the Sec.4.5 pseudorandom-failure remark: the condition should be delta < p.
* Rule-trader bankruptcy is asserted as fact in Sec.0 #6 but is unproven and doubtful.
* Overstatements: 'iff/exactly when' in Lemma A; 'arbitrage has accuracy dominance' in Sec.9 #7; 'trusting stronger theories' in the Prop H gloss.
* Unstated assumptions in Prop C: mu normalized, every A consistent, data included in A.

Checks I ran (scripts in /tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/):
* lit/L3-scripts/axiom_induction_coherence.py (re-run)
* sigma2_weakcoh.py
* proj_check.py
* propC_rand.py

*(Rendering note: the issue labels R1–R11 were added for cross-reference; they follow the order of the JSON report. Line numbers refer to the file before revision.)*

---

## Part 2. Author-repairer's verification log

The issue numbers R1–R11 are the Part 1 headings. The text below is identical to the `## Verification log` section appended to `../lit/L3-learning-to-reason-and-limit-inquiry.md`.

One independent adversarial referee checked:
* Lemma A, Prop C, Theorems D and D′, the Theorem G table and the remark after it, Lemma K, Prop H, Lemma E′ and Corollary F;
* the §4.5 claims about detecting invalid rules;
* the glosses in §0, §7, §8 and §9 that restate these.

The full report is in `../verification/L3-verification.md`.

How I checked:
* I re-checked every issue by hand.
* I re-ran `L3-scripts/axiom_induction_coherence.py` and got the same output.
* I wrote an independent simulation of the referee's Σ₂ construction, `L3-scripts/sigma2_weak_coherence.py`, and ran it on 4 seeds plus one long-horizon re-run. It found 0 pairwise coherence violations, and every false sentence is at 0 at each of its change stages. Every true sentence that was still below 1 at T = 2500 was blocked only by a false competitor whose next change had not yet occurred, and it reached 1 by T = 9000 on the same instance.
* I checked the Lemma E′ counterexample and the §4.5 threshold numerically.
* I confirmed the statement of LI Thm 4.5.4 against a search-result snippet; the full text was not reachable.

Numbering is unchanged. Materially changed items are marked "(revised after verification)".

**Fatal issue (genuine, fixed by retraction and replacement).**

| # | item | verdict | action |
|---|---|---|---|
| R1 | Remark "Credences" after Thm G ("row (f) achievable only incoherently; coherent row is (g)"); L3-T2 headline "ceiling Π₃ → Δ₂"; §0 #3; §9 #4 | **Genuine.** Thm D rules out row (f) only on classes that contain Π₁ and all of Π₂. The referee's construction, which I checked line by line, gives computable credences that are weakly coherent for *all* PA-incompatible pairs and Π₁-convergent, and that gradually verify the Σ₂ column. Th_Σ₂ is not Δ₂. Weakly coherent credences also trivially handle Σ₁, Π₁ and B(Σ₁). Separately, if limits exist then the row (f) success set is Π₂ (∀q∀s∃t≥s P_t > 1−q). So the Π₃ result needs credences that do not converge, and the Π₃-versus-Δ₂ comparison mixed the cost of convergence with the cost of coherence. | **Retracted** the remark and the slogan. **Thm D′ revised** into parts (a)–(d) plus an Open item. (a) Incoherent credences reach Π₂ convergently and Π₃ only non-convergently. (b) Weak coherence excludes the Π₂ and Π₃ columns, generalized via a new Remark after Thm D to any decidable C ⊆ Π₂ whose truths are not Σ₂. (c) Weak coherence leaves Σ₁, Π₁, B(Σ₁) and Σ₂, with the Σ₂ construction and full proof included. (d) Convergent credences have a Π₂ ceiling, coherent or not. Open: the exact class that weakly coherent credences can gradually verify. The referee's example {"W_e infinite"} *is* excluded for Π₁-convergent credences by the new Remark, and is open otherwise. Rewrote the "Credences" remark, §0 #3, §7 Q1, L3-T2 and §9 #4. Added the script. |

**Issues rated "ok" with optional fixes (applied).**

| # | item | verdict | action |
|---|---|---|---|
| R2 | Thm D | Correct. The proof uses weak coherence only with Π₁ π. | Hypothesis restricted to Π₁ π, which makes the theorem stronger. Added the convention that quantifier blocks may be empty (Π₁ ⊆ Σ₂ ∩ Π₂), with the strict-prenex alternative ∀y∃z θ. |
| R4 | Thm G table and proof sketch | Correct. Two undefined cases. | Set x_t := t+1 in (d) when every x ≤ t is refuted, and j_t := t+1 in (f) when no V_k outputs 0. Added the true/false argument for (f) and noted that the Π₂ credences converge. Label changed to "[std … proof sketch of standard results here]". |
| R8 | Cor F | Correct, given LI Thm 4.5.4. I confirmed the form from a search snippet: A ∈ BCS(P̄), constant b, W(A_n) ≥ b for all W ∈ PC(Γ). | §4.2 bullet restated with the theorem number, BCS, the constant b and PC(Γ). The old "Γ proves A_n ≥ b_n" paraphrase is flagged as loose. Cor F now cites Thm 4.5.4 and gives the proof via ‖A_n‖₁ = 2, P̄-generability and b = 0. "Valid" is replaced by "Γ-provable instances". Added a per-sequence scope note. |
| R10 | Lemma K | Correct; standard folklore. | Labelled "[std folklore; one-line proof here]". "Bounds its convergence time" is made precise as "bounds the stage of its last mind change". |
| R11 | Prop H | Correct. Its gloss was misleading. | The statement now requires *arbitrary* queries, answered true or false, and a caveat says a computable positive-only stream adds nothing. The proof adds "≤_T ∅^(n+1) = Δₙ₊₂ (Post)". Replaced "which in effect means trusting stronger theories" with "no consistent r.e. theory provides this; stronger r.e. theories add speed, not limit power". |

**Minor issues (all genuine, all fixed).**

| # | item | verdict | action |
|---|---|---|---|
| R3 | Thm D′ (old) | Genuine on all four points. (i) It needs Π₁ ⊆ Π₂ or the vacuous-quantifier trick. (ii) The Π₃ credences do not converge, so convergent should be compared with convergent. (iii) T2 Thm 3.10(c)'s learner outputs only on Σ₁ ∪ Π₁; I checked T2. (iv) Q4 said "credence 0" where D gives liminf 0. | (i) Convention added (R2). (ii) Handled in the revised D′(a), (d). (iii) Reworded to "any weakly coherent credence extension of it to all sentences", with an explicit example of such an extension. (iv) Q4 and §0 #3 now say "liminf credence 0 (limit 0 if limits exist)" and "weakly coherent". |
| R5 | Lemma A and its glosses (§0 #2, L3-T1, Upshot, §9 #2) | Genuine on all five points. | (1) "iff"/"exactly when" weakened to a sufficient condition plus the failing regime, noting the fresh-randomness regime (iii). The Upshot's and §9 #2's "only" were also softened. (2) (ii) now covers ε = 0 with false instances off the support. (3) (i) states per-scene validity, with a note that per-(scene, instance) PAC guarantees do not supply it. (4) Rules are stated at sequent level, with truth of a sequent under all assignments, which covers discharge and eigenvariables. (5) (iii) now requires a verifier-enforced degree bound, a polynomial nonzero over the field used (freshman's-dream example over 𝔽_p), N fixed in advance, and |S_k| ≥ d·2^k/δ for the unbounded case. |
| R6 | Prop C | Genuine. The assumptions were unstated and "essentially Demski conditioned on the data" was loose. | Added standing hypotheses: μ normalized, each A consistent and containing the data, with the reasons (semimeasure gives Bel(⊤) < 1; inconsistent A gives Bel(⊥) > 0; consistency is Π₁ in arithmetic). The Demski phrase is replaced by "μ-mixture of Demski-type priors, one per hypothesis; need not equal Demski's prior conditioned on the data". Same change in §0 #8 and L3-T5. The script output is unchanged. |
| R7 | Lemma E′ and §9 #7 | Genuine. (a) The bound is the squared *Euclidean distance to K*, not Arb. (b) Dominance belongs to the projection, not to arbitrary arbitrage removal. Checked: x = (0.6, 0.6), Arb = 0.2; moving to (1,0) gives Brier 2.0 in world (0,1), versus 0.52 before and 0.5 for the projection. | (a) Wording fixed. (b) A scope paragraph with the counterexample was added, and §9 #7 and §0 #5 were fixed. Also **added the converse**, which I proved: if the actual world is outside 𝒲, its indicator v ∉ K (0/1 vectors are extreme points of the cube), and projecting x = v strictly hurts. So "projection never hurts in the actual world" holds iff the constraints are sound. |
| R9 | §4.5 "Detection of invalid rules"; §0 #6; L3-T6(b) | Genuine on all four points. | (1) The inequality is corrected to δ < p. (2) The bankruptcy claim is withdrawn. The text now says that prices reveal the violation (P(γ_n) − P(φ_n) → 1), while bankruptcy is conjecture L3-T6(b), because per-instance losses → 0 and may be summable. §0 #6 now matches. (3) Threshold trades are replaced by the continuous ramp h(u) = min{1, max{0, u/ε − 1}}. (4) "Invisible" is restricted to failures that B does not refute, with the example ∃x (x+1=0), which is refutable in Q. "T_r never loses" is changed to "need not lose". |

**Items whose statement or proof changed non-trivially (to re-verify):**
* Thm D′, including the new Σ₂ construction and its proof.
* The "Credences" remark after Thm G.
* L3-T2, and the glosses that restate it (§0 #3, §7 Q1/Q4, §9 #4).
* Thm D: Π₁-premise hypothesis, the convention, and the Remark that "the proof gives more".
* Lemma A: the sequent-level and per-scene hypotheses, and the (iii) conditions.
* Lemma E′: the converse and the scope.
* The §4.5 detection claims and the trading rule.
* Cor F: the precise citation.
