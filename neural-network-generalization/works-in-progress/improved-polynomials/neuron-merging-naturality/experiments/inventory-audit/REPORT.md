# Exact checkpoint inventory and population-condition threshold

This audit reads existing checkpoints without changing weights. It is an
independent inventory check for the neuron-population experiment, not a test
of the statistical learning theorem or the full internal-noise restriction.

The replay script is `inventory.py`; `inventory.json` records checkpoint paths,
SHA-256 hashes, architecture, all readout-energy rational numerators and
denominators, and the exact largest allowed population count. Run with the
existing `/workspace/ai-works-env/venv/bin/python` environment.

## Exact automatic-membership test

For width N and stored readout vector v, let Ev=N sum_i v_i^2. If Ev>=N-1,
the condition q<=1+Ev allows q=N. Singleton groups are balanced and all
population projectors are the identity. The population-averaged network is
then exactly the original network, so its clipped-score discrepancy is
identically zero on every input. This is an exact certificate of membership
in the population-averaging support, independent of data, activation values,
and labels. It does not certify the optional separate internal-noise support.

The script evaluates every sum with Python `Fraction` on the exact stored
binary floating-point coordinates. No floating-point threshold decision is
used. The nearest checkpoint to the threshold has absolute gap about
0.113347, so none is a numerically marginal case.

| Existing checkpoint collection | Trained checkpoints | Automatic q=N membership | Need actual compression |
|---|---:|---:|---:|
| Round-two local archive | 168 | 98 | 70 |
| Five published round-three representatives | 5 | 5 | 0 |

Two additional round-two `teacher-d10-seed*.npz` files are random generating
teachers, not gradient-trained learner checkpoints; their energies are
recorded separately and excluded from these counts. Other NPZ files contain
attack witnesses, inputs, or matrix certificates and are not model weights.

Among the round-two models, 112 are Boolean problems with dimensions 8, 10,
or 12; 61 need actual compression, including 54 with zero recorded training
sign errors. Zero sign error alone does not establish the training-margin
condition. Of 56 digit models with dimension 64, only nine need compression;
all nine have recorded training sign errors, so these nine are not examples
of an eligible hard-margin interpolation learner.

The five published representatives have energies approximately:

| Model | Width | Ev |
|---|---:|---:|
| 105, MNIST even/odd | 256 | 564.4503 |
| 301, deep MNIST 3/8 | 128 | 259.4230 |
| 500, majority9 | 64 | 304.9332 |
| 504, deep majority9 | 64 | 157.0926 |
| 505, recursive majority9 | 64 | 156.6010 |

## Array conventions and experimental scope

Files contain `w0,...,wH`, with shapes `(d+1,N)`, `(N,N)` for each later
hidden matrix, and `(N,)` for the scalar readout. Row-batched propagation is
`h @ w`, so the matrices are transposed relative to the theorem's
column-vector notation. The input is augmented with a final constant one;
there are no separate hidden biases. All listed saved architectures have
constant hidden width.

Existing training uses readout initialization standard deviation
`1/sqrt(N)`, for which the initial expected Ev is N. This is already near
the automatic-membership threshold. The theorem's raw Gaussian mean-field
readout standard deviation is `t/N`, for which the expected Ev is `t^2<=1`.
The existing models therefore study ordinary gradient training, not
sampling from the theorem's prior or posterior. Round two uses mean squared
loss and ordinary L2 regularization; the published round-three models use
logistic loss with ordinary weight decay. Automatic membership of these
large-energy trained examples says little about compression of small-energy
networks selected by the mean-field posterior.

Any readout rescaling changes Ev quadratically as well as the output margin.
It can provide a useful diagnostic of redundant representation after output
normalization, but describes changed weights and must be reported separately
from the original-checkpoint support test.

## Signed grouping is a different condition

In the theorem's column-vector convention, let D_s be diagonal matrices with
entries in {-1,1}. Replacing

```
W1 by D1 W1,
Ws by Ds Ws D(s-1),
v by DH v
```

preserves the network's real-valued output exactly because tanh is odd. It
also preserves Ev, the raw independent centered Gaussian law, and normalized
Euclidean disturbance sizes. Ordinary balanced population averaging of the
transformed network corresponds, in the original coordinates, to signed
projectors Q_s=D_s P_s D_s.

The paper's original support uses unsigned P_s only. It has not been shown
to be invariant under arbitrary neuron-sign changes. Thus a successful
signed-grouping experiment establishes the signed/gauge-invariant variant,
not necessarily the original unsigned condition at the saved weights.
This distinction remains even though the uncompressed networks have
identical functions, Gaussian densities, and readout energies.

For both grouping variants, a failure of a heuristic clustering search is
not a proof that no admissible balanced partition exists. A successful
all-cube floating-point scan is stronger than a probe test but is still not
an interval or exact-arithmetic certificate of the tanh inequalities.
