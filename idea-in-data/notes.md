# Is the idea in the data?

*Notes on a proposed definition: an idea $Y$ is in data $X$ iff $K(Y\mid X)\ll K(Y)$.*

Notes by Claude on a definition proposed by Kaarel Hänni, 26 October 2026. Draft.

**Summary.**

1. **Where it comes from.** The proposal is Kolmogorov's own 1965 quantity, "the amount of information in $x$ about $y$", $I(X:Y)=K(Y)-K(Y\mid X)$. It is normalised by $K(Y)$ and thresholded: $Y$ is in $X$ when $X$ carries nearly all of the information about $Y$ there is.
2. **Literature.** Its symmetric relatives (information distance, NID, NCD) are well studied. Its $\varepsilon\to0$ limit (the preorder "$Y$ is simple given $X$") and the obstruction in item 4 (Gács–Körner, Muchnik) are well studied too. In Shannon theory it is Theil's uncertainty coefficient. I found no work that studies the one-sided ratio $K(Y\mid X)/K(Y)$ as a containment notion in its own right (§1).
3. **Equivalent forms.** It has several equivalent characterisations (§2):
   - joint cost: $K(X,Y)\approx K(X)$;
   - two-part-code optimality: $Y$ "pays for itself" as a hint for $X$;
   - universal posterior: $\mathbf m(Y\mid X)\ge \mathbf m(Y)^{\varepsilon}$;
   - Muchnik's blind patch;
   - the Romashchenko–Zimand secret key.

   On i.i.d. data the ratio converges to $H(Y\mid X)/H(Y)$.
4. **Main theorem: "99% contained" does not mean "a 99% part is contained".** For a random point $Y$ of $\mathbb F_q^m$ and a random line $X$ through it, $Y$ is $(1-1/m)$-contained in $X$. Yet every part of $Y$ either misses as much information given $X$ as $Y$ does, or shares nothing with $X$ (§4). Partial containment is a *constraint*, not a *fragment*.
5. **Where it goes wrong.** Because $K$ ignores computation time, theorems contain their proofs and ciphertexts contain their plaintexts (§7). The notion measures information, not insight. Its resource-bounded version stays equivalent to the joint-cost and hint forms only in a world without one-way functions, by Hirahara–Ilango–Lu–Nanashima–Oliveira (2023).

---

## 0. Conventions

- $K$ is prefix complexity.
- $X^*$ is a shortest program for $X$; it encodes both $X$ and $K(X)$.
- $n$ bounds all lengths and complexities in play, and $\approx$, $\lesssim$ mean "up to $O(\log n)$" unless stated otherwise.
- **Mutual information:** $I(X:Y):=K(Y)-K(Y\mid X^*)$, which is symmetric up to $O(1)$ (Gács 1974; Chaitin 1975). The proposal's version $K(Y)-K(Y\mid X)$ differs from it by at most $K(K(X)\mid X)=O(\log K(X))$.

Write

$$\rho(Y\sqsubseteq X):=1-\frac{K(Y\mid X)}{K(Y)}\ \ (\approx I(X:Y)/K(Y)),\qquad Y\sqsubseteq_\varepsilon X\ :\iff\ K(Y\mid X)\le\varepsilon K(Y).$$

Every statement below carries an additive $O(\log n)$ error, so $\rho$ has content only when $K(Y)\gg\log n$. Proposition 3.4 shows the error is not an artefact of the proofs.

## 1. Literature: where the notion sits

1. **The numerator is classical.** Kolmogorov (1965) defined $I(x:y)=K(y)-K(y\mid x)$ as "the amount of information in $x$ about $y$". Symmetry of information (Kolmogorov–Levin; Gács 1974; Chaitin 1975) makes it symmetric up to logarithmic terms. So the proposal is a symmetric quantity, normalised asymmetrically.
2. **Symmetric normalisations are well studied.** They are:
   - the information distance $\max(K(x\mid y),K(y\mid x))$ (Bennett, Gács, Li, Vitányi, Zurek 1998);
   - the normalised information distance $\mathrm{NID}=\max(K(x\mid y),K(y\mid x))/\max(K(x),K(y))$ (Li, Chen, Li, Ma, Vitányi 2004);
   - its compressor version, NCD (Cilibrasi–Vitányi 2005);
   - the "shared information distance" used for plagiarism detection (Chen, Francia, Li, McKinnon, Seker 2004).

   $\mathrm{NID}(x,y)\le\varepsilon$ implies mutual containment at level $\varepsilon/(1-\varepsilon)$, and mutual containment at level $\varepsilon$ implies $\mathrm{NID}\le\varepsilon$. The one-sided ratio is the natural "inclusion" half of NID. I did not find it studied in its own right. Its compressor estimate $C(XY)-C(X)$ is used informally as "what $Y$ adds to $X$": Benedetto, Caglioti and Loreto (2002) used it for language and authorship attribution. Ziv and Merhav's (1993) cross-parsing of $Y$ by phrases of $X$ is a literal-substring version of the same idea.
