# Tanh VC bound: reference and applicability record

The classical bound used in `source/critical-rate-sublevel-learning.tex` is:
for a fixed feedforward standard sigmoid architecture with W trainable real
weights and thresholds, the VC dimension is at most C W^4, with an absolute
constant C. No bound on parameter magnitudes or finite precision is assumed.
This deliberately loose bound is enough; sharper architecture-specific
bounds are unnecessary here.

Primary citation:

Marek Karpinski and Angus Macintyre, *Polynomial Bounds for VC Dimension of
Sigmoidal and General Pfaffian Neural Networks*, Journal of Computer and
System Sciences 54(1), 169–176 (1997).
DOI: https://doi.org/10.1006/jcss.1997.1477 .
The preliminary STOC 1995 version is titled *Polynomial bounds for VC
dimension of sigmoidal neural networks*, pp. 200–208.

Suggested bibliography entry:

```tex
\bibitem{karpinski1997}
M. Karpinski and A. Macintyre.
Polynomial bounds for VC dimension of sigmoidal and general Pfaffian
neural networks.
\emph{Journal of Computer and System Sciences} 54(1):169--176, 1997.
\href{https://doi.org/10.1006/jcss.1997.1477}{doi:10.1006/jcss.1997.1477}.
```

Direct primary-source retrieval from Bonn/Oxford/arXiv was unavailable in
this environment because its enforced outbound host policy omits those
hosts. This is a source-access limitation, not a mathematical gap or a
claim that the primary source was re-read here. The publication metadata
was independently located in a public reference listing. The exact
quartic bound was checked in two accessible independent secondary sources:

1. Neyshabur et al., *Geometry of Optimization and Implicit Regularization
   in Deep Learning*, arXiv:1705.03071, introduction footnote 1. The
   PeerRead text mirror says, with S the number of weights: “With sigmoidal
   activation it is between Ω(S²) and O(S⁴) (Anthony and Bartlett, 1999).”
   Full accessed text: https://github.com/allenai/PeerRead/blob/9bb37751781a900cee9e74ec3105997732c8e8e5/data/arxiv.cs.lg_2007-2017/train/parsed_pdfs/1705.03071.pdf.json .
   Local working copy: `neyshabur-vc-reference.json`.
2. Benny Avelin, *Deep Learning Lecture Series*, Session 2 slides. The
   sigmoid section explicitly states “(Karpinski & Macintyre 1994) Sigmoid
   activation” and `VC-dim <= C W^4`.
   https://github.com/BennyAvelin/DeepLearningLectureSeries/blob/f01ea266a1fef1b4024b7ce56e7d10b940126acd/slides_mini_course/Session2.ipynb .
   This secondary source uses the preprint date rather than the journal date.

## Applicability to the present representation

For a depth-L width-M tanh network, permit biases at every layer in the
containing class, even though the prior itself has no separate internal
biases. The identity tanh(t)=2 sigmoid(2t)-1 rewrites each tanh layer as
a sigmoid layer, with the additive terms absorbed in subsequent biases
and the linear readout. The number of parameters is at most
C(d+L+1)(M+1)^2. Thus the containing sign class has VC dimension at most
C(d+L+1)^4(M+1)^8, uniformly in depth.

On the finite input cube, Sauer counting gives log cardinality at most
(d+1) log(2) times the VC bound. This applies to arbitrary finite real
weights, including large weights from an ill-conditioned anchor Gram.
No product-norm bound is used or asserted. Since the architecture is
fixed after zero-padding to a common width, no uncontrolled union over
architectures is needed.
