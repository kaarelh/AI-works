# Verification record: T5-steeper-simplicity-and-normativity-from-imitation

*Target file: `research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md`.*
* *Two independent adversarial referees checked the file: Referee A for §§1–2 and Referee B for §§3–6.*
* *Their reports are reproduced verbatim below as JSON, followed by the author-repairer's log. The same log is appended to the theory file.*
* *Repair checks are in `research/theory/T5-checks/repair_checks.py`. The repaired on-hull test is in `research/theory/T5-checks/c3_rate_threshold.py`.*

**Outcome in brief.**
* **One fatal issue, genuine.** Identification clause 2 of Thm 3.3 was false, because its proof used $1-\log_2(1+2^{1-t})\ge1-2^{1-t}$, which goes the wrong way.
  * The clause's hypotheses are corrected to $\pi_j g(d_j/4)>c d_j+\Delta$ and $\pi_j g(2)>\Delta+8c$, where $g(t)=1-\log_2(1+2^{1-t})$. These are implied by $\pi_j>c d_j+\Delta+\pi_j2^{1-d_j/4}/\ln2$ and $\pi_j>2.41(\Delta+8c)$.
  * The proof of the two-sided estimate is rewritten. $\Delta_0$ is unchanged.
* No issue was labelled major.
* Every minor issue was genuine and has been fixed or made precise. No issue was rejected.
* The most substantive minor repair is to Thm 2.5(b). The $2p$ slack meant that no kink was shown for $p\ge0.142$.
  * A new Lemma 2.5c, combining concentration with coding, replaces that slack by $O(\sqrt{p(\delta_E+\log n)/n})$ for incompressible $E$.
  * The "partial knowledge is worthless" phrasing is replaced by an exponential-decay statement.
* A new Cor 3.5a gives identification in the parity example.

---

## Referee reports (verbatim JSON)

