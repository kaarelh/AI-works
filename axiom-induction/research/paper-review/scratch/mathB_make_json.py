"""Writes ../issues-math-B.json (review B). Run from the scratch directory."""
import json, os

I = []
def add(id_, file, loc, sev, problem, evidence, fix):
    I.append(dict(id=id_, file=file, label_or_line=loc, severity=sev, problem=problem, evidence=evidence, fix=fix))

add("MB-01", "paper/sections/universal.tex",
    "l.8 (opening), l.39 (subsection title), l.68 (thm:univ:B title), l.72 ('Not covered'), l.86 ('The effect is bounded'), l.222",
    "fatal",
    "The section states without qualification that instance data 'never favour' forall x phi over sigma_phi, that the B2 effect "
    "'is bounded', and (l.222) that 'the axioms prove forall x phi' does not gain from closed instances. Thm B only covers single "
    "axioms (B1), a background under mu_T, Lone, Lcl (B2), and CUiii (B3). The case of a background with a FIXED common weight under "
    "Lsel - the likelihood the paper recommends as the good version (l.224) - is missing from the 'Not covered' list, although the "
    "source lists it. There the selected laws differ (phi-instance share wc/(1-w+wc) against w), so on closed-instance data from "
    "B(+)_w forall x phi the log odds for the forall-version grow linearly, and in the class {B(+)_w forall x phi, B(+)_w sigma_phi} "
    "P(T |- forall x phi | D_n) -> 1: neither 'never favour', nor 'bounded', nor the prior-share regime holds. This is a claim "
    "stronger than the source.",
    "Universal notes Sec. 4, 'Not covered, or false': 'With fixed weights and a background under L1-sel, the two laws have different "
    "effective weights, and whichever matches the data wins.' The effective weight is derived in the paper's own proof of Prop B2 "
    "(app-universal l.32), valid at fixed w. scratch/mathB_lsel_fixed.py (c=0.3, w=0.5): drift +0.153 nats/datum for the "
    "forall-version on data from B(+)forall (log odds +324.6 at n=2000), -0.171 on data from B(+)sigma.",
    "Qualify l.8/l.39/l.68 ('in the comparisons of Thm B'). Add to 'Not covered' (l.72): 'Lsel with a background and a fixed common "
    "weight: the selected laws differ (effective weight wc/(1-w+wc) against w) and whichever matches the mixture proportion wins at a "
    "linear rate; this signal is not logical.' Change l.86 to 'With learned weights the effect is bounded'. Qualify l.222 and l.224, "
    "or recommend the per-citation Lselc, under which rem:univ:B2cit gives an exact tie at every w.")

add("MB-02", "paper/sections/universal.tex; paper/sections/app-universal.tex",
    "thm:univ:B (B3), universal.tex l.69; proof app-universal l.20 ('the score argument above')",
    "fatal",
    "(B3) asserts the odds bound 'under the scores' in CUiii calculi for all data not containing forall x phi. That is false as "
    "stated. The 'score argument' (proof of thm:univ:odds) covers only single axioms on closed-instance data. With first-order "
    "derivability (def:model:scores, def:sound:tri): (i) single axioms, datum s = not exists x not phi (or forall x (phi and phi)), "
    "s != forall x phi: H_all |- s but I_c(phi) does not, so S_prove(H_sch;D)=0 < S_prove(H_all;D)=1 and the odds become infinite in "
    "favour of the forall-version; (ii) with a background, as prop:univ:sim allows: B={forall x phi -> S0=0}, quantifier-free datum "
    "S0=0. B with forall x phi proves it; B with I_c(phi) does not. S_prove and S_g with g_inf<1 then favour the forall-version.",
    "Countermodel for (ii): N with an extra element e, 0+e=S0 (!= e), S0 != 0: forall x phi fails, so B holds, every closed "
    "instance holds, S0=0 fails (scratch/mathB_models.py). For (i) a model with an extra element where 0+e != e. For "
    "quantifier-free data and single axioms the restricted claim is true: by Herbrand's theorem {forall x phi} |- s iff "
    "I_c(phi) |- s for quantifier-free closed s.",
    "Restrict the score part of (B3) to single axioms and quantifier-free data (cite Herbrand), or to provability |-_C in the calculus. "
    "Keep mu_T and Lmax with backgrounds (prop:univ:sim covers quantifier-free data; quantified data have equal mass from both added "
    "axioms). Say in (B1) that restricting the data to closed instances is what makes the scores part true.")

