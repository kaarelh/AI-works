# Proxy training as conditioning

We train an LLM on a proxy and hope it generalizes to a true target. This project asks two things:
* Can proxy training be thought of as conditioning the model's implicit distribution over dispositions on a proxy property?
* What does that say about whether a loop of AI generations, each building the next one's graders, data and audits, keeps every generation on task as intended?

Claude (Anthropic) prepared this in response to questions from Kaarel Hänni (11 and 18 October 2026). It is a draft. Separate Claude instances did all the drafting, refereeing and checking; no human has checked the mathematics. Authorship and publication are for Kaarel Hänni to decide.

## Start here

1. **[The framing note](framing.md)** (round 1). It contains:
   * the view, spelled out, with a toy latent-variable model;
   * ten neighbouring literatures and how they relate;
   * the recommended frame, "teaching a latent-variable learner through a proxy channel";
   * 25 candidate research questions, pruned to 10.
2. **[Will the loop stay on task? Seven tools from a toy model](rsi-loop.md)** (round 2). It works through the task-AI RSI loop. In order:
   * a one-picture summary and a short answer;
   * seven tools:
     * what training can and cannot do;
     * the audit target;
     * the loop inequality;
     * the structure of generalization;
     * protocols and honesty;
     * the prior;
     * slop and observability;
   * a crux scorecard and design rules.

## Layout

| path | contents |
|---|---|
| `framing.md` | round-1 note |
| `checks/` | numerical checks of the four formulas in `framing.md` (Python 3 with numpy) |
| `rsi-loop.md` | round-2 synthesis note |
| `rsi-loop/drafts/` | nine theory sections (T1 to T4, G1 to G5), each with its adversarial referee report (`*-referee.md`) and revision notes |
| `rsi-loop/sim/` | simulation suite, per-section check scripts with their outputs, figures, and `reconciliation.md` comparing simulations with theory |
| `rsi-loop/lit/` | literature notes: oversight and RSI-loop theory (L1); empirical evidence for the loop's parameters (L2) |

Reproduce the simulations from `rsi-loop/sim/` with `bash run_all.sh` (Python 3 with numpy, scipy and matplotlib). Each section's check scripts run on their own; see `rsi-loop/sim/README.md`.

Working branch: `claude/beautiful-babbage-492kjb`. Nothing here stays only on the working branch.