3. **The Shannon analogue is Theil's uncertainty coefficient.** $I(X;Y)/H(Y)=1-H(Y\mid X)/H(Y)$ is Theil's (1970) uncertainty coefficient, also called the "coefficient of constraint" (Coombs, Dawes, Tversky 1970). Theorem 2.4 shows the algorithmic ratio converges to it on i.i.d. data.
4. **The strong version is a known preorder.** "$K(Y\mid X)=O(\log n)$" is the preorder studied by Chernov, Muchnik, Romashchenko, Shen and Vereshchagin (2002) as a finite analogue of the Turing degrees. They show it is an upper semilattice but not a lattice: meets ("the common part") need not exist. The phenomenon in §4 is the Gács–Körner (1973) / Muchnik (1998) non-extractability of common information. Romashchenko (2025) is recent work in the same line, also using finite-geometry incidences.
5. **Operational meanings.** These are:
   - conditional codes (Muchnik 2002);
   - the Kolmogorov version of Slepian–Wolf coding (Zimand 2017);
   - mutual information as the longest secret key that the holders of $X$ and $Y$ can agree on over a public channel (Romashchenko–Zimand 2018/2019).
6. **Models in data.** In algorithmic statistics, a model $S$ with small optimality deficiency for $x$ has $K(S\mid x)$ small, i.e. the model is "in" the data (Vereshchagin–Vitányi 2004; survey by Vereshchagin–Shen 2017). Vitányi's (2006) "meaningful information" takes the model part of an optimal two-part code as the meaningful content of $x$.
7. **Resource-bounded versions in machine learning.** These are:
   - $\mathcal V$-information (Xu, Zhao, Song, Stewart, Ermon 2020);
   - MDL probing (Voita–Titov 2020).

   The probing debate is exactly the bounded-versus-unbounded issue of §7. Pimentel et al. (2020) argued from the data-processing inequality that a representation contains no more than its sentence; Hewitt–Liang (2019) introduced control tasks. The "adversarial compression ratio" for LLM memorisation (Schwarzschild, Feng, Maini, Lipton, Kolter 2024) is the proposal with the model in the role of $X$, a prompt in the role of a conditional description, and $|Y|$ in place of $K(Y)$.
8. **Complexity theory.** Symmetry of information for time-bounded $K$ fails if one-way functions exist (Longpré–Watanabe 1995). On average, its failure is *equivalent* to the existence of one-way functions (Hirahara, Ilango, Lu, Nanashima, Oliveira 2023).
9. **Infinite objects.** For infinite sequences and points, the analogues are:
   - mutual dimension (Case–Lutz 2015);
   - conditional dimension $\dim(x\mid y)$, which drives the point-to-set principle in geometric measure theory (Lutz–Lutz 2018; survey Lutz–Stull 2020).
10. **Philosophy.** Dretske (1981): a signal $r$ carries the information that $s$ is $F$ iff $P(s\text{ is }F\mid r,k)=1$ (but $<1$ given background knowledge $k$ alone). This is the probability-one cousin of the strong version.

## 2. Equivalent characterisations

**Theorem 2.1 (one number, several faces).** For all $X,Y$, up to $O(1)$:

$$K(Y\mid X^*)\;=\;K(X,Y)-K(X)\;=\;K(Y)+K(X\mid Y^*)-K(X)\;=\;-\log\mathbf m(Y\mid X^*),$$

where $\mathbf m$ is the universal discrete semimeasure. Consequently, up to $O(\log n)$, the following are equivalent:

1. $Y\sqsubseteq_\varepsilon X$.
2. **Joint cost:** $K(X,Y)\le K(X)+\varepsilon K(Y)$. Appending $Y$ to $X$ is nearly free.
3. **Hint, or two-part code:** $K(Y)+K(X\mid Y)\le K(X)+\varepsilon K(Y)$. Describing $X$ by first describing $Y$ wastes at most $\varepsilon K(Y)$ bits; $Y$ pays for itself as a hint for $X$.
4. **Universal posterior:** $\mathbf m(Y\mid X)\ge\mathbf m(Y)^{\varepsilon}$, up to $\mathrm{poly}(n)$ factors. Conditioning the universal prior on $X$ raises the probability of $Y$ from $2^{-K(Y)}$ to at least $2^{-\varepsilon K(Y)}$.
5. **Mutual information:** $I(X:Y)\ge(1-\varepsilon)K(Y)$.

*Proof.*

- The first equality is symmetry of information: $K(X,Y)=K(X)+K(Y\mid X^*)+O(1)$ (Gács; Chaitin).
- The second applies the same identity with $X$ and $Y$ swapped.
- The third is the conditional coding theorem.
- The equivalences then follow from $K(Y\mid X^*)\le K(Y\mid X)+O(1)\le K(Y\mid X^*)+K(K(X)\mid X)+O(1)$ and $K(K(X)\mid X)\le\log K(X)+O(\log\log K(X))$. $\square$

Face 3 is the algorithmic-statistics reading. Take $Y=S$, a finite set containing $X$, used as a model. Since $K(X\mid S)\le\log|S|+O(1)$, the optimality deficiency $\delta(X\mid S)=K(S)+\log|S|-K(X)$ is at least $K(S\mid X)-O(\log n)$, which is the Vereshchagin–Vitányi bound. **The ideas in $X$ are the hypotheses that compress $X$ by about their own length.**

**Theorem 2.2 (Muchnik 2002: the missing part can be sent blind).** For all $X,Y$ there is a string $p$ with:

- $|p|\le K(Y\mid X)+O(\log n)$;
- $K(p\mid Y)=O(\log n)$;
- $K(Y\mid X,p)=O(\log n)$.