```json
[
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md",
  "items_checked": [
   "Sec 1.1-1.3 setup: teacher/norm, Definition 1.1 (product / shared-randomness / block models), objectives, idealized vs computable versions, rates",
   "Lemma 1.2 (empirical selection tracks population selection)",
   "Sec 1.4 literature relations (structure function, VV 2004/2010, GTV 2001, Barron-Cover, tempered posteriors = lambda, SafeBayes)",
   "Theorem 2.1 (no adaptation with private randomness) (i),(ii) + c2(a) example",
   "Proposition 2.2 (weighted form)",
   "Proposition 2.3 (sequence pathology)",
   "Theorem 2.4 (function-case universal hypotheses are fixed predictors)",
   "Sec 2.2 kink setting (L_E, delta_E, s_h, Fourier coefficients)",
   "Lemma 2.5a (list decoding)",
   "Lemma 2.5b (risk vs correlation)",
   "Theorem 2.5(a) shared randomness has no kink",
   "Theorem 2.5(b) private randomness has a kink",
   "Theorem 2.5(c) error segment / sufficiency line",
   "Sec 2.2 'Reading' and c2(b) numbers",
   "Proposition 2.6 (per-block pricing / in-context universality) + c5 'Consequence' numbers",
   "Sec 2.3 design consequence (step checker (Pi,j) is a function model; checked against T1's definition of a step)",
   "Sec 2.4 answer summary",
   "Scripts re-run: T5-checks/c1_user_example.py, c2_pricing_and_kink.py, c5_incontext_persona.py (all reproduce the quoted numbers)"
  ],
  "issues": [
   {
    "item": "Sec 1.2-1.3, Definition 1.1 and idealized hypothesis class",
    "severity": "minor",
    "description": "Three small precision problems in the setup. (1) The text says a shared-randomness hypothesis P(y_{1:N}|x_{1:N}) is 'equivalently' a program reading one random tape on the interleaving x1y1x2y2... That program view is causally conditioned (y_i may depend only on x_{<=i}, y_{<i}), while a general P(y_{1:N}|x_{1:N}) can depend on future inputs. The two coincide for a single fixed x_{1:N}, which is all Thm 2.1(ii) uses, but not as classes of hypotheses. (2) 'K(h) = the prefix complexity of a program computing h' should be the minimum over programs computing h, which is how h* is used later. (3) The idealized class ('total programs with rational outputs') excludes the objects later compared within it: M in Prop 2.3 and m in Thm 2.4 (lower-semicomputable semimeasures), and h_w in Prop 2.6 for infinite families (its outputs are not rational).",
    "evidence": "Def 1.1: 'Equivalently, it is a program that reads one random tape across all inputs, as in sequence-Solomonoff on the interleaving'. §1.3: 'Hypotheses are total programs with rational outputs.' Prop 2.3 uses lambda*K(M) and Thm 2.4 uses R(m) with K(m) implicitly, but neither M nor m is in that class.",
    "suggested_fix": "Say 'causally conditioned' (or drop 'equivalently'). Define K(h)=min{|p|: p computes h}. State that Prop 2.3 and Thm 2.4 enlarge the class to lower-semicomputable semimeasures, or replace M by a computable mixture such as the P_u of Thm 2.5(a)."
   },
   {
    "item": "Lemma 1.2",
    "severity": "ok",
    "description": "Verified line by line. Two-sided Hoeffding at confidence delta*2^{-l(h)} gives exactly B*sqrt((l ln2 + ln(2/delta))/(2N)), and the union bound works by Kraft. c*l(hhat) <= Jhat(h0) <= c*l(h0)+B is correct, and so is the same bound for h_c. The chain J(hhat) <= Jhat(hhat)+eps <= Jhat(h_c)+eps <= Phi+eps(h_c)+eps(hhat) is correct. Population and empirical minimizers exist because {h: l(h)<=L} has at most 2^L elements under Kraft (not stated, but true). The second display holds on the same probability->=1-delta event, which is implicit. The remark correcting L11 Prop 2.2 matches L11, which states the fixed-lambda window claim.",
    "evidence": "Constants recomputed by hand: 2exp(-2N eps^2/B^2) = delta 2^{-l} gives eps = B sqrt((ln(2/delta)+l ln2)/(2N)).",
    "suggested_fix": "Optionally add 'on the same event' and one line on why minimizers exist (finite sublevel sets)."
   },
   {
    "item": "Sec 1.4 literature relations",
    "severity": "ok",
    "description": "The bibliographic data I can check from memory are correct: VV 2004 IEEE TIT 50(12):3265-3290; VV 2010 IEEE TIT 56(7):3438-3454; GTV 2001 IEEE TIT 47(6); Barron-Cover 1991 IEEE TIT 37(4); Zhang 2006 AoS 34(5); Bhattacharya-Pati-Yang 2019 AoS 47(1); Grunwald 2012 ALT; Grunwald-van Ommen 2017 BA 12(4). The relation lambda_x(alpha) = h_x(alpha)+alpha+O(log), and hence beta_x = h_x+alpha-K(x), holds only up to logarithmic argument shifts, which the file already flags as (u). The tempered-posterior computation is correct: pi_eta proportional to 2^{-l(h) - eta N Rhat}; MAP = argmin of l/eta + N Rhat; with eta = 1/(cN) the posterior is 2^{-(l + Rhat/c)}, which tends to 2^{-(l+R/c)}. On Barron-Cover, I believe (also unverified) that their main convergence theorem uses the alpha-weighted criterion with alpha>1, as Grunwald 2007 discusses under 'alpha-two-part MDL'. The (unverified) tag is appropriate.",
    "evidence": "Hand check of the Gibbs limit and of the slope property h_x(alpha+delta) <= h_x(alpha)-delta+O(log) by splitting S.",
    "suggested_fix": "None needed beyond the existing (u) tags."
   },
   {
    "item": "Theorem 2.1 (no adaptation with private randomness)",
    "severity": "minor",
    "description": "(i) and (ii) are correct: E_Q of the cross-entropy is at least H(Q_x), the uniform-on-F(x) hypothesis attains the bound, and Shtarkov/NML gives (ii). Two clarity points. (1) In general the exact minimax value over product h is max_Q sum_i H(Q_{x_i}) (minimax theorem). It equals sum_i log|F(x_i)| only when a uniform-marginal Q exists, and that hypothesis is genuinely needed. (2) 'any class invariant under a group acting transitively on each F(x)' is true only if the action on F induces a well-defined action on each F(x), for example (g.f)(x) = sigma_{g,x}(f(x)), as with parity translations. A group acting transitively on F alone does not suffice. The c2(a) example (200.0 vs 10.0 bits) reproduces.",
    "evidence": "Brute force on F = {(a,a),(a,b),(b,a),(c,a)} over two points: there is no Q with uniform marginals, and min_h max_f loss = max_Q sum H(Q_x) = 2.5431 < log2(3)+1 = 2.5850. Sym(F) acts transitively on F, but its action on F(x) is not well defined.",
    "suggested_fix": "State the minimax value as max_Q sum_i H(Q_{x_i}). Rephrase the group condition: 'G acts on F with (g.f)(x) = sigma_{g,x}(f(x)) for permutations sigma_{g,x} of Y, transitive on each F(x)'."
   },
   {
    "item": "Proposition 2.2 (weighted form)",
    "severity": "ok",
    "description": "Correct. Dropping all but one term gives both bounds, and the tightness example ({const 0, const 1}, w=1/2, N ones: N bits vs 1 bit) is correct. Standard; marked [known].",
    "evidence": "Direct computation: xi_fun(1|x)=1/2 per input, xi_seq(1^N)=1/2.",
    "suggested_fix": "None."
   },
   {
    "item": "Proposition 2.3 (sequence pathology)",
    "severity": "minor",
    "description": "The body is correct: lambda*c_M - log M <= lambda*c_M + K(nu) + c_0 - log nu, and this beats nu's objective iff (lambda-1)K(nu) > lambda*c_M + c_0. The §0 summary misstates the threshold as 'complexity above O(1)/(lambda-1)'. The true threshold is (lambda c_M + c_0)/(lambda-1) = c_M + (c_M+c_0)/(lambda-1). Under the user's scaling lambda = cN -> infinity it tends to c_M, not 0. Read literally, the summary would claim M beats hypotheses with K(nu) < c_M at large lambda, which is false. Separately, M is not a total program (see the setup issue).",
    "evidence": "§0: 'the universal semimeasure beats every nu of complexity above O(1)/(lambda-1)'. Counterexample to the literal summary: nu with K(nu) < c_M and lambda large has lambda K(nu) - log nu < lambda c_M <= M's objective whenever -log nu < lambda (c_M - K(nu)).",
    "suggested_fix": "In §0 write 'above c_M + O(1)/(lambda-1)'. In Prop 2.3, say that the hypothesis class is enlarged to lower-semicomputable semimeasures."
   },
   {
    "item": "Theorem 2.4",
    "severity": "ok",
    "description": "Correct but trivial. The SLLN claim holds for fixed h. For binary Y the semimeasure gives m(y|x) <= 1 - 2^{-kappa_U}, so R(m) >= -log(1-2^{-kappa_U}) > 0. Wording only: m(.|x) varies with x (within a bounded ratio), so 'a coin with a machine-dependent bias' is loose, and m is outside the total-program class.",
    "evidence": "Hand check: m(0|x)+m(1|x) <= 1 and both are >= 2^{-kappa_U}.",
    "suggested_fix": "Optional: 'a predictor whose odds are bounded by a machine constant'."
   },
   {
    "item": "Lemma 2.5a (list decoding)",
    "severity": "minor",
    "description": "Correct. Parseval gives count * 2^{-2t} <= sum s_hat^2 <= E[s^2] <= 1, and the description of a given h* (d, t self-delimiting, then a 2t-bit index) is right. Small points: t must be a nonnegative integer, both for the self-delimiting code and for a 2t-bit index; for real t use ceil(t), whose extra O(1) is absorbed into kappa. The list-size bound is the standard Parseval/Johnson bound for Hadamard codes (Goldreich-Levin; Kushilevitz-Mansour) and could be cited.",
    "evidence": "Brute force with d=6, 20,000 random product h of four kinds, t in {0,0.5,1,2,3}: 0 violations of |{a': s_hat(a') >= 2^-t}| <= 2^{2t}.",
    "suggested_fix": "Restrict to t in N (or use ceil(t)) and add a citation."
   },
   {
    "item": "Lemma 2.5b (risk vs correlation)",
    "severity": "ok",
    "description": "Correct. Jensen holds, h(f_a(x)|x) = (1+s_h chi_a)/2 when h(0|x)+h(1|x)=1, and the E part is <= p. The exact identity is E_x h(y*|x) = 1/2 + (1/2)<s_h, (-1)^{y*}>. The lemma is tight as a function of s_hat_h(a) alone: an h that is correct on E with s_hat_h(a)=0 reaches E_x h(y*|x) = 1/2 + p. So the 2p slack in Thm 2.5(b) cannot be removed without using that E is random (see the Thm 2.5(b) issue).",
    "evidence": "Brute force with d=6 and random a, E, h: 0 violations of R(h) >= -log2((1+s_hat(a))/2+p). The exact identity was asserted to machine precision on every trial.",
    "suggested_fix": "None needed for the lemma."
   },
   {
    "item": "Theorem 2.5(a) (shared randomness has no kink)",
    "severity": "minor",
    "description": "The two upper bounds are correct. In particular the true component has weight 2^{-u} and likelihood exactly 2^{-nH(p)} because |E| = pn. But 'the total is the same for all u' and 'the lambda-objective is minimized, up to kappa', at u=d' are supported only by upper bounds. Flatness needs the matching lower bounds: K(P_u) >= d-u-O(log d), since a is recoverable from P_u plus u bits, and the sufficiency line K(P) - log P(y*) >= K(y*) - O(1), which comes from the coding argument of (c) and applies to any computable P. Then the lambda-objective's slack is lambda*(kappa'+O(log d)), not kappa'. The correct conclusion is that the minimizing u satisfies d-u <= (lambda/(lambda-1))(kappa'+O(log d)). So 'every lambda>1 selects the zero-knowledge mixture' fails to follow for lambda-1 << (kappa'+log d)/d. Also kappa' = O(log d)+K(p) need not be small: for p = |E|/n, K(|E|) can be about d.",
    "evidence": "objective(u) >= lambda(d-u-O(log d)) + u + nH(p) - o(1) and objective(d) <= lambda kappa' + d + nH(p), so the difference is >= (lambda-1)(d-u) - lambda(kappa'+O(log d)). c2(b) (explicit code lengths) shows exactly flat totals of 128.9 bits; that is the computable version, where the issue disappears.",
    "suggested_fix": "Add the lower bound and state the selection conclusion as d-u <= (lambda/(lambda-1))(kappa'+O(log d)) (exact in the computable version)."
   },
   {
    "item": "Theorem 2.5(b) (private randomness has a kink) and its 'Reading' / Sec 2.4",
    "severity": "minor",
    "description": "The displayed inequality is correct: the contradiction via K(a) <= K(h)+K(a|h*)+O(1) is valid, as is the last step 1-log2(1+z) >= 1-z/ln2. But the 2p/ln2 slack inherited from Lemma 2.5b means the bound shows no kink once p >= 0.1421, a range the hypothesis p < 1/4 allows. There 1-2p/ln2 <= H(p), so under-specified product models are not shown to be worse than the good model at all. Even for small p, low-complexity h are only shown to lie within 2p/ln2 of the coin, so the coin-good chord is not shown to be undercut-free for K(h) < ~2pd/((1-H(p))ln2). Separately, the 'Reading' ('Partial knowledge of the simple model is worthless per input') and §2.4 ('buys nothing until it is complete') overstate the result. The file's own c2(b) list mixtures have risk 0.546 at 9 of 10 bits and 0.779 at 8. The correct statement is that the advantage decays exponentially in the number of missing bits, roughly <= 2^{-(d-K)/2+O(log d)} + 2p/ln2. Downstream, Thm 3.5's coin/good switch point (1-H(p))/d inherits the 2p slack.",
    "evidence": "1-2p/ln2 = H(p) at p = 0.14215 (brentq). Examples: p=0.15 gives bound 0.567 < H=0.610; p=0.2 gives 0.423 < 0.722; p=0.24 gives 0.308 < 0.795. c2(b) product risks: 0.116, 0.546, 0.779, 0.890 at 10, 9, 8, 7 bits.",
    "suggested_fix": "Either restrict to p <= 0.1 (or state the kink only where 1-2p/ln2 > H(p)), or strengthen Lemma 2.5b using the randomness of E. Given (a,h*), sum_{x in E} s_h chi_a concentrates around p n s_hat_h(a) (Hoeffding without replacement), and E with deviation eta has K(E|a,h*) <= L_E - Omega(p n eta^2) + O(log n). This gives R(h) >= 1 - [(1-2p)2^{-t} + O(sqrt(p(delta_E+K(h)+log n)/n))]/ln2, which yields a kink for every p < 1/4. Replace 'worthless/buys nothing' with the exponential-decay statement."
   },
   {
    "item": "Theorem 2.5(c) (error segment)",
    "severity": "minor",
    "description": "The step K(y*|h*) <= -log P_h(y*) + O(1) needs n = 2^d. P_h on {0,1}^n is computable from h* only once d is known, which is exactly the point Lemma 2.5a makes ('a program for h need not determine it'). The correct bound is K(h)+nR(h) >= d + L_E - delta_E - 2log2 d - kappa (or -K(d)), so kappa is not a pure machine constant here. The other steps check out: a is uniquely decodable from y* because the correlation with chi_a is 1-2p while every other correlation is <= 2p < 1-2p when p < 1/4; E = {y* != f_a}; and symmetry of information K(a,E) = K(a) + K(E|a,K(a)) + O(1).",
    "evidence": "Inconsistency with Lemma 2.5a's own 2 log2 d term. With h defined on all of {0,1}^*, the product distribution over {0,1}^n is not determined by h* alone.",
    "suggested_fix": "Add -2log2 d (or condition on d) in (c), and propagate it to Thm 3.5's K_tot."
   },
   {
    "item": "Proposition 2.6 (per-block pricing)",
    "severity": "minor",
    "description": "The loss bound is correct. Within a block, the product of the Bayes-posterior predictives telescopes to sum_theta w_theta prod nu_theta / sum w, even for history-dependent nu_theta and for inputs that depend on earlier steps. The proof should say this telescoping identity explicitly rather than 'Prop 2.2's sequential bound', because Prop 2.2 is stated for history-independent q. The complexity claim K(h_w) <= K(w)+O(1) omits the description of the persona family: it should be K(w, (nu_theta)_theta)+O(1), and for an arbitrary (possibly uncomputable) 'countable family' h_w is not computable at all. For infinite families the outputs of h_w are infinite sums, so h_w is outside the 'rational outputs' class unless truncated or approximated.",
    "evidence": "Numeric check with 3 history-dependent personas over 3 labels and blocks of length 6: block loss <= bound on all trials (e.g. 9.42 <= 10.09). The statement says 'any countable family ... K(h_w) <= K(w)+O(1)'.",
    "suggested_fix": "State 'for a uniformly computable family', write K(h_w) <= K(w,(nu_theta))+O(1), and spell out the telescoping identity in the proof."
   },
   {
    "item": "Prop 2.6 'Consequence' (c5 copier numbers)",
    "severity": "ok",
    "description": "The numbers reproduce exactly: K=1 gives 4.759 vs 4.759; K=2 gives 3.032 vs 4.637; K=16 gives 1.327 vs 4.679. Remark: the norm model is a fixed predictor, so its expected per-context loss is the constant 4.635 for every K. The 4.52-4.76 spread in that column is Monte Carlo noise (T=4000 blocks), not an effect of K. The script's persona likelihoods and norm model are over-normalized by about eta/M2 = 7.6e-7 and 3.7e-6, which is negligible. The qualitative claim (an O(1)-bit copier beats the norm model for K >= 2) stands.",
    "evidence": "Exact computation: (1-q)((1-eta)(-log2(1-e_n)) + eta(-log2(e_n/(M2-1)))) + q(-log2(e_n/(M2-1))) = 4.635.",
    "suggested_fix": "Optionally quote the exact 4.635 for the norm model."
   },
   {
    "item": "Sec 2.3 design consequence (step checker is a function model)",
    "severity": "ok",
    "description": "Checked against T1. A step there is (Pi, j), with Pi the finite premise set and j the conclusion, so the input carries no labelled history by the same author, and the function-model reading is consistent with Prop 2.6's hypothesis.",
    "evidence": "T1-soundness-under-search.md line 64: 'A step is a pair s=(Pi,j), where Pi subset of J is finite (the premises) and j in J (the conclusion).'",
    "suggested_fix": "None."
   },
   {
    "item": "Check scripts c1, c2, c5",
    "severity": "ok",
    "description": "All three ran cleanly and reproduce every number quoted in §0, §2.1, §2.2 and §2.3. c1: window c in (1.1185e-6, 8.9893e-3), ratio 8037x, the standard-MDL switch at N = 894054, and the lambda window (1.12, 8990) at N=1e6. c2(a): 200.0 vs 10.00 bits. c2(b): product risks 0.1161, 0.5464, 0.7790, 0.8895, ..., 0.9990; shared totals 128.9 at every u; hulls and selections at lambda in {1.5, 4, 50} as stated. c5: as above. The hull routine in c2 is a correct lower-hull scan.",
    "evidence": "python3 output of each script; I read the code.",
    "suggested_fix": "None."
   }
  ],
  "overall": "Sections 1-2 contain no fatal and no major errors, and every displayed theorem statement I checked holds. I verified Lemma 1.2, Thm 2.1, Prop 2.2, Prop 2.3 (body), Thm 2.4, Lemmas 2.5a and 2.5b (brute force, d=6, 0 violations), the core logic of Thm 2.5(a)-(c), and Prop 2.6 (numeric telescoping check); scripts c1, c2 and c5 reproduce every quoted number.\n\nThe defects are minor, but several affect how the results are read:\n(1) The most substantive is in Thm 2.5(b). The 2p/ln2 slack from Lemma 2.5b means the theorem shows no kink for p >= 0.142, although it assumes only p < 1/4. The 'worthless / buys nothing until complete' phrasing also overstates the result: c2's own list mixtures have risk 0.546 at 9 of 10 bits. Restrict p, or strengthen the bound by using the randomness of E (a concentration-plus-complexity argument replaces 2p by O(sqrt(p(delta_E+K(h)+log n)/n))).\n(2) Thm 2.5(c) omits the 2log2 d needed to supply n to the coding theorem, which Lemma 2.5a itself accounts for.\n(3) Thm 2.5(a) proves flatness and lambda-selection only through upper bounds; the slack is lambda(kappa'+O(log d)), not kappa'.\n(4) The §0 summary of Prop 2.3 gives the threshold as O(1)/(lambda-1); the correct value is c_M + O(1)/(lambda-1).\n(5) Prop 2.6's K(h_w) <= K(w)+O(1) must include the description of the persona family.\n(6) Several objects (M, m, infinite-family h_w) fall outside the declared 'total programs with rational outputs' class, and Def 1.1's 'equivalently' conflates causal and non-causal conditioning.\n\nThm 2.1, Prop 2.2 and Lemma 2.5a are standard facts. Thm 2.1(ii) and Prop 2.2 are credited; Lemma 2.5a, a Parseval/Johnson-type list-size bound, is not, though no misleading novelty claim is made."
 },
 {
  "file": "/home/user/AI-works/inferential-learning/research/theory/T5-steeper-simplicity-and-normativity-from-imitation.md",
  "items_checked": [
   "Lemma 3.1 (convex hull / supported points / vertex <-> open c-interval)",
   "Thm 3.2 (separable product classes; rate threshold)",
   "Thm 3.3 two-sided estimate of Phi(c)",
   "Thm 3.3 identification clause 1 (not learned)",
   "Thm 3.3 identification clause 2 (learned)",
   "Cor 3.4 (every convex hull shape realizable)",
   "Thm 3.5 (parity version of user's example) + Section 3.4 numbers (c1, c2)",
   "Thm 4.1 (rate blindness) (i)-(iv) and the illustrative 200-bit-rule claim after it",
   "Prop 4.2 (cheap fallacies out-rate genuine rules)",
   "Thm 4.3 (validation prefers the teacher; non-identifiability of c) + SafeBayes remark",
   "Prop 4.4 (guard erosion)",
   "Prop 4.5 (error envelopes)",
   "(d3) non-additivity / parasitic errors",
   "(d4),(d5) cross-references",
   "(d6) language relativity",
   "(d7) distribution dependence",
   "Section 5.1 situation-typed step imitation",
   "Thm 5.2 (division of labour) incl. brute-force check",
   "Cor 5.2a (best c given the other filters)",
   "Prop 5.3 (coherence repair by sacrifice) incl. brute-force check",
   "Prop 5.4 (meaning postulates)",
   "Section 5.4 toy table",
   "Section 0 summary items 2-4 and Section 6 assessment / novelty claims",
   "Literature citations used in Sections 3-6",
   "Re-run of T5-checks/c3_rate_threshold.py",
   "Re-run of T5-checks/c4_rules_toy.py (also c1, c2 for Thm 3.5 numbers)"
  ],
  "issues": [
   {
    "item": "Thm 3.3, identification clause 2 (\"if pi_j > c d_j + Delta + pi_j 2^{1-d_j/4} and pi_j > 2Delta+16c then shat_{h,j}(a_j) >= 1/2\")",
    "severity": "fatal",
    "description": "As stated, this clause is false. The proof step at line 304 says: \"If shat_j<1/2 then t_j>=2 and R_j >= 1-2^{1-t_j} >= 1/2\". That inequality does not hold. Lemma 2.5b with p=0 gives only R_j >= 1-log2(1+shat_j) > 1-log2(3/2) ≈ 0.415, and a hypothesis that predicts the correct parity with constant confidence attains this bound. The error is in the constants and is easy to repair. Qualitatively, near-optimal hypotheses still learn high-rate components.",
    "evidence": "Counterexample. Take m=1, pi_1=1, d_1=40, with a K-random. Let h_q(f_a(z)|z)=q=0.745 for every z, i.e. the true parity predicted with confidence 0.745. Then shat(a)=2q-1=0.49<1/2, R=-log2(0.745)=0.4247, and K(h_q) <= d+O(log d)+O(1). Take c=1e-6/(kappa+100) and eta:=J_c(h_q); this is legitimate because Phi>=0 gives J_c(h_q)<=Phi+eta, and it gives eta≈0.4248. Then Delta_0 ≈ 2^{-9}+O(1e-6) ≈ 0.00196 and Delta=2Delta_0+eta ≈ 0.4287. Check both hypotheses: c d+Delta+2^{-9} ≈ 0.431 < 1 = pi_1, and 2Delta+16c ≈ 0.857 < 1. So both hold, yet shat=0.49<1/2. A script confirmed this for kappa in {10,100,1000} and q in {0.74,0.745,0.749}. Root cause: log2(1+u) is concave and >= u on [0,1], so 1-log2(1+u) <= 1-u. For example, at t=2 the bound is 0.415, not the claimed 0.5.",
    "suggested_fix": "Use the correct bound R_j >= g(t):=1-log2(1+2^{1-t}). It is concave in t, since g''<0, so the endpoint argument on [2,d_j/4] still goes through. With it, condition 2 becomes pi_j(1-log2 1.5) > Delta+8c, i.e. pi_j > 2.41(Delta+8c). The endpoint condition becomes pi_j(1-log2(1+2^{1-d_j/4})) > c d_j+Delta, which is roughly the stated one with 2^{1-d_j/4} replaced by 2^{1-d_j/4}/ln2. Alternatively, keep the stated hypotheses and weaken the conclusion to shat >= sqrt2-1 ≈ 0.414, because shat<sqrt2-1 implies R_j>1/2."
   },
   {
    "item": "Thm 3.3, two-sided estimate |Phi(c)-sum_j min(c d_j,pi_j)| <= Delta_0(c) (proof, line 298)",
    "severity": "minor",
    "description": "The proof uses the false inequality 1-log2(1+2^{1-t_j}) >= 1-2^{1-t_j}, which goes the wrong way for t_j>=2. The correct elementary bound, used in Thm 2.5(b), carries a factor 1/ln2. The stated Delta_0 is nonetheless true. With the exact concave R-bound, the shortfall pi_j(log2(1+u)-u) <= 0.443 pi_j u at the endpoint u=2^{1-d_j/4} is absorbed by the -4c slack. So the result stands, but the written proof does not establish it.",
    "evidence": "Absorption argument. Case c d_j <= pi_j: it suffices that 0.886*2^{-d_j/4} <= 4/d_j, which holds for all d_j. Case c d_j > pi_j: then 4c > 4pi_j/d_j, which reduces to the same inequality. A numerical check over d in [1,63]∪{80,100,200,400}, pi in [1e-3,1], c=2^{e/4} with e in [-60,9], and integer t found no violation of the stated per-region bound min(cd,pi)-4c-pi*2^{1-d/4}. This held both with the proof's s(t)<=4t and with the exact s(t)=2t+2log2(t+1).",
    "suggested_fix": "Replace line 298 with R_j >= 1-log2(1+2^{1-t_j}), note that it is concave in t, and add the two-case absorption argument above. Alternatively, put a factor 1/ln2 on the last term of Delta_0 and propagate it into the identification conditions."
   },
   {
    "item": "Thm 3.3, identification clause 1 (not learned)",
    "severity": "ok",
    "description": "Verified. shat>=1/2 gives t_j<=1, so the K-part is >= c(d_j-4). This contradicts phi_j <= pi_j+Delta when pi_j < c d_j-Delta-4c. The step phi_j <= min(cd_j,pi_j)+Delta (line 302) is correct once the per-region lower bound is stated correctly (see the previous item). The upper-bound witness h_S and the encoding of K(a_j|h*) (flag, t, list index, d_j) are fine; per-region O(1) overheads are covered by the per-region kappa+4 in Delta_0.",
    "evidence": "Line-by-line check of lines 292-303.",
    "suggested_fix": "None beyond the Delta_0 constant correction."
   },
   {
    "item": "Cor 3.4 (every convex hull shape is realizable)",
    "severity": "minor",
    "description": "(a) The claim \"A fair-coin region adds the constant 1-sum pi_j to every hypothesis's risk\" is false. Cross-entropy against a fair coin is >= 1 bit per unit mass, with equality only for hypotheses that are uniform on that region. This is harmless, because the proof only needs R >= pi_0 + sum pi_j R_j, and the upper-bound witnesses are uniform there. (b) \"*Any* convex decreasing piecewise-linear frontier is realizable\" overclaims. The realized frontiers start at about (0,1), drop by at most 1 bit/sample in total (binary labels), have integer edge lengths d_j, and match only up to a horizontal shift of sum_j(2log d_j+2log m+4+kappa)+kappa bits and a vertical shift of sum pi_j 2^{1-d_j/4}/ln2. So an arbitrary shape is realized only after rescaling the d_j upward. (c) Thm 3.3 controls the support function Phi(c), not the hull directly. The hull statement follows by Legendre duality, and that step should be stated.",
    "evidence": "For h with h(0|x)=0.9 on the coin region, the risk there is 0.5*(log2(1/0.9)+log2(1/0.1)) ≈ 1.737 bits, not 1.",
    "suggested_fix": "Write 'adds at least pi_0, with equality for hypotheses uniform there'. State the realizable class precisely: start (0,1), total drop <=1, slopes rational, d_j integers, everything up to an O(m log + m kappa) horizontal band, so any shape is realized after scaling. Add the Legendre-duality sentence."
   },
   {
    "item": "Thm 3.5 and the Section 3.4 numbers",
    "severity": "minor",
    "description": "The sandwich bounds are verified. In both regimes of the lower-bound split (c >= 1/n and c < 1/n), the stated second term is weaker than the true c(d-tau_t)+(K_tot-d+tau_t)/n but still valid, and K_tot >= d-tau_t holds. All numbers check out. The gap is in the gloss: §0 item 2 and §6 say that in Thm 3.5 'the good model is selected for c in (≈1/n, ≈(1-H(p))/d)', but Thm 3.5 only sandwiches Phi(c) and gives no identification of the minimizer.",
    "evidence": "c1: window (1.1185e-6, 8.989e-3); MDL switch at N=894054. d=20, p=2^-10: L_E=11710, window (9.54e-7, 0.0494). d=10, |E|=16: L_E=115.58, error rate 1.0046e-3, so lambda>1.029.",
    "suggested_fix": "Add an identification corollary. For c in the window, a near-optimal h has R <= H(p)+slack, and Lemma 2.5b then gives shat(a) >= 2^{1-R}-1-2p, i.e. strong correlation with f_a. Alternatively, soften 'selected' to 'Phi(c) is attained, up to slack, by the good model'."
   },
   {
    "item": "Thm 4.1 (rate blindness) (ii),(iii)",
    "severity": "minor",
    "description": "(i) and (iv) are correct and TOSU (trivial once set up). (ii) The proof 'c < r_v/k_v <= r_e/k_e' ignores ties. Thm 3.2 makes ties arbitrary, so at c=r_v/k_v=r_e/k_e it is possible that v is selected and e is not. In the Thm 3.3 setting the rate criterion holds only outside the Delta-bands, because true marginal costs are d_j+O(log d_j+log m); so (ii) is unproved for c inside those bands. (iii) 'selectable iff on hull^-(A)' fails for points on the horizontal or vertical rays of the boundary of conv(A+R^2_{>=0}). 'Uniquely selectable iff vertex' holds for points, not hypotheses: if another hypothesis has the same (l,R), h° is never the unique minimizer. The same imprecision appears in §0 item 2 ('A hypothesis is the unique minimizer ... iff it is a hull vertex').",
    "evidence": "Rays: A={(0,1),(1,0),(2,0)}. The point (2,0) lies on the boundary but is never a minimizer for c>0. Hypothesis ties: two hypotheses with identical (l,R) at a vertex are co-minimizers on the whole interval.",
    "suggested_fix": "(ii): say 'for every c not equal to a tie value' (Thm 3.2), and 'for c outside the slack bands' (Thm 3.3). (iii): require the point to lie on the part of hull^- with finite negative slope, and require h° to be the only hypothesis at that point."
   },
   {
    "item": "Illustrative claim after Thm 4.1 (line 351: 200-bit rule at frequency 1e-4 'is discarded at any c that rejects the user's 10 000-bit error')",
    "severity": "minor",
    "description": "This holds only if the per-use gain g <= 2.24 bits. It also compares rates across two different settings: a binary-label parity setting and M-way step imitation.",
    "evidence": "The rule's rate is 1e-4*g/200 = 5e-7 g, and the user's error rate is 1.1185e-6. With the file's own c4 value g=5.42, the rule's rate is 2.7e-6 > 1.12e-6, so every c in (1.12e-6, 2.7e-6) rejects the error and keeps the rule.",
    "suggested_fix": "Add 'if g <= 2.2 bits', or rephrase as 'a slightly rarer or longer rule is discarded'."
   },
   {
    "item": "Prop 4.2 (cheap fallacies)",
    "severity": "ok",
    "description": "Correct within the model; it is Thm 3.2/4.1(ii) applied. The rate ratio pi_AC/pi_MP assumes equal g, i.e. the same M and eta, which holds in c4. The c4 numbers are reproduced exactly: AC 5.42e-3, orE 1.36e-3, negI 1.55e-3, botE 7.23e-4, induction 1.21e-4, FD 2.46e-3, CP 2.17e-3, and the simplicity-only window is empty. The follow-up paragraph ('a fallacy becomes systematic exactly because it is short') is an empirical conjecture, not part of the proposition.",
    "evidence": "c4 output.",
    "suggested_fix": "Optionally label the 'not an accident' paragraph as a conjecture."
   },
   {
    "item": "Thm 4.3 (validation prefers the teacher; non-identifiability of c)",
    "severity": "minor",
    "description": "(ii) is correct: strict propriety, pointwise and then integrated (Gneiting–Raftery 2007 is cited correctly), with 'closest' meaning in the scoring rule's divergence. (iii) is correct by the twin-world argument. Three caveats. First, (i) 'picks the smallest c considered' holds only asymptotically for a fixed finite c-grid. At finite N with lambda=cN, Lemma 1.2's B/c term blows up for small c, and cross-validation picks an interior c when the error component is not yet learnable from N samples. Second, §0 item 3(c) states the SafeBayes conclusion as fact, while the body (line 386) calls it an unchecked reading. That reading is plausible: R-SafeBayes minimizes posterior-expected log loss, whose optimum concentrates on P*, and the user's eta=1/(cN)->0 Gibbs measure does not concentrate. Third, §6's 'Every data-fit criterion targets the teacher's channel' overreaches. Imitation-data heuristics that use no proper score, e.g. picking the hull vertex with the widest log c-interval (the 'knee'), would pick the good model in the user's example. Only (iii) rules out a criterion that is correct in all worlds.",
    "evidence": "c4 cross-validation lines reproduce the stated results: held-out loss 1.0, 0.01117, 0.01117, 0. In the user's example the good model's c-interval spans a factor of about 8037, far wider than any other vertex's interval.",
    "suggested_fix": "In (i), say 'for a fixed finite grid as N->inf'. Hedge the SafeBayes claim in §0. In §6, restrict the claim to proper-score validation and point to (iii) for the general statement."
   },
   {
    "item": "Prop 4.4 (guard erosion)",
    "severity": "minor",
    "description": "The conclusion 'for c above [the guard's rate] the selected rule is the unguarded, unsound sigma' needs two unstated hypotheses. The unguarded option must be a vertex of its region's 3-option hull, i.e. rate(unguarded sigma) > rate(guard). And c must stay below the unguarded schema's own net rate. Otherwise sigma is dropped altogether, which keeps the verifier sound. There is also a constant issue. The guard's gain is log2(M/eta)-log2(M-1) = log2(1/eta)+log2(M/(M-1)) > log2(1/eta), so 'rate at most pi log2(1/eta)/k_G' is slightly wrong; c4 correctly uses the exact value, 4.34 vs 4.32. If the guarded hypothesis also models the teacher's alternative step, the gain is larger and the '<=' fails.",
    "evidence": "M=64, eta=0.05, k_sigma=22, k_G=12, pi_G=0.002, pi_notG=0.002. The guard's rate is 7.24e-4 and the unguarded sigma's net rate is 1.0e-4. For every c above the guard's rate the selection is 'none', never 'unguarded' (script). The c4 instance (pi_G=0.05, pi_notG=5e-4) does satisfy the missing hypothesis: unguarded is selected for c in (1.81e-4, 1.22e-2).",
    "suggested_fix": "State the result as: if rate_G < rate_sigma(unguarded), then for c in (rate_G, rate_sigma) the unguarded schema is selected. Write the guard's rate as pi_notG*(log2(M/eta)-log2(M-1))/k_G for a guarded model that is uniform on the other M-1 steps in not-G contexts."
   },
   {
    "item": "Prop 4.5 (error envelopes)",
    "severity": "ok",
    "description": "Verified. The risk reduction H(p)-sigma H(theta) is correct. The example's numbers are correct: 0.0112-0.0032=0.0080, giving rate 2.7e-4. The remark that a K-random E admits no useful envelope is also right: an envelope would give K(E|a) <= k_S + sigma n H(theta) + O(log), i.e. deficiency of about n(H(p)-sigma H(theta)).",
    "evidence": "Direct computation.",
    "suggested_fix": "None."
   },
   {
    "item": "(d3) Non-additivity: parasitic errors",
    "severity": "minor",
    "description": "This is labelled '[proved by example]', but no worked example is given. The closing claim, 'the selection path ... interleaves valid and erroneous refinements in an order fixed by conditional rates', is false in general. With non-additive costs, bundles enter the hull together, and a valid rule can be selected only because it subsidizes a cheap error.",
    "evidence": "Take v with k=10, r=0.01 (rate 1e-3), and e with K(e)=100, K(e|v)=1, r=0.01. At c=1.5e-3 the optimum is {v,e} (J=-0.0035 vs 0, +0.005, +0.14). Yet rate(v)=1e-3 < c, and e's unconditional rate is 1e-4 < c. Neither a per-component rule nor a conditional-rate ordering predicts this.",
    "suggested_fix": "Replace the ordering claim with 'the selection path is the hull of the subset lattice under the joint code; bundles {v,e} can enter together, so valid rules may be kept because of the errors they subsidize'. This strengthens the pathology. Also give one explicit numerical example."
   },
   {
    "item": "(d6) Language relativity",
    "severity": "minor",
    "description": "The claim is true, but the construction is wrong. 'Pad with unused codewords to satisfy Kraft' cannot work, because adding codewords only increases the Kraft sum. The construction also needs r_j>0 for every j in S°.",
    "evidence": "With l(h_S)=l_0+sum_{j in S}k_j, the Kraft sum is 2^{-l_0} prod_j(1+2^{-k_j}). This is <=1 iff l_0 >= sum_j log2(1+2^{-k_j}). Setting l_0=m works for any integers k_j>=0, and k_j=0 handles r_j/c<1. Separately, under the invariance theorem the marginal cost k changes by up to 2c_UV, not c_UV.",
    "suggested_fix": "Replace the padding step with 'prepend a common prefix of length l_0 >= sum log2(1+2^{-k_j})'. Assume r_j>0 for j in S°. Use 2c_UV."
   },
   {
    "item": "(d4), (d5), (d7)",
    "severity": "ok",
    "description": "(d4) and (d5) are cross-references to Prop 5.3 and Prop 2.6. (d7) is a correct TOSU remark: rates scale with D-frequency and lambda=cN fixes the selection asymptotically.",
    "evidence": "Inspection.",
    "suggested_fix": "None."
   },
   {
    "item": "Section 5.1 (situation-typed step imitation)",
    "severity": "ok",
    "description": "This is a correct instance of Thm 3.2 with two options per type, and g_tau=log2 M-H_tau matches c4 (5.423 bits). Small points: the rate formula drops the stated '+O(1)' per modelled type, i.e. rho=pi g/(l+O(1)). The symbol g is reused for net value g_j=r_j-c k_j in §5.2.",
    "evidence": "c4 output: g=5.423.",
    "suggested_fix": "Write rho_tau=pi_tau g_tau/(l(sigma_tau)+O(1)), and rename the net value in §5.2, e.g. to nu_j."
   },
   {
    "item": "Thm 5.2 (division of labour)",
    "severity": "minor",
    "description": "The statement is verified. Proof steps 1-3 are correct; the zero-value case of E_1 also works, because witnesses inside a feasible S are nonempty so B is nonempty and sum_B g>0. Step 4 is loose: 'Adding V_+\\S keeps feasibility' can fail when the optimal S contains zero-valued valid rules. The conclusion is unaffected. Also, the 'spelled out' attributions to coherence, world feedback and postulates presuppose that 𝔉 is the intersection of the three families and that error-independence and valid dominance hold for that intersection.",
    "evidence": "Brute force: on 20,000 random instances with error-independence built in and about 10% zero-valued components, 17,806 satisfied valid dominance. In every one, the optimal sets minus zero-valued items equal S*(c); there were 0 violations. Step-4 counterexample: V={v+,v0}, g(v0)=0, F with sole witness {v+,v0}. Then S={v0,F} is feasible but S∪{v+} is not.",
    "suggested_fix": "In step 4, first delete zero-valued items from S, or compare val(S*) >= val(S) directly, since S∩E ⊆ {F: V_+∪{F} feasible, g_F>=0}. Make the intersection assumption explicit."
   },
   {
    "item": "Cor 5.2a (separation iff max surviving error rate < min valid rate)",
    "severity": "minor",
    "description": "This holds only under valid dominance (and error-independence) at the separating c. The corollary does not restate these hypotheses, and valid dominance depends on c. Without it the 'if' direction fails because of sacrifice. There is also an edge case: if max = min, a zero-value tie can still allow separation.",
    "evidence": "V={v} with r=0.01, k=10 (rate 1e-3). E={F} with r=0.02, k=10 (rate 2e-3) and witness {v}. No error survives relative to V, so the corollary predicts separation. In fact, for every c<1e-3 the coherent optimum is {F} (value 0.02-10c > 0.01-10c), and for c>=1e-3 the rule v is lost (script).",
    "suggested_fix": "Prefix the corollary with 'Under the hypotheses of Thm 5.2 (valid dominance at the relevant c)', and use <= with tie-breaking, or say 'uniquely possible'."
   },
   {
    "item": "Prop 5.3 (coherence repair by sacrifice)",
    "severity": "minor",
    "description": "The proof is correct and the brute-force check confirms it. Error-independence is used implicitly to keep S'=(V_+\\B)∪{F}∪{other feasible errors} feasible, and F must have a witness inside V_+. The second sentence, 'Every optimum either contains F ... or does better still', is vacuous. One caveat on the c4 illustration: it relies on the designated contexts being only {∅}. With substantive designated contexts, which T2 allows (e.g. {p0->q0, q0, ¬p0}), MP is itself a witness partner for AC. Sacrificing MP is too costly, so in that setting AC is dropped rather than →I.",
    "evidence": "Brute force: 1,882 random instances with beta(F)<g_F. In all of them the clean set V_+∪{feasible errors} is strictly suboptimal; 0 violations. The c4 output matches the text: at c=5e-4 with →I rare (rate 8.7e-4), the coherent optimum is {AC, MP, ⊤I}; with →I frequent it is {MP, →I, ⊤I}.",
    "suggested_fix": "State error-independence and 'F has a witness inside V_+' as hypotheses. Drop the 'or does better still' clause. Note that the c4 example assumes A={∅}."
   },
   {
    "item": "Prop 5.4 (meaning postulates) (a)",
    "severity": "minor",
    "description": "(a) is ill-quantified. 'F is excluded at every c iff V_+ ∪ Ax ∪ G(F) ⊢ ⊥' uses V_+, which depends on c. Correctly: F is excluded at every c iff for every c < rho_F the set {v: rho_v>c} ∪ Ax ∪ G(F) is incoherent, i.e. some witness uses only valid rules whose rate is at least rho_F. Valid dominance is also needed. So exclusion is 'rate-independent' only relative to the rates of the witness rules; for FD the witness rule is substitution of equals, with rate 4.07e-2. (b) is verified: (1+1)^2 = 1^2+1^2 leads to 4=2. 'FD plus ring rules derives only 2ab=0' is loose, since it also derives 2=0, but the coherence claim is right: FD holds in characteristic 2. (c) and (d) are fine.",
    "evidence": "Inspection; c4 rates.",
    "suggested_fix": "Restate (a) with the c-dependent V_+ and the valid-dominance hypothesis, and say that 'rate-independent' means independent of rho_F given that the witness rules are kept."
   },
   {
    "item": "Section 5.4 toy table",
    "severity": "ok",
    "description": "Every rate, every 'loses k valid rules' count and both window statements match the c4 output. The final window for removing the false lemma, (9.04e-6, 1.21e-4), is nonempty. Valid dominance for AC holds throughout the grid: beta=0.434-25c exceeds sum_{E+} g ≈ 0.26.",
    "evidence": "c4 output.",
    "suggested_fix": "None."
   },
   {
    "item": "Lemma 3.1 (convex hull)",
    "severity": "ok",
    "description": "Standard and correctly labelled as such. (i) and (ii) are correct; the derivation (c'-c)(l(h')-l(h)) <= 0 is right. (iii) is correct as a statement about points. Two hypotheses are needed: only finitely many hypotheses have l<=L, and R>=0. Together they make the sup of slopes to the right attained, so every extreme point has an open cone of normals. The proof of (iii) is terse: the 'two other boundary points' must be taken as the edge endpoints, which lie in A. Hypothesis-level issues are reported under Thm 4.1.",
    "evidence": "Hand check, plus c3(ii).",
    "suggested_fix": "Optionally say that the edge endpoints are in A, and that s_+=0 at the rightmost vertex."
   },
   {
    "item": "Thm 3.2 (separable rate threshold)",
    "severity": "ok",
    "description": "Correct and TOSU. It implicitly needs finitely many regions and k_j>0.",
    "evidence": "c3(i): 0 violations in 6000 cases. c3(iii): 0 violations in 2000.",
    "suggested_fix": "State k_j>0."
   },
   {
    "item": "Re-run of T5-checks/c3_rate_threshold.py",
    "severity": "minor",
    "description": "The output reproduces exactly: (i) 0/6000, (ii) 0/0/0, (iii) 0. However, the (ii) test for 'minimizers off hull' is vacuous. It compares the global minimum value with the minimum over hull vertices and never tests the minimizer p itself (the loop variable p is unused). Monotonicity and vertex selectability are genuinely tested.",
    "evidence": "c3 lines 48-51: `for p in mins: if abs(min(c*a+b for a,b in Hv) - val) > 1e-12` does not depend on p.",
    "suggested_fix": "Test whether each minimizer p lies on a hull edge or vertex, or simply drop that claim from the [computed] annotation."
   },
   {
    "item": "Re-run of T5-checks/c4_rules_toy.py (and c1, c2 for the Thm 3.5 numbers)",
    "severity": "ok",
    "description": "All outputs match the file: g=5.423, the rate list, the filter tables, the windows, guard erosion (rate 1.81e-4, dropped while botE kept at 7.23e-4), the sacrifice trade-off, and the CV pathology. c1 and c2 also match Section 3.4.",
    "evidence": "Script outputs.",
    "suggested_fix": "None."
   },
   {
    "item": "Section 0 / Section 6 assessment and novelty claims; literature",
    "severity": "minor",
    "description": "Most standardness labels are honest (Lemma 3.1, Thms 3.2, 4.1, 4.3, 5.2 are flagged TOSU or standard). Problems: the overstatements already noted (§0's 'unique minimizer iff vertex' for hypotheses, 'every' hull shape, 'the good model is selected' from Thm 3.5, unhedged SafeBayes, and §6's 'every data-fit criterion'). Thm 3.3's 'explicit O(log) slack' carries the incorrect constants identified above. The Parseval list-size bound behind Thm 3.3 (Lemma 2.5a) is the standard Fourier list-decoding fact (Goldreich–Levin 1989; Kushilevitz–Mansour 1993) and should be cited, even though the combination with the coding theorem may be new. The citations checked look accurate: Gneiting–Raftery 2007 JASA 102:359-378; Grünwald 2012 ALT; Grünwald–van Ommen 2017 BA 12(4); Lieberman et al. 2007 Nature 449:713-716 (half-life ∝ frequency^{1/2}); Armstrong–Mindermann 2018 NeurIPS; Vereshchagin–Vitányi 2004. The VV realizability side conditions are correctly flagged as unverified.",
    "evidence": "Cross-reading §0 and §6 against the theorems as stated.",
    "suggested_fix": "Align the §0 and §6 wording with the corrected statements and add the Goldreich–Levin / Kushilevitz–Mansour citation."
   }
  ],
  "overall": "Most of Sections 3-5 holds up. The results are largely trivial once set up or standard, and they are honestly labelled that way. Re-running c3 and c4 (and c1 and c2 for the Thm 3.5 numbers) reproduces every number quoted in the file. Brute-force checks confirm Thm 5.2 (17,806 random instances satisfying error-independence and valid dominance, 0 violations) and Prop 5.3 (1,882 instances, 0 violations).\n\nOne statement is false: the second identification clause of Thm 3.3. Its proof uses the inequality 1-log2(1+2^{1-t}) >= 1-2^{1-t}, which goes the wrong way. A hypothesis that predicts the true parity with confidence 0.745 has shat=0.49<1/2. It satisfies both hypotheses of the clause (m=1, pi=1, d=40, small c, eta=J(h)), so it contradicts the conclusion. The fix is a constant change: pi_j > 2.41(Delta+8c), or conclude shat >= sqrt2-1. The two-sided Phi estimate in Thm 3.3 survives with the stated Delta_0, which I checked analytically and numerically, but its written proof contains the same incorrect step.\n\nMinor issues:\n* Thm 4.1: ties, slack bands, boundary rays, and uniqueness stated for points rather than hypotheses.\n* Prop 4.4 is missing a hypothesis: the unguarded option must be a hull vertex. Counterexample: with pi_G=pi_notG=0.002 the selection jumps to 'none'.\n* Cor 5.2a needs valid dominance; there is an explicit counterexample without it.\n* Prop 5.4(a) is ill-quantified, because V_+ depends on c.\n* (d3)'s 'order fixed by conditional rates' is false: bundles can enter the hull together.\n* (d6)'s Kraft 'padding' step is wrong.\n* Cor 3.4 overstates 'any shape' and wrongly says the coin region adds a constant to every hypothesis's risk.\n* The 200-bit-rule illustration after Thm 4.1 is false for g > 2.24 bits.\n* Thm 4.3(i) holds only asymptotically.\n* The c3(ii) on-hull test is vacuous.\n\nNone of these overturns the qualitative conclusions: selection is by rate rather than validity, proper-score validation targets P*, guards can erode, and the division of labour holds under its stated assumptions."
 }
]
```

