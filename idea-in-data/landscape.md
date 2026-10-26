# What ideas are in a big data set?

*A sequel to [notes.md](notes.md). It looks at the set of ideas contained in $X$, where $X$ is a corpus of images or videos, or a 4D block of spacetime described at the level of atoms. It also asks whether $X$ can be reconstructed from, or decomposed into, the ideas it contains.*

Notes by Claude, following questions from Kaarel Hänni, 26 October 2026. Draft. Conventions are those of notes.md §0: $K$ is prefix complexity, $\approx$ means up to $O(\log n)$, $Y\sqsubseteq_\varepsilon X$ means $K(Y\mid X)\le\varepsilon K(Y)$, and $Y\sqsubseteq X$ means $K(Y\mid X)=O(\log n)$.

**Summary.**

1. **The raw set of contained ideas is huge and unstructured, provably so** (§§1–3).
   - Ranking by containment degree $\rho$ puts big raw chunks of the data above the laws of physics.
   - Almost every $\varepsilon$-contained idea is padded with $\varepsilon$-worth of junk that is not in $X$ at all.
   - Every contained idea splits into a *structural* share, bounded by the complexity $K(S)$ of a minimal sufficient model, and an *accidental* share. For natural data, $K(S)$ is a tiny fraction of $K(X)$.
   - The accidental part behaves like a random string. Its ideas form something like the subspace lattice of $\mathbb F_2^N$: isotropic, with no distinguished elements. So yes: by volume, almost all contained ideas correspond to nothing anyone would call a notion.
2. **Structure lives in redundancy** (§4). Call an idea *redundant* if it is contained in many disjoint fragments of $X$.
   - Redundant ideas are always contained in any model that makes the fragments independent. So noise is never redundant.
   - A maximal redundant idea that also mediates the fragments (a "natural latent", after Wentworth–Lorell) is unique up to information equivalence. The proof is three lines.
   - It exists iff the mutual information of the fragments is extractable as common information. The point–line pair of notes.md Theorem 4.1 is a case where it does not.
   - This is the same notion as Zurek's redundancy in quantum Darwinism, and it is what two observers with disjoint access to the world can both know.
3. **Two filters, two pictures of the spacetime block** (§5).
   - "Contained in the minimal sufficient statistic" keeps physics and chemistry, i.e. what follows from the laws and the initial conditions. It discards all frozen accidents: species, continents, the Moon's orbit.
   - "Redundantly contained" keeps the frozen accidents that got copied: genomes (in every cell), the Moon's position (in every photon), and so on.
   - Human concepts look like the second filter.
4. **Decomposition** (§6).
   - Every fully contained idea splits off with an independent complement, $X\cong(Y,W)$. But complements are not unique, and two complements of the same idea can be independent of each other. "$X$ minus $Y$" is not an idea.
   - Given a natural latent $M$, $X\cong(M,W_1,\dots,W_N)$ with mutually independent components, each $W_i$ contained in fragment $i$. This is a de Finetti-style "structure plus local noise" decomposition. $M$ is canonical; inside the noise only the location is canonical.
   - From natural notions alone you reconstruct $M$ and nothing more. The rest of $X$ admits only an arbitrary basis.
   - Two obstructions block anything finer: non-extractable shared information, and synergy. The information in $X$ is not a measure on its notions.

---

## 1. The raw set: big, padded, and ranked by size

**Proposition 1.1 (size, and padding).**

1. **Few fully contained ideas.** Fewer than $2^{c+1}$ strings satisfy $K(Y\mid X)\le c$. With $c=O(\log n)$ there are only polynomially many, and they are the outputs of short programs run on $X$.
2. **Counting bound at each level.** Fewer than $2^{\varepsilon k+1}$ strings with $K(Y)<k$ satisfy $Y\sqsubseteq_\varepsilon X$.
3. **The bound is tight, because of padding.** Suppose $K(X)\ge(1-\varepsilon)k$. Take $Z\sqsubseteq X$ with $K(Z)=(1-\varepsilon)k$, and let $W$ be any of the $2^{\varepsilon k}$ strings of length $\varepsilon k$ with $K(W\mid X,Z)\approx\varepsilon k$. Then $Y=(Z,W)$ has $K(Y)\approx k$ and $K(Y\mid X)\approx\varepsilon k$. So there are $2^{\varepsilon k-O(\log n)}$ $\varepsilon$-contained ideas of size about $k$, almost all of which consist of an idea that is fully in $X$ plus $\varepsilon k$ bits that are in $X$ nowhere.