Hence $Y\sqsubseteq_\varepsilon X$ iff $Y$ has a fingerprint of length about $\varepsilon K(Y)$, computable from $Y$ alone with $O(\log n)$ advice, that together with $X$ determines $Y$. The encoder never needs to see $X$. This is Slepian–Wolf coding for individual strings; Zimand (2017) gives a probabilistic polynomial-time version.

**Theorem 2.3 (Romashchenko–Zimand 2018/2019).** Up to $O(\log n)$, $I(X:Y)$ is the maximal length of a secret key that two parties can agree on, one holding $X$ and the other $Y$, both knowing the complexity profile, using randomised public communication. Hence $Y\sqsubseteq_\varepsilon X$ iff all but an $\varepsilon$ fraction of the information in $Y$ can be turned into a secret that the holder of $X$ shares.

**Theorem 2.4 (Shannon limit).** Let $(X_i,Y_i)$ be i.i.d. from a computable distribution $P$ with $H(Y)>0$. Then

$$H(Y^n\mid X^n)\ \le\ \mathbb E\,K(Y^n\mid X^n)\ \le\ H(Y^n\mid X^n)+K(P)+O(\log n),$$

and almost surely $K(Y^n\mid X^n)/K(Y^n)\to H(Y\mid X)/H(Y)$. So $\rho\to$ Theil's $U$.

*Proof.*

- **Expectation.** For each fixed $x$, $K(\cdot\mid x)$ is a prefix-code length, so $\sum_yP(y\mid x)K(y\mid x)\ge H(Y\mid X=x)$. For the upper bound, use the Shannon–Fano code for $P(\cdot\mid x^n)$, which is computable from $P$ and $n$.
- **Almost sure limit, upper bound.** $K(y^n\mid x^n)\le-\log P(y^n\mid x^n)+O(\log n)$, and $-\frac1n\log P(Y^n\mid X^n)\to H(Y\mid X)$ a.s.
- **Almost sure limit, lower bound.** Write $K(y^n\mid x^n)\ge K(x^n,y^n)-K(x^n)-O(\log n)$, where $K(x^n)\le-\log P(x^n)+O(\log n)$. Since $P\{z:K(z)<-\log P(z)-m\}\le2^{-m}$, Borel–Cantelli with $m=2\log n$ gives $K(X^n,Y^n)\ge-\log P(X^n,Y^n)-2\log n$ eventually, a.s.
- **Denominator.** It is handled the same way. Divide by $n$. $\square$

## 3. Basic calculus and sanity checks

**Proposition 3.1 (more data contains more; re-encoding is harmless).**

- $K(Y\mid X')\le K(Y\mid X)+K(X\mid X')+O(1)$.
- If $Y$ occurs literally in $X$, then $K(Y\mid X)\le2\log|X|+O(\log\log|X|)$ (give the position and the length). So substrings are in, once $K(Y)\gg\log|X|$.
- For computable bijections $f,g$, $\rho(f(Y)\sqsubseteq g(X))$ and $\rho(Y\sqsubseteq X)$ differ by at most $(K(f)+K(g)+O(\log n))/K(Y)$.

**Proposition 3.2 (literal presence is not enough: Borges and $\pi$).** Let $B_L$ be the concatenation of all binary strings of length $\le L$. Every $Y$ with $|Y|\le L$ occurs in $B_L$. Yet $K(B_L)\le K(L)+O(1)$, so $I(B_L:Y)\le K(L)+O(1)$ and

$$K(Y\mid B_L)\ \ge\ K(Y)-\log L-O(\log\log L).$$

No idea of complexity much above $\log L$ is in the Library of Babel. The same holds for the first $N$ digits of $\pi$, which contain every short book if $\pi$ is normal: here $I\le K(N)+O(1)$. It also holds for monkeys: if $Y$ occurs in a random $X$ only at a position that takes about $K(Y)$ bits to specify, then locating $Y$ costs as much as writing it down. This is a real point in favour of the definition over any "the string appears in it" notion.

**Proposition 3.3 (data contain few large ideas, none larger than themselves).**

- (a) If $Y\sqsubseteq_\varepsilon X$ then $K(Y)\le(K(X)+O(\log n))/(1-\varepsilon)$.
- (b) For every $k$, fewer than $2^{\varepsilon k+1}$ strings $Y$ have $K(Y)<k$ and $Y\sqsubseteq_\varepsilon X$.

*Proof.* (a) $(1-\varepsilon)K(Y)\le I(X:Y)+O(\log n)\le K(X)+O(\log n)$. (b) Each such $Y$ has $K(Y\mid X)<\varepsilon k$, and there are fewer than $2^{\varepsilon k+1}$ programs that short. $\square$

**Proposition 3.4 (granularity is real: the complexity of $X$ need not be in $X$).** For every $n$ there is $X$ of length $n$ with $K(K(X)\mid X)\ge\log n-O(1)$ (Gács 1974; tight form by Bauwens–Shen 2014). Let $Y$ be $K(X)$ written in binary. Then $K(Y)\le\log n+O(\log\log n)$, so $\rho(Y\sqsubseteq X)\approx0$ while $\rho(Y\sqsubseteq X^*)=1$. For ideas of size $O(\log n)$, the choice between $X$ and $X^*$, and the logarithmic slack, change the verdict.

