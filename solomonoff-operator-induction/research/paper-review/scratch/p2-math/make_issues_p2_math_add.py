#!/usr/bin/env python3
"""Second-pass additions to research/paper-review/p2/issues-p2-math.json.
Loads the existing list (P2M-01..P2M-24, written by make_issues_p2_math.py), appends the new items of the
second independent pass (P2M-25..), checks ids are unique and fields complete, and writes the merged list.
Idempotent: items whose id is already present are not added twice."""
import json, os
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..', '..', 'p2', 'issues-p2-math.json')
S = 'research/paper-review/scratch/p2-math/'
FIELDS = ["id", "file", "label_or_line", "severity", "problem", "evidence", "fix"]

new = [
dict(id="P2M-25", file="paper-steeper/sections/teacher.tex",
     label_or_line="cor:teacher:fulltable(ii) (line 153); proof in app-teacher.tex app:teacher:fulltable (ii) (line 134)",
     severity="major",
     problem="Part (ii) states without qualification that at lambda=1 'the optimum, J_1(pi_g) and J_1(pi_b) lie within O(log N)+delta_E of each other'. The proof covers programs of level >= 2 only through 'J_1 >= N G_1, and this exceeds J_1(pi_g) once N(G_1-H(p)) > d+kappa_g+log(N+1)'. That needs G_1 > H(p), i.e. p < 0.056, and N large. Neither condition is in the statement, and def:teacher:instance allows every p = 2^-r with 2 <= r <= m. A second problem: in this section J_c := c*ell + R is the per-sample objective, so 'J_1' reads as c = 1 (ell + R). The proof means the two-part length ell + N R at lambda = 1, i.e. J_lambda(pi;D) of def:setup:objectives.",
     evidence="At p = 1/16 (r = 4, allowed), G_1 = 1 - log(3/2 + 1/8) = 0.2996 < H(1/16) = 0.3373. Then N(G_1 - H(p)) < 0, and the proof gives no lower bound on the two-part length of level >= 2 programs, so 'the optimum' is not controlled. The statement is still true for every p < 1/4 by a different argument. Lemma setup:coding gives ell(pi) - log nu_pi(D) >= K(y_D|dom D) - kappa >= K(z|d) - kappa for every program, whatever its level. Minimum-distance decoding (p < 1/4) gives K(z) >= d + L_E - delta_E - kappa, as in app-algstat (ii). Hence optimum >= d + L_E - delta_E - O(log N). The steeper notes (Cor 2.5) have the same gap.",
     fix="Either add to (ii) 'if p < 0.056 and N(G_1-H(p)) > d+kappa_g+log(N+1)', or replace the level-split in the proof by the coding bound: 'every program has ell(pi)+N R(pi) = ell(pi) - log nu_pi(D) >= K(y_D|dom D) - kappa >= d + L_E - delta_E - 2log d - kappa (minimum-distance decoding, p < 1/4)'. With the second fix, (ii) holds for every p < 1/4. In both cases write the two-part length as J_1(pi;D) or 'ell + N R', not J_1(pi)."),
dict(id="P2M-26", file="paper-steeper/sections/limits.tex",
     label_or_line="paragraph after prop:limits:envelope (line 44), parenthesis '(Its deficiency is about 1,300 bits, so thm:teacher:main does not cover it; above c_env nothing is proved for it.)'",
     severity="major",
     problem="Both halves of the parenthesis are false. thm:teacher:main is stated for every error rule S with |S| = s_0, and delta_S enters only as a parameter of its bounds, so it does cover the j = 13 envelope rule. For that rule, with delta_S of about 1,260 to 1,310 bits, the bounds are weaker but not vacuous above c_env. The source sentence (steeper notes, after Prop 2.17: 'Theorem 2's bounds there contain delta_S of about 5,300 (first instance) and are vacuous for the error label') concerns the j = 11 instance. The paper transfers it to the j = 13 instance, where it does not hold.",
     evidence="Independent computation (" + S + "v4_extra.out), kappa = 0, B = infinity, eps = 0, delta_S in {1256, 1306}. These bound delta_S = L_S - K(S|a,K(a)) with K(S) at most log binom(2^20-128, 896) + 2log 14 + 2log 20 + 2log 897 = 10,418 + O(log). At c = 1e-4, Theorem 2(i)-(ii) give Delta(c) <= 5.8e-3, u >= 0.983, ell <= d+33.0, I <= 50.3 and e <= 0.71 (g = 11). At c = 1e-3 they give ell <= d+21.2 and e <= 0.78. At c = c_env = 1.64e-5 they give u >= 0.990 and ell <= d+104. For j = 11 (delta_S about 5,300) the error-label bound is vacuous (e <= 1.38 at c = 1e-4), as the notes say, but u >= 0.983 and ell <= d+72 still hold. These bounds are consistent with prop:limits:envelope: at c = 1e-5, (b) gives R >= H(p) - 1.4e-3 = 0.00975 and (i) gives R <= R_e + zeta = 0.0107.",
     fix="Replace the parenthesis by: '(Its deficiency is about 1,300 bits. thm:teacher:main still applies, but its bounds are weaker: at c = 10^-4 (kappa = 0) every near-optimal hypothesis has u >= 0.98, ell <= d+33 and e <= 0.71, and near 2^-m the bounds are vacuous. Whether the good model itself is near-optimal above c_env is open.)' Make the matching change in app-limits.tex line 125 if it is read the same way."),
dict(id="P2M-27", file="paper-steeper/sections/setup.tex",
     label_or_line="line 48 ('In statistics these objects are generalised, Gibbs, fractional or safe posteriors with learning rate eta=1/lambda'); related.tex rem:related:posteriors (line 39); intro.tex line 50; discussion.tex line 67",
     severity="major",
     problem="The power-prior posterior Pi_lambda(pi|o), proportional to 2^{-lambda ell(pi)} P_pi(o), is not a generalised, Gibbs, fractional or safe posterior with learning rate 1/lambda. That description fits the tempered posterior Pi^{1/lambda}, proportional to 2^{-ell(pi)} P_pi(o)^{1/lambda}. The two share their maximiser (lem:setup:basic(ii)) but differ as distributions: Pi_lambda is proportional to (Pi^{1/lambda})^lambda, which is Bayes with the sharper prior 2^{-lambda ell}. rem:related:posteriors says 'The posteriors of def:setup:objectives are generalised, Gibbs, fractional or safe posteriors with learning rate eta=1/lambda', which is false for Pi_lambda. The paper's posterior results are about Pi_lambda: thm:split:private(ii)-(iii), thm:split:shared(ii), prop:teacher:concentration and prop:limits:ood. A reader could wrongly carry over fractional-posterior theory to them, or the paper's results to fractional posteriors.",
     evidence="Two programs with ell = 0, P = 1/2 and ell = 1, P = 1, at lambda = 2. Pi_2 gives odds (1/2):(1/4) = 2:1. Pi^{1/2} gives odds 2^{-1/2}:2^{-1} = sqrt(2):1. In general, odds under Pi_lambda are the lambda-th power of odds under Pi^{1/lambda}. Only thm:split:private(iii) treats the tempered posterior, separately. The steeper notes (sec. 1.3) use the looser wording 'Hanni's two descriptions ... appear as generalised ... posteriors ..., and as two-part MDL with a complexity weight above 1', which maps the two descriptions to the two literatures.",
     fix="setup.tex line 48: 'The tempered posterior Pi^{1/lambda} is the generalised (Gibbs, fractional, safe) posterior with learning rate 1/lambda [cites]. The lambda-MAP, its maximiser, is two-part MDL with complexity weight lambda [cites]. The power-prior posterior Pi_lambda has the same maximiser but is Bayes with the prior 2^{-lambda ell}; it is proportional to (Pi^{1/lambda})^lambda.' Make the same correction in rem:related:posteriors, intro.tex line 50 and discussion.tex line 67."),
dict(id="P2M-28", file="paper-steeper/sections/teacher.tex",
     label_or_line="sentence after cor:teacher:sampled (line 164) and q:teacher:open (line 183, 'far below the n~1e11 that uniform convergence needs here'); intro.tex line 52 ('The finite-sample guarantee needs about 10^11 samples'); discussion.tex line 75",
     severity="minor",
     problem="The paper says repeatedly that the finite-sample guarantee needs about 10^11 samples at Hanni's sizes. Its own appendix gives a meaningful guarantee at n = 10^9 (app-teacher.tex line 192: ell <= d+113.9, e <= 0.284), and the corollary applies with nontrivial identification well below that. What needs about 10^11 is an excess below about 10 bits at c = 1e-4. The framing understates the result and contradicts the appendix.",
     evidence="Independent computation of cor:teacher:sampled (" + S + "v4_extra.out), B = 30, delta = 0.01, kappa = 0, delta_S = 0, g optimised. At c = 1e-3: n = 1e8 gives eps_n/c = 22.6 bits, u >= 0.898, ell <= d+42.6, e <= 0.305; n = 1e7 gives u >= 0.868, ell <= d+92.2, e <= 0.374. At c = 1e-4: n = 1e9 gives eps_n/c = 92.5, u >= 0.977, ell <= d+113.9, e <= 0.280; n = 1e10 gives eps_n/c = 29.0, ell <= d+49.8, e <= 0.228. The condition J_g + eps_n < Phi_2 holds in all these cases.",
     fix="Write: 'Uniform convergence gives identification with near-population constants (excess below 10 bits at c = 10^-4) only at n of about 10^11. Coarser guarantees hold much earlier: at c = 10^-3 and n = 10^8, u >= 0.90, ell <= d+43 and e <= 0.31.' Change intro.tex line 52, discussion.tex line 75 and q:teacher:open to match."),
dict(id="P2M-29", file="paper-steeper/sections/app-absorb.tex",
     label_or_line="proof of prop:absorb:price(iii) (line 67); absorb.tex rem:absorb:why (line 71) and prop:absorb:price(iii) (line 78)",
     severity="minor",
     problem="The macro \\nulen denotes two different laws in the two companion papers. The papers share NOTATION.md, and rem:absorb:why cites the companion paper's result about nu_len. Paper 1 defines nu_len as the law of F(x) := omega_{|x|+1}, one coin per input length including the empty input (paper/sections/versions.tex line 61; app-versions.tex line 66). Paper 2 defines it as the machine that answers omega_{|x|} for x != epsilon and is undefined at epsilon. Both give nu_len(D_beta) = 2^-k, so no result changes.",
     evidence="paper/sections/versions.tex line 61: 'let nu_len be the law of F(x) := omega_{|x|+1}'. paper-steeper/sections/app-absorb.tex line 67: 'nu_len is the law of the function machine T = {(x,w,w_{|x|}) : x != epsilon, w in {0,1}^{|x|}}'. The steeper notes call Paper 2's law sigma (Prop 1.7(iii)).",
     fix="Use Paper 1's definition: inputs 0^i and 1^i still share bit i+1, distinct i still get independent bits, and nu_len(D_beta) = 2^-k. Alternatively, call Paper 2's law sigma, as the notes do."),
dict(id="P2M-30", file="paper-steeper/sections/teacher.tex",
     label_or_line="def:teacher:instance (lines 21-32)",
     severity="minor",
     problem="The instance never says that the label set is Y = {0,1}. def:setup:data allows any finite Y with |Y| >= 2. Several parts of the section use binary labels: the teacher y* = f_a XOR 1_E, the coin with R = 1, list decoding through h_0 - h_1, the floor (on E, nu(y*|x) <= 1 with the 'other' label being f_a), and the identity (eq:teacher:identity) with A + V <= 1. Over a larger Y the coin's risk is log|Y|, and several constants change.",
     evidence="teacher.tex line 28: 'the coin ... with ell <= kappa and R = 1'. app-teacher.tex line 10: nu_pi(f_{a'}(x)|x) = (h_0+h_1)/2 + chi s_h/2 holds only when the labels are 0 and 1.",
     fix="Add to def:teacher:instance: 'Throughout this section and the next, Y = {0,1}.'"),
dict(id="P2M-31", file="paper-steeper/sections/teacher.tex",
     label_or_line="sentence before c_hi (line 72): 'The pieces of Phi_2 are nondecreasing in c and J_g is linear, so {c>0 : J_g(c) <= Phi_2(c)} = (0,c_hi]'",
     severity="minor",
     problem="The stated reason does not imply the conclusion. That the pieces of Phi_2 are nondecreasing does not make {J_g <= Phi_2} an initial interval. What does is that J_g minus each piece is affine and strictly increasing in c: the slope d + kappa_g exceeds both d - 8 - Lambda_1 and 0. The conclusion also needs J_g(0+) = H(p) < min{G_1, G_{t*-1}}; otherwise the set is empty, which the next sentence covers only implicitly.",
     evidence="J_g(c) - (c(d-8-Lambda_1) + G_1) = c(8 + Lambda_1 + kappa_g) + H(p) - G_1, and J_g(c) - G_{t*-1} = c(d + kappa_g) + H(p) - G_{t*-1}. Both are increasing in c, so the set where both are <= 0 is (0, min of the two zeros], and it is nonempty iff G_1 > H(p).",
     fix="Write: 'J_g minus each piece of Phi_2 is affine and increasing in c, so {c > 0 : J_g(c) <= Phi_2(c)} = (0, c_hi] (empty if c_hi <= 0), with ...'."),
dict(id="P2M-32", file="paper-steeper/sections/teacher.tex",
     label_or_line="cor:teacher:fulltable (line 152 'every lambda in (1,N c_hi)' against line 155 'window lambda in (1,1.19e4]'); app-teacher.tex line 137 '(1,11945]'",
     severity="minor",
     problem="The corollary correctly gives the open interval (1, N c_hi): at c = c_hi, J_g = Phi_2, and Theorem 2(ii) needs J_g + eps < Phi_2 strictly. The numbers below it report closed windows (1, 1.19e4] and (1, 11945], so they disagree with the corollary at the endpoint. The same applies to 'window' figures elsewhere whenever they are used for identification rather than for (i).",
     evidence="Theorem 2(ii) hypothesis: J_g(c) + eps < Phi_2(c). At c = c_hi, J_g(c_hi) = Phi_2(c_hi), by the definition of c_hi as the zero of J_g - Phi_2.",
     fix="Write the identification window as (1, 1.19e4) and (1, 6456), or add 'the right end point belongs to the window of (i), not of (ii)'."),
dict(id="P2M-33", file="paper-steeper/sections/algstat.tex",
     label_or_line="prop:algstat:parity(ii) (line 65, 'rho^x_D(alpha) >= N G_1 for every alpha < d-4-Lambda_1: the product structure function has a kink at alpha ~ d')",
     severity="minor",
     problem="A kink needs bounds on both sides of alpha ~ d, but the statement gives only the lower bound rho^x_D(alpha) >= N G_1 below d - 4 - Lambda_1. The upper side, rho^x_D(alpha) <= N H(p) for alpha >= d + kappa_g (the good model), is used only implicitly. The same holds for (iv).",
     evidence="By def:algstat:product, rho^x_D(d + kappa_g) <= -log nu_{pi_g}(D) = N H(p), because ell(pi_g) <= d + kappa_g and |E| = pN exactly. This is not stated in prop:algstat:parity.",
     fix="Add: 'and rho^x_D(alpha) <= N H(p) for alpha >= d + kappa_g, so rho^x_D drops by at least N(G_1 - H(p)) within an alpha-interval of length 4 + Lambda_1 + kappa_g = O(log d)' (with N(F_t - H(p)) and s(t) + Lambda_1 + kappa_g in (iv))."),
dict(id="P2M-34", file="paper-steeper/sections/limits.tex",
     label_or_line="paragraph after prop:limits:ood (line 95): 'With lambda=cn the bound vanishes, so steeper simplicity removes his constant lower bound, but only through (ii)'",
     severity="minor",
     problem="Part (i) gives only a lower bound, 2^{-lambda(K(Q,b)+kappa)}, on the probability of behaviour b on Q. That this bound vanishes for lambda = cn does not show that the probability vanishes. 'Removes his constant lower bound' can be read as a proof that the probability tends to 0, which nothing in the paper shows; part (ii) concerns posterior odds between equal-likelihood programs.",
     evidence="prop:limits:ood(i) is an inequality xi_lambda(D u b|_Z) >= 2^{-lambda(K(Q,b)+kappa)} xi_lambda(D). No upper bound on xi_lambda(D u b|_Z)/xi_lambda(D) is proved anywhere in the paper.",
     fix="Write: 'With lambda = cn the lower bound of (i) degrades to 2^{-cn(K(Q,b)+kappa)}, so his constant lower bound no longer follows. Whether the probability of b on Q actually vanishes depends, by (ii), on what the shortest train-fitting hypotheses do on Q.'"),
dict(id="P2M-35", file="paper-steeper/sections/limits.tex",
     label_or_line="rem:limits:schedule (line 21): 'so the code length exceeds pi's own loss by c ell(pi) bits per sample'",
     severity="minor",
     problem="The display before this sentence, -log xi_lambda(D_n) <= n(c ell(pi) + R_hat(pi)), is an upper bound. It shows that the code length exceeds pi's loss by at most c ell(pi) bits per sample, not exactly that much. discussion.tex line 61 states it correctly ('its guaranteed code length exceeds ...').",
     evidence="For a mixture, -log xi_lambda(D_n) can be smaller than lambda ell(pi) - log nu_pi(D_n), for example when many programs share pi's likelihood.",
     fix="Write 'exceeds pi's own loss by at most c ell(pi) bits per sample (the guaranteed excess)'."),
dict(id="P2M-36", file="paper-steeper/sections/related.tex",
     label_or_line="rem:related:nn (line 29): 'parameters that memorise the label noise get posterior mass exponentially small in the sampled randomness'",
     severity="minor",
     problem="thm:split:private(iii) bounds the posterior mass of deterministic programs consistent with the data, the fill-ins, and nothing else. Parameters that memorise the label noise only partly, or stochastically, are not covered. The source says 'deterministic parameter settings that memorise the label noise' (steeper notes, Rem 4.7).",
     evidence="thm:split:private(iii): 'Every deterministic program consistent with D_n has ...; Pi_lambda(det|D_n) <= ...'. Part (ii) bounds long programs whatever they are, but not memorisers as such.",
     fix="Write 'deterministic parameter settings that reproduce the noisy labels'."),
dict(id="P2M-37", file="paper-steeper/sections/limits.tex",
     label_or_line="paragraph after lem:limits:robust (line 61)",
     severity="minor",
     problem="Two small mismatches with the results. (1) 'no program that knows the parity and fits no better than noise is optimal at any c' is stronger than prop:limits:rateblind(ii), which gives 'beaten by the memoriser or beaten or tied by the coin'. A program tied with the coin can be a minimiser. (2) 'leaves a window of a factor of about 8000 (kappa=0)': rem:teacher:numbers gives the ratio 8453 for Theorem 2's window. 8037 is Hanni's three-hypothesis ratio.",
     evidence="prop:limits:rateblind(ii) proof: J_c(pi) >= 1 + c kappa >= J_c(pi_coin), a weak inequality. Ratio c_hi 2^20 = 8.0618e-3/9.5367e-7 = 8453.4 (" + S + "v1_teacher.out).",
     fix="Write '... is ever the unique optimum (at every c it is beaten by the memoriser or matched by the coin)' and 'a window of a factor of about 8500 (kappa=0) or 3800 (kappa=30)'."),
dict(id="P2M-38", file="paper-steeper/sections/app-limits.tex",
     label_or_line="paragraph after the proof of prop:limits:ood (line 143), conjunction ladder",
     severity="minor",
     problem="Calling the companion paper's conjunction ladder 'a concrete instance of the warning in (ii)' conflicts with the companion paper's own reading. There, the failure is a failure of deterministic tie-breaking (lambda-MAP selection). Uniform tie-breaking among least-size consistent formulas, the lambda -> infinity limit of the power posterior, makes only O(d^2) Gibbs mistakes. Paper 1, rem:comp:uniformties, concludes: 'So thm:comp:ladder is a failure of deterministic tie-breaking; it does not show that steeper SFI fails on this ordering.' The warning in (ii) is about the steeper posterior.",
     evidence="paper/sections/comp.tex lines 131-133 (rem:comp:uniformties). The paper's own sentence reports both facts, but frames them as illustrating the posterior's danger.",
     fix="Write: 'On a conjunction ladder [companion paper] deterministic selection of a least-size consistent formula, a lambda-MAP rule, makes exponentially many mistakes on some ordering for every tie rule, while the lambda -> infinity power posterior, uniform over those formulas, makes O(d^2) Gibbs mistakes. The danger in (ii) is therefore sharpest for single-hypothesis selection.'"),
dict(id="P2M-39", file="paper-steeper/sections/teacher.tex",
     label_or_line="rem:teacher:numbers (line 108): 'for m=24 (L_S=187,457) the bound at c=10^-4 is e<=0.065 (kappa=0)'",
     severity="minor",
     problem="This number does not state the deficiency it assumes, contrary to the paper's convention (line 34: 'every number we give states the delta_S it assumes').",
     evidence="Recomputed: e <= 0.0650 at kappa = 0 and 0.0842 at kappa = 30, both with delta_S = 0 (" + S + "v1_teacher.out).",
     fix="Write '(kappa = 0, delta_S = 0; 0.084 at kappa = 30)'."),
dict(id="P2M-40", file="paper-steeper/sections/split.tex",
     label_or_line="thm:split:shared, last sentence (line 92); app-split.tex line 99",
     severity="minor",
     problem="'For SI with adaptive or non-computable inputs, (Dom) in the needed form is supplied by H_chr ..., not by H_SI' misplaces the difficulty. (Dom) is a property of the class and holds in H_SI with U = M on every observation. What fails with adaptive or non-computable inputs is the theorem's other hypothesis, that the sampler has a program pi_nu in the class: an SI hypothesis must also model the inputs.",
     evidence="rem:absorb:examples: (Dom) holds in H_SI with kappa_0 = 0. thm:split:shared requires 'pi_nu a program of length k for a sampler in the class'.",
     fix="Write: 'For SI with adaptive or non-computable inputs the sampler is not an SI hypothesis, since it does not model the inputs. Use H_chr, where it is a chronological semimeasure and (Dom) holds with U = M_H. With i.i.d. computable inputs, H_SI with U = M works.'"),
dict(id="P2M-41", file="paper-steeper/sections/intro.tex",
     label_or_line="Contributions, fourth bullet (line 23): 'so it is not a fill-in once the sampled randomness is larger'",
     severity="minor",
     problem="The comparison has no stated object ('larger' than what?), and the claim is a derived statement not given in the body. From thm:split:private, a lambda-MAP has length at most (lambda k + delta*)/(lambda-1), and every fill-in has length at least -log nu(D_n) - delta*. So no lambda-MAP is a fill-in once -log nu(D_n) > lambda(k + delta*)/(lambda-1).",
     evidence="thm:split:private(i) and (iii): (lambda k + delta*)/(lambda-1) < -log nu(D_n) - delta* iff -log nu(D_n) > (lambda k + lambda delta*)/(lambda-1).",
     fix="Write 'so it is not a fill-in once the sampled randomness -log nu(D_n) exceeds lambda(k + delta*)/(lambda-1)', and add this one-line consequence to rem:split:reading."),
dict(id="P2M-42", file="paper-steeper/sections/setup.tex",
     label_or_line="lem:setup:hull(iv) (line 72): 'not on the horizontal ray to the right of the least-R vertex'",
     severity="minor",
     problem="The least-R vertex is the endpoint of that ray and is a penalised minimiser, so the statement must exclude only the open ray. The proof (app-setup.tex line 29) says 'open horizontal ray'.",
     evidence="In {(0,1),(10,0),(20,0)} the vertex (10,0) minimises c ell + R for c < 0.1 and lies at the start of the horizontal ray. Exact rational check of (iii): 0 mismatches in 17,588 point tests (" + S + "v5b_hull_exact.out).",
     fix="Write 'not on the open horizontal ray to the right of the least-R vertex'."),
]

with open(OUT) as f:
    issues = json.load(f)
have = {x["id"] for x in issues}
for x in new:
    assert set(x) == set(FIELDS), x["id"]
    assert x["severity"] in ("fatal", "major", "minor")
    if x["id"] not in have:
        issues.append({k: x[k] for k in FIELDS})
ids = [x["id"] for x in issues]
assert len(ids) == len(set(ids))
with open(OUT, "w") as f:
    json.dump(issues, f, indent=1, ensure_ascii=False)
from collections import Counter
print(len(issues), Counter(x["severity"] for x in issues))