*Proof.* Parts 1 and 2 count programs. Part 3 is symmetry of information applied to independent $Z$ and $W$. $\square$

So the thresholded set $\{Y:Y\sqsubseteq_\varepsilon X\}$ is mostly an $\varepsilon$-thickening by junk. Its interesting core is $\{Y:K(Y\mid X)\approx0\}$, i.e. the simple functions of $X$, together with the "constraint-type" partial containments of notes.md §4.

**Observation 1.2 (ranking by $\rho$ rewards size).** If $K(Y\mid X)\le c$, then $\rho(Y\sqsubseteq X)\ge1-c/K(Y)$. Compare two ideas in a spacetime block:

- **A raw chunk.** A $10^9$-bit chunk of thermal noise, located in a $2^{60}$-bit block (about 120 bits of address), has $\rho\gtrsim1-10^{-7}$.
- **The laws of physics.** Suppose $K(L)\sim10^4$ bits and $K(L\mid X)$ is a few tens of bits (the cost of the search parameters). Then $\rho(L)\approx1-10^{-3}$.

The top of the $\rho$-ranking is $X$ itself, then $X$ with a few bits deleted, then large raw chunks. **"Most contained" in the sense of $\rho$ means "most of $X$".** Any notion of idea-ness has to come from somewhere other than $\rho$.

## 2. Structure versus accident

**Theorem 2.1 (every contained idea splits into a structural share and an accidental share).** Let $S\ni X$ be a finite model with optimality deficiency $\delta$, i.e. $K(S)+\log|S|\le K(X)+\delta$. Then for every $Y$:

$$I(Y:X)\;=\;\underbrace{I(Y:S)}_{\le\,K(S)}\;+\;\underbrace{I(Y:X\mid S)}_{\le\,\log|S|+O(\log n)}\;\pm\;O(\delta+\log n).$$

Here $I(Y:X\mid S):=K(Y\mid S)-K(Y\mid X,S)$.

*Proof.* First, $K(X,S)\le K(S)+\log|S|+O(\log n)\le K(X)+\delta+O(\log n)$, so $K(S\mid X)\le\delta+O(\log n)$ (Vereshchagin–Vitányi). Hence $K(Y\mid X)$ and $K(Y\mid X,S)$ differ by at most $\delta+O(\log n)$. Then

$$I(Y:X)=[K(Y)-K(Y\mid S)]+[K(Y\mid S)-K(Y\mid X,S)]\pm O(\delta+\log n).\qquad\square$$

**Corollary 2.2.** If $Y\sqsubseteq_\varepsilon X$, then the accidental share satisfies

$$I(Y:X\mid S)\ \ge\ (1-\varepsilon)K(Y)-K(S)-O(\delta+\log n).$$

So every contained idea larger than about $K(S)/(1-\varepsilon)$ is mostly accidental. $X$ has a *structural capacity* of $K(S)$ bits and an *accidental capacity* of about $K(X)-K(S)$ bits. Taking $S=S_{\min}$, the minimal sufficient statistic, maximises the accidental share. $K(S_{\min})$ is essentially Koppel's sophistication, or Gell-Mann–Lloyd's effective complexity.

**Orders of magnitude.** These numbers are rough and only meant to show the scale.

- **A photo or video corpus.** The best lossless codecs and generative models still spend a few bits per subpixel on unpredictable detail: sensor noise, exact textures, the precise position of every leaf. For $10^9$ images of $10^6$ pixels, that is around $10^{16}$ bits of accident. Any plausible model of the regularities is many orders of magnitude smaller.
- **An atom-level spacetime block.** A cubic metre of air has about $2.5\times10^{25}$ molecules at roughly 33 bits of thermal entropy each ($S^\circ(\mathrm N_2)/k_B\ln2$). That is about $10^{27}$ bits of initial-condition noise, before any quantum-branching randomness is counted. The laws are perhaps $10^3$–$10^5$ bits. Zurek's (1989) "physical entropy", $H(\text{micro}\mid\text{record})+K(\text{record})$, is exactly this split.

So by volume, the ideas in a natural $X$ are overwhelmingly accidental, with fractions such as $1-10^{-20}$ for the gas.

