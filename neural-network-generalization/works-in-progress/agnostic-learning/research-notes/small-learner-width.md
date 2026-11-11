# Learner width tied to $n$: the tightly conditioned learner at width $n^\alpha$, $\alpha<1/4$ (`red-team.md` Proposition 6.1, corrected)

*This is a research note of the agnostic-learning note ([`../README.md`](../README.md)). It replaces the Proposition 6.1 part of §6.3 of the red-team report [`red-team.md`](red-team.md): Proposition 6.1, its proof, its "In particular" clause and the paragraph after it. The list of surviving versions that opens §6.3, and Remark 6.2 after Proposition 6.1, are not part of this note and stay in `red-team.md` (§7.3). The note keeps the numbering under which the second-round referees read it, and other documents cite its results by these numbers: `red-team.md` Proposition 6.1 is Theorem 1 here, and the other results are Lemmas A–F, Corollaries 2 and 3, Theorem 4 and Remarks 5–8. No result was renumbered or added after the second round. The problem is stated in the brief, [`problem-brief.md`](problem-brief.md). The note was refereed twice, each time by a logic referee and a computation referee. The first-round reports, [`../verification/RT-width-logic.md`](../verification/RT-width-logic.md) and [`../verification/RT-width-computation.md`](../verification/RT-width-computation.md), reviewed Proposition 6.1 and the text around it in `red-team.md` §6.3 (lines 480–497 of the version they read, published as [`../verification/red-team-first-version.md`](../verification/red-team-first-version.md); the final `red-team.md` keeps only a pointer to this note), and §9 answers them. Where this note cites "the display of `red-team.md` Proposition 6.1", it means that version. The second-round reports, [`../verification/RT-width-logic-revised.md`](../verification/RT-width-logic-revised.md) and [`../verification/RT-width-computation-revised.md`](../verification/RT-width-computation-revised.md), reviewed the repaired text, published as [`../verification/small-learner-width-first-version.md`](../verification/small-learner-width-first-version.md). Both found the repaired result correct and asked for minor fixes; §10 records how each issue was resolved, and how the points raised by two independent checks of the revised text were resolved. The proofs are paper proofs with numerical checks; nothing here is Lean-verified. Every lemma, theorem and corollary below is proved here; the proofs use Hoeffding's and Bernstein's inequalities, which are classical, without proof. Remarks 7 and 8 and §7.1 item 6 import results from the refereed companions [`B-tempered-likelihood.md`](B-tempered-likelihood.md) and [`A-tight-conditioning-fails.md`](A-tight-conditioning-fails.md) and mark them as imports. The scripts and their outputs are in [`../checks/small-learner-width/`](../checks/small-learner-width/) (§8). `NNG/` denotes the project folder `neural-network-generalization/` of this repository, and `paper.tex` is `NNG/side-results/continuous-domains/source/paper.tex`.*

## 0. What this note proves

**The result.** Take the strong-prior Bayesian learner with the clean-label likelihood scaling $c=1$, that is, the learner SP$_1$ that conditions tightly on the training outputs, and run it at learner width $N=\lceil n^\alpha\rceil$ with $0<\alpha<\frac14$. Its clipped predictions compete with the depth-$L$ networks of the repository architecture whose width and weights are at most $n^\alpha$. This holds for every data law on $X\times[-1,1]$, with $X\subseteq[-1,1]^d$ compact and $d\le n^\alpha$, and for three predictors: the clipped near-minimizers $\operatorname{clip}z_w$, $w\in\mathcal N_1$; the clipped Gibbs risk; and the posterior mean of the clipped outputs, the last two in the strong-prior limit. With probability at least $1-\delta/2$, the excess test MSE over the best such network is at most $C_{L,\alpha,\delta}\,n^{2\alpha-1/2}$ for an explicit constant $C_{L,\alpha,\delta}$, so it is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$ (Corollary 3(i) with Theorem 4). More generally, any learner width $N\le2n^\alpha$ competes in the same way with the networks of width at most $N$ and weights at most $n^\alpha$.

The guarantee holds at one learner width tied to $n$. It is not uniform over learner widths, and for $L\ge3$ it cannot be: Claim A (`A-tight-conditioning-fails.md` Theorem 4.4) shows that the same learner has a constant excess on the noisy cube at every learner width above a polynomial in $n$ (Remark 8). So SP$_1$ does not have the width-uniform property (P$_L$) of the brief (`problem-brief.md` §1; the name is from `A-tight-conditioning-fails.md` §5.1). At depth two the known failure is weaker: `depth-two.md` Corollary 5.2 (parts (i) and (a)) refutes the polynomial-sample property for SP$_1$ at learner widths above $O(n\log^4n)$, with a certified excess of order $1/d^2\asymp1/\log^2n$. The certified excess is a lower bound, and it tends to $0$ as $d\to\infty$; whether the excess itself tends to $0$ is open (`depth-two.md` §0). The proof here is parameter counting. The Bayesian structure enters only through the fact that the strong-prior posterior concentrates on near-minimizers.

**Verdict on `red-team.md` Proposition 6.1.** The displayed inequality of Proposition 6.1 is correct, and Theorem 1(c) below recovers it. The "In particular" clause is not. On the class it names (competitor width at most $\lceil n^\alpha\rceil$, weights at most $n^\alpha$, $d\le n^\alpha$), the display's own competitor term $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$ is of order $n^{4\alpha-1/2}$, and the stated rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ leaves it out. Read off the display, the excess is polynomially small only for $\alpha<1/8$, at the rate $n^{4\alpha-1/2}$, and for $1/8<\alpha<1/4$ the displayed bound tends to infinity.

Replacing Hoeffding's inequality for the competitor by Bernstein's inequality restores the range $\alpha<1/4$, with a slower rate than the one stated. The corrected clause is the following.

> **Corrected clause (Corollary 3(i) and Theorem 4).** Let $c=1$, $L=H+1\ge2$, $0<\alpha<\frac14$, $n\ge2$, $\delta\in(0,1)$ and $1\le d\le n^\alpha$. Let $D$ be any Borel law on $X\times[-1,1]$, with $X\subseteq[-1,1]^d$ compact. Run SP$_1$ at learner width $N=\lceil n^\alpha\rceil$, with $n$, the sample and $N$ fixed before $\sigma\downarrow0$. Let $\mathcal G_n$ be the set of depth-$L$ networks of the repository architecture (tanh hidden layers without internal biases, input $\bar x=(1,x)$, linear readout without bias) with width at most $N$ and all weights in $[-n^\alpha,n^\alpha]$. With probability at least $1-\delta/2$ over the sample, every near-minimizer $w\in\mathcal N_1$ satisfies
> $$L_D(\operatorname{clip}z_w)\le\min_{g\in\mathcal G_n}L_D(g)+5\sqrt2\,n^{2\alpha-\frac12}\sqrt{\ln\tfrac4\delta}+4\sqrt{(2H+1)(H+5)}\;n^{\alpha-\frac12}\sqrt{\ln(2n)}+(8L-1)\Bigl(1+\ln\tfrac4\delta\Bigr)n^{4\alpha-1}.$$
> On the same event, the same bound holds for $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk $\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)$ and for $\limsup_{\sigma\downarrow0}$ of the risk of the posterior mean of the clipped outputs, $\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w$. It does not cover $\operatorname{clip}(\mathbb E_{\Pi_\sigma}z_w)$ or unclipped predictors. The excess is at most $C_{L,\alpha,\delta}\,n^{2\alpha-1/2}$, with $C_{L,\alpha,\delta}=5\sqrt2\sqrt{\ln(4/\delta)}+4\sqrt{(2H+1)(H+5)}\,2^\alpha/\sqrt{2e\alpha}+(8L-1)(1+\ln(4/\delta))$, so for fixed $\alpha\in(0,\frac14)$ it is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$, which is polynomially small.

Changes relative to `red-team.md`:

- **Withdrawn.** The rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ is not proved. For a single competitor, the proof's chain of inequalities cannot give it (Remark 6(b)). Against the class minimum, whether it holds is open (Remark 6(c)).
- **Weakened.** The rate is now $O(n^{2\alpha-1/2})$. With Hoeffding's inequality for the competitor, as in the original display, only the clause's conclusion "polynomially small" survives, for $\alpha<1/8$ and at the rate $n^{4\alpha-1/2}$; its stated rate does not follow (Remark 5).
- **Scope stated.** The result covers clipped predictions only. It holds at one learner width at a time and is not uniform over learner widths. The competitors must have the repository architecture, and the inputs must lie in $X\subseteq[-1,1]^d$ with $d\le n^\alpha$.
- **Added.**
  - The transfer from near-minimizers to the Gibbs risk and the posterior mean (Lemma F, Theorem 4). The original asserted this without proof.
  - An arbitrary competitor weight bound $\bar B$ (Corollary 3). Weights up to $n^\omega$ give excess $\tilde O(n^{\alpha+\omega-1/2})$. Corollary 3(iii) repairs `red-team.md` §2.3 A2.
  - Corrected wording for every place in `red-team.md` that cites Proposition 6.1 (§7.3). One of them, the finite-scale sketch in `red-team.md` §8, is not supported by the corrected result. Suggested wording for the places in `A-tight-conditioning-fails.md` that cite Proposition 6.1 is in §7.4.

---

## 1. Setting and notation

**Networks.** Fix $d\ge1$ and a compact $X\subseteq[-1,1]^d$, and write $\bar x=(1,x)$. The depth is $L=H+1\ge2$. A learner parameter of width $N$ is $w=(W^1,\dots,W^H,v)\in\mathcal W_N=\mathbb R^{P_N}$, where $W^1\in\mathbb R^{N\times(d+1)}$, $W^\ell\in\mathbb R^{N\times N}$ for $2\le\ell\le H$, and $v\in\mathbb R^N$. So
$$P_N=N(d+1)+(H-1)N^2+N .$$
The network computes $h^0=\bar x$, $h^\ell=\tanh(W^\ell h^{\ell-1})$ for $1\le\ell\le H$, and $z_w(x)=v^\top h^H(x)$. There are no internal biases; offsets enter only through the constant coordinate of $\bar x$. This is the architecture of `paper.tex` §"Model and main results" and `problem-brief.md` §2.

**Energy** (`paper.tex` eq. `energy`). $\kappa_N(w)=a_1+\dots+a_L$, where
$$a_1=\tfrac dN\lVert W^1\rVert_F^2,\qquad a_\ell=\lVert W^\ell\rVert_F^2\ (2\le\ell\le H),\qquad a_L=N\lVert v\rVert_2^2 .$$
Thus $\kappa_N(w)=\lvert\operatorname{diag}(\lambda_N)\,w\rvert^2$, where $\lambda_N\in(0,\infty)^{P_N}$ has the entry $\sqrt{d/N}$ at each coordinate of $W^1$, the entry $1$ at each coordinate of $W^2,\dots,W^H$, and the entry $\sqrt N$ at each coordinate of $v$. (The vector $\lambda_N$ is unrelated to the ratio $\lambda$ of the cube family in Remark 8.)

