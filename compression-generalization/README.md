# Compression bounds for trained networks, without validation data

Notes by Claude, prompted by Kaarel Hänni. Research note, 27 October 2026; not reviewed by a human. The proofs and their implementation were checked by AI referees ([`verification/`](verification/)), not by humans.

**Question.** If a trained network $f$ can be compressed, that is, if a network $g$ with a short description (a code of $L$ bits fixed in advance) agrees with $f$ on most inputs, then

$$\mathrm{err}(f)\ \le\ \mathrm{err}(g)+\Pr_x[f(x)\ne g(x)],$$

and a Chernoff/Occam union bound over all $L$-bit descriptions bounds $\mathrm{err}(g)$ by its training error plus about $L\ln 2/m$. So a generalization bound for $f$, with no validation set, reduces to compressing $f$ and certifying the closeness term. (1) Has this been explored? (2) Is there a compression scheme that gives interesting bounds for real networks (Boolean toy tasks, standard datasets), beating parameter counting? (3) Does the random initialization have to be described? Would a zero initialization help? What can be said from a typical initialization?

**Paper:** [`paper/main.pdf`](paper/main.pdf) (LaTeX sources in [`paper/`](paper/)). **Literature review:** [`literature.md`](literature.md). **Theory note:** [`theory/README.md`](theory/README.md).

## Short answers

**(1) Prior work.** The idea is known in two halves.
- *Bounds on a compressed network* $g$ (Arora et al. 2018; Zhou et al. 2019; Lotfi et al. 2022, 11.6% on MNIST) bound $g$, not the trained $f$.
- *The full reduction*, with $\Pr[f\ne g]$ estimated on **unlabeled** inputs, goes back to Kääriäinen (2005) and was carried out for modern networks by Bazinet, Zantedeschi & Germain, *Bound to Disagree* (UAI 2026). Their repository reports 1.8–3.5% for an MNIST CNN and 17–35% for a CIFAR-10 ResNet-18. Hsu, Ji, Telgarsky & Wang (2021) use augmentation samples instead.
- *With no extra data*, the derandomized PAC-Bayes bounds of Neyshabur et al. (2018) and Nagarajan & Kolter (2019) bound $f$ but are vacuous. Biggs & Guedj (2022) get non-vacuous bounds for one-hidden-layer erf/GELU networks through an exact majority-vote identity.

What seems new here:
- clean bounds with a known input distribution on Boolean tasks, and distribution-free bounds by exact equivalence;
- a *dithered transfer theorem*, which bounds the original network from the training set alone and removes the $\sqrt d$ loss of worst-case perturbation sets;
- a quantitative study of how the initialization enters the description length.

**(2) Compression schemes and bounds.** Parameter-counting (32 bits per weight) and VC bounds are 1.0 for every network below.
- **Boolean tasks, known (uniform) input distribution.** The disagreement term is free. A 289,281-parameter MLP on 50 bits compresses into a 28–100-bit truth table on the relevant coordinates, a threshold function, or a small quantized network distilled from $f$. The bound tracks $f$'s test error along the whole learning curve ([table](results/boolean/summary_n50.md), [figure](figures/boolean_n50.png)):
  - within 0.005 at $m=16000$;
  - 0.30 against 0.29 for networks that have only partly learned a 3-parity;
  - 0.17 against 0.14 for networks that **interpolate 10% label noise** ($g$ is the clean rule, and $\Pr[f\ne g]$ measures the damage memorization does).
- **Boolean tasks, any input distribution.** On 20 bits the compressed networks agree with $f$ on all $2^{20}$ inputs, so the bound holds for every input distribution. For example, 0.0065 for 3-parity at $m=4000$ ([table](results/boolean/summary_n20.md)).
- **MNIST / Fashion-MNIST with unlabeled inputs** (the setting of Bound to Disagree): see [summary](results/summary_t2.md).
- **MNIST / Fashion-MNIST from the training set alone.** No validation data, no unlabeled data, no knowledge of the input distribution: a deterministic bound on the ReLU network that was trained ([summary](results/summary_t3.md), [figure](figures/t3_mnist.png)).
  - Non-vacuous (below chance, 0.9) for narrow networks: 0.44 with 8 hidden units (test error 7.0%), 0.55 with 16.
  - Vacuous for wide dense ones: 0.87 at 64 units, 0.97 at 128. The certificate needs the weights described to the precision the margins demand, about 3 bits per first-layer coefficient.
  - Networks whose first-layer update is sparse in a DCT basis: see the summary.
  - Worst-case weight sets would need about 8 bits per coefficient ([probe](results/mnist/t3_worstcase_probe.txt)).