**Proposition 3.5 (closure under pairing, with a factor 2).** If $Y\sqsubseteq_\varepsilon X$ and $Z\sqsubseteq_\varepsilon X$, then $(Y,Z)\sqsubseteq_{2\varepsilon}X$, up to $O(\log n)/K(Y,Z)$. The factor 2 is asymptotically tight.

*Proof.* $K(Y,Z\mid X)\le K(Y\mid X)+K(Z\mid X)+O(\log n)\le\varepsilon(K(Y)+K(Z))\le2\varepsilon\max(K(Y),K(Z))\le2\varepsilon K(Y,Z)+O(1)$.

For tightness, take independent random $C$, $a$, $b$ of lengths $N$, $\varepsilon N$, $\varepsilon N$, and set $X=C$, $Y=(C,a)$, $Z=(C,b)$. Then $K(\cdot\mid X)/K(\cdot)$ is $\varepsilon/(1+\varepsilon)$ for $Y$ and for $Z$, and $2\varepsilon/(1+2\varepsilon)$ for $(Y,Z)$. $\square$

So the ideas contained in $X$ form a "fuzzy ideal": closed upward (3.1) and under pairing, up to a factor 2.

**Proposition 3.6 (transitivity only with weights).** If $Z\sqsubseteq_\varepsilon Y$ and $Y\sqsubseteq_\delta X$, then $K(Z\mid X)\le\varepsilon K(Z)+\delta K(Y)+O(\log n)$. The weight $K(Y)/K(Z)$ cannot be dropped.

*Counterexample without the weight.* Take independent $Z$ and $R$ with $K(R)=(1/\delta-1)K(Z)$, and set $Y=(Z,R)$, $X=R$. Then $Y\sqsubseteq_\delta X$ and $Z\sqsubseteq_0Y$, but $\rho(Z\sqsubseteq X)\approx0$. A 99%-contained $Y$ can have its crucial 1% wholly missing. A paper minus its key lemma is 99% of the paper.

**Proposition 3.7 (a Bayes rule for containment).** Since both sides equal $I(X:Y)$ up to $O(\log n)$,

$$\rho(Y\sqsubseteq X)\,K(Y)\;\approx\;\rho(X\sqsubseteq Y)\,K(X).$$

For example, a small idea fully in large data, $\rho(Y\sqsubseteq X)=1$, gives $\rho(X\sqsubseteq Y)=K(Y)/K(X)$.

## 4. Main theorem: partial containment is not containment of a part

There are two natural readings of "$Y$ is 99% in $X$":

- **(R1) $X$ plus a short patch determines $Y$.** The patch is 1% of $K(Y)$. This is what $K(Y\mid X)\le0.01\,K(Y)$ says, and by Theorem 2.2 the patch can even be computed from $Y$ alone.
- **(R2) Most of $Y$ is a part that is wholly in $X$.** Formally, there is $Z$ with $K(Z\mid Y)\approx0$, $K(Z\mid X)\approx0$ and $K(Z)\ge0.99\,K(Y)$.

(R2) implies (R1): $K(Y\mid X)\le K(Y\mid Z)+K(Z\mid X)+O(\log n)$, and $K(Y\mid Z)\le K(Y)-K(Z)+K(Z\mid Y)+O(\log n)$ by symmetry of information.

The converse fails, and as badly as it can:

**Theorem 4.1.** Let $m\ge2$, $s\ge1$, $q=2^s$, $n=ms$. Let $X$ be a line in $\mathbb F_q^m$ and $Y$ a point on it, with $K(X,Y)\ge(2m-1)s-O(\log n)$; all but a vanishing fraction of incident pairs qualify. Then:

**(a)** $K(Y)=ms\pm O(\log n)$ and $K(Y\mid X)=s\pm O(\log n)$, so

$$\rho(Y\sqsubseteq X)=1-\tfrac1m\pm O(\log n/n).$$

Also $K(X)=(2m-2)s\pm O(\log n)$ and $K(X\mid Y)=(m-1)s\pm O(\log n)$.

**(b)** There is a constant $C$ such that for every string $Z$ with $K(Z\mid Y)\le n$: if $K(Z\mid X)<s-C\log n$, then

$$K(Z)\ \le\ K(Z\mid X)+2K(Z\mid Y)+C\log n.$$

**Corollary 4.2 (dichotomy for the parts of $Y$).** Call $Z$ a part of $Y$ if $K(Z\mid Y)=O(\log n)$. Every part of $Y$ satisfies one of:

1. $K(Z\mid X)\ge K(Y\mid X)-O(\log n)$: $Z$ is missing as much information given $X$ as the whole of $Y$ is; or
2. $I(X:Z)=O(\log n)$: $Z$ is not in $X$ at all.

Consequences:

- No part of $Y$ is better contained in $X$ than $Y$ is: $\rho(Z\sqsubseteq X)\le\rho(Y\sqsubseteq X)+O(\log n/n)$ for every part $Z$ with $K(Z)\gg\log n$. With $m=100$, $Y$ is 99% in $X$, but the 99% is not located in any part of $Y$.
- **With slack.** If $Z$ is "wholly in both up to $c$ bits", i.e. $K(Z\mid X),K(Z\mid Y)\le c<s-C\log n$, then $K(Z)\le3c+O(\log n)$. Even the parts of $Y$ that are in $X$ up to $c$ bits have complexity $O(c+\log n)$.

