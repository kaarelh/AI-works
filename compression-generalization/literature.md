
# Compressing a trained network to bound its error: literature review

*For the compression-generalization project, October 2026.*

**Sources and conventions.** This review draws on a literature sweep, which ran web searches and read the result snippets, and on a separate novelty assessment. The sweep also cloned two code repositories: Bound-to-Disagree by Bazinet et al. and tight-pac-bayes by Lotfi et al. The shared search budget ran out partway through, so coverage is uneven and some later sub-sweeps relied on memory. Tags used below:

* A paper with no tag was confirmed by a search result or by its official repository (title, authors, year, venue).
* **(unconfirmed)**: the paper, or the specific claim, comes from memory and no search confirmed it.
* **(unverified)**: a number or claim that no search snippet or repository output supports.
* **(repo)**: a number read from repository code or notebook outputs: the Bound-to-Disagree notebooks, or the tight-pac-bayes plotting and replication scripts. These are not from the paper text, and the paper's tables may differ.
* **(own arithmetic)**: computed here.

**Citation-check pass.** A later adversarial citation check could not run any web searches, because the shared search budget was already exhausted. It re-checked claims against four public repositories:

* Bound-to-Disagree and tight-pac-bayes (cloned earlier);
* RATT_generalization_bound (cloned for the check);
* the compact-proofs repository, guarantees-based-mechanistic-interpretability (README only, for the check).

Everything else was checked from memory. Untagged entries keep the earlier sweep's "confirmed" status, but this pass did not re-verify them.

**Notation.** S = ((x_i, y_i))_{i≤m} is drawn i.i.d. from D on X×Y, and D_X is the input marginal. f = f_S is the trained network. err(h) = Pr_D[h(x) ≠ y], and k_S(h) is the number of training mistakes of h. A *code* is a prefix-free set Σ of descriptions σ with lengths L(σ), so Σ_σ 2^{-L(σ)} ≤ 1 by Kraft's inequality, together with a decoder σ ↦ g_σ. Both are fixed before S is drawn.

---

## 1. The idea, and three routes from "compressible" to "generalizes"

The proposal is to find a short description σ whose decoded network g_σ is close to f, and then use

  err(f) ≤ err(g_σ) + Pr_{x∼D_X}[f(x) ≠ g_σ(x)]. (1)

The first term is bounded by a union bound over all short descriptions. σ is chosen after seeing S, so the bound has to hold for every σ at once, and an Occam bound provides exactly that. The reduction therefore has two halves:

* an **Occam term**, which pays L(σ) bits;
* a **closeness term**, which depends only on D_X.

The literature has explored this idea extensively. The Occam half is mature and works on real networks. The closeness half is where the difficulty lies.

**Route 1: Occam over a code.** This goes back to Blumer, Ehrenfeucht, Haussler and Warmuth 1987, and is stated in its tight form in Langford's 2005 tutorial (unconfirmed). With probability at least 1−δ, for all σ simultaneously,

  err(g_σ) ≤ Bin̄(k_S(g_σ), m, δ·2^{-L(σ)}),

where Bin̄(k, m, δ′) is the largest p with Pr[Binomial(m, p) ≤ k] ≥ δ′. The proof applies the binomial tail to each fixed σ at confidence δ·2^{-L(σ)} and sums using Kraft's inequality.

Two relaxations are common. One is kl(k/m ‖ err) ≤ (L ln 2 + ln(1/δ))/m. At zero training error this gives err ≤ 1 − exp(−(L ln 2 + ln(1/δ))/m), which the other, linear relaxation bounds above by (L ln 2 + ln(1/δ))/m. At low error the exact binomial or kl form is much tighter than Hoeffding.

The code may depend on any randomness drawn independently of S, such as a seed, an initialization, a random projection or a dither (Section 7). This route certifies a deterministic g. Examples:

* Arora et al. 2018: a finite class of compressed nets, indexed with a "helper string" of random bits.
* Lotfi et al. 2022: arithmetic-coded, quantized coordinates in a random subspace.
* Akinwande et al. 2024: discrete prompts, coded by a language model.

**Route 2: PAC-Bayes with a code-based prior.** This is due to McAllester 1998–99 (unconfirmed), in the Seeger 2002 / Maurer 2004 kl form (unconfirmed):

  kl(êrr_S(Q) ‖ err(Q)) ≤ (KL(Q‖P) + ln(2√m/δ))/m for all Q.

Take P(g_σ) ∝ 2^{-L(σ)} and a point-mass Q. Then KL ≤ L(σ) ln 2, and Route 1 is recovered up to the extra ln(2√m) term; the exact binomial Occam bound is slightly tighter. The advantage of PAC-Bayes is that Q can be a whole cloud of networks around f, and a cloud is often much cheaper than one exact quantized network. A box of per-weight widths Δ_i costs roughly Σ log(range/Δ_i). That is the minimum-description-length (MDL) argument of Hinton & van Camp 1993 and of Hochreiter & Schmidhuber's "Flat minima" (1997), made rigorous. The cost is that the bound applies to the stochastic (Gibbs) predictor, not to f. Zhou et al. 2019 combine the two routes: the prior comes from code lengths of compressed networks, and the posterior is Gaussian noise around the compressed weights.

**Route 3: surrogates and rate–distortion.** These bound f itself, through (1) or an analogue of it.

* Negrea, Dziugaite & Roy 2020 frame the general pattern: uniform convergence over a well-behaved class that contains a surrogate h̃, plus a separately controlled gap between h̃ and the learned predictor.
* Sefidgaran, Gohari, Richard & Şimşekli 2022 define lossy compressibility. The distortion is measured on the generalization gap rather than on Pr[f ≠ g].
* Daniely & Granot 2019 require approximation at every input x, in expectation over shared random coins. This is "approximate description length" (ADL).
* Suzuki, Abe & Nishimura 2020 control the population L2 distance between f and g with the local Rademacher complexity of the difference class.
* Hsu, Ji, Telgarsky & Wang 2021 and Bazinet, Zantedeschi & Germain 2026 implement (1) empirically.

**The crux: the second term of (1).** Because f depends on S, the training disagreement (1/m) Σ_i 1[f(x_i) ≠ g(x_i)] is not an unbiased estimate of Pr[f ≠ g]. Making it valid would need uniform convergence over pairs (f, g), which brings back exactly the complexity of f that compression was meant to avoid. The literature offers five ways out:

* **(a) Fresh unlabeled inputs and a binomial test on disagreement.** Kääriäinen 2005; Kääriäinen & Langford 2005; Bazinet et al. 2026.
* **(b) Synthetic inputs** from a distribution with bounded density ratio to D_X. Hsu et al. 2021.
* **(c) A known D_X**, enumerated or sampled for free. Boolean tasks; Gross et al. 2024.
* **(d) A proof that closeness holds at all inputs, or that closeness on training points generalizes.** Margin-plus-perturbation arguments (McAllester 2003, unconfirmed; Neyshabur, Bhojanapalli & Srebro 2018), noise-resilience (Nagarajan & Kolter 2019), exact majority-vote identities (Biggs & Guedj 2022), ADL (Daniely & Granot 2019), and difference-class Rademacher bounds (Suzuki et al. 2020).
* **(e) Formal verification over the whole input domain.** Differential or equivalence verification (Section 6). If |f − g| ≤ ε holds for all x, then err(f) ≤ Pr[g is wrong or has margin < ε], and that quantity depends on g alone.

A sixth option sidesteps the term: deploy g instead of f, or train f inside the compressed family so that f = g (Lotfi et al. 2022).

---

## 2. Bounds for compressed networks

**Arora, Ge, Neyshabur & Zhang (ICML 2018)** set up the compression framework. f is (γ, S)-compressible if some g_A, taken from a class of about 2^q networks indexed by a helper string fixed before the data, matches f's margins on the training points to within γ. Then g_A generalizes with complexity q. The compression uses random projections, justified by noise-stability properties measured on trained nets: layer cushion, interlayer cushion, activation contraction and interlayer smoothness. Only g_A is bounded. On VGG-19/CIFAR-10 the bound is orders of magnitude below norm-based bounds but still vacuous; a follow-up puts it at about 10^5 (from a snippet of Li et al. 2020). The helper string makes explicit, within the compression framework, that data-independent randomness costs no bits. The same principle underlies Dziugaite & Roy's 2017 PAC-Bayes prior centred at the random initialization.

Several follow-ups use other compressors, all within the Arora framework:

* **Baykal et al. (ICLR 2019)** sparsify fully connected nets by sensitivity-based importance sampling. They prove that, with high probability over a fresh input, the sparsified net's pre-activations stay within (1 ± ε) of the original's. This needs a small batch of inputs to estimate sensitivities.
* **Suzuki et al. (IJCAI 2020)**, spectral pruning, prune nodes using the spectrum of activation covariances.
* **Li, Sun, Su, Suzuki & Huang (AISTATS 2020)** use CP-decomposition layers.
* **Shin (2021 preprint)** sparsifies heavy-tailed weight matrices and claims a non-vacuous bound (unverified).

None of these report verified non-vacuous numbers.

**Zhou, Veitch, Austern, Adams & Orbanz (ICLR 2019)** gave the first non-vacuous bounds at realistic scale. The pipeline is:

1. Prune (Dynamic Network Surgery; for LeNet-5, down to about 1.5% of its weights, unverified).
2. Quantize with a codebook (4 bits for LeNet-5, unverified; 15 clusters for MobileNet per the tight-pac-bayes replication notes, repo).
3. Store positions in compressed sparse row (CSR) format with arithmetic-coded index differences.

The PAC-Bayes prior is a universal-code distribution over such encodings. A Gaussian posterior around the quantized weights earns a noise-robustness correction that subtracts bits. Snippet-supported results:

* MNIST: LeNet-5 goes from 168.4 KiB to 8.1 KiB, and the "effective" size after the noise correction is 6.23 KiB. The top-1 error bound is below 46%.
* ImageNet: MobileNet (67% pruned) is compressed to about 452 KiB, with an effective size of about 350 KiB (sizes from the replication notes in the tight-pac-bayes repo, repo). It gives a top-1 bound below 96.5% and a top-5 bound below 89%. Recomputing a Catoni bound from those notes (about 65% train accuracy, 350 KiB, m = 1,281,167, δ = 0.05) gives 96.5% (own arithmetic), which corroborates the top-1 figure.

Nets trained on random labels compress less. The certified predictor is the noisy compressed net.

**Lotfi, Finzi, Kapoor, Potapczynski, Goldblum & Wilson (NeurIPS 2022; NeurIPS 35:31459–31473 per the Bound-to-Disagree README)** is the current state of the art for data-independent compression bounds on small vision nets. The method:

1. Train in a random affine subspace θ = θ₀ + P w, where θ₀ and P are regenerated from a seed. P uses Kronecker or sparse projections and w has dimension d of about 10²–10⁴. This builds on Li, Farkhoor, Liu & Yosinski (ICLR 2018), whose intrinsic-dimension measurements give about 750 for an MNIST MLP and about 290 for an MNIST CNN (snippet from the Uber blog).
2. Quantize w with quantization-aware training on a learned codebook.
3. Arithmetic-code the result and apply a Catoni/Occam bound.

The sweep checked the released code. The prior is 2^{-(L + 2 log₂ L)}, plus a few bits for the hyperparameter search (`misc_extra_bits`). θ₀ and P cost 0 bits.

Results (snippets unless marked):

* MNIST: 11.6% (11.55% in the text; 11.6 also in repo) at about 0.38–0.4 KB, against 47.9% for pruning plus quantization. With transfer from a pretrained prior: 9.0% (repo).
* Fashion-MNIST: 32.8% data-independent, 28.2% with transfer (repo).
* CIFAR-10: 58.2% data-independent (also repo). 35.1% with an ImageNet-pretrained EfficientNet-B0 as the prior (also repo). 16.6% with a data-dependent prior, against 16.7% quoted for Pérez-Ortiz et al. (unverified).
* CIFAR-100: 94.6% data-independent, 81.3% with transfer (repo).
* ImageNet: 94.1% (single snippet, unverified). The repo's figure scripts contain no ImageNet bound, and the snippet may have confused this with the CIFAR-100 value of 94.6%.

The certified model is the quantized subspace net, which is the deployed model. It is not an independently trained f.

**Related diagnostics and refinements.**

* **Kuhn, Lyle, Gomez, Rothfuss & Gal (2021):** "prunability", the smallest fraction of weights that can be kept without hurting training loss, predicts generalization on CIFAR-10 better than norms or flatness, including through double descent. It is a correlation, not a bound.
* **Rouchouse, Gonon, Gribonval & Guedj (2025):** rescaling symmetries waste code length. A path-plus-sign lifted representation reduced the KL term about 4× and the bound about 2×, turning some vacuous MNIST and CIFAR-10 bounds non-vacuous (secondhand).
* **Goldblum, Finzi, Rowan & Wilson (ICML 2024),** "The no free lunch theorem, Kolmogorov complexity, and the role of inductive biases in machine learning": applies the Lotfi machinery to tabular data and argues that a single low-complexity bias suffices across domains.

**Best compression-only results by dataset.** All of these certify the compressed or noisy g:

| dataset | best data-independent | with data-dependent / transfer prior |
|---|---|---|
| MNIST | 11.6% (Lotfi 2022) | 9.0% transfer (Lotfi 2022, repo) |
| Fashion-MNIST | 32.8% (Lotfi 2022, repo) | 28.2% transfer (repo) |
| CIFAR-10 | 58.2% (Lotfi 2022) | 35.1% transfer; 16.6% data-dependent (Lotfi 2022) |
| CIFAR-100 | 94.6% (Lotfi 2022, repo) | 81.3% transfer (repo) |
| ImageNet | 96.5% top-1 / 89% top-5 (Zhou 2019); 94.1% top-1 (Lotfi 2022, unverified) | — |

**Parameter-counting baseline.** At zero training error the naive Occam bound with b bits per weight is 1 − exp(−(W·b·ln 2 + ln(1/δ))/m), which is at most the linear relaxation (W·b·ln 2 + ln(1/δ))/m. A 784-100-10 MLP has W = 79,510. At b = 1 and δ = 0.05 on MNIST (m = 60k), that gives about 0.60 with the exact kl form, or 0.92 with the linear relaxation. At b = 32 it is vacuous (own arithmetic).

The VC dimension of piecewise-linear nets is O(W L log W), with a nearly matching Ω(W L log(W/L)) lower bound (Bartlett, Harvey, Liaw & Mehrabian, JMLR 2019, unconfirmed). That is vacuous for any modern net. Norm-based bounds are astronomically vacuous (Section 3).

---

## 3. Bounds for the original network via a surrogate (closest prior art)

**Semi-supervised precursors** use disagreement measured on unlabeled data:

* **Schuurmans & Southey (MLJ 2002):** define a metric on hypotheses as the distance between their predictions on unlabeled data, and use triangle-inequality checks for model selection. No certificate.
* **Madani, Pennock & Flake (NIPS 2004), co-validation:** the disagreement of two models on unlabeled data gives lower bounds only.
* **Kääriäinen (COLT 2005)** and **Kääriäinen & Langford (ICML 2005):** bound a randomized or simple classifier, then transfer the bound to a deterministic one by adding their disagreement estimated on unlabeled data with a binomial-tail term. This is (1) with route (a), about twenty years before the neural-net versions.
* **Lacasse et al. (NIPS 2006)**, the C-bound, and follow-ups (Germain et al. JMLR 2015; Masegosa et al. NeurIPS 2020, both unconfirmed): estimate the voter-disagreement term of majority-vote bounds on unlabeled data.
* **Balcan & Blum (JACM 2010):** use unlabeled data to shrink the class that has to be union-bounded.

**Theory without extra data.**

* **Suzuki, Abe & Nishimura (ICLR 2020)** name the difficulty explicitly: bounding the population L2 distance between f and g naively gives a VC bound. They control it with the local Rademacher complexity of the difference between the near-compressible class and the compressed class, under near-low-rank conditions on the weights and covariances. The rate can beat the compressed-net bound, but the constants are not computable, according to Bazinet et al.
* **Daniely & Granot (NeurIPS 2019):** if each function can be approximately described at *every* input x with ℓ bits, in expectation over shared coins, then the sample complexity is about ℓ/ε². For nets with O(1) spectral norms whose weights lie within Frobenius distance R of the initialization, with inputs in [−1,1]^d, this gives Õ(dR²/ε²), where d is the input dimension (from memory). Because closeness is required at every x, no data is needed to certify it, and the coins cost nothing.
* **Daniely & Katzhendler (2022)** show that ADL is essentially equivalent to covering numbers for real-valued classes. So the researcher's scheme is, in effect, a data-dependent covering argument, and its gains must come from f being near a small network rather than from a small class.
* **Barsbey et al. (NeurIPS 2021)** include a section titled "Generalization bound for the uncompressed network", under mean-field and heavy-tailed-SGD assumptions. The result is asymptotic, not computable.
* **Turner & Kabán (2022)** prove bounds through approximability, and identify when unlabeled data is or is not needed to certify the approximation.
* **Grønlund, Høgsgaard, Kamma & Larsen (2021), "Compression implies generalization"**, claimed to extend Arora et al. to the uncompressed net. It was **withdrawn** ("bug in the proof"), which is a concrete sign that the step from a bound on g to a bound on f is subtle.

**Distillation with augmentation.** Hsu, Ji, Telgarsky & Wang (ICLR 2021) show that f inherits g's bound plus a softmax distillation distance. The distance is measured on samples from an augmentation distribution whose density ratio to D_X is bounded; per the sweep's reading, the concrete construction mixes uniform noise and a kernel density estimate. In a snippet of their Figure 1, standard bounds are about 10^15 and distillation shrinks them by about 10^10 (ResNet8, test error 0.067 on CIFAR-10 and 0.008 on MNIST). The bounds therefore appear to remain far above 1 (my inference), and Bazinet et al. say the constants are not computable.

**Bound to Disagree.** Bazinet, Zantedeschi & Germain (UAI 2026; OpenReview CZeG5HW1Y5, per the repo README; PMLR 337:491–520 and arXiv 2602.23128 not re-verified in the citation-check pass) implement exactly (1) with route (a):

  R(f) ≤ cert_{δ₁}(h) + Bin̄(|U|·d_U(f, h), |U|, δ₂), with δ₁ + δ₂ = δ,