---

## Author-repairer's log

The log below is identical to the "Verification log" section appended to the theory file.

### Verification log (as appended to the theory file)

Two independent adversarial referees checked this file: Referee A covered §§1–2, and Referee B covered §§3–6. Their full reports are reproduced in `verification/T5-verification.md`. I re-checked every reported issue myself, using computation where useful. Severity tags are the referees' own.

**Re-checks run.**
* Re-runs of `T5-checks/c1`–`c5`. Every number quoted in the file reproduces.
* `T5-checks/c3_rate_threshold.py`. Its vacuous on-hull test was repaired, and its result is unchanged.
* New script `T5-checks/repair_checks.py`, which covers:
  * the Thm 3.3 counterexample and the corrected constants;
  * the minimax example for Thm 2.1;
  * the $p$-crossover for Thm 2.5(b);
  * the identity and concentration behind Lemma 2.5c;
  * the $o(1)$ bound for Thm 2.5(a);
  * the telescoping identity for Prop 2.6, and the exact norm-model loss in c5;
  * the hull example for Thm 4.1(iii);
  * the illustration after Thm 4.1;
  * the three-option hull for Prop 4.4;
  * the bundle example for (d3);
  * the Kraft construction for (d6);
  * the counterexamples for Cor 5.2a and for Thm 5.2 step 4;
  * the numbers for Cor 3.5a.