*Proof.*

**Setup.**

- Let $\mathcal P=\mathbb F_q^m$ be the set of points ($\log|\mathcal P|=ms$).
- Let $\mathcal L$ be the set of lines: $|\mathcal L|=q^{m-1}(q^m-1)/(q-1)$, so $\log|\mathcal L|=(2m-2)s+O(1)$.
- Each line has $q$ points, so there are $|\mathcal L|q$ incident pairs.
- Fix encodings computable from $(m,s)$: find an irreducible polynomial of degree $s$ by search, and use canonical line representatives. Everything below is computable from $(m,s)$, which costs $O(\log n)$ bits.

**(a).**

- Upper bounds. $K(Y\mid X)\le s+O(\log n)$ (the index of $Y$ on $X$). $K(X)\le(2m-2)s+O(\log n)$. $K(X\mid Y)\le\log\frac{q^m-1}{q-1}+O(\log n)=(m-1)s+O(\log n)$. $K(Y)\le ms+O(\log n)$.
- Lower bounds. They come from $K(X,Y)\ge(2m-1)s-O(\log n)$ and symmetry of information: $K(Y\mid X)\ge K(X,Y)-K(X)-O(\log n)\ge s-O(\log n)$, and likewise for the others.

**(b).** Let $k=K(Z)$, $a=K(Z\mid X)$ and $b=K(Z\mid Y)$, where $a<s\le n$ and $b\le n$. Put

$$S=\{\ell\in\mathcal L:\ K(Z\mid\ell)\le a\}\ni X,\qquad T=\{p\in\mathcal P:\ K(Z\mid p)\le b\}\ni Y.$$

*Step 1: the sources of $Z$ are few.* We show

$$\log|S|\le(2m-2)s+a-k+O(\log n),\qquad\log|T|\le ms+b-k+O(\log n).$$

Fewer than $2^{a+1}$ strings $z$ satisfy $K(z\mid\ell)\le a$ for a given line $\ell$. So, writing $S_z$ for the analogous set for an arbitrary $z$, $\sum_z|S_z|<2^{a+1}|\mathcal L|$. Hence $\{z:|S_z|\ge2^j\}$ has fewer than $2^{a+1-j}|\mathcal L|$ elements, and it is enumerable from $(m,s,a,j)$. Taking $j=\lfloor\log|S|\rfloor\le2n$ gives $k\le\log|\mathcal L|+a-j+O(\log n)$. The same argument works for $T$.

*Step 2: there are many incidences between $S$ and $T$.* Let $I$ be the number of incident pairs in $S\times T$. This set of pairs is enumerable from $(Z^*,a,b,m,s)$ and contains $(X,Y)$. Hence

$$(2m-1)s-O(\log n)\le K(X,Y)\le k+\log I+O(\log n).$$

*Step 3: the incidence bound.* Two points lie on at most one line, so $\sum_{\ell\in S}\binom{|\ell\cap T|}2\le\binom{|T|}2$, i.e. $\sum_\ell|\ell\cap T|^2\le|T|^2+I$. By Cauchy–Schwarz, $I^2\le|S|\sum_\ell|\ell\cap T|^2\le|S|(|T|^2+I)$, so

$$I\le|S|^{1/2}|T|+|S|.$$

*Step 4: combine.* There are two cases.

- If $|S|\ge|S|^{1/2}|T|$, then $\log I\le\log|S|+1$. Steps 1 and 2 give $(2m-1)s-k\le(2m-2)s+a-k+O(\log n)$, i.e. $a\ge s-O(\log n)$. This is excluded for $C$ large enough.
- Otherwise $\log I\le\log|T|+\tfrac12\log|S|+1$, and Steps 1 and 2 give

$$(2m-1)s-k\ \le\ ms+b-k+\tfrac12\big((2m-2)s+a-k\big)+O(\log n)=(2m-1)s+b+\tfrac a2-\tfrac{3k}2+O(\log n).$$

  That is, $k\le a+2b+O(\log n)$.

*Proof of the corollary.*

- With $b=O(\log n)$: either $a\ge s-C\log n$, or $k\le a+O(\log n)$, i.e. $I(X:Z)=K(Z)-K(Z\mid X)\pm O(\log n)=O(\log n)$.
- In the first case, since $k\le K(Y)+b+O(\log n)=ms+O(\log n)$, we get $\rho(Z\sqsubseteq X)=1-a/k\le1-1/m+O(\log n/n)$.
- The slack version follows from $k\le a+2b+O(\log n)\le3c+O(\log n)$. $\square$

**Remarks.**