where d_U is the empirical disagreement on an unlabeled set U that is independent of f and h.

* **Surrogates h:** Pick-To-Learn sample compression; random or selected coresets; Lotfi-style subspace-plus-quantization compression ("PAC-TL", with a data-dependent prior split, optionally distilled on f's outputs); PAC-Bayes (the Pérez-Ortiz et al. library); quantization.
* **Data split (repo configs: validation_size 0.1, disagreement_size 0.2):** about 10% of the training split is used for f's early stopping, and 20% of the rest (about 18% of the total) is kept as the unlabeled disagreement set. f trains on about 72%.
* **Other experiments:** DistilBERT and GPT-2 on Amazon polarity, using bounded cross-entropy versions.

Numbers (repo; each checked against the notebook outputs):

| target | f's test error | surrogate (g's test error) | cert(g) + disagreement = bound on err(f) |
|---|---|---|---|
| MNIST CNN | 0.50% | PAC-TL (0.89%) | 2.45 + 1.00 = **3.45%** |
| MNIST CNN | 0.50% | Pick-To-Learn | 3.06 + 0.82 = 3.88% |
| CIFAR-10 ResNet18 | 5.84% | uniform coreset | 9.02 + 8.34 = **17.36%** |
| CIFAR-10 ResNet18 | 5.84% | PAC-TL (14.95%) | 20.15 + 14.91 = 35.06% |
| CIFAR-10 ResNet18 | 5.84% | Pick-To-Learn | 50.39 + 6.74 = 57.13% |

The coreset surrogate's certificate is a test-set bound on the part of the training split outside the coreset. That is valid, because those labels are independent of g, but the labelled data is effectively split.

Headline and baseline values. Rows marked † are hard-coded in the repo's headline figure (front_page_plot.ipynb). The k-means partition values and the CIFAR CNN norm value come from bounds_from_literature.ipynb instead. The 1.78%, 4.83% and 28.13% values appear only hard-coded in the figure; no saved notebook output reproduces them.

| | MNIST | CIFAR-10 |
|---|---|---|
| sample compression † | 1.78% | 17.36% |
| PAC-Bayes surrogate † | 4.83% | 28.13% |
| model compression † | 3.45% | 35.06% |
| norm-based baseline | 3.14×10^8 % † | 3.80×10^21 % (ResNet18) †; 3.80×10^15 % for a CIFAR CNN |
| partition-based baseline | 86.5% (k-means on the training set), 138% (random) † | 90.3% (k-means), 111% (random) † |

Two caveats. Aggregator sites quote different figures (0.0744 for MNIST, 0.6858 for CIFAR-10; unverified). A third-party review flags the variant that optimizes disagreement on the available data (distillation) as invalid as written (unconfirmed). Even so, this paper is the researcher's idea, published and non-vacuous, at the price of unlabeled inputs.

**Other routes that bound the original network.**

* **RATT** (Garg, Balakrishnan, Kolter & Lipton, ICML 2021; venue and authors confirmed from the official repo): add unlabeled points with random labels to training; the error on those points certifies the clean risk. CIFAR-10 ResNet: certified accuracy 76.4% vs test 88.9%. CIFAR-10 MLP: 48.4% vs 54.2% (both from a snippet). The guarantee is provable for 0-1 ERM and linear models, and empirical for deep nets.
* **Than & Phan (2025):** a partition-based, data-dependent bound on unmodified models, claimed non-vacuous for 30 ImageNet models. The best partition uses K-means on validation inputs, and Bazinet et al. argue that the data-dependent partition violates the theorem's hypotheses.
* **Jiang, Nagarajan, Baek & Kolter (ICLR 2022):** disagreement between two SGD runs on unlabeled data approximates test error. This is an estimator, not a bound; Kirsch & Gal (TMLR 2022, unconfirmed) critique it. It also shows that independently retrained nets disagree on roughly a test-error fraction of inputs, so a useful g must be *derived from* f, not retrained independently.
* **Rosenfeld & Garg (NeurIPS 2023):** the out-of-distribution analogue.
* **Boix-Adserà (2024), "Towards a theory of model distillation":** defines PAC-distillation and gives polynomial-time distillation of networks with linear representations into decision trees or juntas, given query access and samples.

| paper | how d(f, g) is controlled | extra data |
|---|---|---|
| Kääriäinen 2005; Kääriäinen–Langford 2005 | binomial test on unlabeled data | unlabeled inputs |
| Suzuki et al. 2020 | local Rademacher complexity of the difference class | none (non-computable constants) |
| Daniely–Granot 2019 | approximation at every x | none (theory) |
| Hsu et al. 2021 | distillation distance on augmentation samples | synthetic inputs with bounded density ratio |
| Bazinet et al. 2026 | binomial / kl inversion on a disagreement set | about 18% of the training split, unlabeled |
| Neyshabur et al. 2018; Nagarajan–Kolter 2019 | margin plus worst-case or noise-resilience perturbation | none (vacuous) |
| Biggs–Guedj 2022 | exact identity: deterministic net = majority vote | none |

---

## 4. Stochastic vs deterministic: PAC-Bayes, MDL, flat minima, derandomization

**The noisy-network line.**

* **Hinton & van Camp (COLT 1993)** give the bits-back MDL objective: KL(Q‖P) plus expected misfit.
* **Hochreiter & Schmidhuber (1997)** argue that a box of weights that all fit the data has a short description.
* **Langford & Caruana (NIPS 2001)** turned this into the first nontrivial bounds for small stochastic nets, using per-weight sensitivity analysis.
* **Dziugaite & Roy (UAI 2017)** optimized a PAC-Bayes-kl bound over a diagonal Gaussian with the prior centred at the random initialization. They obtained 16–22% on binary MNIST across architectures (snippet), vacuous with random labels.
* **Pitas (ICML 2020)** ablated the recipe. Optimizing the mean-field (diagonal-Gaussian) posterior gives negligible gains, and the paper points to richer posteriors as the way forward. The further claim that centring the prior at the initialization, rather than at 0, is the dominant factor is unverified.

**Data-dependent priors.**

* Entropy-SGD as prior optimization (Dziugaite & Roy, ICML 2018), valid under an SGLD-stationarity assumption.
* Differentially private priors (Dziugaite & Roy, NeurIPS 2018).
* "On the role of data in PAC-Bayes bounds" (Dziugaite et al., AISTATS 2021): a prefix of the data sets the prior, and it is dropped from the empirical term.
* **Pérez-Ortiz, Rivasplata, Shawe-Taylor & Szepesvári (JMLR 22(227), 2021):** the tightest stochastic-net certificates on MNIST and CIFAR-10. The CIFAR-10 certificate is quoted inconsistently: about 16.7% as quoted by Lotfi et al., and about 18% at 14.6% test error per a third-party summary. Both are unverified. MNIST is about 1–2% with data-dependent priors (unverified).
* Recursive PAC-Bayes (Wu et al., NeurIPS 2024, unconfirmed) and example-difficulty bounds (Biggs & Guedj, AISTATS 2023, unconfirmed) push further.

In coding terms, these methods spend part of the labelled data on choosing the reference point, which in effect is a train/certify split.

**Derandomization to the deterministic f.** Four mechanisms exist:

1. **Margin plus worst-case perturbation.** McAllester 2003 for linear classifiers (unconfirmed). Neyshabur, Bhojanapalli & Srebro (ICLR 2018) bound the worst-case output change under weight noise by products of spectral norms; vacuous.
2. **Noise-resilience on training points, proved to generalize to test points.** Nagarajan & Kolter (ICLR 2019). This avoids spectral-norm products but is still numerically vacuous (unverified). Wei & Ma's all-layer margin (2019/2020, unconfirmed) is similar.
3. **Exact identities.** Biggs & Guedj (ICML 2022) use E[sign(w·x + noise)] = erf(·), so a deterministic one-hidden-layer erf or GELU net is exactly a PAC-Bayes majority vote. Non-vacuous for unmodified SGD nets. From the conference slides, with the column mapping inferred (unverified mapping):
   * MNIST erf: test 0.046, bound 0.772 data-free, 0.490 with a data-dependent prior.
   * MNIST GELU: test 0.043, bounds 0.693 / 0.293.
   * Binary MNIST erf: test 0.038, bounds 0.837 / 0.286.

   Biggs & Guedj (AISTATS 2022) add margin-based and partial derandomization; Letarte et al. (NeurIPS 2019) do the same for binary-activated aggregates.
4. **Disintegrated bounds.** Rivasplata et al. (NeurIPS 2020); Viallard et al. (MLJ 2024), with a Rényi-divergence term; Blanchard & Fleuret's Occam's hammer (COLT 2007). These certify one network drawn from Q. It is deterministic once drawn, but it is not the SGD output.

**Flatness caveats.**

* Dinh et al. (ICML 2017): rescaling makes parameter-space flatness arbitrary, so codes must respect symmetries.
* Jiang et al. (ICLR 2020): perturbation and PAC-Bayes measures correlate best with generalization (unverified).
* Andriushchenko et al. (ICML 2023): even adaptive sharpness correlates weakly or inconsistently in modern settings (unverified).
* Zhang, Reid, Valle-Pérez & Louis (2021, arXiv 2103.06219; content unconfirmed): argue that the prior volume of the *function* is the robust quantity.

