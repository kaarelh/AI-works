# Actual activation-network Gaussian events

The modules `BatchTwoActivationFullNetworkEventsModel`, `Law`, `Diagonal`, `Measurable`, `Tail`, `Readout`, and the final `BatchTwoActivationFullNetworkEvents` prove the actual full-network probability ingredient used by the unified activation paper.

For every positive input dimension and width, every `σ>0` with `N*σ²≤1`, an activation vanishing at zero with a bounded Lipschitz constant, and the explicit polynomial width threshold, the final theorem

`NeuralGeneralization.BatchTwoActivation.ActivationGoodNetwork.compl_tail`

bounds the actual original product-Gaussian exceptional probability by `(2*(r+1)+1)*exp(-N*K)`. The good event includes the recursively defined Gaussian layer reconstruction events and physical readout energy at most `8K`.

The proof establishes the exact independent Gaussian source law at the first layer and every appended layer, validates each incoming variance budget by induction on the preceding good event, proves joint measurability of the adaptive exceptional sets, and integrates their conditional probabilities under the actual Gaussian layer split. No Gaussian approximation, conditional independence, or covariance budget is assumed at the main endpoint.

`ActivationGoodHidden.diagonal`, `ActivationGoodHidden.compl_tail`, `ActivationGoodNetwork.compl_tail`, and `measurableSet_ActivationGoodNetwork` all pass axiom checks with only `propext`, `Classical.choice`, and `Quot.sound`. This is a probability ingredient; the final paper theorem additionally uses the separately proved deterministic reconstruction, capacity, target mass, and posterior-learning arguments.
