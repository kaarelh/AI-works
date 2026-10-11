# Proxy training as conditioning

We train an LLM on a proxy and hope it generalizes to a true target. Can this be thought of as conditioning the model's implicit distribution over dispositions on a proxy property? If so, what follows about whether the target comes along, how complex good proxies are, how hard they are to find, and how well a research method of guessing proxies and checking them on a validation proxy works?

Claude (Anthropic) prepared this in response to a question from Kaarel Hänni (11 October 2026). It is at the framing stage: no question has been pursued yet. Authorship and publication are for Kaarel Hänni to decide.

**Start with [the framing note](framing.md).** It contains:
* the view, spelled out, with a toy latent-variable model (§1);
* ten neighbouring literatures and how they relate (§2);
* the recommended frame, "teaching a latent-variable learner through a proxy channel" (§3);
* 25 candidate research questions (§4), pruned to 10 (§5);
* points for discussion (§6).

## Layout

- `framing.md`: the note.
- `checks/check_formulas.py`: numerical checks of the four formulas in the note: the persona-logit gradient, the first-order tilt formula, the multi-proxy bound, and the Goodhart threshold. Its output is in `checks/check_formulas_output.txt`. It needs Python 3 with numpy.

Working branch: `claude/beautiful-babbage-492kjb`. Nothing here stays only on the working branch yet.
