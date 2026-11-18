# Sharp high-probability Bayesian oracles for row-contractive deep networks

[Paper](paper.pdf) · [Source](source/paper.tex) · [Independent review](verification/fresh-reader-independent-review.md)

One ordinary Bayesian posterior, trained on all observations at fixed Gaussian variance, has a coefficient-one high-probability risk bound against a same-depth smaller network. The prior uses signed beta-prime coordinates and conditions each internal row and the readout on absolute row sum at most one. First-layer rows are unrestricted for bounded activations such as tanh; ReLU additionally requires the first-row restriction.

For a teacher with V relevant hidden vertices, E internal/readout edges, J=E−V, and Q counting vertices, edges and first-layer coefficients, the remainder is

    O(sqrt(s) V/N) + O(s [J log N + Q log(resource*n) + log(1/delta)] / n),

where s=1+sigma². The theorem holds at every prescribed N at least twice the teacher's maximum layer width; N>=n absorbs its first remainder. All constants are independent of depth. It controls posterior-average population risk and therefore the posterior mean. There is no architecture mixture, validation, or temperature selection.

The norm restriction is part of the model. For ReLU, any teacher of absolute path variation at most one can be rescaled into the comparison class without increasing its graph. This paper does not establish the same sharp high-probability theorem for an unrestricted independent-coordinate prior.

The proof transfers an arbitrary posterior approximately halfway toward the teacher at additive KL cost. Downstream influences identify inexpensive neurons to overwrite, and the number of compatible marked-edge placements cancels the hidden-neuron location cost. A direct comparison law near the teacher and a doubled-temperature relative-loss inequality give the sharp population bound.

Run `./build.sh` to rebuild the PDF. The proof has received independent mathematical review; it has not been formalized in Lean.