**MDL without weights.** Blier & Ollivier (NeurIPS 2018) find variational weight codes poor, sometimes worse than uniform. Prequential codes are much shorter: about 4.10 kbit for MNIST labels at 99.5% accuracy (snippet). They need neither the weights nor the initialization, only a seeded training procedure. Online-to-batch conversion bounds an averaged predictor, not the final f.

**Limitations.**

* Nagarajan & Kolter (NeurIPS 2019) build GD settings where every two-sided uniform-convergence bound is nearly vacuous at small test error. An Occam bound over short g is uniform convergence over the code. So if f memorizes noise, either g copies the memorization (and costs about m bits), or g disagrees with f on training points, and then Pr[f ≠ g] needs fresh inputs or a proof.
* Livni & Moran (NeurIPS 2020, unconfirmed): some learnable classes admit no non-trivial PAC-Bayes bound.
* Gastpar, Nachum, Shafer & Weinberger (ICLR 2024, unconfirmed): bounds that depend only on (S, f) cannot be uniformly tight in overparameterized settings. Tightness has to come from the code matching structure in natural data.

---

## 5. Toy tasks, Boolean functions and simplicity bias

**The function-space prior.** Valle-Pérez, Camargo & Louis (ICLR 2019) define P(f) as the probability that random initialization implements f. For n = 7 Boolean nets, P(f) spans many orders of magnitude and tracks Lempel-Ziv complexity. Dingle, Camargo & Louis (Nat. Commun. 2018) give the AIT bound P(x) ≲ 2^{-aK̃(x) - b} behind this.

The realizable PAC-Bayes bound depends on ln(1/P(U)), where P(U) is the prior mass of functions consistent with S, so the initialization is integrated out rather than described. On MNIST and CIFAR, P(U) is estimated with a Gaussian-process (NNGP) approximation. That makes the certificate non-rigorous as computed, and the bounded predictor is the Bayesian posterior, not SGD's f. Valle-Pérez & Louis (2020) report non-vacuous bounds across 19 architectures (snippet; values unverified).

Mingard et al. support the link to SGD and to initialization:

* "Is SGD a Bayesian sampler? Well, almost" (JMLR 2021): SGD's function distribution correlates strongly with the NNGP posterior.
* "Neural networks are a priori biased towards Boolean functions with low entropy" (2019).
* "Deep neural networks have an inbuilt Occam's razor" (Nat. Commun. 2025): the bias depends on initialization scale; the chaotic regime loses it.

Similar results on random-initialization priors come from De Palma, Kiani & Lloyd (NeurIPS 2019, unconfirmed) and Teney et al., "Neural Redshift" (CVPR 2024, unconfirmed).

**What SGD learns on structured Boolean tasks.**

* Barak et al. (NeurIPS 2022): SGD learns k-sparse parities in about n^{O(k)} steps.
* Abbe, Boix-Adserà & Misiakiewicz: the merged-staircase property (COLT 2022) and leap complexity (COLT 2023). Two-layer nets learn low-dimensional-support functions in stages, and kernel or NTK methods cannot.
* Edelman et al. (NeurIPS 2023, unconfirmed): sparse initialization changes the trade-offs.
* Merrill et al. (unconfirmed): sparse subnetworks take over at grokking.
* Bhattamishra et al. (ACL 2023, unconfirmed): transformers have a low-sensitivity bias.

Together these predict that trained nets end close to k-juntas, which cost about log₂C(n,k) + 2^k bits. With n = 50, k = 3, δ = 0.01 and zero training error, that is about 22.3 bits, and the realizable Occam bound is about 20/m, i.e. 2.0% at m = 1000 (own arithmetic, re-checked; k is taken as fixed in advance). A 50-512-1 MLP at 8 bits per weight is vacuous at that m (own arithmetic).

**Compression on toy tasks.** DeMoss et al. (2024; Physica D 2025) track a rate–distortion description length of the weights through grokking. It rises during memorization and falls at generalization. A spectral-entropy regularizer compresses 30–40× better than naive baselines, but the resulting bounds only come "closest to" non-trivial (snippet). Lan, Chemla & Katzir (ACL 2024, unconfirmed) show that MDL-optimal nets for formal languages are not minima of standard objectives, so post-hoc compression of f may stall above the true minimal description length.

**Sample compression** describes g by the indices of training points rather than by its weights:

* Foundations: Littlestone & Warmuth 1986; Floyd & Warmuth 1995 (unconfirmed); Moran & Yehudayoff 2016 (size exp(d), too weak for nets).
* Pick-To-Learn (Paccagnan, Campi & Garatti, NeurIPS 2023), building on Campi & Garatti (JMLR 2023, unconfirmed).
* Real-valued losses (Bazinet et al., AISTATS 2025).
* Meta-learned decoders (Leblanc et al., ICML 2025).

The initialization and SGD randomness are free if they are seeded in advance. The certified model is the P2L output, which Bound to Disagree then transfers to f.

**Typical solutions and teacher size.** Buzaglo et al. (ICML 2024) show that random interpolators under a near-uniform prior over quantized weights generalize with sample complexity set by the size of a narrow teacher. Dziugaite & Roy (AISTATS 2025) give a short PAC-Bayes proof and define data complexity as the size of the smallest teacher. In both, the bound pays for the teacher's bits, not for the random student weights.

---

## 6. Proving performance and certifying closeness

**Compact proofs.** Gross, Agrawal, Kwa, Ong, Yip, Gibson, Noubir & Chan (arXiv 2406.11779, 2024; ICML 2024 Mechanistic Interpretability Workshop spotlight; confirmed from the official repo README, and no main-conference venue confirmed) prove accuracy lower bounds for 151 small (one-layer attention-only) transformers on Max-of-K under a known uniform distribution, using 102 proof strategies. The strategies range from brute force, which gives the exact accuracy, to mechanistic proofs. A compact proof is structurally a short g, the mechanism, plus a worst-case bound on the residual f − g. Its trade-off between length and tightness mirrors L(g) against Pr[f ≠ g]. The main obstacle they report is "compounding structureless noise" in the weights, whose worst-case bounds compound across layers. Follow-ups:

* Wu, Jaburi, Drori & Gross on group-operation networks (2024; ICLR 2025, unconfirmed; titles differ between versions).
* Yip, Agrawal, Chan & Gross, modular-addition MLPs read as numerical integration (2024, unconfirmed).

These need a known D_X and bound true accuracy directly; generalization never enters. They become relevant to the researcher when D_X is known but the target is not. ARC's heuristic arguments (Christiano, Neyman & Xu 2022, unconfirmed) give estimates without PAC guarantees. MIPS (Michaud et al. 2024) distils RNNs into Python programs and checks them only on test sequences.

**Weight-perturbation verification.**

* auto_LiRPA (Xu et al., NeurIPS 2020; confirmed from its documentation) propagates linear-relaxation bounds when weights as well as inputs lie in user-defined ranges, and ships a weight-perturbation certified-training example.
* Weng et al. (AAAI 2020, unconfirmed) handle single-layer weight perturbations.
* Tsai et al. (NeurIPS 2021, unconfirmed) link weight robustness to generalization through Rademacher complexity, not through Occam counting.

These tools output per-input certificates that hold for *all* weights in a set. SAM's motivating theorem (Foret et al., ICLR 2021) bounds population loss by max_{‖e‖≤ρ} L_S(w + e) plus a ‖w‖²/ρ² term, but the inner max is only approximated by gradient ascent. AWP (Wu et al., NeurIPS 2020) trains for weight robustness, with no bound.

**Differential and equivalence verification.**

* ReluDiff (Paulsen, Wang & Wang, ICSE 2020) proves sup_{x∈X} |f(x) − g(x)| ≤ ε for structurally similar f and g over an input region, by propagating the difference layer by layer.
* Later tools: NeuroDiff (ASE 2020, unconfirmed); QEBVerif for quantization error (CAV 2023, unconfirmed); MILP equivalence checking (Kleine Büning, Kern & Sinz 2020); Teuber et al.'s geometric path enumeration (arXiv 2112.06582, which proves ε-equivalence coNP-complete); SMT checkers (Eleftheriadis et al. 2022, unconfirmed); proof transfer to approximate nets (Ugare et al. 2022, unconfirmed); SAT encodings of binarized nets (Narodytska et al. 2018, unconfirmed).

A global top-1 equivalence certificate gives err(f) = err(g), so the Occam bound for g transfers to f with no extra data. This is practical for Boolean inputs up to roughly 20–30 bits and for low-dimensional inputs. Global bound propagation over [0,1]^784 is very loose. **The sweep found no paper that combines such verification with a generalization bound.**

---

## 7. Initialization: is it free?

**Yes, if it is fixed before the data.** Condition on θ₀: S is still i.i.d., so an Occam or PAC-Bayes bound holds for any code that depends on θ₀ (for example, one that describes θ − θ₀). Then average over θ₀. The literature uses this in several equivalent forms:

* Arora et al.'s helper string.
* PAC-Bayes priors centred at w₀ (Dziugaite & Roy 2017; Pérez-Ortiz et al. 2021).
* Reference matrices in norm bounds (Bartlett, Foster & Telgarsky 2017, unconfirmed; Neyshabur et al. ICLR 2019, unconfirmed; Long & Sedghi ICLR 2020, unconfirmed).
* Seeded subspaces (Li et al. 2018; Lotfi et al. 2022, checked in code).
* Shared seeds in MDL (Blier & Ollivier 2018).
* In information-theoretic bounds, I(S;W) ≤ I(S;W|U) when U is independent of S (Xu & Raginsky, NeurIPS 2017, unconfirmed), with CMI and f-CMI conditioning on training randomness (Steinke & Zakynthinou 2020; Harutyunyan et al. 2021; both unconfirmed).

Choosing the best of N seeds after training costs log₂N bits. Data-dependent reference points cost samples (Dziugaite et al. 2021).

**A zero initialization buys no bits, and it is likely a worse reference point.** Distance from w₀ predicts generalization better than distance from 0 (Nagarajan & Kolter 2017/2019, unconfirmed; Jiang et al. 2020). Pitas (ICML 2020) is reported to find that centring at the random initialization rather than 0 is what makes Dziugaite–Roy bounds non-vacuous, but this is unverified (see Section 4). Pure all-zero initialization is degenerate for MLPs: hidden units stay identical and gradients vanish. Deterministic schemes that work:

* ZerO initialization (Zhao, Schäfer & Anandkumar; arXiv 2110.12661, confirmed from the repo): identity, zeros and Hadamard transforms. It reportedly matches random initialization on ImageNet ResNets and follows low-rank, sparse trajectories (unverified).
* Fixup and ReZero (unconfirmed): residual branches start at zero.
* Antisymmetric initialization (Zhang, Xu, Luo & Ma 2020, unconfirmed): removes the random initial function f₀, which adds an initialization-induced error in the lazy regime.

These inits can only help through the solution training reaches, not through the cost of describing θ₀.

**The regime decides compressibility.**

* **Lazy/NTK training** (Chizat, Oyallon & Bach 2019, unconfirmed): weights move little in relative norm, but θ − θ₀ lies in the span of about m per-example gradients. That is dense and of dimension about m, so coding it is vacuous.
* **Rich, small-init training** produces incremental low-rank updates. Evidence: Saxe et al. 2014 for deep linear nets; Boix-Adserà et al. NeurIPS 2023 ("gradual rank increase"); Huh et al. TMLR 2023 (low-rank simplicity bias); Yang & Hu ICML 2021 (µP); LoRA, with ranks 1–8 sufficing. All unconfirmed.
* **Heavy-tailed SGD** yields prunable nets (Barsbey et al. 2021; Wan et al. ICML 2024, which proves compressibility for one-hidden-layer nets with heavy-tailed noise injection).

**Masks over a seeded initialization.**

* Lottery tickets (Frankle & Carbin 2019, unconfirmed).
* Supermasks (Zhou, Lan, Liu & Yosinski 2019): about 86% on MNIST with a mask on an untrained network (snippet).
* Edge-popup (Ramanujan et al. 2020, unconfirmed).

Strong-LTH theory (Malach et al. 2020; Pensia et al. 2020; Orseau et al. 2020; all unconfirmed) puts the mask cost at about (number of target parameters) × O(log(1/ε)) bits, the same order as quantizing the target directly. The sweep found **no non-vacuous supermask bound**.

**Theory from a typical initialization.**

* NTK analysis (Arora, Du, Hu, Li & Wang, ICML 2019, unconfirmed): with high probability over initialization, generalization is about √(2 yᵀ(H^∞)^{-1} y / m). The quantity yᵀ(H^∞)^{-1}y approximately upper-bounds the squared Frobenius distance moved from initialization. Rigorous, not numerically non-vacuous.
* Daniely–Granot ADL relative to initialization.
* Lei & Xie (2026): path-norm distance from initialization for shallow nets, with a matching lower bound; reports non-vacuous experiments (unverified).
* Ledent, Alves & Lei (NeurIPS 2025): rank-sparse bounds.
* Function-space priors (Section 5), basin-volume estimates under the initialization distribution (Scherlis & Belrose 2025, unconfirmed), and the local learning coefficient of singular learning theory and its MDL link (Lau et al. AISTATS 2025; Urdshals et al. 2025; both unconfirmed).

None of these has yet given tight bounds for a specific trained network.

---

## 8. Most recent work (2023–2026)

* **The surrogate route arrived.** Bound to Disagree (UAI 2026) is the first non-vacuous, computable certificate for unmodified MNIST and CIFAR-10 networks via (1), using unlabeled inputs.
* **LLMs, with bounds on the compressed or quantized model only:**
  * SubLoRA (Lotfi et al., ICML 2024): bits-per-dimension bounds of 12.12 / 11.96 / 11.95 for 124M / 354M / 458M models (third-party snippet, unverified), against a vacuous log₂V ≈ 15.6 (own arithmetic: log₂ 50257 = 15.62). Quantization alone, or LoRA alone, was vacuous.
  * Token-level martingale bounds (Lotfi et al., NeurIPS 2024): LLaMA2-70B at 2 bits gives BPD bound 6.14 and top-1 error bound 56.24% (table snippet; a review quotes 6.39 / 58.26%; unverified which is correct).
  * Freedman-type bounds along the compute-optimal frontier (Finzi et al., ICLR 2025): quantization error and loss variance both fall with scale.
  * Multi-task amortized intrinsic dimension (Zakerinia, Ghobadi & Lampert 2025).
  * RLVR fine-tuning with TinyLoRA (Zhu, Alur & Kang 2026, arXiv 2607.14506): bounds within 6–11% of fine-tuned accuracy (secondhand, unverified); rank-1 LoRA is vacuous.
* **Short learned objects on top of a free pretrained machine.** Discrete prompts for CLIP, coded by LM log-probability (Akinwande et al., ICLR 2024): ImageNet bound 0.319 vs test 0.256 (snippet). Informative priors keep prompt bounds non-vacuous at low data (Madras, Safyan & Zhang 2025): about 0.46 vs more than 0.8 (secondhand).
* **Sample compression for nets:** P2L (2023), real-valued losses (AISTATS 2025), hypernetwork decoders (ICML 2025).
* **Unmodified nets without compression:**
  * Than & Phan 2025 (validity disputed).
  * Rescaling-invariant PAC-Bayes (Rouchouse et al. 2025).
  * Sparsity-aware bounds (Muthukumar & Sulam, COLT 2023).
  * Rank-sparse bounds (Ledent et al. 2025).
  * Initialization-dependent shallow-net bounds (Lei & Xie 2026).
* **Theory:**
  * Variable-size compressibility (Sefidgaran & Zaidi 2023).
  * Teacher size (Buzaglo et al. 2024; Dziugaite & Roy 2025).
  * Limitation results (Gastpar et al. 2024, unconfirmed).
  * Wilson's ICML 2025 position paper, which states the "compressed file size explains generalization" view and acknowledges the bounds certify the compressed model.
* **Toy-task interpretability as certification:** compact proofs (2024) and follow-ups; complexity dynamics of grokking (2025); provable distillation (Boix-Adserà 2024); progressive distillation on sparse parity (Panigrahi et al. 2024).

---

## 9. What appears new in the planned constructions, and open gaps

The novelty verdicts below were formed **without new searches**, because the search budget was exhausted. "Apparently new" therefore means "not known to the sweep agents"; re-run targeted searches before claiming it.

* **(0) Core reduction (1), and (E) its unlabeled-data version: known.** The direct prior art is Kääriäinen 2005 and Kääriäinen & Langford 2005 (unlabeled data, non-neural classifiers), Hsu et al. 2021 (augmentation) and Bazinet et al. 2026 (unlabeled data). The project should cite Bazinet et al.'s 1.78% (sample compression) to 3.45% (model compression) on MNIST, and 17.4–35% on CIFAR-10, as the bar. Its distinctive claims must come from using no unlabeled data and no validation split.
* **(A) Certified-set transfer: the combination appears new.** A description σ defines a set K_σ of weights around a quantized g, and a sound interval or LiRPA certificate π_σ(x, y) implies h(x) = y for every h ∈ K_σ. The Occam bound is applied to 1 − π_σ on the training set, and f ∈ K_σ is checked on the weights. Each ingredient exists: weight-space boxes (flat minima), per-point robustness transferred from training data (Neyshabur 2018; Nagarajan–Kolter 2019; Wei–Ma, unconfirmed), and weight-perturbation LiRPA (auto_LiRPA; Weng 2020, unconfirmed). Expect reviewers to call it an Occam version of PAC-Bayes margin derandomization. The known obstacle is that worst-case sets overshoot the actual residual by a factor of about √d for dense updates.
* **(B) Known D_X on Boolean tasks: modest novelty.** The construction distils into a junta or sparse polynomial and computes Pr[f ≠ g] exactly or by free Monte Carlo. On a finite domain, the exceptions to exact equivalence can be appended to the code. The statistics are standard. The application to trained nets appears unreported, and it differs from Valle-Pérez et al., whose bound covers the Bayesian posterior.
* **(C) Initialization study: the principle is known (seeded initialization is free); the systematic study appears new.** No paper was found that measures the code length of θ − θ₀ as a function of initialization scale, lazy vs rich regime, or ZerO-type inits, and turns it into bounds. The planned kernel argument shows the contrast: under uniform Boolean inputs, a lazily trained net needs about Σ_{ℓ≤k} C(n,ℓ) Walsh coefficients, while a junta needs about log₂C(n,k) + 2^k bits. This matches the known kernel-versus-feature-learning separations (Abbe et al.).
* **(D) A fixed, data-independent input basis (2-D DCT) inside the certificate: apparently new.** The certificate splits the first-layer perturbation effect into in-subspace and out-of-subspace parts, evaluated per x. The closest work uses data-dependent subspaces (Arora 2018; Suzuki 2020) or frequency-domain weight compression without bounds (CNNpack, unconfirmed). A fixed DCT basis keeps the code data-free, whereas PCA would cost bits or a split.
* **(F) Dithered transfer: an apparently new combination, and the likely main novelty claim.** Public subtractive dither makes g − f i.i.d. uniform noise independent of f (Schuchman 1964; Gray & Stockham 1993; Ziv 1985; all unconfirmed). A per-input, typical-case certificate then covers the fixed deterministic f except on an η-fraction of inputs, by Fubini and Markov, from training data alone. Related work: noisy-posterior compression bounds (Zhou 2019), shared-randomness weight coding (MIRACLE; Agustsson & Theis 2020; both unconfirmed), lossy-compression bounds (Sefidgaran 2022), and disintegrated bounds and Occam's hammer. Those bound g or a sampled network, or are worst-case and vacuous (Neyshabur 2018; Nagarajan–Kolter 2019). Suggested checking searches: "dithered quantization generalization bound", "universal quantization PAC-Bayes", "Occam's hammer neural network".