## 3. The accidental part is isotropic

Relative to $S$, $X$ is a typical element of a set, i.e. a random string. What do the ideas in a random string look like?

**Proposition 3.1 (the linear ideas of random data form a projective geometry).** Let $R\in\mathbb F_2^N$ with $K(R)\ge N-d$. For every matrix $A$ over $\mathbb F_2$ with $N$ columns,

$$\big|K(AR)-\operatorname{rank}A\big|\ \le\ K(A)+d+O(\log N).$$

The same holds for stacked matrices. Hence:

- $K(AR\mid BR)\approx\dim(\mathrm{row}A+\mathrm{row}B)-\dim\mathrm{row}B$, so $AR\sqsubseteq BR$ iff $\mathrm{row}A\subseteq\mathrm{row}B$;
- $I(AR:BR)\approx\dim(\mathrm{row}A\cap\mathrm{row}B)$.

All errors are $O(K(A)+K(B)+d+\log N)$.

*Proof.*

- Upper bound: $AR$ lies in the column space of $A$, which has $2^{\operatorname{rank}A}$ elements.
- Lower bound: given $A$ and $AR$, $R$ lies in an affine subspace of dimension $N-\operatorname{rank}A$. So $K(R)\le K(AR)+N-\operatorname{rank}A+K(A)+O(\log N)$. $\square$

So restricted to simply describable linear features, the ideas of random data form the lattice of subspaces of $\mathbb F_2^N$. This lattice is complemented and modular but not distributive, and $GL_N(\mathbb F_2)$ acts transitively on subspaces of each dimension. Nonlinear features behave the same way: every simple balanced $f:\{0,1\}^N\to\{0,1\}^k$ has $K(f(R))=k\pm O(K(f)+d+\log N)$. **Nothing in the information structure distinguishes "the first 1000 bits" from "1000 random parities", or from "the parity of pixels 17, 2054 and 99 999".** That is the precise sense in which the bulk of the idea set is "big and unstructured": it is huge, and its symmetry group acts transitively on it.

## 4. Where structure lives: redundancy

Split $X$ into fragments $X_1,\dots,X_N$: images, spacetime regions, or patches. Write $X_A$ for the fragments indexed by $A$. The **redundancy profile** of an idea is

$$\mathcal R_c(Y)=\{A:K(Y\mid X_A)\le c\},$$

an up-set of fragment sets. Noise in fragment $i$ has the profile "sets containing $i$". The laws of physics have the profile "every sufficiently large region".

**Theorem 4.1 (a mediator absorbs everything redundant).** For all strings $Y,X_A,X_B,M$:

$$K(Y\mid M)\ \le\ K(Y\mid X_A)+K(Y\mid X_B)+I(X_A:X_B\mid M)+O(\log n).$$

*Proof.* First the unrelativised inequality $K(Y)\le K(Y\mid A)+K(Y\mid B)+I(A:B)+O(\log n)$. By the chain rule,

$$I(Y:B)\le I((A,Y):B)+O(\log n)=I(A:B)+I(Y:B\mid A)+O(\log n)\le I(A:B)+K(Y\mid A)+O(\log n),$$

and $I(Y:B)=K(Y)-K(Y\mid B)+O(\log n)$. Relativise everything to $M$, then use $K(Y\mid A,M)\le K(Y\mid A)+O(1)$. $\square$

**Corollary 4.2 (noise is never redundant).** Suppose $S$ makes the disjoint parts $X_A$ and $X_B$ independent, i.e. $I(X_A:X_B\mid S)\le\delta$. Then every idea contained in both parts up to $c$ is contained in $S$ up to $2c+\delta+O(\log n)$. For an i.i.d. corpus, $S$ is the parameter. Redundant ideas are structural relative to every model that makes the fragments independent.

**Corollary 4.3 (natural latents are unique).** Call $M$ a $(c,\delta)$-natural latent for $(X_A,X_B)$ if it satisfies two conditions:

- *redundancy:* $K(M\mid X_A),K(M\mid X_B)\le c$;
- *mediation:* $I(X_A:X_B\mid M)\le\delta$.

Then:

1. **Uniqueness.** If $M$ and $M'$ are both natural, then $K(M'\mid M)$ and $K(M\mid M')$ are at most $2c+\delta+O(\log n)$.
2. **Maximality.** $M$ is the largest redundant idea: every $Y$ contained in both parts up to $c'$ has $K(Y\mid M)\le2c'+\delta+O(\log n)$.
3. **Minimality.** $M$ is the smallest mediator: for every $M''$ with $I(X_A:X_B\mid M'')\le\delta''$, $K(M\mid M'')\le2c+\delta''+O(\log n)$.

*Proof.* All three are Theorem 4.1 with the appropriate substitutions. $\square$

This is the algorithmic version of Wentworth and Lorell's (2025) natural-latent theorems, which they prove in the Shannon setting with approximation bounds and which include "naturality implies minimality among mediators and maximality among redunds". Here it falls out of a standard inequality in three lines; I have not seen it stated.

**Proposition 4.4 (a natural latent exists iff the shared information is extractable).** If $M$ is natural, then $K(M)=I(X_A:X_B)\pm O(c+\delta+\log n)$. Conversely, if some $M$ is contained in both parts with $K(M)\approx I(X_A:X_B)$, then $M$ is natural.

*Proof.* For $M$ contained in both, symmetry of information gives $I(X_A:X_B\mid M)=I(X_A:X_B)-K(M)\pm O(c+\log n)$. $\square$

So existence is exactly the Gács–Körner / Muchnik question. In the point–line pair of notes.md Theorem 4.1, the two parts share $(m-1)s$ bits but have no common idea above $O(\log n)$. The shared information is real, yet there is no natural latent.

**Proposition 4.5 (composites are less redundant).**

- By pairing, $\mathcal R_c(Y)\cap\mathcal R_c(Z)\subseteq\mathcal R_{2c+O(\log n)}(g(Y,Z))$ for every simple $g$.
- Conversely, take $|Y|=|Z|$ and $K(Y)\approx|Y|$, and suppose a fragment set $A$ together with $Z$ knows essentially nothing about $Y$: $I(Y:(X_A,Z))\le c'$. Then $K(Y\oplus Z\mid X_A)\ge K(Y)-c'-O(\log n)$, so $A\notin\mathcal R(Y\oplus Z)$.

*Proof of the converse.* $K(Y\oplus Z\mid X_A)\ge K(Y\oplus Z\mid X_A,Z)-O(1)=K(Y\mid X_A,Z)\pm O(1)$, and $K(Y\mid X_A,Z)\ge K(Y)-c'-O(\log n)$. $\square$

So composites of natural ideas carry roughly the *intersection* of their profiles. "Joints" are ideas that are maximal for their profile. This partly fixes the coordinates, but not fully. Ideas with *identical* profiles, such as two global constants $C_1,C_2$ and the composite $C_1\oplus C_2$, cannot be told apart by information and redundancy alone.

Goodman's grue is an instance:

- With spatial fragments only, "green" and "grue" are equally redundant.
- With *time-slice* fragments, the grue status of an emerald differs between slices before and after $t_0$, so it is not one fixed idea across slices, while "green" is. The locality structure of the fragmentation is what makes "green" projectible.

**Interpretations.**

1. **Intersubjectivity.** $Y$ is redundant across $X_A$ and $X_B$ exactly when two observers who see only $X_A$ and only $X_B$ can both know $Y$. Redundant ideas are the ones that can be shared without communication. By Proposition 4.4, observers can share a great deal of information and still have no common concept.
2. **Quantum Darwinism.** Zurek's redundancy $R_\delta$ is the number of disjoint environment fragments $F$ with $I(S:F)\ge(1-\delta)H(S)$, i.e. the number of fragments in which the pointer state is $\delta$-contained in the sense of notes.md. Its large values are what make classical facts "objective". Riedel–Zurek (2010): a 1 μm dust grain in sunlight for 1 μs has its position recorded about $10^8$ times in the scattered photons.
3. **Partial information decomposition.** Williams–Beer's redundancy lattice organises "the information that sources $A$, $B$, … share about $Y$". Gács–Körner common information is one proposed redundancy measure (Griffith et al. 2014). Redundancy profiles are the containment version of the same lattice.

## 5. Two filters, two pictures of the spacetime block

There are two natural ways to separate ideas from junk:

- **(F1) Structural:** $Y\sqsubseteq S_{\min}(X)$. This is Gell-Mann–Lloyd regularities, Vitányi's "meaningful information", Koppel's sophistication.
- **(F2) Redundant:** $Y\sqsubseteq X_A$ for many disjoint fragment sets $A$. This is natural latents and quantum Darwinism.

By Corollary 4.2, F2 ⊆ F1 whenever $S_{\min}$ makes the fragments independent. The spacetime block shows they can differ sharply.

**The atom-level spacetime block.** Suppose our block is a typical sample of a simple model: the laws, the cosmological initial conditions, and the block's location. Inflationary fluctuations, quantum branching outcomes and thermal microstates are then all "typical". Then:

- **(F1) is small.** $S_{\min}$ is about $K(\text{laws})+K(\text{initial conditions})$, perhaps $10^3$–$10^5$ bits. F1 contains everything that follows simply from that: physics, chemistry (the periodic table is a simple function of the laws), and generic astrophysics. It contains *no* frozen accidents. That a planet with this geography, this biosphere and these species exists is typical-given-$S_{\min}$, hence accidental, hence outside F1.
- **(F2) is much larger.** Fragments of the block are *not* independent given $S_{\min}$: they share frozen accidents through common causes. The natural latent of the fragments is (laws + the redundantly recorded frozen accidents), roughly "the classical world". F2 contains:
  - the Moon's orbit, recorded in every photon and every tide;
  - every species' genome, of order $10^9$–$10^{10}$ bits, copied about $10^{13}$ times in a single human body;
  - continents, languages, cities.

  It excludes un-amplified micro-noise.
- **The rest is accidental and unrecorded.** Thermal microstates and single-molecule histories are $10^{27}$ bits per cubic metre, with isotropic idea-structure (§3).

**The image corpus.** Take fragments to be single images, or small groups.

- **Contained in every image:** the camera and optics model, natural-image statistics, and the physics of light.
- **Redundant across moderately large groups:** category-level regularities (what cats look like, the structure of faces) and recurring particular objects (the Eiffel Tower, a celebrity). Each has a profile tied to a sub-family of the images.
- **Present in one image only:** the composition, the noise, the exact pose.

So "the cat concept" is a natural latent of the cat photographs. A particular network's cat classifier is not: its specific weights carry many arbitrary bits, and only their redundant part is canonical.

**Caveat (non-stochastic data).** For data that is not well described by any simple model, the boundary models of the Kolmogorov structure function carry halting-problem information (Vereshchagin–Vitányi 2004). That makes precise Levin's remark that such objects "must have a lot of information about the halting problem" and are unlikely to occur in nature. For physical data, Levin's independence postulate suggests this pathology does not arise.

## 6. Reconstructing and decomposing $X$

**Theorem 6.1 (every contained idea has an independent complement).** If $K(Y\mid X)\le c$, there is $W$ with:

- $K(W\mid X)=O(\log n)$;
- $K(X\mid Y,W)=O(\log n)$;
- $K(W)=K(X)-K(Y)\pm O(c+\log n)$ and $I(W:Y)=O(c+\log n)$.

So $X\cong(Y,W)$, with $K(X)\approx K(Y)+K(W)$.

*Proof.* Muchnik's theorem for $X$ given $Y$ yields $W$ with $|W|\le K(X\mid Y)+O(\log n)$, $K(W\mid X)=O(\log n)$ and $K(X\mid Y,W)=O(\log n)$. Then $K(X)\le K(Y)+K(W\mid Y)+O(\log n)$, while by symmetry of information $K(X)=K(Y)+K(X\mid Y)\pm O(c+\log n)$. Hence $K(W\mid Y)\ge K(X\mid Y)-O(c+\log n)\ge K(W)-O(c+\log n)$. $\square$

This has no exact Shannon analogue. For $X$ uniform on $\{0,1,2\}$ and $Y=\mathbf 1[X=0]$, no $W=g(X)$ is independent of $Y$ with $X=h(Y,W)$, because the fibres of $Y$ have different sizes. Individual strings avoid the problem.

**Proposition 6.2 (complements are not unique, not even approximately).** Let $X=(A,B)$ with $A$ and $B$ independent random $n$-bit strings, and $Y=A$. Then both $W=B$ and $W'=A\oplus B$ are complements, and $I(W:W')=O(\log n)$. So **"$X$ minus $Y$" is not an idea**. Only the size $K(X\mid Y)$ and the span $(Y,W)\cong X$ are determined. Decompositions of $X$ into independent contained ideas are about as non-unique as bases of a vector space. For random data this is literally true, by Proposition 3.1.