**Data and losses.** $D$ is a Borel probability measure on $X\times[-1,1]$, and $S=((x_i,y_i))_{i=1}^n\sim D^n$. Write
$$L_D(f)=\mathbb E_D(f(x)-y)^2,\qquad \hat L(f)=\hat L_S(f)=\frac1n\sum_{i=1}^n(f(x_i)-y_i)^2,\qquad \operatorname{clip}(u)=\max\{-1,\min\{1,u\}\}.$$
For $\lvert y\rvert\le1$ and $u,u'\in\mathbb R$,
$$(\operatorname{clip}u-y)^2\le(u-y)^2,\qquad \bigl\lvert(\operatorname{clip}u-y)^2-(\operatorname{clip}u'-y)^2\bigr\rvert\le4\lvert u-u'\rvert,\qquad(\operatorname{clip}u-y)^2\le4. \tag{1.1}$$
The first inequality holds because clip is the metric projection onto $[-1,1]$, which contains $y$. The second holds because $\lvert\operatorname{clip}u-\operatorname{clip}u'\rvert\le\lvert u-u'\rvert$ and $\lvert\operatorname{clip}u+\operatorname{clip}u'-2y\rvert\le4$.

**The learner SP$_c$.** The prior has density proportional to $e^{-\kappa_N(w)/(2\sigma^2)}$, and the likelihood is $y_i\sim\mathcal N(z_w(x_i),c\sigma^2)$. The posterior is
$$\Pi_\sigma(dw)=\Pi_{\sigma,N,S}(dw)=\frac{e^{-F_{c,S}(w)/(2\sigma^2)}\,dw}{\int e^{-F_{c,S}/(2\sigma^2)}},\qquad F_{c,S}(w)=\kappa_N(w)+\frac nc\hat L_S(z_w).$$
*Limit order:* $n$, the sample $S$ and the width $N$ are fixed first, and then $\sigma\downarrow0$. Let $m_*=\min_{\mathcal W_N}F_{c,S}$; the minimum is attained (Lemma F). The set of $\zeta$-near-minimizers is $\mathcal N_\zeta=\mathcal N_\zeta^{(N)}(S)=\{w\in\mathcal W_N:F_{c,S}(w)\le m_*+\zeta\}$.

**Predictors covered.** The results cover three predictors:

- $\operatorname{clip}z_w$ for $w\in\mathcal N_1$;
- the clipped Gibbs risk $\mathcal G^{\rm clip}_\sigma=\mathbb E_{\Pi_\sigma}L_D(\operatorname{clip}z_w)$;
- the posterior mean of the clipped outputs, $\bar f_\sigma(x)=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w(x)$.

Unclipped outputs and the clip of the posterior mean of the raw outputs are not covered (§7.1).

**Competitors.** A competitor of width $m\ge1$ with weight bound $B\ge0$ is a function
$$g(x)=u^\top h_g^H(x),\qquad h_g^0=\bar x,\qquad h_g^\ell=\tanh(M^\ell h_g^{\ell-1}),$$
with $M^1\in[-B,B]^{m\times(d+1)}$, $M^\ell\in[-B,B]^{m\times m}$ for $2\le\ell\le H$, and $u\in[-B,B]^m$. It has the learner's architecture and depth, the *repository architecture*: tanh hidden layers without internal biases, input $\bar x=(1,x)$, and a linear readout without bias. Put
$$U:=mB,\qquad E_*:=d(d+1)B^2+2(L-1)m^2B^2 .$$
Since every coordinate of $h_g^H$ lies in $[-1,1]$, $\sup_x\lvert g(x)\rvert\le\lVert u\rVert_1\le U$.

Let $\mathcal G_L(d,\bar m,\bar B)$ be the set of functions computed by competitors of width at most $\bar m$ with weight bound $\bar B$. A competitor of width $m<\bar m$ is padded with $\bar m-m$ units per hidden layer whose incoming and outgoing weights are all $0$. These units compute $\tanh0=0$ and contribute nothing, so the function and the weight bound are unchanged. Hence
$$\mathcal G_L(d,\bar m,\bar B)=\bigl\{g_\theta:\theta\in[-\bar B,\bar B]^{Q}\bigr\},\qquad Q=\bar m(d+1)+(H-1)\bar m^2+\bar m,$$
where $g_\theta$ is the width-$\bar m$ competitor with parameter $\theta$.

**Constants of the deviation term.** For a learner width $N$, put
$$K:=\frac nc+1,\qquad \Lambda_N:=\ln\Bigl(2+2n\sqrt{KN}\,H(d+N+1)(K+1)^{H/2}\Bigr),\qquad \mathrm{Dev}_N(\delta):=4\sqrt{\frac{P_N\Lambda_N+\ln(4/\delta)}{2n}},\qquad \ell_\delta:=\ln\frac4\delta .$$
By Lemma D, $e^{\Lambda_N}$ bounds the number of grid values per coordinate. None of these quantities depends on the sample, on $D$ or on a competitor.

---

## 2. Deterministic lemmas

**Lemma A (cloning; `paper.tex` eq. `teacher-energy`).** Let $g$ be a competitor of width $m$ with weight bound $B$, and let $N\ge m$. There is $w^g_N\in\mathcal W_N$ with $z_{w^g_N}=g$ on all of $\mathbb R^d$ and $\kappa_N(w^g_N)\le E_*$.

*Proof.* Partition the $N$ learner units of each hidden layer into groups $G_1,\dots,G_m$ of sizes $k_j\in\{\lfloor N/m\rfloor,\lceil N/m\rceil\}$, and let $j(p)$ be the group of unit $p$. Set
$$W^1_{p,:}=M^1_{j(p),:},\qquad W^\ell_{pq}=M^\ell_{j(p)j(q)}/k_{j(q)}\ (2\le\ell\le H),\qquad v_p=u_{j(p)}/k_{j(p)} .$$

*Every learner unit in group $j$ equals competitor unit $j$.* We argue by induction over layers. In layer 1 this holds by construction. In layer $\ell\ge2$, the preactivation of unit $p$ is
$$\sum_qM^\ell_{j(p)j(q)}k_{j(q)}^{-1}h^{\ell-1}_{g,j(q)}=\sum_jM^\ell_{j(p)j}h^{\ell-1}_{g,j},$$
because each group $G_j$ has $k_j$ members. The same computation shows that the output is $g$.

*Energy.* Since $N\ge m$, we have $\lfloor N/m\rfloor\ge1$, so $k_j/k_{j'}\le\lceil N/m\rceil/\lfloor N/m\rfloor\le2$. Also $N/\lfloor N/m\rfloor<2m$: write $N=qm+r$ with $q\ge1$ and $0\le r<m$, so that $N/q<2m$. Therefore:

- $a_1=\frac dN\sum_jk_j\lvert M^1_{j,:}\rvert^2\le d(d+1)B^2$;
- $a_\ell=\sum_{j,j'}(k_j/k_{j'})(M^\ell_{jj'})^2\le2m^2B^2$ for $2\le\ell\le H$;
- $a_L=N\sum_ju_j^2/k_j\le2m^2B^2$.

The sum is $d(d+1)B^2+2Hm^2B^2=E_*$. ∎

**Lemma B (near-minimizers).** Fix $N$, $S$, $c>0$, $\zeta\ge0$ and $w\in\mathcal N^{(N)}_\zeta(S)$.

- (a) $\kappa_N(w)\le c^{-1}\sum_iy_i^2+\zeta\le n/c+\zeta$.
- (b) For every competitor $g$ of width $m\le N$, $\hat L(z_w)\le\hat L(g)+c(E_*+\zeta)/n$.

*Proof.* For every $w'\in\mathcal W_N$ we have $F_{c,S}(w)\le m_*+\zeta\le F_{c,S}(w')+\zeta$.

(a) Take $w'=0$. Then $z_0\equiv0$ and $F_{c,S}(0)=c^{-1}\sum_iy_i^2\le n/c$; also $\kappa_N\le F_{c,S}$.

(b) Take $w'=w^g_N$ from Lemma A. Then $\kappa_N(w)+\frac nc\hat L(z_w)\le E_*+\zeta+\frac nc\hat L(g)$. Drop $\kappa_N(w)\ge0$ and multiply by $c/n$. ∎

Part (a) bounds the energy without reference to any competitor. This is why one grid serves every competitor below. (`red-team.md` used the larger budget $E_*+1+n(U+1)^2/c$; part (a) is `B-tempered-likelihood.md` Lemma 2.3(a).)

**Lemma C (perturbation).** Let $K>0$, let $w\in\mathcal W_N$ satisfy $\kappa_N(w)\le K$, and let $w'\in\mathcal W_N$ differ from $w$ by at most $\xi$ in every coordinate. Then for every $x\in[-1,1]^d$,
$$\lvert z_w(x)-z_{w'}(x)\rvert\le\xi\Bigl[(d+1)K^{H/2}+N\sum_{j=0}^{H-1}K^{j/2}\Bigr]\le\xi\,H(d+N+1)(K+1)^{H/2}.$$
The point $w'$ need not satisfy any energy bound.

*Proof.* Let $h^\ell,h'^\ell$ be the hidden layers of $w,w'$ at $x$, and $e_\ell=\lvert h^\ell-h'^\ell\rvert_2$. The energy bound gives $\lVert W^\ell\rVert_{\rm op}\le\lVert W^\ell\rVert_F=\sqrt{a_\ell}\le\sqrt K$ for $2\le\ell\le H$, and $\lvert v\rvert_2=\sqrt{a_L/N}\le\sqrt{K/N}$. A matrix with $N$ rows and entries in $[-\xi,\xi]$ maps a vector $q$ to a vector of Euclidean norm at most $\sqrt N\xi\lvert q\rvert_1$. tanh is 1-Lipschitz in each coordinate, $\lvert\bar x\rvert_1\le d+1$, and $\lvert h'^\ell\rvert_1\le N$. Hence:

- $e_1\le\lvert(W^1-W'^1)\bar x\rvert_2\le\xi(d+1)\sqrt N$;
- for $2\le\ell\le H$, $e_\ell\le\lvert W^\ell(h^{\ell-1}-h'^{\ell-1})\rvert_2+\lvert(W^\ell-W'^\ell)h'^{\ell-1}\rvert_2\le\sqrt K\,e_{\ell-1}+\xi N^{3/2}$;
- $\lvert z_w(x)-z_{w'}(x)\rvert\le\lvert v^\top(h^H-h'^H)\rvert+\lvert(v-v')^\top h'^H\rvert\le\sqrt{K/N}\,e_H+\xi N$.

Unrolling gives $e_H\le\xi\bigl[(d+1)\sqrt NK^{(H-1)/2}+N^{3/2}\sum_{j=0}^{H-2}K^{j/2}\bigr]$; for $H=1$ the sum is empty. Multiplying by $\sqrt{K/N}$ and adding $\xi N$ gives the first bound. The second follows from $K^{j/2}\le(K+1)^{H/2}$ for $0\le j\le H$ and from $d+1+NH\le H(d+N+1)$. ∎

*How sharp Lemma C is.* At $H=1$ the first bound is nearly attained. Adversarial searches by the second-round referees reach $0.90$ and $0.92$ of it, and $0.64$ and $0.74$ of the second bound (`../checks/verify-RT-width-logic-revised/check_lemmas_AC.out`, `../checks/verify-RT-width-computation-revised/perturb_adv.out`); the random and sign-gradient perturbations of `check_lemmas.py` reach $0.73$ and $0.49$ (§8). The constant enters the results only through the logarithm $\Lambda_N$.

**Lemma D (a grid chosen before the sample).** Let $K=n/c+1$, $R=\sqrt{KN}$ and $\xi_N=1/\bigl(nH(d+N+1)(K+1)^{H/2}\bigr)$. Let $T=\{-R+k\xi_N:k=0,1,\dots,\lceil2R/\xi_N\rceil\}$ and $\mathcal T_N=T^{P_N}\subset\mathcal W_N$. Then:

- $\ln\lvert\mathcal T_N\rvert\le P_N\Lambda_N$;
- $\mathcal T_N$ depends only on $(n,c,N,d,H)$;
- every $w$ with $\kappa_N(w)\le K$ has some $w'\in\mathcal T_N$ with $\sup_{x\in[-1,1]^d}\lvert z_w(x)-z_{w'}(x)\rvert\le1/(2n)$.

*Proof.*

- *Cardinality.* $\lvert T\rvert=\lceil2R/\xi_N\rceil+1\le2+2R/\xi_N=2+2n\sqrt{KN}H(d+N+1)(K+1)^{H/2}=e^{\Lambda_N}$, so $\ln\lvert\mathcal T_N\rvert=P_N\ln\lvert T\rvert\le P_N\Lambda_N$.
- *Every coordinate of $w$ lies in $[-R,R]$.* We have $\lvert W^1_{jk}\rvert\le\lVert W^1\rVert_F=\sqrt{Na_1/d}\le\sqrt{KN/d}$, $\lvert W^\ell_{jk}\rvert\le\sqrt{a_\ell}\le\sqrt K$ and $\lvert v_j\rvert\le\sqrt{a_L/N}\le\sqrt{K/N}$, each at most $\sqrt{KN}$ because $d,N\ge1$.
- *Rounding.* The points of $T$ are spaced $\xi_N$ apart, the first is $-R$ and the last is at least $R$. So every point of $[-R,R]$ lies within $\xi_N/2$ of $T$. Rounding each coordinate gives $w'\in\mathcal T_N$ that differs from $w$ by at most $\xi_N/2$ in every coordinate. Lemma C with $\xi=\xi_N/2$ gives $\sup\lvert z_w-z_{w'}\rvert\le\frac12\xi_NH(d+N+1)(K+1)^{H/2}=\frac1{2n}$. ∎

---

## 3. Concentration

**Lemma E.** Let $Z_1,\dots,Z_n$ be i.i.d. with values in $[0,b]$ and mean $\mu$. Write $\bar Z=\frac1n\sum_iZ_i$, and let $\delta'\in(0,1)$ and $\ell'=\ln(1/\delta')$.

- (i) *Hoeffding.* $\Pr\bigl(\mu-\bar Z\ge b\sqrt{\ell'/(2n)}\bigr)\le\delta'$, and $\Pr\bigl(\bar Z-\mu\ge b\sqrt{\ell'/(2n)}\bigr)\le\delta'$.
- (ii) *Bernstein.* $\Pr\bigl(\bar Z-\mu\ge\sqrt{2b\mu\ell'/n}+2b\ell'/(3n)\bigr)\le\delta'$.

*Proof.* (i) is Hoeffding's inequality, $\Pr(\pm(\bar Z-\mu)\ge t)\le e^{-2nt^2/b^2}$.

(ii) We use Bernstein's inequality for independent variables bounded above: if $X_i\le b$ and $\sum_i\mathbb EX_i^2\le v$, then $\Pr\bigl(\sum_i(X_i-\mathbb EX_i)\ge s\bigr)\le\exp\bigl(-s^2/(2(v+bs/3))\bigr)$ (Boucheron, Lugosi and Massart, *Concentration Inequalities*, 2013, Corollary 2.11).

Apply it to $X_i=Z_i-\mu$. Then $X_i\le b$, $\mathbb EX_i=0$, and $\mathbb EX_i^2=\operatorname{Var}Z_1\le\mathbb EZ_1^2\le b\,\mathbb EZ_1=b\mu$, so we may take $v=nb\mu$. Let $A=\sqrt{2b\mu\ell'/n}$, $C=2b\ell'/(3n)$, $t=A+C$ and $s=nt$. Then
$$t^2=A^2+2AC+C^2\ge A^2+Ct=\tfrac{2\ell'}n\bigl(b\mu+bt/3\bigr),$$
so $s^2/(2(v+bs/3))=nt^2/(2(b\mu+bt/3))\ge\ell'$. ∎

Theorem 2.10 of the same book (Bernstein's inequality under a moment condition, which holds here with scale parameter $b/3$) gives the smaller linear term $b\ell'/(3n)$ in (ii). The form above suffices here.

In Theorem 1 the variables are $Z_i=(g(x_i)-y_i)^2\in[0,(U+1)^2]$, so $b\mu=(U+1)^2L_D(g)$. This is the variance bound the first-round referees proposed.

---

## 4. The corrected proposition

**Theorem 1 (replaces `red-team.md` Proposition 6.1).** Fix $L=H+1\ge2$, $c>0$, $n\ge1$, $\delta\in(0,1)$, a compact $X\subseteq[-1,1]^d$, a Borel law $D$ on $X\times[-1,1]$, and a learner width $N\ge1$.

**(a) Uniform deviation, independent of any competitor.** There is an event $\mathcal E_0=\mathcal E_0(N)$ with $D^n(\mathcal E_0)\ge1-\delta/4$ on which every $w\in\mathcal W_N$ with $\kappa_N(w)\le K=n/c+1$ satisfies
$$L_D(\operatorname{clip}z_w)\le\hat L(\operatorname{clip}z_w)+\mathrm{Dev}_N(\delta)+\frac4n .$$

**(b) Oracle inequality against one competitor.** Let $g$ be a competitor of width $m\le N$ with weight bound $B\ge0$, chosen without reference to the sample. Put
$$\Gamma_H(g)=(U+1)^2\sqrt{\frac{\ell_\delta}{2n}},\qquad \Gamma_B(g)=(U+1)\sqrt{\frac{2\min\{L_D(g),4\}\,\ell_\delta}n}+\frac{2(U+1)^2\ell_\delta}{3n}.$$
There are events $\mathcal E_H(g)$ and $\mathcal E_B(g)$, each of probability at least $1-\delta/4$, with the following property. On $\mathcal E_0\cap\mathcal E_H(g)\cap\mathcal E_B(g)$, which has probability at least $1-3\delta/4$, every $w\in\mathcal N_1^{(N)}(S)$ satisfies
$$L_D(\operatorname{clip}z_w)\le L_D(g)+\frac{c(E_*+1)}n+\frac4n+\mathrm{Dev}_N(\delta)+\min\{\Gamma_H(g),\Gamma_B(g)\}. \tag{4.1}$$
On $\mathcal E_0\cap\mathcal E_H(g)$ alone, (4.1) holds with $\Gamma_H(g)$ in place of the minimum. On $\mathcal E_0\cap\mathcal E_B(g)$ alone, it holds with $\Gamma_B(g)$. Each of these events has probability at least $1-\delta/2$.

**(c) The original display.** With probability at least $1-\delta/2$, every $w\in\mathcal N_1^{(N)}$ satisfies the display of `red-team.md` Proposition 6.1:
$$L_D(\operatorname{clip}z_w)\le L_D(g)+\frac{c(E_*+1)}n+\frac8n+4\sqrt{\frac{P_N\ln\bigl(2+2n\sqrt{K'N}H(d+N+1)(K'+1)^{H/2}\bigr)+\ln(4/\delta)}{2n}}+(U+1)^2\sqrt{\frac{\ln(4/\delta)}{2n}},$$
with $K'=E_*+1+n(U+1)^2/c$.

*Proof.*

*Step 1: the event $\mathcal E_0$.* Fix $w'\in\mathcal T_N$, the grid of Lemma D. The losses $(\operatorname{clip}z_{w'}(x_i)-y_i)^2$ are i.i.d. with values in $[0,4]$ and mean $L_D(\operatorname{clip}z_{w'})$. Apply Lemma E(i) with $b=4$ and $\delta'=\delta/(4\lvert\mathcal T_N\rvert)$, and take a union bound over the grid. This gives an event $\mathcal E_0$ with $D^n(\mathcal E_0)\ge1-\delta/4$ on which, for every $w'\in\mathcal T_N$,
$$L_D(\operatorname{clip}z_{w'})\le\hat L(\operatorname{clip}z_{w'})+4\sqrt{\frac{\ln\lvert\mathcal T_N\rvert+\ln(4/\delta)}{2n}}\le\hat L(\operatorname{clip}z_{w'})+\mathrm{Dev}_N(\delta).$$
$\mathcal E_0$ is a finite intersection of events, each defined by a measurable function of $S$. It involves neither $\sigma$ nor any competitor.

*Step 2: part (a).* Let $\kappa_N(w)\le K$, and let $w'$ be the grid point of Lemma D, so that $\lvert z_w-z_{w'}\rvert\le1/(2n)$ on $X$. By (1.1), the clipped losses of $w$ and $w'$ differ by at most $4\cdot\frac1{2n}=\frac2n$ at every $(x,y)\in X\times[-1,1]$. Averaging over $D$ and over $S$ gives
$$L_D(\operatorname{clip}z_w)\le L_D(\operatorname{clip}z_{w'})+\tfrac2n,\qquad \hat L(\operatorname{clip}z_{w'})\le\hat L(\operatorname{clip}z_w)+\tfrac2n .$$
Combining these with Step 1 proves (a).

*Step 3: part (b).* Let $w\in\mathcal N_1$. Lemma B(a) with $\zeta=1$ gives $\kappa_N(w)\le K$, so (a) applies. By (1.1) and Lemma B(b), $\hat L(\operatorname{clip}z_w)\le\hat L(z_w)\le\hat L(g)+c(E_*+1)/n$. Hence, on $\mathcal E_0$,
$$L_D(\operatorname{clip}z_w)\le\hat L(g)+\frac{c(E_*+1)}n+\frac4n+\mathrm{Dev}_N(\delta). \tag{4.2}$$
It remains to bound $\hat L(g)-L_D(g)$. The losses $(g(x_i)-y_i)^2$ are i.i.d. with values in $[0,(U+1)^2]$, because $\lvert g\rvert\le U$ and $\lvert y\rvert\le1$, and their mean is $L_D(g)$.

- *Hoeffding event.* Lemma E(i) with $b=(U+1)^2$ and $\delta'=\delta/4$ shows that $\mathcal E_H(g)=\{\hat L(g)\le L_D(g)+\Gamma_H(g)\}$ has probability at least $1-\delta/4$.
- *Bernstein event, case $L_D(g)<4$.* Then $\min\{L_D(g),4\}=L_D(g)$. Lemma E(ii) with $b=(U+1)^2$, $\mu=L_D(g)$ and $\delta'=\delta/4$ shows that $\mathcal E_B(g)=\{\hat L(g)\le L_D(g)+\Gamma_B(g)\}$ has probability at least $1-\delta/4$.
- *Bernstein event, case $L_D(g)\ge4$.* Let $\mathcal E_B(g)$ be the sure event. Inequality (4.1) with $\Gamma_B(g)$ then holds trivially, because $L_D(\operatorname{clip}z_w)\le4\le L_D(g)$ by (1.1).

Inserting these bounds into (4.2) proves (b). The failure probabilities add up to at most $3\delta/4$, or $\delta/2$ when only two of the three events are used.

*Step 4: part (c).* Use $\mathcal E_0\cap\mathcal E_H(g)$. We have $K=n/c+1\le K'$ because $E_*\ge0$ and $(U+1)^2\ge1$. The right side of the original display increases with $K$, and $4/n\le8/n$. ∎

**What the theorem adds to the display.** The display was correct, and part (c) recovers it with a smaller failure probability. Three changes are new.

- The energy budget $K=n/c+1$ does not depend on the competitor (Lemma B(a)), so one grid serves every competitor.
- The rounding radius is $\xi_N/2$, so the discretization cost is $4/n$ rather than $8/n$.
- There is a Bernstein form $\Gamma_B$ of the competitor term. This is the change that matters.

Since $\min\{L_D(g),4\}\le4$, we always have $\Gamma_B(g)\le(U+1)\sqrt{8\ell_\delta/n}+\frac23(U+1)^2\ell_\delta/n$. The Bernstein form scales like $U/\sqrt n$, while $\Gamma_H$ scales like $U^2/\sqrt n$.

---

## 5. The class minimum, and rates

**Corollary 2 (oracle inequality against a class).** Fix $L,c,n,\delta,X,D,N$ as in Theorem 1, a width bound $\bar m\in\{1,\dots,N\}$ and a weight bound $\bar B\ge0$. Let $\mathcal G=\mathcal G_L(d,\bar m,\bar B)$, $\bar U=\bar m\bar B$ and $\bar E_*=d(d+1)\bar B^2+2(L-1)\bar m^2\bar B^2$. Then $L_D$ attains its minimum on $\mathcal G$, and $\min_{\mathcal G}L_D\le1$. With probability at least $1-\delta/2$, every $w\in\mathcal N^{(N)}_1(S)$ satisfies
$$L_D(\operatorname{clip}z_w)\le\min_{\mathcal G}L_D+\mathrm{Exc},\qquad \mathrm{Exc}:=\frac{c(\bar E_*+1)}n+\frac4n+\mathrm{Dev}_N(\delta)+(\bar U+1)\sqrt{\frac{2\ell_\delta}n}+\frac{2(\bar U+1)^2\ell_\delta}{3n}. \tag{5.1}$$

*Proof.*

- *A best-in-class competitor exists.* The parameter set $[-\bar B,\bar B]^Q$ is compact (§1). The map $\theta\mapsto L_D(g_\theta)$ is continuous by dominated convergence: $g_\theta(x)$ is continuous in $\theta$, and $(g_\theta(x)-y)^2\le(\bar U+1)^2$. So the minimum is attained at some $g^*=g_{\theta^*}$. The choice of $\theta^*$ depends only on $D$ and $\mathcal G$, not on the sample.
- *Its risk is at most 1.* The zero parameter gives the zero function, so $L_D(g^*)\le L_D(0)=\mathbb Ey^2\le1$.
- *The bound.* Apply Theorem 1(b) to $g^*$, using the event $\mathcal E_0\cap\mathcal E_B(g^*)$, which has probability at least $1-\delta/2$. Here $g^*$ is a competitor of width $\bar m\le N$ with weight bound $\bar B$, so its constants are $U=\bar U$ and $E_*=\bar E_*$. Since $\min\{L_D(g^*),4\}\le1$, the term $\Gamma_B(g^*)$ is at most the last two terms of (5.1). ∎

**Corollary 3 (rates at $c=1$).** Let $c=1$, $n\ge2$, $0\le\alpha<\frac12$, $\bar B\ge1$ and $1\le d\le n^\alpha$. Let the learner width satisfy $1\le N\le2n^\alpha$, and take the class $\mathcal G=\mathcal G_L(d,N,\bar B)$, whose competitor width bound is the learner width. Then
$$\mathrm{Exc}\le5\sqrt2\,\bar B\,n^{\alpha-\frac12}\sqrt{\ell_\delta}+4\sqrt{(2H+1)(H+5)}\;n^{\alpha-\frac12}\sqrt{\ln(2n)}+(8L-1)(1+\ell_\delta)\,\bar B^2n^{2\alpha-1}. \tag{5.2}$$
So, with probability at least $1-\delta/2$, every $w\in\mathcal N_1^{(N)}$ satisfies $L_D(\operatorname{clip}z_w)\le\min_{\mathcal G}L_D+(5.2)$. By Theorem 4, the same holds in the strong-prior limit for the clipped Gibbs risk and for the posterior mean of the clipped outputs. Three cases:

- **(i) The class of `red-team.md`** ($N=\lceil n^\alpha\rceil$, $\bar B=n^\alpha$). The bound (5.2) becomes
$$5\sqrt2\,n^{2\alpha-\frac12}\sqrt{\ell_\delta}+4\sqrt{(2H+1)(H+5)}\;n^{\alpha-\frac12}\sqrt{\ln(2n)}+(8L-1)(1+\ell_\delta)\,n^{4\alpha-1}.$$
  For $0<\alpha<\frac14$ all three exponents are negative, and the bound is at most $C_{L,\alpha,\delta}\,n^{2\alpha-1/2}$, where
$$C_{L,\alpha,\delta}:=5\sqrt2\sqrt{\ell_\delta}+4\sqrt{(2H+1)(H+5)}\,\frac{2^\alpha}{\sqrt{2e\alpha}}+(8L-1)(1+\ell_\delta).$$
  As $n\to\infty$ the leading term is $5\sqrt2\,n^{2\alpha-1/2}\sqrt{\ell_\delta}$, with no logarithmic factor.
- **(ii) Weights up to $n^\omega$** ($\bar B=n^\omega$, $\omega\ge0$). The exponents are $\alpha+\omega-\frac12$, $\alpha-\frac12$ and $2(\alpha+\omega)-1$, so the bound tends to $0$ polynomially if and only if $\alpha+\omega<\frac12$. In particular, with weights bounded by $1$ ($\omega=0$), every $\alpha<\frac12$ works, at rate $O(n^{\alpha-1/2}\sqrt{\ln n})$.
- **(iii) Fixed weight bound, learner width up to $n^{1/2-\epsilon}$.** Let $\bar B=B_0\ge1$, $0<\epsilon\le\frac12$, $N\le n^{1/2-\epsilon}$ and $d\le n^{1/2-\epsilon}$. Then
$$\mathrm{Exc}\le5\sqrt2\,B_0\,n^{-\epsilon}\sqrt{\ell_\delta}+4\sqrt{(2H+1)(H+5)}\;n^{-\epsilon}\sqrt{\ln(2n)}+(8L-1)(1+\ell_\delta)B_0^2n^{-2\epsilon}.$$
  This is the corrected form of `red-team.md` §2.3 A2. For a weight bound $B_0<1$ the same bound holds with $\max\{B_0,1\}=1$ in place of $B_0$, because the class with weight bound $1$ contains the class with weight bound $B_0$, so its minimum risk is no larger.

*Proof of (5.2).* Write $\nu=n^\alpha$, so $1\le\nu\le n^{1/2}$, $N\le2\nu$ and $d\le\nu$. Let $\ell=\ell_\delta$.

1. *Clone energy.* $\bar E_*+1=d(d+1)\bar B^2+2(L-1)N^2\bar B^2+1\le(2\nu^2+8(L-1)\nu^2+\nu^2)\bar B^2=(8L-5)\nu^2\bar B^2$. Here we used $d(d+1)\le2\nu^2$, $N^2\le4\nu^2$ and $1\le\nu^2\bar B^2$. Hence $\frac{\bar E_*+1}n+\frac4n\le(8L-1)\bar B^2n^{2\alpha-1}$.
2. *Competitor range.* $\bar U+1=N\bar B+1\le3\nu\bar B$. So $(\bar U+1)\sqrt{2\ell/n}\le3\sqrt2\,\bar Bn^{\alpha-1/2}\sqrt\ell$, and $\frac{2(\bar U+1)^2\ell}{3n}\le6\bar B^2n^{2\alpha-1}\ell$.
3. *Parameter count.* $P_N=N(d+2)+(H-1)N^2\le2\nu\cdot3\nu+4(H-1)\nu^2=(4H+2)\nu^2$.
4. *The logarithm.* For $n\ge2$ we have $K=n+1\le\frac32n$, $K+1\le2n$, $N\le2n^{1/2}$ and $d+N+1\le4\nu\le4n^{1/2}$. Hence $2n\sqrt{KN}H(d+N+1)(K+1)^{H/2}\le8\sqrt3\,H2^{H/2}n^{(2H+9)/4}$, and the argument of $\Lambda_N$ is at most $16H2^{H/2}n^{(2H+9)/4}$. Using $\ln H\le(H-1)\ln2$,
$$\Lambda_N\le\bigl(3+\tfrac{3H}2\bigr)\ln2+\tfrac{2H+9}4\ln n .$$
   The difference $(H+5)\ln(2n)-\bigl[(3+\tfrac{3H}2)\ln2+\tfrac{2H+9}4\ln n\bigr]=(2-\tfrac H2)\ln2+\tfrac{2H+11}4\ln n$ is at least $(2-\tfrac H2+\tfrac{2H+11}4)\ln2=\tfrac{19}4\ln2>0$, because $\ln n\ge\ln2$. So $\Lambda_N\le(H+5)\ln(2n)$.
5. *Deviation term.* Using $\sqrt{a+b}\le\sqrt a+\sqrt b$, $\mathrm{Dev}_N(\delta)\le4\sqrt{(2H+1)(H+5)\ln(2n)}\,n^{\alpha-1/2}+2\sqrt2\sqrt{\ell/n}$.

Adding the five bounds, and using $6\le8L-1$ and $n^{-1/2}\le\bar Bn^{\alpha-1/2}$, gives (5.2). Cases (ii) and (iii) are substitutions: in (iii), take $\alpha=\frac12-\epsilon$, so that $N\le n^\alpha\le2n^\alpha$.

For case (i), substitute $\bar B=n^\alpha$ and let $0<\alpha\le\frac14$. Then $n^{4\alpha-1}\le n^{2\alpha-1/2}$, because $n\ge1$ and $4\alpha-1\le2\alpha-\frac12$. Also $n^{\alpha-1/2}\sqrt{\ln(2n)}=n^{2\alpha-1/2}\cdot n^{-\alpha}\sqrt{\ln(2n)}\le n^{2\alpha-1/2}\cdot2^\alpha/\sqrt{2e\alpha}$. For the last step, consider $f(t)=t^{-\alpha}\sqrt{\ln(2t)}$ on real $t\ge1$. Its logarithmic derivative is $\frac1t\bigl(\frac1{2\ln(2t)}-\alpha\bigr)$, which is positive for $\ln(2t)<\frac1{2\alpha}$ and negative after. The critical point $t_*=e^{1/(2\alpha)}/2$ exceeds $1$ because $\alpha\le\frac14$. So $\sup_{t\ge1}f(t)=f(t_*)=e^{-1/2}\,2^\alpha(2\alpha)^{-1/2}=2^\alpha/\sqrt{2e\alpha}$. Summing the three terms gives the bound $C_{L,\alpha,\delta}\,n^{2\alpha-1/2}$. For $\alpha<\frac14$ the second and third terms are $o(n^{2\alpha-1/2})$ as $n\to\infty$, so the first term is the leading one. ∎

`check_explicit_bound.py` evaluates the exact $\mathrm{Exc}$ of (5.1) on 160,750 admissible parameter combinations: $n$ from $2$ to $10^{300}$, $0\le\alpha\le0.4999$, $H\le6$, $\delta$ from $10^{-9}$ to $0.99$, and $\bar B\in\{1,n^\alpha,n^{0.3},100,n^{0.6}\}$. The largest value of $\mathrm{Exc}/(5.2)$ is $0.678$, and the largest value of $\Lambda_N/((H+5)\ln2n)$ is $0.631$. The measured log–log slopes agree with the stated exponents to within $0.002$. For example, in case (i) the slope is $-0.100$ at $\alpha=0.2$ and $-0.020$ at $\alpha=0.24$. Part (6) of the script checks the constant of case (i). On a grid of 8,401 values of $t$ from $1$ to $10^{420}$, for ten values of $\alpha$ in $(0,\frac14)$, $t^{-\alpha}\sqrt{\ln2t}$ never exceeds $2^\alpha/\sqrt{2e\alpha}$, and it equals it at $t_*$. On 4,400 combinations in case (i), (5.2) is at most $0.9997$ times $C_{L,\alpha,\delta}n^{2\alpha-1/2}$, and the exact $\mathrm{Exc}$ at most $0.49$ times it.

The constant $5\sqrt2$ is not sharp. In case (i) the leading term of the exact $\mathrm{Exc}$ is $(\bar U+1)\sqrt{2\ell_\delta/n}\approx\sqrt2\,n^{2\alpha-1/2}\sqrt{\ell_\delta}$, and $\mathrm{Exc}/(5.2)$ tends to $0.200$ as $n\to\infty$ (`../checks/verify-RT-width-computation-revised/bound_check.out`, part (5)). The factor $5$ comes from allowing $N\le2n^\alpha$, which gives $\bar U+1\le3n^{2\alpha}$, and from absorbing the $\sqrt{\ell_\delta/n}$ part of the deviation term. The decay is slow near $\alpha=\frac14$: at $\alpha=0.24$, $L=3$ and $\delta=0.05$ the exact $\mathrm{Exc}$ is $4.36$ at $n=10^{12}$, $0.67$ at $n=10^{40}$ and $0.030$ at $n=10^{100}$ (`check_explicit_bound.out`, part (4)). "Polynomially small" is an asymptotic statement.

**In the user's words.** After $n$ samples, run the clean-label-scaled Bayesian network (SP$_1$, in the strong-prior limit) at width $\lceil n^\alpha\rceil$ with $0<\alpha<1/4$. As predictor, use either a posterior draw with its output clipped to $[-1,1]$ (the bound is for its expected test MSE) or the posterior average of the clipped outputs; the clip of the posterior average of the raw outputs is not covered. The test MSE of this predictor is at most the best test MSE among depth-$L$ tanh networks of the repository architecture (no internal biases; offsets only through the constant input coordinate) with width and weights at most $n^\alpha$, plus $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$. This holds with probability at least $1-\delta$ over the sample (Corollary 3 gives $1-\delta/2$), for every data law with inputs in a compact $X\subseteq[-1,1]^d$, $d\le n^\alpha$, and labels in $[-1,1]$. It holds at this one learner width, not uniformly over learner widths (§7.1 item 2).

**Remark 5 (the Hoeffding form: the clause's conclusion holds for $\alpha<1/8$, at a slower rate).** Suppose $\Gamma_H$ is used in place of $\Gamma_B$, as in the display of `red-team.md`. Then the class version has competitor term $(\bar U+1)^2\sqrt{\ell_\delta/(2n)}$. In case (i), $n^{2\alpha}\le\bar U+1\le3n^{2\alpha}$, so this term lies between $n^{4\alpha-1/2}\sqrt{\ell_\delta/2}$ and $\frac9{\sqrt2}n^{4\alpha-1/2}\sqrt{\ell_\delta}$. With it, the excess bound is
$$O_L\bigl(n^{4\alpha-1/2}\sqrt{\ell_\delta}+n^{\alpha-1/2}\sqrt{\ln n}\bigr),$$
which is polynomially small exactly when $\alpha<1/8$. So with the original display, the clause's conclusion "polynomially small" holds for $\alpha<1/8$, at the rate $n^{4\alpha-1/2}$; its stated rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ does not follow. For $1/8<\alpha<1/4$ the bound tends to infinity. The risk itself never exceeds 4; it is the bound that becomes vacuous. The script finds slope $+0.300$ at $\alpha=0.2$; the Hoeffding-form bound is $5.9\cdot10^3$ at $n=10^{12}$ and $1.5\cdot10^{12}$ at $n=10^{40}$, against $0.228$ and $3.0\cdot10^{-4}$ for the Bernstein form.

**Remark 6 (what is not proved).**

(a) The rate $O(n^{4\alpha-1}+n^{\alpha-1/2}\sqrt{\log n})$ stated in `red-team.md` is not proved here. Nor is any rate faster than $n^{2\alpha-1/2}$ for the class $\mathcal G_L(d,\lceil n^\alpha\rceil,n^\alpha)$.

(b) *Per competitor, the chain cannot do better.* The proof bounds $L_D(\operatorname{clip}z_w)-L_D(g)$ through $\hat L(g)-L_D(g)$, and the other terms do not depend on $g$'s fluctuation. So the competitor term of a bound of this form must be at least the upper $(1-\delta')$-quantile of $\hat L(g)-L_D(g)$ for every $g$ it covers, where $\delta'$ is the failure probability allotted to that step.

Here is a competitor in the class of case (i), due to the first-round logic referee:

- $L=3$, $d=1$, width $m=\lceil n^\alpha\rceil$;
- first-layer rows $(0,B)$, all internal weights $B$, all readout weights $B$, with $B=n^\alpha$;
- so $g(x)=mB\tanh(mB\tanh(Bx))$, and $G:=g(1)\approx mB=U$.

Let $x=1$ with probability $p=(G+1)^{-2}$ and label $-1$; otherwise $x=0$ with label $0$. Then $L_D(g)=1$ and $\hat L(g)=(G+1)^2\,\mathrm{Bin}(n,p)/n$, whose standard deviation is about $(G+1)/\sqrt n$, of order $n^{2\alpha-1/2}$. `check_competitor_fluct.py` computes the exact binomial $95\%$ quantile of $\hat L(g)-L_D(g)$. It lies between $1.63$ and $1.72$ times $(G+1)/\sqrt n$ in every row below. Its ratio to the withdrawn rate grows with $n$:

| $\alpha$ | $n=10^8$ | $10^{10}$ | $10^{12}$ | $10^{14}$ |
|---|---|---|---|---|
| 0.10 | 2.7 | 3.8 | 5.0 | 7.5 |
| 0.15 | 5.7 | 10.3 | 19.2 | 35.3 |
| 0.20 | 6.4 | 11.7 | 20.0 | 33.6 |

These values agree with the first-round logic referee's table, and the second-round computation referee reproduced them. (The first-round computation referee's table concerns a different competitor, with $L_D(g)=1/2$.) The example does not show that the learner does badly. For this $D$ the zero network has $L_D(0)=p$, so the class minimum is nearly $0$, and nothing here bounds the learner's risk from below.

(c) *Against the class minimum, the question is open.* Corollary 2 applies Bernstein's inequality to a best-in-class $g^*$ with $L_D(g^*)\le1$. Its fluctuation is at most of order $(\bar U+1)/\sqrt n$, but I have not shown that a best-in-class competitor can fluctuate that much; in the example of (b), the zero network is nearly optimal and fluctuates negligibly. A numerical probe by the second-round logic referee points the other way. At $L=2$ and $d=1$, on a three-point law with a steep step and a rare distant point, the best competitors found by 400-restart box-constrained minimization overshoot at the rare point to between $0.33$ and $0.69$ times $\bar U$, with a loss standard deviation between $0.07$ and $0.26$ times $\bar U$, in four of five settings; in the fifth there is no overshoot (`../checks/verify-RT-width-logic-revised/check_bestinclass_fluct.out`). This suggests, but does not show, that the chain of Corollary 2 cannot beat $n^{2\alpha-1/2}$ even against the class minimum. Whether the excess over $\min_{\mathcal G}L_D$ is $o(n^{2\alpha-1/2})$ uniformly in $D$, by this proof or another, is open.

---

## 6. The strong-prior posterior

**Lemma F (Laplace concentration, uniform in the sample).** Fix $N,n\ge1$, $c>0$ and $\zeta>0$. For every sample $S\in(X\times[-1,1])^n$, the function $F=F_{c,S}$ is continuous and coercive, its minimum $m_*$ is attained, $m_*\le n/c$, and $\Pi_{\sigma,N,S}$ is a probability measure. Moreover
$$\sup_{S\in(X\times[-1,1])^n}\Pi_{\sigma,N,S}\bigl(F_{c,S}>m_*+\zeta\bigr)\xrightarrow[\sigma\downarrow0]{}0 .$$

*Proof.* Write $P=P_N$, write $\lvert w\rvert_N=\lvert\operatorname{diag}(\lambda_N)\,w\rvert=\sqrt{\kappa_N(w)}$, which is a norm on $\mathbb R^P$, and let $\lambda_{\max}$ be the largest entry of $\lambda_N$.

*Basic properties.* $F$ is continuous. Since $F\ge\kappa_N=\lvert w\rvert_N^2$, it is coercive and $0<\int e^{-F/(2\sigma^2)}\le\int e^{-\lvert w\rvert_N^2/(2\sigma^2)}<\infty$. Hence $m_*$ is attained, and $m_*\le F(0)=c^{-1}\sum_iy_i^2\le n/c$.

*A Lipschitz constant that does not depend on $S$.* Let $E=\{w:\lvert w\rvert_N^2\le n/c\}$ and $\Omega=\{w:\operatorname{dist}(w,E)\le1\}$. Both sets are compact and convex, and neither depends on $S$. The map $(w,x)\mapsto z_w(x)$ is smooth, so the following maxima over $\Omega\times[-1,1]^d$ are finite:
$$J_\Omega=\max\lvert\nabla_wz_w(x)\rvert,\qquad Z_\Omega=\max\lvert z_w(x)\rvert,\qquad R_\Omega=\max_{w\in\Omega}\lvert w\rvert_N .$$
Let $w,w'\in\Omega$.

- $\lvert\kappa_N(w)-\kappa_N(w')\rvert=(\lvert w\rvert_N+\lvert w'\rvert_N)\,\bigl\lvert\lvert w\rvert_N-\lvert w'\rvert_N\bigr\rvert\le2R_\Omega\lvert w-w'\rvert_N\le2R_\Omega\lambda_{\max}\lvert w-w'\rvert$.
- By the mean value theorem along the segment joining $w$ and $w'$, which lies in $\Omega$: $\lvert(z_w(x_i)-y_i)^2-(z_{w'}(x_i)-y_i)^2\rvert\le\lvert z_w(x_i)-z_{w'}(x_i)\rvert(2Z_\Omega+2)\le J_\Omega(2Z_\Omega+2)\lvert w-w'\rvert$.

Hence $\lvert F(w)-F(w')\rvert\le\ell_F\lvert w-w'\rvert$, where $\ell_F=2R_\Omega\lambda_{\max}+\frac ncJ_\Omega(2Z_\Omega+2)$ does not depend on $S$.

*Lower bound on the normalizer.* A minimizer $w_*$ has $\lvert w_*\rvert_N^2\le F(w_*)\le n/c$, so $w_*\in E$. Let $\rho=\min\{1,\zeta/(4\ell_F)\}$. The ball of radius $\rho$ around $w_*$ lies in $\Omega$, and on it $F\le m_*+\zeta/4$. Therefore
$$\int e^{-F/(2\sigma^2)}\ge v_P\rho^Pe^{-(m_*+\zeta/4)/(2\sigma^2)},$$
where $v_P$ is the volume of the unit ball in $\mathbb R^P$.

*Upper bound on the tail.* Let $\tau=\zeta/(4(n/c+\zeta))\in(0,\frac14]$. Where $F>m_*+\zeta$,
$$F=(1-\tau)F+\tau F\ge(1-\tau)(m_*+\zeta)+\tau\lvert w\rvert_N^2 .$$
Since $\int e^{-\tau\lvert w\rvert_N^2/(2\sigma^2)}dw=(2\pi\sigma^2/\tau)^{P/2}\big/\prod_j\lambda_{N,j}$, where $\lambda_{N,j}$ are the entries of $\lambda_N$,
$$\int_{\{F>m_*+\zeta\}}e^{-F/(2\sigma^2)}\le e^{-(1-\tau)(m_*+\zeta)/(2\sigma^2)}\Bigl(\frac{2\pi\sigma^2}\tau\Bigr)^{P/2}\frac1{\prod_j\lambda_{N,j}}.$$

*The ratio.* We have $(1-\tau)(m_*+\zeta)-m_*-\zeta/4=\frac34\zeta-\tau(m_*+\zeta)\ge\frac34\zeta-\tau(n/c+\zeta)=\frac\zeta2$. Dividing the two bounds,
$$\Pi_\sigma(F>m_*+\zeta)\le\frac{(2\pi\sigma^2/\tau)^{P/2}}{\prod_j\lambda_{N,j}\;v_P\rho^P}\,e^{-\zeta/(4\sigma^2)} .$$
The right side does not depend on $S$, and it tends to $0$ as $\sigma\downarrow0$. ∎

This is the argument of `B-tempered-likelihood.md` Lemma 3.1, simplified for bounded functionals. It goes back to the Laplace estimates in the proof of Theorem `strong` in `paper.tex`.

**Theorem 4 (the Bayesian predictors).** Fix $N,n,c$. Let $\mathcal E$ be any of the sample events of Theorem 1(b), Corollary 2 or Corollary 3, and let $\mathrm{RHS}$ be the corresponding bound for near-minimizers. For every sample in $\mathcal E$:
$$\limsup_{\sigma\downarrow0}\ \mathbb E_{\Pi_{\sigma}}L_D(\operatorname{clip}z_w)\le\mathrm{RHS},\qquad \limsup_{\sigma\downarrow0}\ L_D(\bar f_\sigma)\le\mathrm{RHS},\qquad \bar f_\sigma(x)=\mathbb E_{\Pi_\sigma}\operatorname{clip}z_w(x).$$
Moreover, for every $\epsilon'>0$ there is $\sigma_0=\sigma_0(d,H,N,n,c,\epsilon')>0$, which depends neither on $D$ nor on the sample, such that for all $\sigma\in(0,\sigma_0)$ and every sample in $\mathcal E$ both quantities are at most $\mathrm{RHS}+\epsilon'$. Since $\mathcal E$ does not involve $\sigma$, "on $\mathcal E$" and "for all $\sigma<\sigma_0$" can be taken in either order. The probability of the resulting statement is that of $\mathcal E$: at least $1-\delta/2$ for the events of Corollaries 2 and 3 and for the two-event versions in Theorem 1(b), and at least $1-3\delta/4$ for the three-event version.

*Proof.* Let $\Phi(w)=L_D(\operatorname{clip}z_w)$. It takes values in $[0,4]$ by (1.1), and it is continuous in $w$ by dominated convergence, hence Borel.

*Gibbs risk.* For every $\sigma$,
$$\mathbb E_{\Pi_\sigma}\Phi\le\sup_{\mathcal N_1}\Phi+4\,\Pi_\sigma(\mathcal N_1^c),$$
and on $\mathcal E$, $\sup_{\mathcal N_1}\Phi\le\mathrm{RHS}$. By Lemma F with $\zeta=1$, $\sup_S\Pi_\sigma(\mathcal N_1^c)\to0$, so we may choose $\sigma_0$ with $4\sup_S\Pi_\sigma(\mathcal N_1^c)\le\epsilon'$ for $\sigma<\sigma_0$.

*Posterior mean.* The map $(w,x)\mapsto\operatorname{clip}z_w(x)$ is jointly continuous and bounded, so $\bar f_\sigma$ is Borel with values in $[-1,1]$. By Jensen's inequality at each $(x,y)$, $(\bar f_\sigma(x)-y)^2\le\mathbb E_{\Pi_\sigma}(\operatorname{clip}z_w(x)-y)^2$. Integrating over $D$ and applying Tonelli's theorem gives $L_D(\bar f_\sigma)\le\mathbb E_{\Pi_\sigma}\Phi$. ∎

---

## 7. Scope, context and corrected wording

### 7.1 What the result does not cover

1. **Unclipped predictions, and the clip of the posterior mean.** The only output bound available for near-minimizers is $\lvert z_w\rvert\le\lVert v\rVert_1\le\sqrt N\lVert v\rVert_2=\sqrt{a_L}\le\sqrt{\kappa_N(w)}\le\sqrt{n/c+1}$, by Lemma B(a). A parameter-counting bound for the unclipped loss pays the loss range $(\sqrt K+1)^2\approx n/c$, which is vacuous at $c=1$. So the Gibbs risk and posterior mean of $z_w$, and $\operatorname{clip}(\mathbb E_{\Pi_\sigma}z_w)$, are not covered. For $\operatorname{clip}(\mathbb E_{\Pi_\sigma}z_w)$ the argument of Theorem 4 does not extend either. Jensen's inequality bounds the loss of an average of clipped outputs, but for an average $\bar z$ of raw outputs $z_1,\dots,z_k$ one has pointwise only $(\operatorname{clip}\bar z-y)^2\le\max_i(\operatorname{clip}z_i-y)^2$. For example, let each $z_i$ be at most $1$ everywhere and below $-(2k-1)$ on its own set $A_i$ of label $+1$, with the $A_i$ disjoint. Each $\operatorname{clip}z_i$ pays the loss $4$ on $A_i$, but $\operatorname{clip}\bar z$ pays it on all of $A_1\cup\dots\cup A_k$ (second-round logic report, m2(a)). Whether near-minimizers of $F_1$ behave like this is not known. Claim A's failure (`A-tight-conditioning-fails.md` Theorem 4.4) holds for clipped and unclipped predictors alike. The contrast "fails at large width, succeeds at small width" is therefore established for clipped predictors only.
2. **Several widths at once.** The event $\mathcal E_0(N)$ depends on $N$ through the grid. Suppose all widths $1\le N\le N_{\max}$ are wanted at once. Apply Theorem 1(a) with $\delta/N_{\max}$ for each $N$ and take a union bound; this replaces $\ln(4/\delta)$ by $\ln(4N_{\max}/\delta)$ in $\mathrm{Dev}_N$. If the competitor class depends on $N$, as in Corollary 3, the Bernstein events for the $N_{\max}$ best-in-class competitors cost the same replacement in $\Gamma_B$. The total failure probability stays at most $\delta/2$. For $L\ge3$, no bound for SP$_1$ whose excess tends to $0$ can hold at all learner widths: `A-tight-conditioning-fails.md` Theorem 4.4 gives a constant excess on the cube family at every $N\ge N_0$, with $N_0=O(n\log^2n)$ at a fixed accuracy (Remark 8). At such widths Theorem 1's bound exceeds $4$ and says nothing (Remark 8), so the two results are consistent.
3. **Other values of $c$.** Theorem 1 and Corollary 2 hold for every $c>0$. The parameter $c$ enters only through $c(E_*+1)/n$ and through $K=n/c+1$ inside $\Lambda_N$. Corollary 3 is stated for $c=1$ only.
4. **Sharper competitor constants.** The proof uses only two facts about $g$: $\lvert g\rvert\le U$ on $X$, and $\kappa_N(w^g_N)\le E_*$. So $U$ may be replaced by $\sup_X\lvert g\rvert$, and $E_*$ by the energy of any exact clone of $g$ at width $N$.
5. **The Bayesian structure.** Only Lemma B and Lemma F concern the learner. Lemma B says that near-minimizers have energy at most $n/c+1$ and training loss at most that of any clone. Lemma F says that the posterior concentrates on near-minimizers. Any procedure that returns a point of $\mathcal N_1$ at width $N$ has the same guarantee.
6. **Competitors with internal biases.** The class $\mathcal G_L(d,\bar m,\bar B)$ contains only networks of the repository architecture, and Lemma A needs that architecture. `B-tempered-likelihood.md` Remark 8.2 (imported) shows that a tanh network with internal biases, of width $m$ and with weights and biases in $[-B,B]$, computes the same function as a network of the repository architecture of width $m+1$ with weights in $[-B',B']$, $B'=\max\{B,1\}/\tanh1$. This note does not carry that conversion through its bounds; its statements concern the bias-free class only.

### 7.2 Context

**Remark 7 (how far the exponent can go; imported from `B-tempered-likelihood.md`).** Consider SP$_1$ at learner width $\lceil n^\alpha\rceil$ against $\mathcal G_L(d,\lceil n^\alpha\rceil,n^\alpha)$, for laws on $X\times[-1,1]$ with $X\subseteq[-1,1]^d$ and $d\le n^\alpha$. Fix one of the three covered predictors: the clipped near-minimizers (in the worst case over $\mathcal N_1$), $\limsup_{\sigma\downarrow0}$ of the clipped Gibbs risk, or $\limsup_{\sigma\downarrow0}$ of the risk of the posterior mean of the clipped outputs. Call $\alpha$ *good* if, for every fixed $\delta\in(0,1)$, the supremum over $d\le n^\alpha$ and over laws $D$ of the $(1-\delta)$-quantile over samples of the excess over $\min L_D$ tends to $0$ as $n\to\infty$; the supremum is taken outside the quantile. The *critical exponent* $\alpha_c$ is the supremum of the good $\alpha$.

Corollary 3(i) with Theorem 4 shows that every $\alpha<1/4$ is good, for all three predictors. No $\alpha>\frac L{2(2L-1)}$ is good: for such $\alpha$ the excess is at least $1-o(1)$ for every sample, on a law with $d=1$. So $\alpha_c\in\bigl[\frac14,\frac L{2(2L-1)}\bigr]$ for each of the three predictors. The set of good $\alpha$ need not be an interval, but its supremum is well defined and lies in this window. The window is $[0.25,0.333]$ at $L=2$ and $[0.25,0.3]$ at $L=3$, and its upper end decreases to $1/4$ as $L\to\infty$. The failure side is imported, and only the exponent arithmetic is new here.

- *What `B-tempered-likelihood.md` gives.* Let $D_{\delta_0}$ be uniform on $\{(-\delta_0,-1),(\delta_0,1)\}$, with $d=1$ and noiseless labels. The symbol $\eta$ below is that note's notation.
  - `B-tempered-likelihood.md` Lemma 9.2: if $mB\ge(\tanh1)^{-H}$ and $1\ge\delta_0\ge(\tanh1)^{-H}/(m^HB^L)$, some width-$m$ network with weights in $[-B,B]$ fits $D_{\delta_0}$ exactly.
  - `B-tempered-likelihood.md` Proposition 9.1(a): for every sample and every width $N$, every $w\in\mathcal N_1^{(N)}$ has $L_D(\operatorname{clip}z_w)\ge(1-\eta)^2$, where $\eta=\delta_0(K/L)^{L/2}$ and $K=n/c+1$, provided $\eta\le1$. The same lower bound holds for the $\liminf_{\sigma\downarrow0}$ of the clipped Gibbs risk and of the risk of the posterior mean of the clipped outputs (that note states it for the unclipped versions as well), hence also for their $\limsup_{\sigma\downarrow0}$, which the definition of a good $\alpha$ uses.
- *The exponent arithmetic.* Take $c=1$, $m=\lfloor n^\alpha\rfloor$, $B=n^\alpha$ and $\delta_0=(\tanh1)^{-H}/(m^HB^L)$. Since $m\ge n^\alpha/2$, we have $m^HB^L\ge2^{-H}n^{\alpha(2L-1)}$, and so
$$\eta\le(\tanh1)^{-H}2^H\,n^{-\alpha(2L-1)}\bigl((n+1)/L\bigr)^{L/2}\to0\qquad\text{if }\alpha(2L-1)>L/2 .$$
  For all large $n$ the hypotheses of Lemma 9.2 ($mB\ge(\tanh1)^{-H}$, $\delta_0\le1$) and $\eta\le1$ hold. Then the class contains a zero-loss network, while SP$_1$ has risk at least $(1-\eta)^2\to1$ at every width, for every sample.
- *Checks.* I re-derived Lemma 9.2 and the Lipschitz step of Proposition 9.1(a). `check_lemmas.py` (4) confirms numerically that $\log_{10}\eta$ changes sign across $\alpha=L/(2(2L-1))$ for $L=2,\dots,6$.

**Remark 8 (where the width transition lies; replaces the paragraph after Proposition 6.1).** Take $L\ge3$, $c=1$ and clipped predictions. The two ends below carry different quantifiers: success holds for every $D$, failure for one family.

- **Success.** Let $g$ be a competitor with fixed $m$ and $B$, with $m\le N$, and let $d\le n$. Theorem 1(b) bounds the excess over $L_D(g)$ by $(E_*+1)/n+4/n+\mathrm{Dev}_N(\delta)+\Gamma_B(g)$, for every $D$. Here $\Gamma_B(g)=O\bigl((U+1)\sqrt{\ell_\delta/n}\bigr)\to0$, and $E_*/n=O\bigl((d^2+m^2)B^2/n\bigr)$, which tends to $0$ when $d=o(\sqrt n)$; for the zero competitor $E_*=U=0$. When $N,d\le n$, $\Lambda_N=O_H(\ln n)$, so $\mathrm{Dev}_N\to0$ whenever $N(N+d)\ln n=o(n)$. On the cube family, where $d=\log_2n$ and the relevant competitor is $g\equiv0$, this gives success for $N=o(\sqrt{n/\ln n})$. The method stops there. Since $\Lambda_N\ge\ln(2n)$ and $P_N\ge(H-1)N^2$, the deviation term exceeds the trivial bound 4 once $N\ge\sqrt{2n/((H-1)\ln2n)}$.
- **Failure** (imported from the refereed `A-tight-conditioning-fails.md`: Theorem 4.4 with Lemma 2.1, Corollaries 4.5 and 4.5a, and Remark 4.7). Take the cube family $D_d$: $x$ uniform on $\{-1,1\}^d$, a fair $\pm1$ label independent of $x$, and $n/2^d\to\lambda\in(0,\infty)$. For a memorizer accuracy $a\in(0,1]$ (A's notation) put $N_0=\lfloor64\ln2\cdot d(d+1)\min\{n,2^d\}/a^2\rfloor+1=O(n\log^2n/a^2)$. On an event of probability at least $1-\delta$, at every width $N\ge N_0$, every near-minimizer has excess at least the quantity $\underline e$ of A's (4.3), clipped or not, and so do the Gibbs and posterior-mean predictors in the limit $\sigma\downarrow0$.
  - *Fixed accuracy.* For fixed $a$, $\underline e\to\bigl(\sqrt{\beta(\lambda)}-a\sqrt\lambda\bigr)_+^2$ (Remark 4.7).
  - *Full excess.* The full excess $\beta(\lambda)-o(1)$ needs $a=a_n\to0$, and every such schedule with $na_n\to\infty$ gives it: at $c=1$ the terms $\lambda a_n^2$ and $9(H+1)/(2a_n2^d)$ of A's $\epsilon$ then tend to $0$, as do its other terms. The threshold is $N_0=O(n\log^2n/a_n^2)$. For example, $a_n=1/d$ gives $N_0=O(n\log^4n)$; A's Corollary 4.5a uses $\max\{a_d,1/d\}$ and states this width. Corollary 4.5's schedule $a_d=(\max\{c,1\}/2^d)^{1/3}$, about $n^{-1/3}$ at $c=1$, gives $N_0=O(n^{5/3}\log^2n)$. So the failure end of the window can be taken $n^{1+o(1)}$, for the full excess as well. The probability bound holds for fixed $\delta$, and $\delta=\delta_n\to0$ slowly also works.
  - *Numbers.* At $c=1$, $H=2$, $\lambda=1$ and $\delta=0.01$, the schedule $a=1/d$ certifies excess $0.449$, $0.462$ and $0.471$ at $d=40$, $60$ and $100$, against $\beta(1)=0.4848$, with $N_0\approx4.5\cdot10^5\,n\log_2^2n$ at $d=100$ (`../checks/verify-RT-width-computation-revised/transition_check.out`, part (a)).
- **In between.** Nothing is proved between these ranges, and no monotonicity in $N$ is shown.

### 7.3 Corrected wording for the places in `red-team.md` that cite Proposition 6.1

Line numbers refer to the version of `red-team.md` that the referees read. In the finalized `red-team.md`, lines 480–497 of its §6.3 have been replaced by a pointer to this note with a summary of it, and the other entries below have been applied verbatim (`red-team.md`, "Record of the finalization"). These lines hold Proposition 6.1, its "In particular" clause, its proof and the paragraph after the proof; the second and third §6.3 entries below cover them. The rest of §6.3 stays in `red-team.md`: the heading and the list of surviving versions (lines 472–478), with item 2 amended as in the first §6.3 entry below, and Remark 6.2 on conditioning on aggregate fit (lines 499–505). Remark 6.2 was refereed separately ([`../verification/RT-aggregate-logic.md`](../verification/RT-aggregate-logic.md)), and `A-tight-conditioning-fails.md` §5.4 cites it. The other entries say how the remaining citations of Proposition 6.1 should read.

- **§0 item 1** (line 20). Replace "At widths $N\le n^{1/2-\epsilon}$ the same learner is agnostically consistent by parameter counting (Proposition 6.1)" by: "At learner widths with $N(N+d)\log n=o(n)$ and input dimension $d=o(\sqrt n)$, for example $N\le n^{1/2-\epsilon}$ with $d\le N$, the same learner with clipped predictions is agnostically consistent against every fixed competitor of the repository architecture with width at most $N$, by parameter counting (`small-learner-width.md`, Theorems 1 and 4, Remark 8)."
- **§0 item 7** (line 30). Replace "learner width tied to $n$ (Proposition 6.1)" by "learner width tied to $n$, with clipped predictions (Proposition 6.1 as corrected in `small-learner-width.md`)".
- **§2.3 A2** (line 196). Three sentences of A2 rest on Proposition 6.1: "At $N\le n^{1/2-\epsilon}$ (for $L\ge3$), the same learner satisfies an agnostic oracle inequality against every competitor of width $\le N$ (Proposition 6.1).", "So A refutes **width-uniform** statements, which is the repository's style and the brief's formalisation." and "It does not refute 'Bayesian learning at width $n^{\alpha}$ competes with width-$n^\alpha$ networks', and that statement is true for $\alpha<1/4$." (Inner quotation marks are single here.) Replace these three sentences by: "At learner width $N\le n^{1/2-\epsilon}$, with inputs in a compact $X\subseteq[-1,1]^d$ and $d\le n^{1/2-\epsilon}$, the same learner with clipped predictions has excess at most $O_L\bigl(B_0n^{-\epsilon}\sqrt{\ln(4/\delta)}+n^{-\epsilon}\sqrt{\ln n}+B_0^2n^{-2\epsilon}\ln(4/\delta)\bigr)$ over the best network of the repository architecture with width at most $N$ and weights at most $B_0$, for any fixed $B_0\ge1$ (`small-learner-width.md`, Corollary 3(iii) with Theorem 4; for $B_0<1$ use $\max\{B_0,1\}$). At learner width $\lceil n^\alpha\rceil$ with $d\le n^\alpha$, against the networks of the repository architecture with width and weights at most $n^\alpha$, its excess is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$, polynomially small for every $\alpha\in(0,\frac14)$ (Corollary 3(i)). So A refutes **width-uniform** statements, which is the repository's style and the brief's formalisation. It does not refute 'Bayesian learning at width $n^\alpha$ competes with the networks of width and weights at most $n^\alpha$', which holds for $\alpha<1/4$ in the sense just stated. The weight bound cannot be dropped: for every $n$ there is a noiseless law in $d=1$ that a width-1 network with large weights fits exactly and on which SP$_c$ misses by at least $1/4$ at every learner width (`B-tempered-likelihood.md` Proposition 9.1(a) and Lemma 9.2)."
- **§6.3 item 2** (line 475). Replace "**Learner width tied to $n$** (Proposition 6.1 below)" by "**Learner width tied to $n$**, with clipped predictions (Proposition 6.1, corrected in `small-learner-width.md`)".
- **§6.3, Proposition 6.1, the "In particular" clause and the proof** (lines 480–495). Replace by a pointer to Theorem 1, Corollaries 2 and 3, and Theorem 4 of this note.
- **§6.3, the paragraph after the proof** (line 497). Replace by a pointer to Remark 8.
- **§7 item 6** (line 530). Replace "everything is classical (Proposition 6.1)" by "everything is classical for clipped predictions (Proposition 6.1, corrected in `small-learner-width.md`)".
- **§8, "E, positive direction" (sketch), second bullet** (line 562). This use of Proposition 6.1 is not supported by the corrected result. The sketch concerns the finite-scale posterior with a tempered likelihood and no $\sigma\to0$ limit. Theorem 1(a) bounds the clipped test risk by the clipped training risk plus $\mathrm{Dev}_N(\delta)+4/n$ for every parameter of energy at most a fixed budget $K$; it is written for $K=n/c+1$, and the proof works for any fixed $K$, with $\Lambda_N$ computed at that $K$. But this note reaches the posterior only through the near-minimizers of $F_c$, whose energy Lemma B(a) bounds, and through Lemma F and Theorem 4, which are strong-prior statements. The sketch's concentration set bounds only the training loss. Applying Theorem 1(a) there would need, in addition, a bound on the energy of the finite-scale posterior (a finite-scale analogue of Theorem 4), and clipped predictions. Replace the bullet by the following text, whose symbols are those of `red-team.md` §8 ($\theta$ the tempering exponent, $\gamma$ the prior-scale exponent, $a$ an accuracy): "For $m\le N<T$, where $T\asymp(n^{\theta(L-2)}/a^2)^{1/(\gamma-1)}$: open. If $T\le n^{1/2-\epsilon}$, that is, if $\theta<(\gamma-1)/(2(L-2))$, the parameter-counting bound of `small-learner-width.md` Theorem 1(a) would apply to clipped predictions, given a bound on the energy of the finite-scale posterior; no such bound is proved." The exponent arithmetic is the bullet's own and is correct (second-round computation report, issue 2). The finite-scale positive direction is proved by another route in `E-finite-prior-scale.md` Theorem 2.7, for clipped predictions at every width $N\ge m$ and for $\theta<\theta_{L,\gamma}$, which for $L\ge3$ is $1/H$ when $\gamma\ge2-1/H$ and smaller when $1\le\gamma<2-1/H$ (at $\gamma=1$ conditionally on an imported mean-field cover).

### 7.4 Places in `A-tight-conditioning-fails.md` that cite Proposition 6.1

`A-tight-conditioning-fails.md` is finalized separately, and this note does not edit it. The version of A that this note was checked against cited `red-team.md` Proposition 6.1 as "refereed with a corrected rate, repair under review" in §5.3 item 3 (second paragraph), §5.4 ("The heuristic", last sentence) and §10 item 5, and its referee record describes the repair as under review. After this note was finalized, the lead editor replaced those three citations in A by the wording suggested below; A's referee record still describes the text as it was when A was refereed. The version that the second-round logic referee read called Proposition 6.1 an unchecked, unrefereed parameter-counting sketch (m3). Now that the repair is refereed, the three places in the main text can cite this note.

The suggested wording states two restrictions that A's present wording leaves implicit. First, Corollary 3(i) is proved at $c=1$ only (§7.1 item 3), while A also treats SP$_c$ with $c$ growing in $n$. For such $c$ Corollary 2 still applies, but on the class of Corollary 3(i) the clone term $c(\bar E_*+1)/n$ of its excess (5.1) is of order $c\,n^{4\alpha-1}$, so the bound tends to infinity whenever $c\gg n^{1-4\alpha}$; at $c=n^{1/2}$ and $\alpha=0.2$, for example, the clone term grows like $n^{0.3}$. Second, the fixed-competitor statement needs the competitor's width to be at most $N$, as Theorem 1(b) does, and it holds for every fixed $c>0$: Theorem 1(b) holds for every $c>0$, and $c$ enters its bound only through $c(E_*+1)/n$ and through $K=n/c+1$ inside $\Lambda_N$ (§7.1 item 3), so for fixed $c$ the arithmetic of the success bullet of Remark 8, done there at $c=1$, changes only constants. Suggested wording:

- **§5.3 item 3**, from "For small $\alpha'$ there is a positive result" to "at rate $\tilde O(n^{2\alpha'-1/2})$": "For small $\alpha'$ there is a positive result: `small-learner-width.md` (the corrected `red-team.md` Proposition 6.1, refereed in its corrected form) bounds by parameter counting the clipped test MSE of the near-minimizers of $F_c$ at a fixed learner width $N$, for every $c>0$, $c=1$ included, and transfers the bound to the clipped Gibbs risk and the posterior mean of the clipped outputs (its Theorems 1 and 4). For fixed $c>0$, a fixed competitor of width at most $N$ and $d=o(\sqrt n)$, its bound vanishes when $N(N+d)\ln n=o(n)$, for example $N=o(\sqrt{n/\log n})$ on the cube family. At $c=1$, against competitors of the repository architecture with width and weights at most $n^{\alpha'}$, at learner width $\lceil n^{\alpha'}\rceil$ and $d\le n^{\alpha'}$, the excess is $O(n^{2\alpha'-1/2})$ for every $\alpha'<1/4$ (its Corollary 3(i)); the rate $O(n^{4\alpha'-1}+n^{\alpha'-1/2}\sqrt{\log n})$ of `red-team.md` is withdrawn."
- **§5.4, "The heuristic", last sentence.** Replace "`red-team.md` Proposition 6.1, refereed with a corrected rate, repair under review" by "`small-learner-width.md` (the corrected `red-team.md` Proposition 6.1)". The sentence already restricts the positive result to SP$_1$.
- **§10 item 5**, from "`red-team.md` Proposition 6.1, refereed with a corrected rate" to the end of the item: "`small-learner-width.md` (the corrected `red-team.md` Proposition 6.1) gives a positive result for clipped predictions of SP$_c$ at small learner widths: for fixed $c>0$, a fixed competitor of width at most $N$ and fixed $d$, when $N=o(\sqrt{n/\log n})$; and at $c=1$, against competitors of the repository architecture with width and weights at most $n^\alpha$, at learner width $\lceil n^\alpha\rceil$ and $d\le n^\alpha$, excess $O(n^{2\alpha-1/2})$ for every $\alpha<1/4$ (§5.3 item 3)."

The width at which A certifies the full excess (m4) is already stated correctly in A, through its Corollary 4.5a.

---

## 8. Numerical checks

All scripts are in `../checks/small-learner-width/`. Each was run there as `python3 X.py > X.out`.

| script | what is checked | result |
|---|---|---|
| `check_explicit_bound.py` | (1) exact $\mathrm{Exc}$ of (5.1) against the simplified bound (5.2), on 160,750 admissible combinations with $n$ up to $10^{300}$ (60-digit arithmetic); (2) $\Lambda_N\le(H+5)\ln2n$; (3) log–log slopes of the Bernstein and Hoeffding forms, including weights $n^\omega$; (4) values; (5) the A2 setting ($B_0=1$, $d=10$, $L=3$); (6) the constant $C_{L,\alpha,\delta}$ of Corollary 3(i) | (1) max ratio $0.678$; (2) max ratio $0.631$; (3) slopes agree with the predicted exponents to within $0.002$ (the gap comes from the $\sqrt{\ln n}$ factor); for example, at $\alpha=0.2$ the Bernstein form has slope $-0.100$ and the Hoeffding form $+0.300$; (4) at $\alpha=0.2$ the Bernstein form is $0.228$ at $n=10^{12}$, the Hoeffding form $5.9\cdot10^3$; at $\alpha=0.24$ the Bernstein form is $4.36$, $0.67$ and $0.030$ at $n=10^{12}$, $10^{40}$, $10^{100}$; (5) Bernstein-form $\mathrm{Exc}$ is $0.37$ at $\epsilon=0.1$, $n=10^{20}$ and $6.9\cdot10^{-15}$ at $\epsilon=0.2$, $n=10^{80}$; the Hoeffding form is $1.5\cdot10^6$ and $1.5\cdot10^8$; (6) $t^{-\alpha}\sqrt{\ln2t}\le2^\alpha/\sqrt{2e\alpha}$ at all 8,401 grid points for ten values of $\alpha$, with equality at $t_*$; in case (i), (5.2) is at most $0.9997$ and $\mathrm{Exc}$ at most $0.49$ times $C_{L,\alpha,\delta}n^{2\alpha-1/2}$, on 4,400 combinations |
| `check_lemmas.py` | (1) Lemma E(ii) against exact binomial tails for two-point losses (9,090 cases) and three-point losses (864 cases); (2) Lemma C on 4,500 perturbed random networks at energy exactly $K$, with random-sign and sign-gradient perturbations; (3) Lemma A on 400 random competitors; (4) the exponent arithmetic of Remark 7 | (1) max exact tail$/\delta'$ is $0.19$ and $0.05$; (2) max $\lvert\Delta z\rvert$ over the bound is $0.73$ for the sharper form and $0.49$ for the closed form (the second-round referees' adversarial searches reach $0.90$–$0.92$ and $0.64$–$0.74$ at $H=1$); (3) clone error at most $3\cdot10^{-14}$, $\kappa_N(\text{clone})/E_*\le0.75$; (4) $\log_{10}\eta$ changes sign across $L/(2(2L-1))$ for $L=2,\dots,6$ |
| `check_competitor_fluct.py` | the competitor of Remark 6(b): exact binomial quantiles of $\hat L(g)-L_D(g)$ | the $95\%$ quantile is between $1.63$ and $1.72$ times $(G+1)/\sqrt n$; its ratio to the withdrawn rate is $2.7$–$35$ for $n=10^8$ to $10^{14}$, and it grows with $n$ |

In the revision that answered the second round, the docstrings of the three scripts were changed to give this note's file name and current item numbers, the printed labels were changed (the weight exponent is printed as `omega`, or `w` in formulas, and `redteam` became `red-team`), and part (6) was added to `check_explicit_bound.py`. All three were re-run in the checks folder, each in under a minute. Apart from these labels and part (6), the outputs are unchanged.

---

## 9. Response to referees, first round

The four major issues come first, one entry each. The minor points from the two full reports follow. Symbols are those of the final text (§10, logic m1).

**Issue 1** (major; logic report; "In particular" sentence and the proof's last step). *The claimed excess drops the display's competitor term $(U+1)^2\sqrt{\ln(4/\delta)/(2n)}$, which is $\Theta(n^{4\alpha-1/2}\sqrt{\log1/\delta})$ on the stated class. So the display gives a polynomially small excess only for $\alpha<1/8$. The chain through $\hat L(g)$ cannot give the claimed rate. Suggested fix: Bernstein, with the trivial case $L_D(g)\ge4$; or keep Hoeffding and restrict to $\alpha<1/8$; align with `B-tempered-likelihood.md` Corollary 8.1.*

Accepted in full.

- *Bernstein step.* Lemma E(ii) implements it, and Theorem 1(b) uses the suggested case split. The term $\Gamma_B$ contains $\min\{L_D(g),4\}$, so it is always at most $(U+1)\sqrt{8\ell_\delta/n}+\frac23(U+1)^2\ell_\delta/n$.
- *The clause.* It is restated as Corollary 3(i), with explicit constants:
$$5\sqrt2\,n^{2\alpha-1/2}\sqrt{\ell_\delta}+4\sqrt{(2H+1)(H+5)}\,n^{\alpha-1/2}\sqrt{\ln2n}+(8L-1)(1+\ell_\delta)n^{4\alpha-1}.$$
  This is the suggested form; the $\sqrt{\ell_\delta/n}$ part of the deviation term is absorbed into the first term.
- *The Hoeffding alternative* is recorded as Remark 5: $\alpha<1/8$, with rate $n^{4\alpha-1/2}$.
- *The claimed rate is withdrawn* (Remark 6(a)). Remark 6(b) reproduces the referee's competitor; my exact computation gives the same ratios as the referee's table: $2.73$, $3.80$, $5.02$ and $7.54$ at $\alpha=0.1$.
- *Alignment with `B-tempered-likelihood.md` Corollary 8.1.* `B-tempered-likelihood.md` keeps the Hoeffding term and restricts $\alpha$ so that $4\alpha-\frac12\le-\beta$, where $\beta$ is the rate exponent of its Corollary 8.1, so it is internally consistent. This note now states its competitor term explicitly, in the same way. `B-tempered-likelihood.md` is not edited here.

**Issue 2** (major; computation report; the "In particular" rate). *Same omission, with numbers: slope $+0.300$ at $\alpha=0.2$; $5.9\cdot10^3$ at $n=10^{12}$. Suggested fix: Bernstein with variance at most $(U+1)^2L_D(g)$, applied to a best-in-class $g^*$ with $L_D(g^*)\le L_D(0)\le1$, giving $\tilde O(n^{2\alpha-1/2})$ for every $\alpha<1/4$; or restrict to $\alpha<1/8$.*

Accepted. Corollary 2 implements the fix:

- $g^*$ exists by compactness and continuity;
- $L_D(g^*)\le L_D(0)=\mathbb Ey^2\le1$;
- one Bernstein event for $g^*$, with total failure probability at most $\delta/2$.

Corollary 3 gives the rate. `check_explicit_bound.out` reproduces the referee's numbers: slope $+0.300$ for the Hoeffding form at $\alpha=0.2$; Hoeffding-form values $5.9\cdot10^3$ at $n=10^{12}$ and $1.48\cdot10^{12}$ at $n=10^{40}$. The Bernstein form has slope $-0.100$ and value $0.228$ at $n=10^{12}$. The threshold of the Hoeffding form is $\alpha=1/8$: the slope is $0.000$ at $\alpha=0.125$.

**Issue 3** (major; computation report; the stated rate itself). *The rate is not established, and the proof cannot give it: an explicit competitor with $L_D(g)=1/2$ fluctuates at scale $U/\sqrt n$. Suggested restatement: $\tilde O(n^{2\alpha-1/2})$. More generally, width $\le n^\alpha$, weights $\le n^\beta$ and $d\le n^\alpha$ give excess $O(n^{2(\alpha+\beta)-1}\ln\frac4\delta+n^{\alpha+\beta-1/2}\sqrt{\ln\frac4\delta}+n^{\alpha-1/2}\sqrt{\ln n})$, polynomially small iff $\alpha+\beta<1/2$.*

Accepted.

- *The rate.* Corollary 3(i) states the excess with explicit constants; for fixed $\alpha\in(0,\frac14)$ it is $O_{L,\alpha,\delta}(n^{2\alpha-1/2})$, and the leading term carries no logarithm.
- *General weights.* Corollary 3 is proved for an arbitrary weight bound $\bar B\ge1$. Case (ii) is the referee's $(\alpha,\beta)$ form, with $\beta$ written $\omega$ here, the same exponents and the same "iff" for the bound. At $\omega=0$ every $\alpha<1/2$ works. My slopes for the full bound agree with the referee's exponents to within $0.002$, including at $(\alpha,\omega)=(0.4,0)$, $(0.45,0)$ and $(0.3,0.15)$.
- *One qualification.* The referees' competitor examples show that no per-competitor use of the chain beats $n^{2\alpha-1/2}$. They do not settle the class-minimum version, which applies Bernstein to a best-in-class $g^*$: in both examples the zero network is nearly optimal and fluctuates negligibly. I therefore record the faster rate for the class minimum as open, not refuted (Remark 6(c)). This matches the referee's own conclusion that the stated rate is "unproven, not shown false".

**Issue 4** (major; `red-team.md` §0 item 1 and §2.3 A2). *A2 claims an oracle inequality against every competitor of width $\le N$ at $N\le n^{1/2-\epsilon}$. With fixed $B$ the Hoeffding term is about $B^2n^{1/2-2\epsilon}$, which diverges for $\epsilon<1/4$; the Bernstein version tends to 0. Suggested fix: the Bernstein repair, or $N\le n^{1/4-\epsilon}$. §0 item 1 (fixed competitor) is fine.*

Accepted.

- *A2.* Corollary 3(iii) proves A2 with the Bernstein repair: learner width $N\le n^{1/2-\epsilon}$, $d\le n^{1/2-\epsilon}$, the class of width $\le N$ and weights $\le B_0$, and excess at most
$$5\sqrt2B_0n^{-\epsilon}\sqrt{\ell_\delta}+4\sqrt{(2H+1)(H+5)}\,n^{-\epsilon}\sqrt{\ln2n}+(8L-1)(1+\ell_\delta)B_0^2n^{-2\epsilon}.$$
- *The referee's setting* ($d=10$, $B=1$, $L=3$). The full Bernstein-form bound is $0.37$ at $\epsilon=0.1$, $n=10^{20}$ and $6.9\cdot10^{-15}$ at $\epsilon=0.2$, $n=10^{80}$. The Hoeffding form is $1.5\cdot10^6$ and $1.5\cdot10^8$. The referee's $3\cdot10^{-2}$ and $3\cdot10^{-16}$ are the competitor term alone.
- *§0 item 1.* It concerns a fixed competitor and is correct, but it needs "with clipped predictions" and the width condition $N(N+d)\log n=o(n)$. §7.3 gives replacement text for both places.

**Minor points from the full reports.**

- *Clipped predictions only* (logic 3; computation, closing sentence). Adopted. The covered predictors are listed in §1, unclipped outputs are excluded in §7.1, and every replacement sentence in §7.3 says "with clipped predictions".
- *Passage from near-minimizers to the Bayesian learner* (logic 4; computation §6 item 4). Added as Lemma F and Theorem 4. These cover the clipped Gibbs risk and the posterior mean of clipped outputs, with $\sigma_0$ depending on $(d,H,N,n,c,\epsilon')$ only.
- *Hypotheses for "min over the class"* (logic 5).
  - (i) One grid for all competitors: now automatic, since the energy budget $K=n/c+1$ does not depend on the competitor (Lemma B(a)).
  - (ii) Existence of $g^*$: Corollary 2.
  - (iii) Repository architecture: part of the definition of competitors in §1, and needed for Lemma A.
- *$O_L$ and $\delta$ dependence* (logic 6; computation §6 item 6). Corollary 3 gives explicit constants and shows $\sqrt{\ell_\delta}$ and $\ell_\delta$.
- *"For $L\ge3$" is unnecessary* (logic 6; computation §6 item 3). Dropped; Corollary 3 covers every $L\ge2$.
- *The closing sentence* (logic 7; computation §5). Replaced by Remark 8. The success range is now $N(N+d)\ln n=o(n)$, so $N=o(\sqrt{n/\ln n})$ on the cube family, not "$\sqrt n$". The failure is stated on the cube family at a fixed accuracy, with the reduced excess $(\sqrt{\beta(\lambda)}-a\sqrt\lambda)_+^2$. The note now says that nothing is known in between and that no monotonicity in $N$ is shown. (The second round corrected the remark on the full excess and the hypothesis on $d$; §10, logic m4 and m5.)
- *The critical-exponent window* (logic 8). Recorded as Remark 7, with the exponent arithmetic re-done and the `B-tempered-likelihood.md` inputs marked as imported.
- *Conservative probability accounting* (computation §6 item 1). Kept, with $\ln(4/\delta)$ per event. The failure probabilities are now stated explicitly: $\delta/2$ or $3\delta/4$ in Theorem 1, $\delta/2$ in Corollary 2.
- *Discretization cost $4/n$ instead of $8/n$* (computation §6 item 2). Adopted, since the rounding radius is $\xi_N/2$.
- *The event depends on $N$; union bound for several widths* (computation §6 item 5). §7.1 item 2.
- *The perturbation bound is loose* (computation §6 item 7). No change to Lemma C, since its constant enters only inside the logarithm $\Lambda_N$. My check finds at most $0.49$ of the closed form; the first-round referees found $0.38$ and $0.40$. The second round showed that "loose" was wrong at $H=1$: adversarial searches reach $0.90$–$0.92$ of the sharper form and $0.64$–$0.74$ of the closed form there (the paragraph after Lemma C).
- *No "Lemma 2.3" in `red-team.md`* (computation, inputs). This note is self-contained. The near-minimizer facts are Lemma B, matching `B-tempered-likelihood.md` Lemma 2.3. The parts of `red-team.md` Theorem 3.2 used are its first paragraph, which is Lemmas A and B here; the Rademacher part is not used.

---

## 10. Referee record, second round

Two referees reviewed the repaired text, through the same lenses as in the first round. Its result numbers are those of this text.

- [`../verification/RT-width-logic-revised.md`](../verification/RT-width-logic-revised.md): logic and definitions (quantifiers, limit order, hypotheses, use of the sources). Its scripts are in `../checks/verify-RT-width-logic-revised/`.
- [`../verification/RT-width-computation-revised.md`](../verification/RT-width-computation-revised.md): constants, exponents, probability estimates and quoted numbers. Its scripts are in `../checks/verify-RT-width-computation-revised/`.

Both returned the verdict "minor fixes". Neither found an error in Lemmas A–F, Theorem 1, Corollaries 2 and 3 or Theorem 4. The logic referee found no circularity, misapplied lemma or missing hypothesis in the proof, and the computation referee reproduced every number quoted from the scripts. The reports' line numbers refer to the text they reviewed, not to this one.

The table has one row per issue in the issue lists (logic report §3, m1–m12; computation report §3, issues 1–7, with the four parts of issue 7 in separate rows), and one row each for two observations in the reports' audit sections that led to a change. *Fixed* means that a wrong or imprecise statement, number, symbol or citation was corrected, or a missing step or explanation was added, without reducing what any proved statement asserts. *Weakened* means that a sentence that claimed more than is proved now carries the missing hypothesis or qualifier, or claims less. *Rebutted* means that the issue was judged invalid and the text left unchanged; no issue was rebutted.

| report | issue | resolution | where |
|---|---|---|---|
| logic m1 | $\Lambda_N$ names both the diagonal energy matrix and the logarithm in $\mathrm{Dev}_N$; also $U$ ($U^\ell$ and $mB$), $a$ (Lemma F and $a_\ell$), $\eta$ (Lemma C, Remark 7, the brief), $\kappa$ (Corollary 3(i) and $\kappa_N$), $G$ (Remark 6(b) and $G_\Omega$) | fixed: the energy matrix is now written $\operatorname{diag}(\lambda_N)$, so $\Lambda_N$ is only the logarithm, as in the scripts and both reports; competitor matrices $M^\ell$; Lemma F's split $\tau$ and gradient bound $J_\Omega$; perturbation size $\xi$ and mesh $\xi_N$; $\eta$ kept only in Remark 7, marked as B's notation; $\kappa$ no longer used in Corollary 3(i) | §1; Lemmas A, C, D, F; Corollary 3(i); Remark 7; §9 |
| logic m2 | "In the user's words" overstates coverage: (a) "clip its predictions" reads as $\operatorname{clip}(\mathbb E_\Pi z_w)$, which is excluded; (b) "depth-$L$ tanh networks" drops the repository architecture; (c) $X\subseteq[-1,1]^d$ is missing | weakened: the paragraph names the two covered posterior predictors and excludes $\operatorname{clip}(\mathbb E_\Pi z_w)$, names the architecture and the input domain; §7.1 item 1 explains why Jensen's step does not reach $\operatorname{clip}(\mathbb E_\Pi z_w)$ | §5, "In the user's words"; §1 (predictors covered); §7.1 item 1 |
| logic m3 | §7.3 is not the complete list it claims: `red-team.md` §8 (line 562) applies Proposition 6.1 to the finite-scale posterior, where Lemma F and Theorem 4 do not apply and clipping is needed; `A-tight-conditioning-fails.md` still calls Proposition 6.1 unrefereed | fixed: §7.3 entry added, marking that use as unsupported until a finite-scale analogue of Theorem 4 is proved, and pointing to `E-finite-prior-scale.md` Theorem 2.7; suggested wording for A in §7.4 (A is edited separately; the version of A checked against this note said "refereed with a corrected rate, repair under review", and A now uses the suggested wording) | §0 ("Added"); §7.3, last entry; §7.4 |
| logic m4 | Remark 8: "the full excess needs $a\to0$, and then $N_0=O(n^{5/3}\log^2n)$" misleads; $5/3$ comes from Corollary 4.5's schedule | fixed: every schedule $a_n\to0$ with $na_n\to\infty$ gives the full excess at $N_0=O(n\log^2n/a_n^2)$; $a_n=1/d$ gives $O(n\log^4n)$ (A's Corollary 4.5a); Corollary 4.5's $a\approx n^{-1/3}$ gives $O(n^{5/3}\log^2n)$; the computation referee's numbers quoted | Remark 8, failure bullet; §0 |
| logic m5 | Remark 8 success bullet says "fixed $m,B,d$" and then uses the cube family, where $d=\log_2n$ | fixed: fixed $m,B$ and $d\le n$, with $E_*/n\to0$ for $d=o(\sqrt n)$ and $E_*=0$ for the zero competitor; the same hypothesis on $d$ added to the §7.3 replacement for `red-team.md` §0 item 1 | Remark 8, success bullet; §7.3, first entry |
| logic m6 | Remark 5's title and the §0 "Weakened" bullet say the original clause holds for $\alpha<1/8$; only its conclusion "polynomially small" does, at rate $n^{4\alpha-1/2}$ | weakened | Remark 5 (title and body); §0, "Weakened" |
| logic m7 | §7.3 replacement for A2: omits $d\le n^\alpha$ and $X\subseteq[-1,1]^d$, needs $B_0\ge1$, omits the repository architecture; three A2 sentences depend on Proposition 6.1, and "the two sentences" does not say which | weakened: the three sentences are quoted and replaced; the replacement states $d$, $X$, $B_0\ge1$ (else $\max\{B_0,1\}$) and the architecture | §7.3, A2 entry; Corollary 3(iii) (the $B_0<1$ case) |
| logic m8 | Theorem 4: "with probability at least $1-\delta/2$" and "for all $\sigma<\sigma_0$" in either order; the triple event of Theorem 1(b) has probability $1-3\delta/4$ | fixed: the probability is that of $\mathcal E$, listed per event | Theorem 4, last sentences |
| logic m9 | §9 calls the perturbation bound loose; an adversarial search reaches $0.90$ of the sharper form and $0.64$ of the closed form at $H=1$ | fixed: "loose" withdrawn, the referees' values quoted | paragraph after Lemma C; §8; §9, entry on computation §6 item 7 |
| logic m10 | Corollary 3(i): "at most $Cn^{-\kappa}$ for every $\kappa<\frac12-2\alpha$" is weaker than what §0 states | fixed: stated and proved for $\kappa=\frac12-2\alpha$ with the explicit constant $C_{L,\alpha,\delta}$; checked numerically | Corollary 3(i) and the end of the proof of (5.2); §0; `check_explicit_bound.py` part (6) |
| logic m11 | Remark 7's "critical exponent" does not name the predictors or the probability mode | fixed: defined for each of the three predictors, with the $(1-\delta)$-quantile over samples and the supremum over laws outside; the set of good $\alpha$ need not be an interval | Remark 7 |
| logic m12 | Lemma E(ii) cites "Ch. 2" instead of Theorem 2.10 / Corollary 2.11 | fixed: Corollary 2.11, with Theorem 2.10 for the sharper linear term | Lemma E |
| logic §2.7 (observation) | Remark 6(c): a probe at $L=2$ found best-in-class competitors that fluctuate at scale $\bar U$ in four of five settings | fixed: reported in Remark 6(c) as evidence that suggests, but does not show, a negative answer; the question stays open | Remark 6(c) |
| computation 1 | Remark 8: the $n^{5/3}$ sentence suggests the full excess needs width $n^{5/3}$; any $a_n\to0$ gives $N_0=O(n\log^2n/a_n^2)$, for example $O(n\log^4n)$ with $a=1/d$ | fixed (as logic m4) | Remark 8, failure bullet |
| computation 2 | §0 and §7.3 omit `red-team.md` line 562; that use is outside Theorem 1's scope: no energy bound for the finite-scale posterior, clipping needed | fixed (as logic m3): the entry says that Theorem 1(a) needs an energy budget, which the finite-scale posterior is not shown to satisfy, and marks the use as not covered | §0; §7.3, last entry |
| computation 3 | §7.3 replacement for A2 omits $d\le n^\alpha$; "the two sentences" is ambiguous; the sentence without a weight bound is false (`B-tempered-likelihood.md` §9) and must be replaced | weakened (as logic m7): the replacement adds $d\le n^\alpha$, quotes the sentences it replaces, and states that the weight bound cannot be dropped, citing `B-tempered-likelihood.md` Proposition 9.1(a) and Lemma 9.2 | §7.3, A2 entry |
| computation 4 | notation: $\Lambda_N$ twice; $U$; $\eta$; $\beta$ for the weight exponent and for $\beta(\lambda)$ | fixed (as logic m1); the weight exponent of Corollary 3(ii) is now $\omega$, and the script prints `omega` | §1; Lemmas; Corollary 3(ii); §0; §9; `check_explicit_bound.py` part (3) |
| computation 5 | Corollary 3(i) and the end of the proof of (5.2) prove only the strict-$\kappa$ form; state and prove the $\kappa=\frac12-2\alpha$ form, with a constant depending on $\alpha$ through $\sup_nn^{-\alpha}\sqrt{\ln2n}$ | fixed (as logic m10): $\sup_{t\ge1}t^{-\alpha}\sqrt{\ln2t}=2^\alpha/\sqrt{2e\alpha}$ | Corollary 3(i); proof of (5.2) |
| computation 6 | "In the user's words": add the repository architecture and inputs in $[-1,1]^d$; biased networks need a conversion that the note does not prove | weakened (as logic m2); §7.1 item 6 cites `B-tempered-likelihood.md` Remark 8.2 for the conversion and says that it is not carried through here | §5, "In the user's words"; §7.1 item 6 |
| computation 7(a) | informational: the constant $5\sqrt2$ is about 5 times the true leading coefficient $\sqrt2$ in case (i) | fixed: stated, with the source of the factor | §5, paragraph after the script results |
| computation 7(b) | informational: Lemma E(ii)'s linear term could be $b\ell'/(3n)$ (Theorem 2.10) | fixed: noted after Lemma E | Lemma E |
| computation 7(c) | informational: Lemma C's sharper bracket is nearly attained at $H=1$ ($0.92$) | fixed (as logic m9) | paragraph after Lemma C; §8 |
| computation 7(d) | informational: §7.1 item 2's "SP$_1$ cannot satisfy such a bound at all widths" should say "cannot have vanishing excess at all widths", since Theorem 1's bound is vacuous at large $N$ | fixed | §7.1 item 2 |
| computation §2.10 (observation) | near $\alpha=1/4$ the decay is slow: $4.36$ at $n=10^{12}$, $0.668$ at $10^{40}$; "polynomially small" is asymptotic | fixed: the values from this note's script quoted ($4.36$, $0.67$ and $0.030$ at $n=10^{12}$, $10^{40}$, $10^{100}$) | §5, paragraph after the script results; §8 |

The scripts in `../checks/small-learner-width/` were updated as described at the end of §8. No referee found a wrong number in them; the changes are new item numbers in the docstrings, the printed labels, and the new part (6) for the constant of Corollary 3(i).

### Check of the revision

An independent checker, not a referee ([`../verification/small-learner-width-revision-check-1.md`](../verification/small-learner-width-revision-check-1.md); script in `../checks/revision-check-small-learner-width-1/`), read the text as revised after the second round. It compared that text with the version the referees read and with both second-round reports, re-derived the changed statements by hand and with its own script, and re-ran the three scripts in `../checks/small-learner-width/`, whose outputs were identical to the recorded ones. It found every row of the table above resolved as stated, every changed statement and number that it re-derived correct, and every quoted number in agreement with the script outputs. It found that no proved result had been dropped. It noted two statements that are stronger than in the text the referees read, both made at the referees' request and both proved: Corollary 3(i) at the exponent $2\alpha-\frac12$ itself, with an explicit constant (logic m10, computation 5), and the full excess of Remark 8 at learner widths $N\ge N_0=O(n\log^2n/a_n^2)$ (logic m4, computation 1). It raised three minor points and two optional nits, one row each below. All five were judged valid, and each is fixed; none was rebutted. None affects Lemmas A–F, Theorem 1, Corollaries 2 and 3, Theorem 4 or the corrected clause, and no script was changed.

| point | issue | resolution | where |
|---|---|---|---|
| 1 | The opening of §7.3 said that, when `red-team.md` is finalized, its §6.3 is replaced by a pointer to this note; the header said that the note replaces §6.3 and then listed the replaced parts. In the version the referees read, §6.3 also holds the list of surviving versions (lines 472–478) and Remark 6.2 (lines 499–505), which this note does not contain. Remark 6.2 was refereed separately (`../verification/RT-aggregate-logic.md`), and `A-tight-conditioning-fails.md` §5.4 cites it. Read literally, the §7.3 sentence dropped a refereed result and left A's citation without a target; it also contradicted §7.3's own entry amending §6.3 item 2 | fixed: the header says that the note replaces the Proposition 6.1 part of §6.3 and that the list and Remark 6.2 stay in `red-team.md`; §7.3 says that only lines 480–497 (Proposition 6.1, the "In particular" clause, the proof and the paragraph after it) are replaced by a pointer, that the list stays with item 2 amended, and that Remark 6.2 stays; the two §7.3 entries for those lines now read "Replace by a pointer to" | header; §7.3, opening paragraph and the entries for lines 480–495 and line 497 |
| 2 | §0 said that `depth-two.md` Corollary 5.2 refutes the polynomial-sample property for SP$_1$ "with an excess that tends to $0$ as $d\to\infty$". Corollary 5.2(i) gives only a lower bound on the excess, $\gamma(\lambda)(18dc+1)^{-2}(1-o(1))$. At $c=1$ that lower bound tends to $0$ and the known upper bound does not (`depth-two.md` §0), so the sentence could be read as a claim about the excess itself | weakened: "with a certified excess of order $1/d^2\asymp1/\log^2n$", described as a lower bound that tends to $0$; whether the excess itself tends to $0$ is stated as open, citing `depth-two.md` §0 | §0, second paragraph |
| 3 | §7.4: in the wording suggested for A §5.3 item 3, the Corollary 3(i) sentence followed "for every $c>0$, $c=1$ included", so it read as holding for every $c$, while Corollary 3(i) is proved at $c=1$ only (§7.1 item 3). A treats SP$_c$ with $c$ growing in $n$, and for such $c$ the clone term $c(\bar E_*+1)/n\approx c\,n^{4\alpha-1}$ diverges, for example at $c=n^{1/2}$, $\alpha=0.2$. The §10 item 5 suggestion replaced only the rate clause, so A's "SP$_c$, $c=1$ included" stayed, without $d\le n^\alpha$ | weakened: in both suggestions the Corollary 3(i) sentence now says "at $c=1$", and the fixed-competitor clause says "for fixed $c>0$" and "of width at most $N$", which Theorem 1(b) needs; the §10 item 5 suggestion replaces the whole sentence and adds $d\le n^\alpha$ and the repository architecture; the §5.4 suggestion is listed separately, since its sentence already concerns SP$_1$; a new paragraph before the suggestions gives the reasons, including the order $c\,n^{4\alpha-1}$ of the clone term | §7.4 |
| 4 (nit) | Remark 7, first bullet: "The same holds for the limits of the Gibbs risks and posterior means." `B-tempered-likelihood.md` Proposition 9.1(a) bounds their $\liminf_{\sigma\downarrow0}$, and the limits need not exist; the definition of a good $\alpha$ uses the $\limsup$, which the $\liminf$ bound covers | fixed: the bullet now names the $\liminf_{\sigma\downarrow0}$ of the clipped Gibbs risk and of the risk of the posterior mean of the clipped outputs, "hence also for their $\limsup_{\sigma\downarrow0}$" | Remark 7, first bullet, item on Proposition 9.1(a) |
| 5 (nit) | §7.4: "the corrected `red-team.md` Proposition 6.1, refereed twice". The corrected text was refereed once, in the second round; the first round reviewed the original Proposition 6.1 | fixed: "refereed in its corrected form" | §7.4, suggestion for A §5.3 item 3 |

Besides these changes, the opening paragraph now says which lines of `red-team.md` §6.3 the first-round reports reviewed and that §10 also records this check, and its sentence on numbering reads "after the second round" instead of "in the last revision". Since the text was revised again after this check, the last paragraph of §8 now dates the script changes to "the revision that answered the second round" instead of "the final revision".

### Second check of the revision

A second independent check ([`../verification/small-learner-width-revision-check-2.md`](../verification/small-learner-width-revision-check-2.md); script in `../checks/revision-check-small-learner-width-2/`) read the text as revised after the first check. It found every issue of the two second-round reports and every point of the first check resolved as stated, re-derived the changed statements with its own script, and found the three scripts' outputs identical to the recorded ones. It raised five minor points, four of them nits. The lead editor resolved them as follows. None affects Lemmas A–F, Theorem 1, Corollaries 2 and 3, Theorem 4 or the corrected clause, and no script was changed.

| point | issue | resolution | where |
|---|---|---|---|
| 1 | §7.4 and row logic m3 described the citations in A's "final text" as "refereed with a corrected rate, repair under review"; once A adopts the suggested wording, both sentences would describe A wrongly | fixed: both now refer to the version of A that this note was checked against. The lead editor has since replaced the three citations in A by the wording of §7.4, and §7.4 says so | §7.4, first paragraph and last sentence; §10, row logic m3 |
| 2 (nit) | Remark 8, success bullet: the hypothesis $m\le N$, which Theorem 1(b) needs, was missing | fixed: "with $m\le N$" | Remark 8, success bullet |
| 3 (nit) | Remark 6(b) said that its values agree with "the first-round referees' tables", but only the first-round logic referee's table concerns this competitor; the computation referee's table uses a competitor with $L_D(g)=1/2$ | fixed: "the first-round logic referee's table", with a parenthesis on the other table | Remark 6(b) |
| 4 (nit) | row logic m4 said "the referee's numbers quoted", but Remark 8 quotes the computation referee's numbers | fixed: "the computation referee's numbers quoted" | §10, row logic m4 |
| 5 (nit) | §8 and §10 spoke of "two printed labels", but the part-(3) header of `check_explicit_bound.out` also changed and the formulas print the weight exponent as `w` | fixed: "the printed labels were changed (the weight exponent is printed as `omega`, or `w` in formulas, …)" | §8, last paragraph; §10, paragraph after the table |

The check also noted that this section cited no report file; both checks are now linked above. After `red-team.md` was finalized and a final cross-reference check of all the research notes, the lead editor changed the opening of §7.3, which now says that lines 480–497 of `red-team.md` have been replaced by a pointer to this note and that the other entries of §7.3 were applied verbatim. The last sentence of the §7.3 entry on `red-team.md` §8 now states the range $\theta<\theta_{L,\gamma}$ of `E-finite-prior-scale.md` Theorem 2.7.
