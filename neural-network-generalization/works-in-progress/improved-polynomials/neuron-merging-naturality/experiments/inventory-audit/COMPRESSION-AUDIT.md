# Independent compression implementation audit and interval certificates

The reviewed `compression.py` source has SHA-256
`5e69a054810fdd6ecb4c2088b1e142d7ef6c4820260a5d62fa4cf214ee35f76a`.
The matrix reduction, grouping constraints, and absence of target-label
information in grouping were checked independently. No substantive error was
found.

## Reduction algebra

In the saved row-vector convention, let B_s be the signed group-membership
matrix with one nonzero entry per row, and let K_s=B_s^T B_s be the diagonal
matrix of group sizes. The full-space projector is
`Q_s=B_s K_s^(-1) B_s^T`; ordinary unsigned averaging has all signs positive.
Writing compressed hidden row vectors as u_s, the reconstructed full state
is `u_s B_s^T`. The reduced weights therefore are

```
first:    W1 B1 K1^(-1)
internal: B(s-1)^T Ws Bs Ks^(-1)
readout:  BH^T v
```

These agree with the implementation. In particular, there is no missing
division by source-group size: the source multiplicity is already included
in the block sum. Oddness of tanh is what permits the signed version.

`reduced-formula-check.json` independently compares this reduced network with
the full projected network, for every combination of signed/unsigned and
balanced/unbalanced partitions, on an eight-point cube. The maximum float64
discrepancy in that numerical sanity check is below `9e-16`. This check is
distinct from the mathematical derivation and the interval checks below.

The Hungarian assignment in balanced clustering fixes each group's size to
floor(N/q) or ceil(N/q). The unbalanced variant repairs empty groups but does
not impose balance. All variants keep the same q at every hidden layer.
Input probes and original hidden activations determine groups. Target labels
are accessed only afterwards to report original training fit; they do not
choose partitions, signs, or compression witnesses. Witness selection uses
the discrepancy between a network and its own compressed predictions, not
target accuracy. Failure of these heuristics gives no nonexistence result.

The script computes raw q caps using float64. `raw-cap-audit.json` separately
compares those caps against exact rational sums of all saved readout
coordinates for every available result file; no discrepancy was found.

## Two exhaustive interval certificates

`verify_population_witnesses.py` reconstructs compressed coefficients by
explicit rational signed block sums of the exact stored binary weights.
These are then converted to outward-rounded `mpmath.iv` intervals at 50
decimal digits. Original and compressed networks are evaluated on all 256
dimension-eight Boolean inputs. At each point the two output intervals lie
on the same side of +1/2 or -1/2. Consequently their clipped outputs are
exactly equal and the global clipped discrepancy is zero.

| Checkpoint and witness | q / N | Certified minimum absolute output, across both networks | Scope |
|---|---:|---:|---|
| round2-000, raw unsigned balanced | 28 / 32 | >0.61609 | Original population support |
| fresh-002 majority SGD seed0, raw signed unbalanced | 24 / 32 | >0.80876 | Signed, unbalanced alternative only |

For both witnesses the energy constraint `q<=1+Ev` is verified exactly from
rational readout energy. Group sizes and signs are saved with the certificate.
The first witness additionally verifies all sizes are floor(N/q) or ceil(N/q)
and all signs are positive. Interval widths are below `3.2e-47`; these
certificates have substantial margin from the clipping thresholds.

Certificate JSON files include checkpoint and source-result SHA-256 hashes,
per-input signs and lower bounds, exact energy fractions, group witnesses,
arithmetic precision, and mpmath version. The resulting enclosures depend on
the implementation of mpmath directed rounding and its exponential function;
they are rigorous numerical interval checks in that sense, not Lean proofs.
They do not certify the separate internal-noise condition, or turn successful
heuristic searches into a statistical claim about the prevalence of support
membership. The second certificate cannot be counted as a certificate of
the paper's original unsigned balanced condition.

Replay with:

```
python verify_population_witnesses.py
```