1. **History.** $m=2$ is Muchnik's affine-plane example of non-extractable mutual information (Shannon analogue: Gács–Körner 1973). For $m=2$, Shen (2011, "Kolmogorov complexity as a language") gives the bound $C(z)\le2C(z\mid a)+2C(z\mid b)+O(\log n)$. Two things here I have not seen stated, though the proof is the standard one: the $m$-dimensional version, which is what drives $K(Y\mid X)/K(Y)\to0$, and the dichotomy form (b).
2. **Both cases of the dichotomy occur.** $Z=(Y_1,\dots,Y_j)$, the first $j$ coordinates of $Y$, falls in case 1: $K(Z\mid X)=s$ and $K(Z)=js$. The first $t<s$ bits of $Y_1$ fall in case 2: a generic line projects onto all of $\mathbb F_q$ in the first coordinate, so $K(Z\mid X)\approx t\approx K(Z)$.
3. **What survives.** Muchnik's patch $p$ (Theorem 2.2) exists, so $(X,p)$ determines $Y$. But $p$ has no complement: $Y$ cannot be written as $(p,Z)$ with $Z$ in $X$. What $X$ "knows" about $Y$ is the relation "$Y$ lies on $X$", which is a **constraint, not a fragment**. Under this definition, ideas are not mereological, and $\rho$ is not a measure on the parts of $Y$.
4. **Shannon analogue.** The analogue of (R2)-containment is the Gács–Körner common information divided by $H(Y)$: $C_{GK}(X;Y)=\max\{H(f(X)):f(X)=g(Y)\text{ a.s.}\}$, the entropy of the connected-component label of the bipartite support graph. The analogue of (R1) is $I(X;Y)/H(Y)$. The two agree only when $X$ and $Y$ are independent within each connected component of the support graph, so that each component is a complete bipartite block.

## 5. Conservation: computation cannot put ideas into data

**Proposition 5.1 (Levin 1974, 1984).**

- For computable $f$: $K(Y\mid X)\le K(Y\mid f(X))+K(f)+O(1)$, so $\rho(Y\sqsubseteq f(X))\le\rho(Y\sqsubseteq X)+K(f)/K(Y)$.
- For a uniformly random $R\in\{0,1\}^l$: $\Pr_R\big[I((X,R):Y)>I(X:Y)+k+O(\log n)\big]\le2^{-k}$.

*Proof of the randomised part.* $I((X,R):Y)\le I(X:Y)+I(R:(X,Y))+O(\log n)$, and $I(R:W)\le l+K(l)-K(R\mid W^*)+O(1)$. Since $\sum_R2^{-l}\cdot2^{\,l-K(R\mid W^*)}\le1$, Markov's inequality finishes the proof. $\square$

For learning: anything a learner $L$ outputs on $X$ (weights, theories, summaries) contains at most $I(X:Y)+K(L)+O(\log n)$ bits of $Y$. In the unbounded sense, training never creates ideas. In the bounded senses of §7 it can make them *accessible*, which is the interesting part.

## 6. Laws in samples (remark, stated with $\approx$)

Let $\theta\in\mathbb R^d$ be the parameter of a smooth family, drawn from a computable prior with continuous positive density, and let $X^n$ be $n$ samples. Clarke–Barron (1990) give

$$I(\Theta;X^n)=\tfrac d2\log\tfrac n{2\pi e}+h(\Theta)+\mathbb E\,\tfrac12\log\det I(\Theta)+o(1).$$

Combining this with the expectation form of Theorem 2.4 (expected $K$ equals $H$ up to $K(P)$) gives the following for $\Theta_k$, the parameter to $k$ bits per coordinate:

$$\mathbb E\,K(\Theta_k\mid X^n)\approx d\cdot\max\big(0,\,k-\tfrac12\log n\big),$$

up to $O(d+\log n)$. So the law, to $k$ bits per coordinate, is in the sample iff $k\lesssim\tfrac12\log_2 n$, and beyond that $\rho\approx\min(1,\log_2n/(2k))$. This is MDL's "$\tfrac12\log n$ bits per parameter" read as a containment statement: a sample of size $n$ contains about $\tfrac12\log n$ bits of each real parameter of the law that generated it. The quantisation step needs the usual regularity conditions; I have not written it out.

## 7. Resource bounds: information versus insight

**Proposition 7.1 (theorems contain their proofs).** Fix a formal system with decidable proof checking. Let $T$ be a theorem with shortest proof length $L$, and let $\pi_T$ be the lexicographically first proof of length $L$. Then $K(\pi_T\mid T)\le K(L)+O(1)$: enumerate the strings of length $L$ and check each one. So $\pi_T\sqsubseteq T$. In the unbounded sense, a proof contains at most $\log L+O(\log\log L)$ bits that are not already in its statement.

Similar examples:

- **Ciphertexts.** A ciphertext under a $k$-bit key contains its plaintext up to $k+O(\log k)$ bits.
- **Chess.** The rules of chess contain an optimal strategy.
- **Physics.** The laws of physics, plus the initial conditions, contain chemistry.

So the notion measures information, not insight. Most of what is called an "idea" in mathematics is computational content in Bennett's sense: logical depth.

**The bounded version.** Define containment by $K^t(Y\mid X)\ll K^t(Y)$. Three things change.

- **The faces of Theorem 2.1 come apart.** If one-way functions exist, symmetry of information fails for $K^t$ (Longpré–Watanabe 1995). Hirahara–Ilango–Lu–Nanashima–Oliveira (2023): one-way functions exist iff probabilistic time-bounded symmetry of information fails on average over some samplable distribution.

  Concretely, take a one-way permutation $f$, a random $Y$, and $X=f(Y)$:
  - joint-cost face: appending $Y$ to $X$ is free, $K^t(X,Y)\approx K^t(X)$;
  - hint face: $Y$ is a perfect hint for $X$;
  - conditional face: $K^t(Y\mid X)$ is superlogarithmic for almost all $Y$, and at least $\delta n$ under exponential hardness.

  Under exponential hardness, $Y$ is in $X$ by faces 2 and 3 but not by face 1. With only superpolynomial hardness, already the strong version of face 1 ($K^t(Y\mid X)=O(\log n)$) fails. **On average over samplable distributions, the bounded faces of §2 agree iff one-way functions do not exist.**