**Open gaps the sweep found no paper filling:**

1. A non-vacuous bound for an unmodified, deterministic, multi-layer network on a real dataset that uses only the training set. The closest are Biggs–Guedj (one hidden layer only) and Than–Phan (uses validation inputs for its partition; validity disputed).
2. Occam bounds for SGD-trained nets on Boolean tasks with exact or free Monte Carlo disagreement.
3. Global equivalence or differential verification combined with an Occam bound.
4. Non-vacuous description-length bounds for supermasks.
5. A rigorous −log P_init(f) for a specific trained network.
6. A regime-resolved account of how compressible θ − θ₀ is.

---

## 10. Summary table

| paper | year | predictor bounded | extra data | dataset | best bound |
|---|---|---|---|---|---|
| Langford & Caruana | 2001 | stochastic net | none | small benchmarks | nontrivial (unverified) |
| Dziugaite & Roy | 2017 | stochastic (prior at init) | none | binary MNIST | 16–22% |
| Arora et al. | 2018 | compressed g | none | CIFAR-10 VGG-19 | about 10^5, vacuous |
| Neyshabur et al. (PAC-Bayes margin) | 2018 | original f | none | — | vacuous (unverified) |
| Zhou et al. | 2019 | noisy compressed g | none | MNIST / ImageNet | <46% / <96.5% top-1, <89% top-5 (96.5% recomputed from repo notes) |
| Nagarajan & Kolter (ICLR) | 2019 | original f | none | — | vacuous (unverified) |
| Valle-Pérez et al. | 2019 | Bayesian posterior | none (GP approx.) | Boolean, MNIST, CIFAR | non-vacuous (unverified) |
| Baykal et al. | 2019 | sparsified g | input batch | — | no numbers |
| Suzuki et al. | 2020 | original f | none | theory | — |
| Pitas | 2020 | stochastic | none | MNIST-type | ablation |
| Hsu et al. | 2021 | original f | augmentation inputs | MNIST, CIFAR-10 | vacuous (inferred) |
| RATT (Garg et al.) | 2021 | original f (modified training) | unlabeled inputs | CIFAR-10 ResNet | 23.6% error (test 11.1%) (snippet) |
| Pérez-Ortiz et al. | 2021 | stochastic | prior split | CIFAR-10 / MNIST | about 16.7% (as quoted by Lotfi) or about 18% (third-party summary) / about 1–2%; all unverified |
| Grønlund et al. | 2021 | original f (claimed) | none | — | withdrawn |
| Biggs & Guedj | 2022 | original shallow f | none / prior split | MNIST | 0.69–0.77 / 0.29–0.49 (slides, inferred mapping) |
| Lotfi et al. | 2022 | quantized subspace g | none / prior split / transfer | MNIST, FMNIST, CIFAR-10, CIFAR-100, ImageNet | 11.6% (9.0% transfer); 32.8% (28.2%); 58.2% (35.1% transfer, 16.6% data-dep.); 94.6% (81.3%); ImageNet 94.1% (unverified) |
| P2L as run by Bazinet et al. | 2023 / 2026 | P2L output | none | MNIST CNN | 3.06% (repo; Paccagnan et al.'s own numbers not checked) |
| Akinwande et al. | 2024 | prompted CLIP | none | ImageNet | 31.9% (test 25.6%) (snippet) |
| Gross et al. | 2024 | original f | known D_X | Max-of-K | exact by brute force |
| Lotfi et al. (SubLoRA) | 2024 | compressed LLM | none | OpenWebText | BPD 11.95–12.12 vs 15.6 (unverified) |
| Lotfi et al. (tokens) | 2024 | 2-bit quantized LLaMA2-70B | none | pretraining data | top-1 56.24%, BPD 6.14 (snippet; conflicting 58.26% / 6.39) |
| Finzi et al. | 2025 | quantized LLMs | none | Pythia | not verified |
| Than & Phan | 2025 | original f | validation inputs for partition | ImageNet | claimed non-vacuous; disputed |
| Rouchouse et al. | 2025 | stochastic | none | MNIST, CIFAR-10 | about 2× tighter (secondhand) |
| Bazinet et al. | 2026 | original f | about 18% unlabeled | MNIST CNN | 1.78% (SC, hard-coded in figure), 3.45% (MC) (repo) |
| Bazinet et al. | 2026 | original f | about 18% unlabeled (+ labelled coreset complement) | CIFAR-10 ResNet18 | 17.36% (coreset), 35.06% (MC) (repo) |
| Norm-based (Bazinet reimpl.) | 2026 | original f | none | MNIST / CIFAR-10 | 3.1×10^8 % / 3.8×10^21 % (repo) |
| Zhu, Alur & Kang | 2026 | compressed RLVR model | none | reasoning tasks | within 6–11% of accuracy (secondhand, unverified) |
| Naive Occam, 1 bit/weight | — | any net | none | MNIST 784-100-10 | about 0.60 exact kl; 0.92 linear relaxation (δ = 0.05; own arithmetic) |

---

## References

* Abbe, Boix-Adserà, Misiakiewicz. The merged-staircase property. COLT 2022. https://arxiv.org/abs/2202.08658
* Abbe, Boix-Adserà, Misiakiewicz. SGD learning on neural networks: leap complexity and saddle-to-saddle dynamics. COLT 2023. https://arxiv.org/abs/2302.11055
* Akinwande, Jiang, Sam, Kolter. Understanding prompt engineering may not require rethinking generalization. ICLR 2024. https://arxiv.org/abs/2310.03957
* Andriushchenko, Croce, Müller, Hein, Flammarion. A modern look at the relationship between sharpness and generalization. ICML 2023. https://github.com/tml-epfl/sharpness-vs-generalization
* Arora, Du, Hu, Li, Wang. Fine-grained analysis of optimization and generalization for overparameterized two-layer networks. ICML 2019 (unconfirmed). https://arxiv.org/abs/1901.08584
* Arora, Ge, Neyshabur, Zhang. Stronger generalization bounds for deep nets via a compression approach. ICML 2018. https://arxiv.org/abs/1802.05296
* Balcan, Blum. A discriminative model for semi-supervised learning. JACM 2010. https://ttic.edu/blum/Papers/labeled_unlabeled-2009.pdf
* Barak, Edelman, Goel, Kakade, Malach, Zhang. Hidden progress in deep learning: SGD learns parities near the computational limit. NeurIPS 2022. https://arxiv.org/abs/2207.08799
* Barsbey, Sefidgaran, Erdogdu, Richard, Şimşekli. Heavy tails in SGD and compressibility of overparametrized neural networks. NeurIPS 2021. https://arxiv.org/abs/2106.03795
* Bartlett, Foster, Telgarsky. Spectrally-normalized margin bounds for neural networks. NeurIPS 2017 (unconfirmed). https://arxiv.org/abs/1706.08498
* Baykal, Liebenwein, Gilitschenski, Feldman, Rus. Data-dependent coresets for compressing neural networks. ICLR 2019. https://arxiv.org/abs/1804.05345
* Bazinet, Zantedeschi, Germain. Bound to Disagree: generalization bounds via certifiable surrogates. UAI 2026 (confirmed from repo README; OpenReview id CZeG5HW1Y5; PMLR pages and arXiv id not re-verified). https://arxiv.org/abs/2602.23128 ; code https://github.com/GRAAL-Research/Bound-to-Disagree
* Bazinet, Zantedeschi, Germain. Sample compression unleashed. AISTATS 2025. https://arxiv.org/abs/2409.17932
* Biggs, Guedj. Non-vacuous generalisation bounds for shallow neural networks. ICML 2022. https://proceedings.mlr.press/v162/biggs22a.html
* Biggs, Guedj. On margins and derandomisation in PAC-Bayes. AISTATS 2022. https://arxiv.org/abs/2107.03955
* Blanchard, Fleuret. Occam's hammer. COLT 2007. https://arxiv.org/abs/math/0608713
* Blier, Ollivier. The description length of deep learning models. NeurIPS 2018. https://arxiv.org/abs/1802.07044
* Blumer, Ehrenfeucht, Haussler, Warmuth. Occam's razor. IPL 1987. https://portal.mardi4nfdi.de/wiki/Publication:1108056
* Boix-Adserà. Towards a theory of model distillation. 2024. https://arxiv.org/abs/2403.09053
* Buzaglo et al. How uniform random weights induce non-uniform bias: typical interpolating neural networks generalize with narrow teachers. ICML 2024. https://arxiv.org/abs/2402.06323
* Chizat, Oyallon, Bach. On lazy training in differentiable programming. NeurIPS 2019 (unconfirmed). https://arxiv.org/abs/1812.07956
* Daniely, Granot. Generalization bounds for neural networks via approximate description length. NeurIPS 2019. https://arxiv.org/abs/1910.05697
* Daniely, Katzhendler. Approximate description length, covering numbers, and VC dimension. 2022. https://arxiv.org/abs/2209.12882
* DeMoss, Sapora, Foerster, Hawes, Posner. The complexity dynamics of grokking. Physica D 2025. https://arxiv.org/abs/2412.09810
* Dingle, Camargo, Louis. Input–output maps are strongly biased towards simple outputs. Nat. Commun. 2018. https://pmc.ncbi.nlm.nih.gov/articles/PMC5823903/
* Dinh, Pascanu, Bengio, Bengio. Sharp minima can generalize for deep nets. ICML 2017. https://arxiv.org/abs/1703.04933
* Dziugaite, Roy. Computing nonvacuous generalization bounds for deep (stochastic) neural networks. UAI 2017. https://arxiv.org/abs/1703.11008
* Dziugaite, Roy. Entropy-SGD optimizes the prior of a PAC-Bayes bound. ICML 2018. https://arxiv.org/abs/1712.09376
* Dziugaite, Roy. Data-dependent PAC-Bayes priors via differential privacy. NeurIPS 2018. https://papers.nips.cc/paper/2018/hash/9a0ee0a9e7a42d2d69b8f86b3a0756b1-Abstract.html
* Dziugaite, Hsu, Gharbieh, Arpino, Roy. On the role of data in PAC-Bayes bounds. AISTATS 2021. https://proceedings.mlr.press/v130/karolina-dziugaite21a.html
* Dziugaite, Roy. The size of teachers as a measure of data complexity. AISTATS 2025. https://proceedings.mlr.press/v258/dziugaite25a.html
* Finzi et al. Compute-optimal LLMs provably generalize better with scale. ICLR 2025. https://arxiv.org/abs/2504.15208
* Foret, Kleiner, Mobahi, Neyshabur. Sharpness-aware minimization for efficiently improving generalization. ICLR 2021 (arXiv 2020; venue from memory). https://github.com/google-research/sam
* Garg, Balakrishnan, Kolter, Lipton. RATT: leveraging unlabeled data to guarantee generalization. ICML 2021 (confirmed from the official repo README). https://arxiv.org/abs/2105.00303 ; code https://github.com/acmi-lab/RATT_generalization_bound
* Gastpar, Nachum, Shafer, Weinberger. Fantastic generalization measures are nowhere to be found. ICLR 2024 (unconfirmed). https://arxiv.org/abs/2309.13658
* Goldblum, Finzi, Rowan, Wilson. The no free lunch theorem, Kolmogorov complexity, and the role of inductive biases in machine learning. ICML 2024. https://proceedings.mlr.press/v235/goldblum24a.html
* Gross, Agrawal, Kwa, Ong, Yip, Gibson, Noubir, Chan. Compact proofs of model performance via mechanistic interpretability. arXiv 2406.11779, 2024; ICML 2024 Mechanistic Interpretability Workshop (spotlight) (confirmed from the official repo README). https://arxiv.org/abs/2406.11779 ; code https://github.com/JasonGross/guarantees-based-mechanistic-interpretability
* Grønlund, Høgsgaard, Kamma, Larsen. Compression implies generalization (withdrawn). 2021. https://arxiv.org/abs/2106.07989
* Hinton, van Camp. Keeping neural networks simple by minimizing the description length of the weights. COLT 1993. https://www.cs.toronto.edu/~hinton/absps/colt93.pdf
* Hochreiter, Schmidhuber. Flat minima. Neural Computation 1997. https://www.bioinf.jku.at/publications/older/3304.pdf
* Hsu, Ji, Telgarsky, Wang. Generalization bounds via distillation. ICLR 2021. https://arxiv.org/abs/2104.05641
* Jiang, Neyshabur, Mobahi, Krishnan, Bengio. Fantastic generalization measures and where to find them. ICLR 2020. https://arxiv.org/abs/1912.02178
* Jiang, Nagarajan, Baek, Kolter. Assessing generalization of SGD via disagreement. ICLR 2022. https://arxiv.org/abs/2106.13799
* Kääriäinen. Generalization error bounds using unlabeled data. COLT 2005. https://link.springer.com/chapter/10.1007/11503415_9
* Kääriäinen, Langford. A comparison of tight generalization error bounds. ICML 2005. https://dev.icml.cc/Conferences/2005/proceedings/papers/052_Comparison_KaeaeriaeinenLangford.pdf
* Kirsch, Gal. A note on "Assessing generalization of SGD via disagreement". TMLR 2022 (unconfirmed, from memory).
* Kuhn, Lyle, Gomez, Rothfuss, Gal. Robustness to pruning predicts generalization. 2021. https://arxiv.org/abs/2103.06002
* Lacasse et al. PAC-Bayes bounds for the risk of the majority vote. NIPS 2006. https://proceedings.neurips.cc/paper/2006/hash/779efbd24d5a7e37ce8dc93e7c04d572-Abstract.html
* Langford, Caruana. (Not) bounding the true error. NIPS 2001. https://papers.nips.cc/paper/1968-not-bounding-the-true-error
* Langford. Tutorial on practical prediction theory for classification. JMLR 2005 (unconfirmed).
* Leblanc, Bazinet, D'Amours, Drouin, Germain. Generalization bounds via meta-learned model representations. ICML 2025. https://arxiv.org/abs/2410.13577
* Ledent, Alves, Lei. Generalization bounds for rank-sparse neural networks. NeurIPS 2025. https://arxiv.org/abs/2510.21945
* Lei, Xie. Towards initialization-dependent and non-vacuous bounds for shallow nets. 2026. https://arxiv.org/abs/2604.00505
* Letarte, Germain, Guedj, Laviolette. Dichotomize and generalize. NeurIPS 2019. https://proceedings.neurips.cc/paper/2019/hash/7ec3b3cf674f4f1d23e9d30c89426cce-Abstract.html
* Li, Farkhoor, Liu, Yosinski. Measuring the intrinsic dimension of objective landscapes. ICLR 2018. https://arxiv.org/abs/1804.08838 ; https://www.uber.com/blog/intrinsic-dimension/
* Li, Sun, Su, Suzuki, Huang. Understanding generalization in deep learning via tensor methods. AISTATS 2020. https://arxiv.org/abs/2001.05070
* Littlestone, Warmuth. Relating data compression and learnability. 1986. https://mwarmuth.bitbucket.io/pubs/J30.pdf
* Lotfi, Finzi, Kapoor, Potapczynski, Goldblum, Wilson. PAC-Bayes compression bounds so tight that they can explain generalization. NeurIPS 2022 (NeurIPS 35:31459–31473). https://arxiv.org/abs/2211.13609 ; https://github.com/activatedgeek/tight-pac-bayes
* Lotfi, Finzi, Kuang, Rudner, Goldblum, Wilson. Non-vacuous generalization bounds for large language models. ICML 2024. https://arxiv.org/abs/2312.17173
* Lotfi, Kuang, Amos, Goldblum, Finzi, Wilson. Unlocking tokens as data points for generalization bounds on larger language models. NeurIPS 2024. https://arxiv.org/abs/2407.18158
* Madani, Pennock, Flake. Co-validation. NIPS 2004. https://papers.neurips.cc/paper/2004/hash/92f54963fc39a9d87c2253186808ea61-Abstract.html
* Madras, Safyan, Zhang. Prompts generalize with low data. 2025. https://arxiv.org/abs/2510.08413
* Malach, Yehudai, Shalev-Shwartz, Shamir. Proving the lottery ticket hypothesis. ICML 2020 (unconfirmed). https://arxiv.org/abs/2002.00585
* Michaud et al. Opening the AI black box: program synthesis via mechanistic interpretability. 2024. https://github.com/ejmichaud/neural-verification
* Mingard et al. Neural networks are a priori biased towards Boolean functions with low entropy. 2019. https://arxiv.org/abs/1909.11522
* Mingard, Valle-Pérez, Skalse, Louis. Is SGD a Bayesian sampler? Well, almost. JMLR 2021. https://jmlr.org/papers/v22/20-676.html
* Mingard, Rees, Valle-Pérez, Louis. Deep neural networks have an inbuilt Occam's razor. Nat. Commun. 2025. https://arxiv.org/abs/2304.06670
* Moran, Yehudayoff. Sample compression schemes for VC classes. 2016. https://arxiv.org/abs/1503.06960
* Muthukumar, Sulam. Sparsity-aware generalization theory for deep neural networks. COLT 2023. https://arxiv.org/abs/2307.00426
* Nagarajan, Kolter. Deterministic PAC-Bayesian generalization bounds via generalizing noise-resilience. ICLR 2019. https://arxiv.org/abs/1905.13344
* Nagarajan, Kolter. Uniform convergence may be unable to explain generalization in deep learning. NeurIPS 2019. https://neurips.cc/virtual/2019/poster/13240
* Negrea, Dziugaite, Roy. In defense of uniform convergence. ICML 2020. https://proceedings.mlr.press/v119/negrea20a.html
* Neyshabur, Bhojanapalli, Srebro. A PAC-Bayesian approach to spectrally-normalized margin bounds. ICLR 2018. https://arxiv.org/abs/1707.09564
* Paccagnan, Campi, Garatti. The Pick-to-Learn algorithm. NeurIPS 2023. https://proceedings.neurips.cc/paper_files/paper/2023/hash/3a4f287883609241031e6818bd01133e-Abstract.html
* Panigrahi et al. Progressive distillation induces an implicit curriculum. 2024. https://arxiv.org/html/2410.05464v1
* Paulsen, Wang, Wang. ReluDiff: differential verification of deep neural networks. ICSE 2020. https://github.com/pauls658/ReluDiff-ICSE2020-Artifact
* Pérez-Ortiz, Rivasplata, Shawe-Taylor, Szepesvári. Tighter risk certificates for neural networks. JMLR 22(227):1–40, 2021. https://jmlr.org/papers/v22/20-879.html
* Pitas. Dissecting non-vacuous generalization bounds based on the mean-field approximation. ICML 2020. https://proceedings.mlr.press/v119/pitas20a.html
* Rivasplata, Kuzborskij, Szepesvári, Shawe-Taylor. PAC-Bayes analysis beyond the usual bounds. NeurIPS 2020. https://proceedings.neurips.cc/paper/2020/hash/c3992e9a68c5ae12bd18488bc579b30d-Abstract.html
* Rosenfeld, Garg. (Almost) provable error bounds under distribution shift via disagreement discrepancy. NeurIPS 2023. https://arxiv.org/abs/2306.00312
* Rouchouse, Gonon, Gribonval, Guedj. Non-vacuous generalization bounds: can rescaling invariances help? 2025. https://arxiv.org/abs/2509.26149
* Schuurmans, Southey. Metric-based methods for adaptive model selection and regularization. MLJ 2002. https://webdocs.cs.ualberta.ca/~daes/papers/mlj02.pdf
* Sefidgaran, Gohari, Richard, Şimşekli. Rate-distortion theoretic generalization bounds for stochastic learning algorithms. COLT 2022. https://arxiv.org/abs/2203.02474
* Sefidgaran, Zaidi. Data-dependent generalization bounds via variable-size compressibility. 2023. https://arxiv.org/abs/2303.05369
* Shin. Compressing heavy-tailed weight matrices for non-vacuous generalization bounds. 2021. https://arxiv.org/abs/2105.11025
* Suzuki, Abe, Nishimura. Compression based bound for non-compressed network. ICLR 2020. https://arxiv.org/abs/1909.11274
* Suzuki et al. Spectral pruning. IJCAI 2020. https://www.ijcai.org/proceedings/2020/393
* Teuber, Kleine Büning, Kern, Sinz. Geometric path enumeration for equivalence verification of neural networks. 2021. https://arxiv.org/abs/2112.06582
* Than, Phan. Non-vacuous generalization bounds for deep neural networks without any modification to the trained models. 2025. https://arxiv.org/abs/2503.07325
* Turner, Kabán. Approximability and generalisation. 2022. https://arxiv.org/abs/2203.07989
* Valle-Pérez, Camargo, Louis. Deep learning generalizes because the parameter-function map is biased towards simple functions. ICLR 2019. https://arxiv.org/abs/1805.08522
* Valle-Pérez, Louis. Generalization bounds for deep learning. 2020. https://arxiv.org/abs/2012.04115
* Viallard, Germain, Habrard, Morvant. A general framework for the practical disintegration of PAC-Bayesian bounds. MLJ 2024. https://arxiv.org/abs/2102.08649
* Wan, Barsbey, Zaidi, Şimşekli. Implicit compressibility of overparametrized neural networks trained with heavy-tailed SGD. ICML 2024. https://arxiv.org/abs/2306.08125
* Wilson. Position: deep learning is not so mysterious or different. ICML 2025. https://arxiv.org/abs/2503.02113
* Wu, Xia, Wang. Adversarial weight perturbation helps robust generalization. NeurIPS 2020. https://github.com/csdongxian/AWP
* Xu et al. Automatic perturbation analysis for scalable certified robustness and beyond (auto_LiRPA). NeurIPS 2020. https://github.com/Verified-Intelligence/auto_LiRPA
* Xu, Raginsky. Information-theoretic analysis of generalization capability of learning algorithms. NeurIPS 2017 (unconfirmed). https://arxiv.org/abs/1705.07809
* Zakerinia, Ghobadi, Lampert. From low intrinsic dimensionality to non-vacuous generalization bounds in deep multi-task learning. 2025. https://arxiv.org/abs/2501.19067
* Zhang, Reid, Valle-Pérez, Louis. Why flatness does and does not correlate with generalization. 2021. https://arxiv.org/pdf/2103.06219
* Zhao, Schäfer, Anandkumar. ZerO initialization. 2021/2022. http://arxiv.org/abs/2110.12661
* Zhou, Lan, Liu, Yosinski. Deconstructing lottery tickets: zeros, signs, and the supermask. NeurIPS 2019 (venue unconfirmed). https://arxiv.org/abs/1905.01067
* Zhou, Veitch, Austern, Adams, Orbanz. Non-vacuous generalization bounds at the ImageNet scale. ICLR 2019. https://arxiv.org/abs/1804.05862
* Zhu, Alur, Kang. Non-vacuous generalization bounds for reinforcement learning with verifiable rewards. 2026. https://arxiv.org/abs/2607.14506

*Cited only from memory (unconfirmed), no URL verified:* McAllester 1998/1999/2003; Seeger 2002; Maurer 2004; Floyd & Warmuth 1995; Campi & Garatti 2023; Livni & Moran 2020; Bartlett, Harvey, Liaw & Mehrabian 2019; Long & Sedghi 2020; Neyshabur et al. 2019; Wei & Ma 2019/2020; Weng et al. 2020; Tsai et al. 2021; NeuroDiff; QEBVerif; Eleftheriadis et al. 2022; Ugare et al. 2022; Narodytska et al. 2018; Wu, Jaburi, Drori & Gross 2024; Yip et al. 2024; Christiano, Neyman & Xu 2022; Saxe et al. 2014; Huh et al. 2023; Boix-Adserà et al. 2023; Yang & Hu 2021; LoRA (Hu et al. 2022); Fixup; ReZero; Zhang, Xu, Luo & Ma 2020; Frankle & Carbin 2019; Ramanujan et al. 2020; Pensia et al. 2020; Orseau et al. 2020; Steinke & Zakynthinou 2020; Harutyunyan et al. 2021; De Palma et al. 2019; Teney et al. 2024; Bhattamishra et al. 2023; Edelman et al. 2023; Merrill et al. 2023; Lan et al. 2024; Scherlis & Belrose 2025; Lau et al. 2025; Urdshals et al. 2025; Wu et al. (Recursive PAC-Bayes) 2024; Biggs & Guedj 2023; Schuchman 1964; Gray & Stockham 1993; Ziv 1985; Agustsson & Theis 2020; Havasi et al. (MIRACLE) 2019; CNNpack 2016; Kirsch & Gal 2022; Germain et al. 2015; Masegosa et al. 2020; Nagarajan & Kolter 2017.

Files referenced:

* The Bound-to-Disagree repository notebooks and configs, source of the "(repo)" numbers for Bazinet et al.: `/tmp/claude-0/-home-user-AI-works/72f9123c-7af5-51a5-9a6e-7922014be341/scratchpad/dl_btd/Bound-to-Disagree/result_plots/` and `.../Bound-to-Disagree/configs/dataset_configs/`.
* The tight-pac-bayes repository, source of the "(repo)" numbers for Lotfi et al. and Zhou et al.: `/tmp/claude-0/-home-user-AI-works/72f9123c-7af5-51a5-9a6e-7922014be341/scratchpad/dl_tpb/tight-pac-bayes/notebooks/plot_fig1_transfer.py`, `.../notebooks/replicate_imagenet_bound_error.py` and `.../pactl/bounds/get_bound_from_chk_v2.py`.
* The RATT repository README: `/tmp/claude-0/-home-user-AI-works/72f9123c-7af5-51a5-9a6e-7922014be341/scratchpad/dl_ratt/RATT_generalization_bound/README.md`.
* The compact-proofs repository README: `/tmp/claude-0/-home-user-AI-works/72f9123c-7af5-51a5-9a6e-7922014be341/scratchpad/dl_misc/gbmi/README.md`.
* The project theory notes, source of the descriptions of constructions A–F: `/home/user/AI-works/compression-generalization/theory/README.md`.
