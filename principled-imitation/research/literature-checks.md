# Literature checks made by the lead

## Li and Zhang, "Interactive and Hybrid Imitation Learning: Provably Beating Behavior Cloning" (arXiv:2412.07057)

Read on 16 Nov through the arXiv abstract page and the HTML full text of version 3 (Sections 1 to 6 verbatim; of the appendices only the first part of Appendix A).

Verified in the text:

* Authors Yichen Li and Chicheng Zhang (University of Arizona). arXiv comment: "42 pages, Accepted by NeurIPS 2025". Versions: 9 Dec 2024, 3 Dec 2025, 13 Jan 2026.
* Algorithm 1, "Stagger", described in the abstract as "a one-sample-per-round variant of DAgger". In each of N_int rounds the online learner supplies a policy π^n; the learner rolls it out and samples one state s^n from d^{π^n}, the distribution of a uniformly chosen step of the rollout; the expert is asked for its action at that state; the learner is updated with the log loss of that pair. The output is "a first-step uniform mixture" of the π^n: one of them is drawn uniformly and used for a whole episode. The standard online learner named is exponential weights over the class; its iterates are each-step mixtures (Definition 1: a new member is drawn at every step).
* Assumptions: a finite class B of stationary policies; Assumption 1, "The expert policy π^E is deterministic and is contained in the learner's policy class B"; μ-recoverability; episodes of fixed length H; total reward in [0, R].
* Theorem 3: with probability at least 1 − δ, J(π^E) − J(π̂) ≤ μ·H·(log B + 2 log(1/δ))/N_int.
* Section 3.1 on its relation to DAgger: "Similar to the original DAgger [Ross et al. (2011)], it requires base policy class B and reduces interactive imitation learning to no-regret online learning."
* On Foster, Block and Misra (2024): their result "establishes a sharp horizon-independent sample complexity bound of Behavior Cloning", counted in trajectories.

Not verified in the text (only seen in a summary; do not rely on the wording): the statement of the estimation bound as a separate theorem in Appendix B; what Appendix A says is open about first-step mixing with state-wise annotation and about lower bounds.

Consequences for the note:

* For a finite class and a deterministic human, Protocol R (rehearse with the per-call mixture, one uniformly chosen call per run put to the human, deploy the mixture of a uniformly chosen round for a whole run) is Stagger with exponential weights at learning rate 1, and the bound L·K ln 2/n on the expected number of unfaithful calls is the estimation step of Theorem 3 with log B in place of K ln 2. Their Theorem 3 with μ-recoverability is the recoverable form of low stakes: when one wrong step costs μ, the loss is μ·H·log B/N, which does not grow with H if μ is of order R/H.
* The note makes no claim about what that paper leaves open.