- **Data processing fails, as it should.** $K^t(Y\mid g(X))$ can be far below $K^t(Y\mid X)$ for an expensive $g$: thinking extracts ideas. This is the regime of $\mathcal V$-information (Xu et al. 2020) and of MDL probing (Voita–Titov 2020). It is also why Pimentel et al. (2020) were right, in the unbounded sense, that a contextual representation contains nothing its sentence does not.
- **Memorisation.** The adversarial compression ratio (Schwarzschild et al. 2024) is this notion with a model-bounded conditional complexity, the shortest prompt that makes the model emit $Y$, and $|Y|$ in place of $K(Y)$. Normalising by a compressor estimate of $K(Y)$ instead would stop it from flagging strings that are merely compressible.

## 8. Verdict

**Good.**

- It is canonical: Kolmogorov's information in $X$ about $Y$, normalised.
- It is robust: invariant under simple re-encodings, equivalent to MDL optimality, with operational meanings (patch, secret key).
- It handles the Library of Babel, the digits of $\pi$ and monkeys correctly.
- Its Shannon limit is a standard statistic (Theil's $U$).

**Caveats, and what I would change.**

1. **Condition on $X^*$, or carry the $O(\log K(X))$ slack.** Use only ideas with $K(Y)\gg\log n$ (Proposition 3.4).
2. **Report the pair $(K(Y\mid X),K(Y))$, not just the ratio.** The ratio is not transitive, and it hides a crucial small missing part (Proposition 3.6).
3. **Do not read $\rho$ mereologically** (Theorem 4.1). Partial containment is a constraint on $Y$, not a contained piece of $Y$. If you want "a large part of $Y$ is fully in $X$", that is a different and much stronger notion, (R2), whose Shannon analogue is Gács–Körner common information.
4. **Ideas are not strings.** For an idea given as a set $A$ of its encodings, the natural definition is $K(A\mid X):=\min_{a\in A}K(a\mid X)$ and $\rho(A\sqsubseteq X)=1-K(A\mid X)/K(A)$, i.e. Kolmogorov's "complexity of a problem" (Shen–Vereshchagin 2002). Otherwise the verdict depends on the encoding whenever the translation between natural encodings (English and Lean, say) is not simple.
5. **Unbounded containment is "implicitly contains".** For "explicitly contains", or for insight, use $K^t$ or a model class. Then containment becomes asymmetric, depends on the observer, and is sensitive to cryptography (§7).
6. **"Ideas" versus noise.** To count ideas rather than all content (noise excluded), require $Y$ to be in the minimal sufficient statistic of $X$ (Vitányi's meaningful information). That has known pathologies: non-stochastic objects, and non-uniqueness.

## 9. Questions worth pursuing

- **When does (R1) imply (R2)?** Find a structure theorem for pairs where partial containment decomposes into a contained part plus a small remainder. In Shannon theory the answer is Gács–Körner's component structure. In the algorithmic setting the natural tool is the combinatorial interpretation of complexity inequalities (Romashchenko–Shen–Vereshchagin) together with spectral or incidence properties of the "graph of $(X,Y)$".
- **The calculus of $K(A\mid X)/K(A)$ for sets $A$.** The min over encodings does not commute with pairing, so even Proposition 3.5 needs re-proving.
- **The bounded calculus.** Which parts of §§2–3 survive for $pK^t$ under "no one-way functions", and which survive unconditionally?
- **Empirics.** Estimate $\rho$ with LLM-based compressors as a bounded $K$: $(C(XY)-C(X))/C(Y)$. Test it against cases where the answer is known, such as substrings, paraphrases, translations, ciphertexts and proofs.

## References

- C. H. Bennett, P. Gács, M. Li, P. Vitányi, W. Zurek. Information distance. *IEEE Trans. Inf. Theory* 44(4):1407–1423, 1998.
- C. H. Bennett. Logical depth and physical complexity. In *The Universal Turing Machine: A Half-Century Survey*, 1988.
- B. Bauwens, A. Shen. Complexity of complexity and strings with maximal plain and prefix Kolmogorov complexity. *J. Symbolic Logic* 79(2), 2014. [arXiv:1202.6668](https://arxiv.org/abs/1202.6668)
- D. Benedetto, E. Caglioti, V. Loreto. Language trees and zipping. *Phys. Rev. Lett.* 88:048702, 2002.
- A. Case, J. H. Lutz. Mutual dimension. *ACM Trans. Comput. Theory* 7(3), 2015.
- G. J. Chaitin. A theory of program size formally identical to information theory. *J. ACM* 22(3):329–340, 1975.
- X. Chen, B. Francia, M. Li, B. McKinnon, A. Seker. Shared information and program plagiarism detection. *IEEE Trans. Inf. Theory* 50(7):1545–1551, 2004.
- A. Chernov, An. Muchnik, A. Romashchenko, A. Shen, N. Vereshchagin. Upper semi-lattice of binary strings with the relation "$x$ is simple conditional to $y$". *Theor. Comput. Sci.* 271:69–95, 2002.
- R. Cilibrasi, P. Vitányi. Clustering by compression. *IEEE Trans. Inf. Theory* 51(4):1523–1545, 2005.
- B. Clarke, A. Barron. Information-theoretic asymptotics of Bayes methods. *IEEE Trans. Inf. Theory* 36(3):453–471, 1990.
- C. Coombs, R. Dawes, A. Tversky. *Mathematical Psychology: An Elementary Introduction*, 1970.
- F. Dretske. *Knowledge and the Flow of Information*. MIT Press, 1981.
- P. Gács. On the symmetry of algorithmic information. *Soviet Math. Dokl.* 15:1477–1480, 1974.
- P. Gács, J. Körner. Common information is far less than mutual information. *Problems of Control and Inf. Theory* 2(2):149–162, 1973.
- P. Grünwald, P. Vitányi. Shannon information and Kolmogorov complexity. [arXiv:cs/0410002](https://arxiv.org/abs/cs/0410002)
- J. Hewitt, P. Liang. Designing and interpreting probes with control tasks. EMNLP 2019.
- S. Hirahara, R. Ilango, Z. Lu, M. Nanashima, I. C. Oliveira. A duality between one-way functions and average-case symmetry of information. STOC 2023. [ECCC TR23-035](https://eccc.weizmann.ac.il/report/2023/035/)
- A. N. Kolmogorov. Three approaches to the quantitative definition of information. *Problems Inf. Transmission* 1(1):1–7, 1965.
- L. A. Levin. Laws of information conservation (nongrowth) and aspects of the foundation of probability theory. *Problems Inf. Transmission* 10(3):206–210, 1974.
- L. A. Levin. Randomness conservation inequalities: information and independence in mathematical theories. *Information and Control* 61:15–37, 1984.
- M. Li, X. Chen, X. Li, B. Ma, P. Vitányi. The similarity metric. *IEEE Trans. Inf. Theory* 50(12):3250–3264, 2004.
- M. Li, P. Vitányi. *An Introduction to Kolmogorov Complexity and Its Applications*, 4th ed. Springer, 2019.
- L. Longpré, O. Watanabe. On symmetry of information and polynomial time invertibility. *Information and Computation* 121(1):14–22, 1995.
- J. H. Lutz, N. Lutz. Algorithmic information, plane Kakeya sets, and conditional dimension. *ACM Trans. Comput. Theory* 10(2), 2018.
- J. H. Lutz, D. M. Stull. Algorithmic fractal dimensions in geometric measure theory. 2020. [arXiv:2007.14346](https://arxiv.org/abs/2007.14346)
- An. Muchnik. On common information. *Theor. Comput. Sci.* 207:319–328, 1998.
- An. Muchnik. Conditional complexity and codes. *Theor. Comput. Sci.* 271:97–109, 2002.
- T. Pimentel, J. Valvoda, R. Hall Maudslay, R. Zmigrod, A. Williams, R. Cotterell. Information-theoretic probing for linguistic structure. ACL 2020.
- A. Romashchenko. Algebraic barriers to halving algorithmic information quantities in correlated strings. MFCS 2025. [arXiv:2504.14408](https://arxiv.org/abs/2504.14408)
- A. Romashchenko, M. Zimand. An operational characterization of mutual information in algorithmic information theory. ICALP 2018; *J. ACM* 2019. [ECCC TR18-043](https://eccc.weizmann.ac.il/report/2018/043)
- A. Schwarzschild, Z. Feng, P. Maini, Z. Lipton, J. Z. Kolter. Rethinking LLM memorization through the lens of adversarial compression. NeurIPS 2024. [arXiv:2404.15146](https://arxiv.org/abs/2404.15146)
- A. Shen. Kolmogorov complexity as a language. 2011. [arXiv:1102.5418](https://arxiv.org/abs/1102.5418)
- A. Shen, V. Uspensky, N. Vereshchagin. *Kolmogorov Complexity and Algorithmic Randomness*. AMS, 2017.
- A. Shen, N. Vereshchagin. Logical operations and Kolmogorov complexity. *Theor. Comput. Sci.* 271:125–129, 2002.
- H. Theil. On the estimation of relationships involving qualitative variables. *Amer. J. Sociology* 76(1):103–154, 1970.
- N. Vereshchagin, A. Shen. Algorithmic statistics: forty years later. In *Computability and Complexity*, LNCS 10010, 2017.
- N. Vereshchagin, P. Vitányi. Kolmogorov's structure functions and model selection. *IEEE Trans. Inf. Theory* 50(12):3265–3290, 2004.
- P. Vitányi. Meaningful information. *IEEE Trans. Inf. Theory* 52(10):4617–4626, 2006.
- E. Voita, I. Titov. Information-theoretic probing with minimum description length. EMNLP 2020. [arXiv:2003.12298](https://arxiv.org/abs/2003.12298)
- Y. Xu, S. Zhao, J. Song, R. Stewart, S. Ermon. A theory of usable information under computational constraints. ICLR 2020.
- M. Zimand. Kolmogorov complexity version of Slepian–Wolf coding. STOC 2017.
- J. Ziv, N. Merhav. A measure of relative entropy between individual sequences with application to universal classification. *IEEE Trans. Inf. Theory* 39(4):1270–1279, 1993.