add("MB-03", "paper/sections/universal.tex; paper/sections/app-universal.tex",
    "prop:univ:hanni, universal.tex l.147 ('The same holds for Snc and Sg'); proof app-universal l.123",
    "major",
    "Read literally, the sentence says that under S_nc (and S_g) the posterior converges to the prior restricted to {T consistent: "
    "T |- I_c(phi)}. That is false. S_nc(T;D) = 1[T u D consistent] (def:model:scores), so by compactness and continuity of "
    "measure the limit is the prior restricted to {T: T u I_c(phi) consistent}. That set also contains theories that do not prove "
    "the instances: the empty theory, and the over-specific {phi(Sz)} of the c2 class, which is true in N and does not prove phi(0). "
    "Under S_g with g=1 on provable data and g_inf in (0,1), theories that fail finitely many instances keep positive limit mass "
    "(if D_+ is a set). The proof only shows that theories proving the data share one factor.",
    "def:model:scores; app-universal l.123 ('all theories proving the data get the same factor'); universal notes Sec. 6.2, which "
    "claims only that the provers' 'mutual odds stay at the prior odds'.",
    "Write: 'Under S_nc the limit is the prior restricted to {T: T u I_c(phi) consistent}; under S_g (g=1 on provable data) theories "
    "failing finitely many instances keep mass g_inf^k. Among theories that prove all instances both keep the prior odds, so the "
    "trichotomy conclusion and the absence of a size principle carry over.'")

add("MB-04", "paper/sections/time.tex", "rem:time:summary (1), l.191; also l.20",
    "major",
    "'Penalties on the time to check or generate axioms (Kt, speed prior) ... change Haenni's equivalence by an additive constant at "
    "most' is marked proved, but Sec. 6 never defines a time-penalised prior. thm:time:equiv is for the untimed 2^-|p| prior. "
    "prop:time:cheap shows only that membership takes polynomial time for fixed f. For a Levin Kt-style penalty (log of running "
    "time), the Craig decider's time includes simulating f, with an f-dependent overhead, and the charge grows with |chi|. "
    "rem:model:priors(iii) itself says a Levin factor changes ln pi by O(ln l(T)). So 'additive constant' holds only for a penalty "
    "that depends on the time class alone.",
    "time.tex l.104-109; app-time l.75 ('in time polynomial in |chi| for fixed f'); model.tex rem:model:priors(iii). The source "
    "(model notes Sec. 6.5, item 1) makes the same claim without a definition.",
    "Define the penalty, e.g. a prior factor h(deg) for deciders with membership time O(n^deg), and prove the constant for it. "
    "Otherwise say: 'do not block the collapse; for Kt-style penalties the change is at most logarithmic in |f| and |chi|'. Mark "
    "that part as a proof sketch.")

add("MB-05", "paper/sections/time.tex", "l.20 and rem:time:summary (2), l.191",
    "major",
    "'Templates block his schema but not the collapse (in arithmetic)' overstates prop:time:collapse. That proposition needs "
    "background PA and covers only Sigma_n-sound assigners on Sigma_n sentences, at cost a|f|+b_n: linear overhead, not the constant "
    "of thm:time:equiv. For merely consistent assigners PA+rho can be inconsistent (l.99). Whether Craig's set is a finite union of "
    "DT templates is open (app-time l.156, problem 15). l.99 states these limits; the introduction and 'The precise statement' drop "
    "them.",
    "time.tex l.89-99 (statement and the paragraph after it); app-time l.156.",
    "Replace with: 'Templates block his schema. In arithmetic over PA, one ground sentence reproduces every Sigma_n-sound assigner on "
    "Sigma_n sentences, at a cost linear in |f|. Whether templates block the constant-overhead equivalence for consistent "
    "assigners is open.'")