**(3) Initialization.**
- *It costs nothing.* A code may depend on any randomness drawn independently of the data, so a seeded random initialization is free. Even a seed that had to be sent is 32 bits.
- *Function-space codecs never touch it.* The Boolean truth tables and distilled students do not refer to $f$'s 289k random initial weights.
- *Weight-space codecs*, which training-data-only bounds need, code the update relative to the initialization. In the dithered code this barely matters, since coding relative to zero costs about as much. A deterministic DCT initialization gave a more compressible network (65k vs 84k bits). Exact zero initialization does not train a ReLU MLP. See the [init study](results/summary_init.md).
- *From a typical initialization.* Wide networks approach a deterministic limit, and the initialization contributes only fluctuations. In the linearized (kernel) regime, the eigenbasis of the initial kernel is free. Coding the update in it gives a codec whose cost reproduces the $n^k$ sample complexity of kernel methods on degree-$k$ targets, whereas a network that has found the relevant coordinates compresses to a junta. In the description-length picture, feature learning is what makes networks short.

## How the training-data-only bound works

Compress $f$ by **subtractive dithered quantization** with public randomness $\xi$ drawn after training. The decoder knows $\xi$ and the integers $K=\mathrm{round}(a/s+\xi)$, so $g$ costs $L(K)$ bits, and $g-f$ is independent uniform noise whatever $f$ is. At each input, the margin difference between $g$ and $f$ is then sub-Gaussian, with a variance proxy and a bias computable from $g$ alone (Lemma 7). The certificate "$g$'s margin exceeds $t\sqrt{2P}+B$" is a function of the description, so its failure rate on the training set transfers to the population by the Occam bound, and on certified inputs $f$ itself is correct except with probability $\eta$ over the dither. Result (Theorem 5): with probability $1-\delta-\delta'$,

$$\mathrm{err}(f)\le \overline{\mathrm{Bin}}\big(\#\text{uncertified training points},\,m,\,\delta 2^{-L(g)}\big)+\eta/\delta'.$$

A worst-case version (certify every network in a box or ball around $g$) pays a factor $\sqrt d$ and is vacuous; dithering replaces the $\ell_1$ worst case by an $\ell_2$ typical case.

## Contents

- `paper/`: the paper (`main.pdf`) and its LaTeX sources; `paper/tables/` is generated by `code/experiments/make_tables.py`.
- `theory/README.md`: statements and proofs (Occam bound, the reduction, distribution-free corollary, certified and dithered transfer, the one-hidden-layer certificate, the initialization lemma, the init-kernel codec).
- `code/cgb/`: the implementation.
  - `bounds.py`: exact binomial tail inversion in log space, Occam and Clopper–Pearson bounds.
  - `coding.py`: Kraft-valid code lengths (Elias-δ, enumerative subsets, adaptive KT).
  - `boolean.py`, `codec.py`: function-space codecs for Boolean tasks (truth tables, distilled quantized students), the reduction and the distribution-free bound.
  - `coded.py`: init-relative, DCT-coded quantized networks for images (unlabeled-data bounds).
  - `dither.py`: dithered compression and the Lemma 7 certificate.
  - `certify.py`: worst-case weight-set certificates (Theorem 4).
  - `models.py`, `data.py`: networks, training, datasets.
- `code/experiments/`: one script per experiment, the grid and job runners, analyses, the table generator, and `accounting.py` (the design charge: every reported bound pays 4 bits and takes the disagreement term at δ/16 for the codec designs tried on the same data during development).
- `code/tests/`: soundness tests (certificates against sampled weight sets; Monte Carlo calibration of the Lemma 7 constants; Kraft checks; tail inversions).
- `results/`: raw JSON lines for every run and Markdown summaries. `figures/`: figures.
- `verification/`: the AI referee record. `literature.md`: the literature review (citations marked where unconfirmed).

Reproduce: `cd code/experiments`, then `python3 grid.py bool_n50`, `python3 grid.py bool_n20`, `python3 mnist_t3.py ...`, `python3 mnist_t3_sparse.py ...`, `python3 mnist_run.py ...`, `python3 init_kernel.py ...`, `python3 boolean_t3.py ...` (the exact command lines are in the `results/*/` JSON rows), then `python3 analyze_boolean.py n50`, `python3 analyze_t3_init.py`, `python3 make_tables.py`. Datasets: MNIST and Fashion-MNIST in idx format under `$CGB_DATA` (default `/home/user/data`). CPU only; the whole study took about six hours on 4 cores.

All paths in this folder are published; nothing stays only on the working branch `claude/friendly-wright-x6ajj5`.
