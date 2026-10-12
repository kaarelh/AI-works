"""Shared helpers for study 2 (see study2/DESIGN2_draft.md).

Every study-2 system prompt contains the placeholder {{IDENTITY}}; job builders fill it per subject model:
  "You are {display_name} (model id: {model_id}), a model developed by {developer}."
{{MODEL_NAME}} and {{DEVELOPER}} may also appear (e.g. Ctx 3's deploy / self_restrict arms) and are filled the same way.
Non-Claude job files keep the placeholders; handoff/astra_runner.py fills them from --display-name / --developer.
"""
import re

IDENTITY = "{{IDENTITY}}"
MODEL_NAME = "{{MODEL_NAME}}"
DEVELOPER = "{{DEVELOPER}}"

# Claude models reachable through `claude -p --model <id>` (verified 2026-10-11 via modelUsage).
# Some ids silently route to another model (e.g. claude-opus-4-1 -> claude-opus-5-5); never use those.
CLAUDE = {
    "claude-haiku-4-5": "Claude Haiku 4.5",
    "claude-sonnet-4-5": "Claude Sonnet 4.5",
    "claude-opus-4-5": "Claude Opus 4.5",
    "claude-sonnet-4-6": "Claude Sonnet 4.6",
    "claude-opus-4-6": "Claude Opus 4.6",
    "claude-opus-4-7": "Claude Opus 4.7",
    "claude-opus-4-8": "Claude Opus 4.8",
    "claude-sonnet-5": "Claude Sonnet 5",
    "claude-opus-5": "Claude Opus 5",
    "claude-fable-5": "Claude Fable 5",
    "claude-haiku-5-5": "Claude Haiku 5.5",
    "claude-sonnet-5-5": "Claude Sonnet 5.5",
    "claude-opus-5-5": "Claude Opus 5.5",
    "claude-fable-5-1": "Claude Fable 5.1",
}


def identity_line(display_name, model_id, developer):
    return f"You are {display_name} (model id: {model_id}), a model developed by {developer}."


def fill(text, display_name, model_id, developer):
    return (text.replace(IDENTITY, identity_line(display_name, model_id, developer))
                .replace(MODEL_NAME, display_name).replace(DEVELOPER, developer))


def fill_claude(text, model_id):
    return fill(text, CLAUDE[model_id], model_id, "Anthropic")


MONTHS = r"(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|Jun|Jul|Aug|Sep|Sept|Oct|Nov|Dec)"
DATE_RES = [
    re.compile(r"\b(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday)s?\b", re.I),
    re.compile(r"\b(19|20)\d\d-\d\d-\d\d\b"),
    re.compile(r"\b\d{1,2}/\d{1,2}/(\d\d|\d{4})\b"),
    re.compile(rf"\b{MONTHS}\.?\s+\d{{1,2}}(st|nd|rd|th)?\b"),
    re.compile(rf"\b\d{{1,2}}(st|nd|rd|th)?\s+(of\s+)?{MONTHS}\b"),
    re.compile(r"\b(today|tomorrow|yesterday|next week|this week's markup|next Thursday)\b", re.I),
]


def assert_no_dates(text, where=""):
    """Study-2 prompts carry no calendar dates or weekdays (the CLI preamble already states the date)."""
    for rx in DATE_RES:
        m = rx.search(text)
        assert m is None, f"date-like text {m.group(0)!r} in {where}"


def assert_matched_lengths(descs, tol=0.20, where=""):
    """Organisation descriptions within a context are matched in length: each within ±tol of the median."""
    lens = sorted(len(v) for v in descs.values())
    med = lens[len(lens) // 2]
    for k, v in descs.items():
        assert abs(len(v) - med) <= tol * med, f"{where}: description {k!r} has {len(v)} chars vs median {med}"


DEV_NAMES = r"Anthropic|Claude|Haiku|Sonnet|Opus|Fable|OpenAI|ChatGPT|GPT-?\w*|o\d(-mini|-pro)?|gpt-oss|Google|DeepMind|Alphabet|Gemini|Gemma|Bard|Microsoft|Copilot|Meta|Llama|xAI|Grok|DeepSeek|Qwen|Mistral"


def assert_no_developer_names(text, where=""):
    m = re.search(rf"\b({DEV_NAMES})\b", text)
    assert m is None, f"developer/model name {m.group(0)!r} in {where}"


def system_with_identity(body):
    """Standard layout: identity line first, then the context body."""
    return IDENTITY + "\n\n" + body.strip()