add("MB-06", "paper/sections/time.tex", "rem:time:summary (3), l.191",
    "major",
    "'Derivation size in written symbols prices the assigner per datum, between its nondeterministic time (a lower bound for every "
    "theory) and its deterministic time (an upper bound for the collapse constructions)' is inexact in four ways. (a) "
    "thm:time:ntime gives X in NTIME(l^{c_e}), so the lower bound is the c_e-th root of the nondeterministic time, not that time. "
    "(b) It holds only infinitely often, for languages outside the class, and only for theories with polynomial-time membership. "
    "(c) The upper bound covers A^C_f (sketch) and two-sorted A_f (recalled, not checked), but not rho_{f,n} (app-time l.92). "
    "(d) The charges omit the T-dependent constants -ln(Z_T/Z^sigma_T) and log2 Z_T of prop:time:sigma. l.173 states (a) correctly "
    "('a polynomial root'), so the summary contradicts the body.",
    "thm:time:ntime; cor:time:hard; prop:time:sigma(b),(c); app-time l.92; time.tex l.173.",
    "Rewrite: 'Infinitely often, derivation size in written symbols is at least t(m)^{1/c_e}, where t is the nondeterministic time "
    "of the assigner's language, for every theory with polynomial-time membership (thm, cor). A^C_f and two-sorted A_f pay at most "
    "a polynomial of the deterministic time (proof sketch); rho_{f,n} is not bounded here. Lsig charges at least "
    "kappa s(m)/4 - ln(Z_T/Z^sigma_T) nats...'")

add("MB-07", "paper/sections/time.tex; paper/sections/app-time.tex", "rem:time:upper, time.tex l.130; app-time l.92",
    "major",
    "The remark counts rho_{f,n} among the constructions that pay 'at most a polynomial of the assigner's deterministic running time' "
    "('plus the Tarski biconditional for rho_{f,n}'). The appendix says the size of the PA-proof of the Tarski biconditional 'is not "
    "bounded in the notes', and the source does not bound it either. The remark claims more than the sources and contradicts the "
    "appendix.",
    "Model notes Sec. 6.4: 'Template version (Prop 6.5). The same, plus the Tarski biconditional for phi', with no size bound. "
    "app-time l.92.",
    "Write 'for rho_{f,n} add a PA-proof of Tr_n(code(phi)) -> phi, whose size is not bounded here', or give a reference proving a "
    "polynomial bound in |phi| for fixed n.")

add("MB-08", "paper/sections/universal.tex; paper/sections/app-universal.tex",
    "prop:univ:open (d), universal.tex l.168; proof app-universal l.155",
    "major",
    "(d) is stated for any class that contains the guarded H_sch. The proof ('(d) follows from (c), thm:univ:size(2) and "
    "prop:univ:both') covers only the finite class {H_all, H_open, H_sch, H_both} of Tab. c5. prop:univ:both is proved in C_min, "
    "not C_open. In C_open, H_both's per-datum ratio to H_sch is [(1-w)+(1-rho)cw/(1-gc rho)]/[(1-w)+w(1+c)/(1-gc rho)], a "
    "different expression. For countable classes with learned-weight provers, the limit 0 is not proved: thm:univ:omega(a) "
    "needs fixed laws.",
    "Universal notes U11 proof: '(d) follows from (c) and U4(2) for the finitely many hypotheses compared'. The C_open H_both law "
    "follows from the formulas of app-universal l.152-153 with w_open=0.",
    "Restrict (d) to finite classes, or to fixed-weight countable classes, where it follows from thm:univ:omega(a),(c3). Give the "
    "C_open ratio of H_both and its Theta(1/n) decay (the ratio is at most 1 - kappa w near w=0, with kappa > 0).")

add("MB-09", "paper/sections/time.tex", "prop:time:lonesize (Remark, refuted claim), l.140",
    "major",
    "Wrong number. '-ln Pr(tree) <= 12.8 + 12.2k nats' is false for k >= 6. The exact cost is 12.7657 + 12.2061k: per round "
    "-ln(0.1*0.1*(0.2*0.5)^2) - ln(0.1*0.5) = 12.2061, plus -ln(0.2/7) - ln(1e-4) = 12.7657. The paper's own Tab. time:c12 gives "
    "378.95 at k=30, against 12.8 + 12.2*30 = 378.8. Harmless for the argument, which needs only linear growth.",
    "scratch/mathB_time.py: violations at k = 6, 8, 10, 12, 14. The referee's r2_l1_size.out says '<= 12.77 + 12.206 k'.",
    "Write '= 12.77 + 12.21k' or '<= 12.8 + 12.21k'.")

add("MB-10", "paper/sections/universal.tex", "thm:univ:confirm, l.119",
    "minor",
    "The theorem does not state the data-generating assumption: data i.i.d. from P_{T*}, a countable class, a proper prior. "
    "Expectations in (1) and (3) and 'a.s.' in (2) are with respect to P_{T*}. Setting W (def:ident:W) is introduced only in the "
    "next section. Without it, (2) is false (data from a law outside G).",
    "thm:univ:omega states the assumption explicitly (l.132); thm:univ:confirm does not.",
    "Add: 'Assume setting W (def:ident:W), T* in G the generator.'")