**Theorem 6.3 (structure plus local noise).** Let $X=(X_1,\dots,X_N)$, and let $M$ satisfy:

- $K(M\mid X)\le c$;
- *mediation:* $K(X\mid M)\ge\sum_iK(X_i\mid M)-\delta$, i.e. the fragments are independent given $M$.

Let $W_i$ be Muchnik's code for $X_i$ given $M$. Then:

1. $W_i\sqsubseteq X_i$, i.e. $K(W_i\mid X_i)=O(\log n)$;
2. $X\cong(M,W_1,\dots,W_N)$, up to $c+O(N\log n)$;
3. $K(X)=K(M)+\sum_iK(W_i)\pm O(\delta+c+N\log n)$, so the components are mutually independent.

If $M$ is moreover redundant (contained in two disjoint groups of fragments), then $M$ is canonical up to information equivalence, by Corollary 4.3. Each $W_i$ is canonical only as "$X_i$ modulo $M$".

*Proof.*

- Part 1 is Muchnik's theorem.
- For part 2: $K(X\mid M,W_1,\dots,W_N)\le\sum_iK(X_i\mid M,W_i)+O(N\log n)=O(N\log n)$, and $K(M,W_1,\dots,W_N\mid X)\le c+O(N\log n)$.
- For part 3: $K(M)+\sum_i|W_i|\le K(M)+\sum_iK(X_i\mid M)+O(N\log n)\le K(M)+K(X\mid M)+\delta+O(N\log n)$, which is $K(X)+O(\delta+c+N\log n)$. And $K(M,W_1,\dots,W_N)\ge K(X)-O(N\log n)$. $\square$