**Outcome in brief.**
* **One fatal issue, genuine.** Identification clause 2 of Thm 3.3 was false: its proof used $1-\log_2(1+2^{1-t})\ge1-2^{1-t}$, which goes the wrong way. The constants are now corrected, and the proof of the two-sided estimate is rewritten with the exact risk floor. $\Delta_0$ is unchanged.
* No issue was labelled major.
* Every minor issue was genuine and has been fixed or made precise. No issue was rejected.
* The most substantive minor repair is to Thm 2.5(b): the $2p$ slack meant no kink was shown for $p\ge0.142$. A new Lemma 2.5c, combining concentration with coding, replaces the slack by $O(\sqrt{p(\delta_E+\log n)/n})$ for incompressible $E$.
* Cor 3.5a (identification in the parity example) is new.

#### Referee A (§§1–2)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| A1 | §1.2–1.3 setup (causal conditioning; $K(h)$ as a minimum; objects outside the class) | minor | yes | **Fixed.**<br>• Def 1.1 now separates causally conditioned from general shared-randomness hypotheses, and notes that they coincide for a fixed $x_{1:N}$, which is all §2 uses.<br>• $K(h):=\min\{\lvert p\rvert:p\text{ computes }h\}$, with $h^*$ a shortest program.<br>• §1.3 declares an *enlarged class* (lower-semicomputable semimeasures, computable real-valued predictors) used only by Prop 2.3 ($M$), Thm 2.4 ($m$) and Prop 2.6 for infinite families. Each of these results now says so. |
| A2 | Lemma 1.2 | ok | n/a | **Clarified.** "On the same event" is added, as is a line proving that both minimizers exist (finite sublevel sets under Kraft). |
| A3 | §1.4 literature | ok | n/a | No change. |
| A4 | Thm 2.1 (minimax value; group condition) | minor | yes | **Fixed.**<br>• I confirmed the referee's example by optimization: $\max_Q\sum H(Q_x)=\min_h\max_f=2.5431<2.5850$.<br>• The exact minimax value is now stated as $\max_Q\sum_iH(Q_{x_i})$, via Sion's theorem.<br>• The value equals $\sum\log\lvert F(x_i)\rvert$ iff a uniform-marginal $Q$ exists.<br>• The group condition is rephrased as $(g\cdot f)(x)=\sigma_{g,x}(f(x))$ with the induced action transitive on each $F(x)$. The proof that $\mathrm{Unif}(F)$ then has uniform marginals is added. |
| A5 | Prop 2.2 | ok | n/a | No change. |
| A6 | Prop 2.3 (§0 threshold) | minor | yes | **Fixed.**<br>• §0 now gives the threshold as $c_M+O(1)/(\lambda-1)$.<br>• The body gives $c_M+(c_M+c_0)/(\lambda-1)$, notes that it tends to $c_M$ (not to 0) as $\lambda\to\infty$, places $M$ in the enlarged class, and names $P_u$ as an in-class stand-in. |
| A7 | Thm 2.4 | ok | n/a | **Clarified.** The phrase is now "fixed predictor whose odds are bounded by a machine constant", and $m$ is placed in the enlarged class. |
| A8 | Lemma 2.5a | minor | yes | **Fixed.** The lemma is stated for $t\in\mathbb N$ ($\lceil t\rceil$ for real $t$). It is labelled standard and credited to Goldreich–Levin (1989) and Kushilevitz–Mansour (1993). Thm 2.5(b) and Thm 3.5 now quantify over $t\in\mathbb N$. |
| A9 | Lemma 2.5b | ok | n/a | **Clarified.** A tightness remark is added: the additive $p$ cannot be removed using $\hat s_h(a)$ alone. This motivates Lemma 2.5c. |
| A10 | Thm 2.5(a) (flatness and selection only via upper bounds) | minor | yes | **Fixed (statement and proof revised).**<br>• Added $K(P_u)\ge d-u-\kappa'$. Proof: the argmax of $P_u(f_{a'})$ has the true prefix, because $\frac n2\log_2\frac{1-p}p>d$.<br>• Added $-\log P_u(y^*)\ge u+nH(p)-o(1)$. The other components lose by a factor $(p/(1-p))^{n(1/2-2p)}$; the $o(1)$ is $<2^{-2800}$ bits at $d=10$.<br>• The selection claim is now $d-u^*\le\frac{\lambda}{\lambda-1}(2\kappa'+o(1))$, which is vacuous for $\lambda-1\lesssim\log d/d$. It is exact ($u^*=d$) in the computable version.<br>• The assumption $K(p)=O(\log d)$ is made explicit in the §2.2 setting, with the remark that $K(\lvert E\rvert)$ can be of order $d$ otherwise.<br>• §0 is updated. |
| A11 | Thm 2.5(b) (2p slack; "worthless" overstatement), Reading, §2.4 | minor | **yes** | **Fixed (new Lemma 2.5c; (b) restated).**<br>• I confirmed the crossover: $1-2p/\ln2=H(p)$ at $p=0.14215$.<br>• I took the referee's second suggestion. **Lemma 2.5c** shows that $R(h)\ge1-\log_2(1+(1-2p)\hat s_h(a)+\varepsilon_h)$ with $\varepsilon_h=\sqrt{32\ln2\cdot p(\delta_E^++K(h)+\kappa_n)/n}$.<br>• *Proof of 2.5c.* An exact identity (checked to machine precision) shows that $\mathbb E_xh(y^*\mid x)$ depends on $E$ only through the average of $\sigma_h=s_h\chi_a$ over $E$. Hoeffding (1963) for sampling without replacement bounds the number of $pn$-sets with deviation $\ge\eta$. A coding argument then bounds the deviation of the actual $E$ by $\delta_E+K(h)+O(\log n)$.<br>• Thm 2.5(b) now has slack $\beta_t=\min\{2^{-t}+2p,(1-2p)2^{-t}+\varepsilon_E\}$. The text states that the unconditional term shows a kink only for $p<0.1421$, while the second shows one for all $p<1/4$ once $\varepsilon_E$ is small.<br>• The "worthless / buys nothing" phrasing in the Reading, §2.4, §0 and §6 is replaced by the exponential-decay statement (advantage $\le2^{-m/2+O(\log d)}$ plus slack). The c2(b) list mixtures, at $2^{-u}(1-H(p))$, show that the true decay is between $1/2$ and $1$ in the exponent.<br>• Two caveats are added: the kink is shown only up to $O(\log d)$ bits, and the unconditional slack leaves a chord gap for small $K(h)$.<br>• Thm 3.5 uses the new $\beta_t$. |
| A12 | Thm 2.5(c) (missing $2\log_2d$) | minor | yes | **Fixed.** $K(y^*\mid h^*,d)$ is now used, so (c) reads $K(h)+nR(h)\ge d+L_E-\delta_E-2\log_2d-\kappa$. The change is propagated to Thm 3.5 ($K_{\rm tot}$), where the second lower-bound term stays valid because $K_{\rm tot}-d+\tau_t=L_E-\delta_E+s(t)$. |
| A13 | Prop 2.6 (complexity bound; proof) | minor | yes | **Fixed.**<br>• The family is now *uniformly computable* with computable $w$, and $K(h_w)\le K(w,(\nu_\theta)_\theta)+O(1)$.<br>• A note covers rational outputs for finite families, the enlarged class for infinite ones, and possible non-computability for arbitrary families.<br>• The proof now writes out the telescoping $\prod h_w=Z_{\lvert b\rvert+1}/Z_1$, valid for history-dependent $\nu_\theta$ and history-dependent inputs. It was checked numerically ($4\cdot10^{-15}$).<br>• The c5 copier is described as a finite family. |
| A14 | Prop 2.6 consequence (c5 numbers) | ok | n/a | **Clarified.** The exact norm-model loss of 4.635 bits per context (recomputed) is quoted, with a note that c5's 4.52–4.76 spread is Monte Carlo noise. |
| A15 | §2.3 design consequence | ok | n/a | No change. |
| A16 | Scripts c1, c2, c5 | ok | n/a | No change. |

#### Referee B (§§3–6)

| # | item | severity | genuine? | action |
|---|---|---|---|---|
| B1 | Thm 3.3 identification clause 2 | **fatal** | **yes** | **Fixed (statement revised).**<br>• I reproduced the counterexample: $q\in\{0.74,0.745,0.749\}$ and $\kappa\in\{10,100,1000\}$ all satisfy the old hypotheses, with $\hat s<\frac12$.<br>• New clause 2: $\pi_j\,g(d_j/4)>c\,d_j+\Delta$ and $\pi_j\,g(2)>\Delta+8c$, where $g(t)=1-\log_2(1+2^{1-t})$ is concave and increasing. These are implied by $\pi_j>c\,d_j+\Delta+\pi_j2^{1-d_j/4}/\ln2$ and $\pi_j>2.41(\Delta+8c)$.<br>• The proof now uses the exact floor and concavity on $[2,d_j/4]$.<br>• [computed] 0 violations in 8474 random admissible instances. The counterexample fails the new second condition, by a factor of 1.01–1.06.<br>• The constant $1/g(2)$ is optimal for this method.<br>• I did not adopt the referee's alternative (keep the hypotheses and conclude $\hat s\ge\sqrt2-1$). With the $s(t)\le4t$ bound used in the proof, the $t=3$ branch needs $0.678\pi>\Delta+12c$, which $\pi>2\Delta+16c$ does not imply, so that variant would need a finer argument. |
| B2 | Thm 3.3 two-sided estimate (proof step) | minor | yes | **Fixed (proof rewritten; statement unchanged).**<br>• The false inequality is removed. The per-region bound now uses $g$, concavity on $[1,d_j/4]$, and the referee's two-case absorption argument: $\log_2(1+u)-u\le0.443u$ and $0.886\,d\,2^{-d/4}\le4$, with maximum 1.88.<br>• The $d_j<4$ case is handled separately.<br>• [computed] 0 violations over the referee's grid, with both $s(t)$ and $4t$. |
| B3 | Thm 3.3 clause 1 | ok | n/a | No change. The per-region bound it relies on is now correctly proved (B2). |
| B4 | Cor 3.4 | minor | yes (all 3 points) | **Fixed (statement made precise).**<br>• The coin region contributes "at least $\pi_0$, with equality for hypotheses uniform there".<br>• The Legendre-duality step is written out, giving the explicit sandwich $P(k+C')-\epsilon\le\breve\rho(k)\le P(k-C')+\epsilon$.<br>• The realizable class is stated: start at height 1, total drop $\le1$, rational slopes, integer lengths, up to the bands. "Any shape" is weakened to "any such shape after rescaling".<br>• §0 and §6 are updated. |
| B5 | Thm 3.5 / §0, §6 "the good model is selected" | minor | yes | **Fixed (new Cor 3.5a).** For $J_c(h)\le\Phi+\eta$:<br>• (i) $\hat s_h(a)\ge2^{1-c(d+\kappa')-H(p)-\eta}-1-2p$;<br>• (ii) if $cn>1$, $R(h)\ge H(p)-(\eta+c\Lambda)/(cn-1)$, i.e. almost no error memorization.<br>Numbers are computed for $d=20$. §0 and §6 now cite Cor 3.5a instead of saying "selected". |
| B6 | Thm 4.1 (ii),(iii); §0 "unique minimizer iff vertex" | minor | yes | **Fixed.**<br>• (ii) excludes the common tie value in Thm 3.2's setting, and holds outside the slack bands in Thm 3.3's setting, with a short proof via the clauses.<br>• $\mathrm{hull}^-(A)$ is now defined as the boundary part with finite negative slope; the ray example is included.<br>• Lemma 3.1(iii) and Thm 4.1(iii) distinguish points from hypotheses ("and no other hypothesis has the same point").<br>• Lemma 3.1's proof states that edge endpoints are in $A$ and that $s_+=0$ at the rightmost vertex.<br>• §0 and §6 are updated. |
| B7 | 200-bit-rule illustration | minor | yes | **Fixed.** The claim is now conditional on $g\le2.2$ bits (break-even 2.24). With $g=5.42$ the rule survives on $(1.12,2.7)\cdot10^{-6}$. The cross-setting caveat is added. |
| B8 | Prop 4.2 | ok | n/a | **Clarified.** The "not an accident" paragraph is labelled an empirical conjecture. |
| B9 | Thm 4.3 (i), §0 SafeBayes, §6 | minor | yes | **Fixed.**<br>• (i) is stated for a fixed finite grid as $N\to\infty$, with the finite-$N$ caveat (Lemma 1.2's $B/c$).<br>• §0 hedges the SafeBayes claim as an unchecked reading.<br>• §6 restricts the claim to proper-score validation, cites the knee heuristic as a non-proper criterion that succeeds in the user's example, and points to (iii) for the general impossibility. |
| B10 | Prop 4.4 (missing hypothesis; constant) | minor | yes | **Fixed (statement revised).**<br>• The three options and the rates $\rho_\sigma$ and $\rho_G=\pi_{\neg G}\Delta_G/k_G$, with $\Delta_G=\log_2(M/\eta)-\log_2(M-1)>\log_2(1/\eta)$, are explicit.<br>• Claim: if $\rho_G<\rho_\sigma$, the unguarded rule is selected exactly on $(\rho_G,\rho_\sigma)$. Otherwise the path goes guarded → none and stays sound.<br>• The referee's counterexample (selection path guarded → none at $3.2\cdot10^{-4}$) and the c4 instance (unguarded on $(1.8\cdot10^{-4},1.22\cdot10^{-2})$) are both reproduced.<br>• §0 and §6 are qualified. |
| B11 | Prop 4.5 | ok | n/a | No change. |
| B12 | (d3) ordering claim | minor | yes | **Retracted and replaced.** The selection path is now described as the hull of the subset lattice under the joint code, in which bundles can enter together. The referee's example ($\{v,e\}$ optimal at $c=1.5\cdot10^{-3}$ although both separate rates are $<c$) is included and recomputed. §0 is updated. |
| B13 | (d6) Kraft construction | minor | yes | **Fixed.**<br>• The construction now uses a common prefix $\ell_0=m$; the Kraft sum is $2^{-\ell_0}\prod(1+2^{-k_j})\le1$.<br>• It requires $r_j>0$ on $S^\circ$, and the invariance bound is now $2c_{UV}$.<br>• [computed] 0 failures in 3000 instances. |
| B14 | (d4), (d5), (d7) | ok | n/a | No change. |
| B15 | §5.1 | ok | n/a | **Clarified.** The rate is now $\pi g/(\ell+O(1))$. Net values in §5.2–5.3 are renamed $\nu_j$. |
| B16 | Thm 5.2 (step 4; intersection) | minor | yes | **Fixed (proof tightened).**<br>• Step 4 is replaced by a direct value comparison, and the referee's zero-value counterexample to the old step is included.<br>• The zero-valued $E_1$ case is written out.<br>• It is made explicit that $\mathfrak F$ is the intersection of the filters in use, and that the assumptions are imposed on it. |
| B17 | Cor 5.2a | minor | yes | **Fixed (hypotheses added).** The corollary now assumes error-independence and valid dominance at every $c$ considered. It characterizes separation at $c$ with strict inequalities and includes a proof. The referee's counterexample without valid dominance is reproduced. |
| B18 | Prop 5.3 | minor | yes | **Fixed.** Error-independence and "$F$ has a witness inside $V_+$" are stated as hypotheses. The vacuous clause is replaced by the explicit improving set $S'$, with a feasibility proof. The c4 caveat ($\mathcal A=\{\emptyset\}$; with substantive contexts, AC rather than →I is dropped) is added. |
| B19 | Prop 5.4(a) quantification | minor | yes | **Fixed (re-quantified).**<br>• $F$ is excluded at every $c$ iff some witness consists of valid rules with $\rho_w\ge\rho_F$. A proof is given, via a choice of $c$ between $\max_W\min_{w\in W}\rho_w$ and $\rho_F$.<br>• "Rate-independent" is explained, with the FD witness rate $4.07\cdot10^{-2}$.<br>• In (b), "only $2ab=0$" now reads "$2ab=0$ and hence $2=0$; coherent in characteristic 2".<br>• §0 and §6 are qualified. |
| B20 | §5.4 table | ok | n/a | No change. |
| B21 | Lemma 3.1 | ok | n/a | **Clarified.** The finiteness and $R\ge0$ hypotheses are made explicit in the proof, along with the edge endpoints in $A$ and $s_+=0$. |
| B22 | Thm 3.2 | ok | n/a | **Clarified.** The theorem now states finitely many regions and $k_j>0$. |
| B23 | c3 (ii) on-hull test vacuous | minor | yes | **Fixed.** The test now checks that each minimizer lies on a vertex or edge of the computed hull, and a sanity check confirms that it detects an off-hull point. The result is still 0 violations, and the [computed] note says the test was repaired. |
| B24 | c4 (and c1, c2) re-run | ok | n/a | No change. |
| B25 | §0/§6 wording; literature | minor | yes | **Fixed.** §0 and §6 are aligned with every revised statement above. Lemma 2.5a is listed as standard, with citations to Goldreich–Levin and Kushilevitz–Mansour. Hoeffding (1963) and Sion (1958) are added to the references. |

**Items whose statement or proof changed non-trivially** (to re-verify): Thm 3.3 (clause 2 and the lower-bound proof), Thm 2.5(a)(b)(c) with the new Lemma 2.5c, Thm 3.5 (lower bound), new Cor 3.5a, Cor 3.4, Thm 2.1(i), Prop 2.6, Prop 4.4, (d3), (d6), Lemma 3.1 / Thm 4.1(ii),(iii), Thm 5.2 (proof), Cor 5.2a, Prop 5.3, Prop 5.4(a), and Thm 4.3(i).