add("MB-11", "paper/sections/universal.tex; paper/sections/app-universal.tex",
    "prop:univ:noguard (b), l.184; tab:univ:noguard caption",
    "minor",
    "(b) is proved with Laplace (alpha=1) memorisers via prop:univ:memo(ii'). The table and c8 use Dirichlet(1/2) weights, the "
    "paper's default; alpha=1 appears only as a Part 4 variant. The proved statement and the computed default differ.",
    "app-universal l.183 cites prop:univ:memo(ii'), which is for Laplace weights; tab:univ:noguard caption: 'Dirichlet(1/2) weights'.",
    "Either note that the bound of (ii') holds for alpha=1/2, with the Krichevsky-Trofimov regret O(m_n ln n) in place of "
    "(m_n - 1) ln(n + m_n - 1), or state in (b) that the table uses alpha=1/2 and the proof alpha=1.")

add("MB-12", "paper/sections/time.tex", "rem:time:convention l.53 vs l.74",
    "minor",
    "l.53 says his route through the schema 'works only with two sorts'. l.74 says his argument 'needs standard arithmetic (two "
    "sorts) or a sound f'. For a sound f in one sort, PA u A_f is true in N, so it is consistent. It proves f's labels by "
    "Sigma_1-completeness, so the AI hypothesis is compatible whenever f is. The two lines disagree.",
    "time.tex l.53 and l.74; prop:time:single needs an unsound f.",
    "l.53: 'works with two sorts, or in one sort for sound assigners; prop:time:single shows that it fails for some consistent "
    "unsound ones'.")

add("MB-13", "paper/sections/universal.tex; paper/sections/app-universal.tex",
    "prop:univ:factor l.42; proof app-universal l.14",
    "minor",
    "'m leading quantifiers' should be 'm leading universal quantifiers'. Forall-E fails on an existential, so Z_Hsch = "
    "(1-c) sum_{k<=m} c^k counts universal quantifiers only.",
    "Universal notes U1: 'm is the number of leading forall of phi'.",
    "Write 'm leading universal quantifiers' in both places.")

add("MB-14", "paper/sections/universal.tex", "thm:univ:B (B1), l.69",
    "minor",
    "'(equality under Lcl, Lsel, scores)' omits the conditions under which equality holds. Lsel needs forall x phi not in S; "
    "otherwise H_all's normaliser mu(S) includes 1-c and the ratio is strictly below 1. The scores need forall x phi to be "
    "consistent. tab:univ:odds states both conditions.",
    "tab:univ:odds rows 2-3; app-universal l.18.",
    "Write '(equality under Lcl, under Lsel with forall x phi not in S, and under the scores when forall x phi is consistent)'.")

add("MB-15", "paper/sections/universal.tex", "thm:univ:size, last sentence, l.102",
    "minor",
    "The likelihood under which P_tau(I) <= max(max_f p_f, max_g F(root=g)) holds is not stated. The proof (app-universal l.64) "
    "bounds the citation law. Under Lone in C_min, a template with a formula metavariable also reaches instances through "
    "forall-E (e.g. ?A := forall x phi, then forall-E). Tab. c2 applies the theorem under Lone.",
    "app-universal l.64 (proof uses only theta drawn i.i.d. and unique matching).",
    "Write 'under Lzero/Lcl (the citation law)', or bound the extra forall-E mass under Lone.")

add("MB-16", "paper/sections/universal.tex", "l.122 (after thm:univ:confirm)",
    "minor",
    "The dyadic family's prior over j (proportional to 1/(j(j+1)), total 1-pi_0) is not stated. The value '0.37 at n=1e50' depends "
    "on it.",
    "Recomputed: 0.3716 with that prior (scratch/mathB_cmin.out, with the tail j >= 5000 added).",
    "Add 'with prior (1-pi_0)/(j(j+1)) on j >= 1'.")

add("MB-17", "paper/sections/universal.tex", "l.181 (after prop:univ:rkrate)",
    "minor",
    "'wastes a fixed fraction r_w of the tail's mass': r_w is a ratio, not a fraction. The waste equals r_w times the tail mass, "
    "and r_w = 1/c = 3.33 for Split_k.",
    "lem:univ:waste; app-universal l.227 (r_w = 1/c).",
    "Write 'wastes r_w times the tail's mass'.")