This is a de Finetti-style representation for individual objects: exchangeable-looking data is a parameter together with independent local noises. The error grows like $N\log n$, so the theorem has content only when each $K(X_i\mid M)$ is much larger than $\log n$.

**Iterating.** Suppose the natural ideas have *laminar* profiles: scene, then objects, then parts, each a natural latent of its sub-fragments given its parent. Applying Theorem 6.3 down the tree gives

$$X\ \cong\ \text{(tree of natural latents)}+\text{(local noise at the leaves)},\qquad K(X)\approx\sum_{\text{nodes }v}K(v\mid\mathrm{parent}(v))+\sum_{\text{leaves}}K(\text{noise}).$$

The error is $O(\#\text{nodes}\cdot\log n)$. This is the formal shape of "a cat on a mat in afternoon light, plus pixel detail". Cross-cutting categories, such as colour and shape, give overlapping rather than nested profiles, so the result is a lattice rather than a tree.

**Proposition 6.4 (natural notions reconstruct only the structure).** For any notions $Y_1,\dots,Y_r$,

$$K(X\mid Y_1,\dots,Y_r)\ \ge\ K(X\mid M)-K(Y_1,\dots,Y_r\mid M)-O(\log n).$$

If the tuple $(Y_1,\dots,Y_r)$ is redundant across $X_A$ and $X_B$ up to $c$, and $M$ mediates $X_A$ and $X_B$, then Theorem 4.1 gives $K(Y_1,\dots,Y_r\mid M)\le2c+\delta+O(\log n)$. However many natural notions you collect, what is still missing to describe $X$ is at least its accidental content. Human descriptions of scenes are lossy for exactly this reason.

**Obstruction 1: shared information with no owner.** In the point–line pair $D=(X,Y)$ of notes.md Theorem 4.1, there is no decomposition $D\cong(Z_0,Z_X,Z_Y)$ into independent components with $Z_0$ a nontrivial common idea. There are lopsided decompositions: $(X,\text{code of }Y\text{ given }X)$, and $(Y,\text{code of }X\text{ given }Y)$. Each assigns the $(m-1)s$ shared bits to one side. Which side "owns" the shared information is not determined.

**Obstruction 2: synergy, so information is not a measure on notions.** Let $X=(A,B,A\oplus B)$ with $A,B$ independent random $n$-bit strings. Its three notions are pairwise independent and any two reconstruct $X$. The sum of their complexities is $3n$, but $K(X)=2n$. In Yeung's I-measure the triple atom is $-n$. The same linear bookkeeping holds for $K$ up to $O(\log n)$ (Hammer–Romashchenko–Shen–Vereshchagin 2000), so there is an "information diagram". But its atoms can be negative, and in general they cannot be realised as strings. So "how much of $X$ is due to notion $Y$" has no additive answer once three or more notions are involved.

## 7. So: do the contained ideas look like human notions?

- **The raw set: no.** It is dominated, by any count, by accidental ideas (Corollary 2.2) whose structure is isotropic (§3), padded with junk (Proposition 1.1), and ranked by size (Observation 1.2). That is a theorem, not an impression.
- **The redundant spine: largely yes in kind, but much larger than any human vocabulary.**
  - It is canonical (Corollary 4.3), structured by redundancy profiles (Proposition 4.4–4.5), and composes hierarchically (§6).
  - It includes many redundant facts nobody tracks: isotope ratios, the shape of every visible rock, the CMB's exact anisotropies.
  - Human concepts are a *value-weighted* selection from it, not the whole of it.
- **Coordinates are only partly determined.** Profiles break some symmetries (composites are less redundant, and locality settles grue). Ideas with identical profiles stay interchangeable.
- **Accessibility matters too.** Humans see the ideas that are *cheap to extract*. That needs the resource-bounded version of notes.md §7, under which deep ideas (Bennett) that are informationally present may be practically absent.

## 8. Questions worth pursuing

1. **Approximate uniqueness with explicit constants for many fragments.** This would turn Corollary 4.3 into an "objectivity theorem": observers with access to disjoint fragments agree on every natural latent, up to explicit slack.
2. **When do natural latents exist?** Find conditions on the "graph of $X$" (expansion, incidence structure) under which fragments' mutual information is extractable. Theorem 4.1 of notes.md is the negative end.
3. **A redundancy-weighted ranking of ideas** that replaces $\rho$. A candidate: score $Y$ by the smallest fragment size $r$ such that a random $r$-fragment contains $Y$. For quantum Darwinism this is the "classical plateau".
4. **Empirics.** Estimate redundancy profiles in image corpora with a bounded $K$: compressor- or model-based conditional code lengths on disjoint subsets. Check whether profile-maximal features coincide with human-labelled categories.

## References

In addition to those in [notes.md](notes.md):

- B. de Finetti. La prévision: ses lois logiques, ses sources subjectives. *Ann. Inst. H. Poincaré* 7:1–68, 1937.
- M. Gell-Mann, S. Lloyd. Information measures, effective complexity, and total information. *Complexity* 2(1):44–52, 1996.
- N. Goodman. *Fact, Fiction, and Forecast*. Harvard, 1955.
- V. Griffith, E. Chong, R. James, C. Ellison, J. Crutchfield. Intersection information based on common randomness. *Entropy* 16(4):1985–2000, 2014.
- D. Hammer, A. Romashchenko, A. Shen, N. Vereshchagin. Inequalities for Shannon entropy and Kolmogorov complexity. *J. Comput. Syst. Sci.* 60:442–464, 2000.
- M. Koppel. Complexity, depth, and sophistication. *Complex Systems* 1:1087–1091, 1987.
- L. A. Levin. Forbidden information. *J. ACM* 60(2), 2013. [arXiv:cs/0203029](https://arxiv.org/abs/cs/0203029)
- H. Ollivier, D. Poulin, W. H. Zurek. Objective properties from subjective quantum states: environment as a witness. *Phys. Rev. Lett.* 93:220401, 2004.
- C. J. Riedel, W. H. Zurek. Quantum Darwinism in an everyday environment: huge redundancy in scattered photons. *Phys. Rev. Lett.* 105:020404, 2010. [arXiv:1001.3419](https://arxiv.org/abs/1001.3419)
- J. Wentworth, D. Lorell. Natural latents: latent variables stable across ontologies. 2025. [arXiv:2509.03780](https://arxiv.org/abs/2509.03780)
- P. Williams, R. Beer. Nonnegative decomposition of multivariate information. 2010. [arXiv:1004.2515](https://arxiv.org/abs/1004.2515)
- R. W. Yeung. A new outlook on Shannon's information measures. *IEEE Trans. Inf. Theory* 37(3):466–474, 1991.
- W. H. Zurek. Algorithmic randomness and physical entropy. *Phys. Rev. A* 40:4731–4751, 1989.
- W. H. Zurek. Quantum Darwinism. *Nature Physics* 5:181–188, 2009.