add("MB-18", "paper/sections/time.tex; paper/sections/app-time.tex",
    "prop:time:notemplate l.80; app-time l.62",
    "minor",
    "The proposition is stated and proved for C_f, the Acc part. The conclusion 'templates block his schema' concerns "
    "A_f = C_f u {Rej_f(code(phi)) -> not phi}. A template whose instances mix both parts is not covered by 'the Rej part is "
    "symmetric'. At a skeleton position where Acc_f and Rej_f carry different symbols, Case 1(ii) needs a constant body whose root "
    "differs from both.",
    "app-time l.48-53 offers two constant bodies per type, which is not always enough against two symbols.",
    "State the proposition for A_f and add: 'use a constant body whose root differs from both symbols (0, S0, 0+0, 0*0 for terms; "
    "=, not, and, ... for formulas)'.")

add("MB-19", "paper/sections/time.tex", "l.111",
    "minor",
    "'no theory escapes this' overstates thm:time:ntime, which needs membership decidable in polynomial time O(n^e).",
    "thm:time:ntime hypothesis.",
    "Write 'no theory with polynomial-time membership escapes this'.")

add("MB-20", "paper/sections/time.tex", "rem:time:convention, l.53",
    "minor",
    "'The constant equivalence needs the semimeasure convention' is not shown. Only the given argument needs it; app-time l.27 says "
    "'the argument gives nothing better'.",
    "app-time l.27.",
    "Write 'This argument needs ...' or 'is proved only in ...'.")

add("MB-21", "paper/sections/app-time.tex", "proof of prop:time:codelength, l.131",
    "minor",
    "Notation clash. g (parameter-chain continuation probability) and rho (branching rate) reuse the symbols of C_open's Gen "
    "probability g and parameter probability rho in Sec. 3 and prop:univ:rk.",
    "app-time l.131 vs universal.tex l.14, l.17.",
    "Rename, e.g. g_par and rho_br.")

add("MB-22", "paper/sections/universal.tex", "l.224 ('A good version for this case')",
    "minor",
    "'On closed instances it accepts forall x phi only if the prior share of provers ... is >= 1-delta' holds only in the limit. At "
    "finite n the posterior can exceed its limit.",
    "thm:univ:omega(b),(e) give limits only. Finite-n control is cor:univ:sound, under well-specification.",
    "Write 'eventually accepts forall x phi iff the limiting prior share is > 1-delta', and cite cor:univ:sound for finite n.")

add("MB-23", "paper/sections/universal.tex", "l.17",
    "minor",
    "'S_nc,beta is beta^n S_g with g_inf = 1/beta', but def:model:scores requires g_inf in [0,1). beta = 1 (S_nc itself) gives "
    "g_inf = 1.",
    "def:model:scores.",
    "Write 'for beta > 1'; S_nc is the case beta = 1.")

add("MB-24", "paper/sections/universal.tex", "thm:univ:B proof idea, l.72",
    "minor",
    "'The mechanism is the size principle' fits Lone but not mu_T. Under the unnormalised mu_T the factor c is the probability of "
    "the extra forall-E step, not a normalisation effect.",
    "prop:univ:factor; tab:univ:odds row mu_T.",
    "Write 'the extra elimination step (factor c) and, for normalised likelihoods, the size principle'.")

add("MB-25", "paper/sections/universal.tex", "thm:univ:omega (e), l.138",
    "minor",
    "The pair law P_T(s)1[s in S]/P_T(S) is undefined when P_T(S)=0, e.g. for S the closed instances with S-rooted argument and a "
    "theory emitting no such sentence.",
    "Definition in (e).",
    "Restrict F to filters with P_T(S) > 0 for all T, or give such pairs likelihood 0.")

add("MB-26", "paper/sections/universal.tex; paper/sections/app-time.tex", "universal.tex l.234-235; app-time l.154-155",
    "minor",
    "Overfull hboxes: 4.4pt in universal.tex l.234-235 and 0.7pt in app-time l.154-155.",
    "paper/main.log.",
    "Rephrase or allow hyphenation.")

out = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'issues-math-B.json')
with open(out, 'w') as f:
    json.dump(I, f, indent=1, ensure_ascii=False)
print(len(I), 'issues written to', os.path.normpath(out))
from collections import Counter
print(Counter(i['severity'] for i in I))
