"""Build study-2 job files (design §5, §6) from the context modules src/s2_<context>.py.

Claude jobs (placeholders filled per model with s2common.fill_claude):
  python3 src/make_jobs2.py --context analysis --stage main --models claude-haiku-4-5,claude-opus-5-5 \\
      [--arms a,b] [--reps 0-11] [--per-arm N] [--timeout SEC] --out runs2/jobs_analysis_main.jsonl
  Each job keeps every unit field (unit, context, arm, rep, meta) plus id = <unit>__<model>, model, study = 2.
  Replicate r finishes before r+1, with a deterministic shuffle within a replicate.
Model-free files for astra_runner.py (Route A or the Astra handoff):
  python3 src/make_jobs2.py --context analysis --stage main --astra [--canaries 5] [--prefix s2a] \\
      [--keymap study2/astra_keymap_s2_ctx1.json] --out handoff/s2_ctx1.jsonl
  Lines are {id, block, system, prompt}: opaque id <prefix>_NNNNNN (default prefix from the file name), block =
  replicate, placeholders left for the runner, ordered by block with a deterministic shuffle within a block.
  A module may expose astra_units(stage) for non-Claude replicate counts (e.g. Ctx 2b: 16 reps); --astra uses it
  in place of units(stage). Canary pairs repeat a line under a second id in the same block. The id -> unit/arm/meta
  map goes to the keymap (default study2/astra_keymap_<file stem>.json), which must stay outside the handoff
  directory (opacity is against casual reading only: the code that rebuilds the map is in the repo). MANIFEST.sha256
  in the output directory is rewritten to cover the new file, handoff/astra_runner.py and every file it already
  listed, with repo-root-relative paths (check with `sha256sum -c <dir>/MANIFEST.sha256` from the repo root).
Unit sources (default: the module's units(stage)); they can be combined:
  --probes     the module's probes(stage), e.g. Ctx 4 credence probes (meta["probe"] is set if missing)
  --realism    s2_judge.realism_units: --n-realism per arm (default 2)
  --identity   s2_judge.identity_units: --n-identity per context (default 3) under the context's default arm,
               or under each arm given with --arms
--context takes a comma list (e.g. for a smoke file); --arms entries are "arm" or "context:arm".

  python3 src/make_jobs2.py --selftest     # exercises everything on an in-memory fake module
"""
import argparse
import hashlib
import importlib
import json
import os
import random
import re
import shutil
import subprocess
import sys
import tempfile
import types
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import s2_judge  # noqa: E402
from s2common import (CLAUDE, DEVELOPER, IDENTITY, MODEL_NAME, assert_no_dates, fill_claude,  # noqa: E402
                      system_with_identity)

HERE = os.path.dirname(os.path.abspath(__file__))
PROJECT = os.path.dirname(HERE)
RUNNER = os.path.join(PROJECT, "handoff", "astra_runner.py")
UNIT_KEYS = ("unit", "context", "arm", "rep", "system", "prompt", "meta")
PLACEHOLDERS = (IDENTITY, MODEL_NAME, DEVELOPER)
FILLED = re.compile(r"\(model id: [^)\n]+\), a model developed by ")  # an identity line already filled in
MODULES = {}  # context -> module; the selftest registers its fake module here


def load(context):
    if context not in MODULES:
        MODULES[context] = importlib.import_module("s2_" + context)
    return MODULES[context]


def rep_range(s):
    out = []
    for part in s.split(","):
        if "-" in part:
            a, b = part.split("-")
            out += range(int(a), int(b) + 1)
        else:
            out.append(int(part))
    return out


def parse_arms(spec, contexts):
    """[(context or None, arm)] from "arm" / "context:arm" entries; None means every arm."""
    if not spec:
        return None
    out = []
    for e in spec.split(","):
        c, _, arm = e.rpartition(":")
        assert not c or c in contexts, f"--arms {e}: context {c!r} not in --context"
        out.append((c or None, arm))
    return out


def arm_wanted(want, context, arm):
    return want is None or (None, arm) in want or (context, arm) in want


def check_unit(u):
    assert set(UNIT_KEYS) <= set(u), f"{u.get('unit')}: missing {set(UNIT_KEYS) - set(u)}"
    assert isinstance(u["rep"], int), f"{u['unit']}: rep must be int"
    assert u["system"].startswith(IDENTITY), f"{u['unit']}: system prompt must start with {IDENTITY}"
    assert not FILLED.search(u["system"] + u["prompt"]), f"{u['unit']}: identity already filled in the template"
    assert_no_dates(u["system"], f"{u['unit']} system")
    assert_no_dates(u["prompt"], f"{u['unit']} prompt")
    json.dumps(u["meta"])


def collect(contexts, stage, probes=False, realism=False, identity=False, arms=None, reps=None, per_arm=None,
            n_realism=2, n_identity=3, astra=False):
    want = parse_arms(arms, contexts)
    units, matched = [], set()
    for c in contexts:
        mod = load(c)
        src = []
        if not (probes or realism or identity):
            src += mod.astra_units(stage) if astra and hasattr(mod, "astra_units") else mod.units(stage)
        if probes:
            assert hasattr(mod, "probes"), f"s2_{c} has no probes(stage)"
            src += [dict(u, meta=dict({"probe": "probe"}, **(u.get("meta") or {}))) for u in mod.probes(stage)]
        if realism:
            src += s2_judge.realism_units(mod, stage, n_realism)
        if identity:
            id_arms = [a for a in mod.ARMS if arm_wanted(want, c, a)] if want else None
            src += s2_judge.identity_units(mod, stage, n_identity, id_arms)
        for u in src:
            assert u["context"] == c, f"{u['unit']}: context {u['context']!r} != {c!r}"
            if not arm_wanted(want, c, u["arm"]):
                continue
            matched |= {(None, u["arm"]), (c, u["arm"])}
            if reps is not None and u["rep"] not in reps:
                continue
            units.append(u)
    missing = [e for e in want or [] if e not in matched]
    assert not missing, f"--arms entries match no unit: {missing}"
    if per_arm:
        seen = Counter()
        keep = []
        for u in sorted(units, key=lambda u: u["rep"]):
            if seen[u["context"], u["arm"]] < per_arm:
                seen[u["context"], u["arm"]] += 1
                keep.append(u)
        units = keep
    assert units, "no units selected"
    ids = Counter(u["unit"] for u in units)
    assert max(ids.values()) == 1, f"duplicate unit ids: {[k for k, v in ids.items() if v > 1][:5]}"
    for u in units:
        check_unit(u)
    return units


def shuffle_seed(*parts):
    return int(hashlib.sha1("|".join(map(str, parts)).encode()).hexdigest()[:8], 16)


def block_order(items, seed):
    """Sort by replicate (block); deterministic shuffle within a block."""
    rng = random.Random(seed)
    keys = [(it["rep"], rng.random()) for it in items]
    return [items[i] for i in sorted(range(len(items)), key=lambda i: keys[i])]


def claude_jobs(units, models, timeout=None, seed=0):
    for m in models:
        assert m in CLAUDE, f"unknown Claude model {m!r} (see s2common.CLAUDE)"
    jobs = []
    for u in units:
        for m in models:
            j = dict({k: u[k] for k in UNIT_KEYS}, id=f"{u['unit']}__{m}", model=m, study=2,
                     system=fill_claude(u["system"], m), prompt=fill_claude(u["prompt"], m))
            if timeout:
                j["timeout"] = timeout
            assert not any(p in j["system"] + j["prompt"] for p in PLACEHOLDERS), j["id"]
            assert j["system"].startswith(f"You are {CLAUDE[m]} (model id: {m}), a model developed by Anthropic."), j["id"]
            jobs.append(j)
    return block_order(jobs, seed)


def astra_lines(units, prefix, canaries=0, seed=0):
    """(lines, keymap ids): opaque ids in file order, canary copies placed at random in the same block."""
    rng = random.Random(seed + 1)
    items = [dict(u, canary_of=None) for u in block_order(units, seed)]
    if canaries:
        by_block = {}
        for i, u in enumerate(items):
            by_block.setdefault(u["rep"], []).append(i)
        blocks = sorted(by_block)
        picks = [blocks[round(k * (len(blocks) - 1) / max(1, canaries - 1))] for k in range(canaries)] \
            if canaries <= len(blocks) else [rng.choice(blocks) for _ in range(canaries)]
        used = set()
        for b in picks:
            i = rng.choice([i for i in by_block[b] if i not in used])
            used.add(i)
            items[i]["canary_of"] = "pair"
        out = []
        for b in blocks:
            blk = [items[i] for i in by_block[b]]
            for u in [u for u in blk if u["canary_of"] == "pair"]:
                blk.insert(rng.randrange(len(blk) + 1), dict(u, canary_of="copy"))
            out += blk
        items = out
    lines, ids, first = [], {}, {}
    for n, u in enumerate(items):
        oid = f"{prefix}_{n:06d}"
        lines.append(dict(id=oid, block=u["rep"], system=u["system"], prompt=u["prompt"]))
        ids[oid] = dict(unit=u["unit"], context=u["context"], arm=u["arm"], rep=u["rep"], block=u["rep"],
                        canary_of=None, meta=u["meta"])
        if u["canary_of"]:
            first.setdefault(u["unit"], []).append(oid)
    for unit, pair in first.items():  # the first id of a pair is the original, the second the canary
        assert len(pair) == 2, (unit, pair)
        ids[pair[1]]["canary_of"] = pair[0]
    return lines, ids


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def repo_root():
    try:
        p = subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True, text=True, cwd=PROJECT)
        return p.stdout.strip() or os.getcwd()
    except OSError:
        return os.getcwd()


def git_head():
    try:
        return subprocess.run(["git", "rev-parse", "HEAD"], capture_output=True, text=True, cwd=PROJECT).stdout.strip()
    except OSError:
        return None


def update_manifest(out, runner=RUNNER, root=None):
    root = root or repo_root()
    mpath = os.path.join(os.path.dirname(os.path.abspath(out)), "MANIFEST.sha256")
    paths = set()
    if os.path.exists(mpath):
        paths = {line.split(None, 1)[1].strip().lstrip("*") for line in open(mpath) if line.strip()}
    paths |= {os.path.relpath(os.path.abspath(out), root), os.path.relpath(os.path.abspath(runner), root)}
    lines = []
    for p in sorted(paths):
        full = os.path.join(root, p)
        if not os.path.exists(full):
            print(f"MANIFEST: dropping {p} (file is gone)")
            continue
        lines.append(f"{sha256(full)}  {p}\n")
    with open(mpath, "w") as f:
        f.writelines(lines)
    return mpath


def write_astra(units, out, keymap, prefix, canaries, seed, info):
    out_dir = os.path.realpath(os.path.dirname(os.path.abspath(out)))
    assert os.path.realpath(os.path.dirname(os.path.abspath(keymap))) != out_dir, \
        "the keymap must not sit in the handoff directory"
    lines, ids = astra_lines(units, prefix, canaries, seed)
    for ln in lines:
        assert set(ln) == {"id", "block", "system", "prompt"}
        assert not FILLED.search(ln["system"] + ln["prompt"]), ln["id"]
    kdir = os.path.dirname(os.path.abspath(keymap))
    for p in os.listdir(kdir) if os.path.isdir(kdir) else []:
        if p.startswith("astra_keymap_") and p.endswith(".json") and os.path.join(kdir, p) != os.path.abspath(keymap):
            clash = set(json.load(open(os.path.join(kdir, p)))["ids"]) & set(ids)
            assert not clash, f"ids {sorted(clash)[:3]} already used in {p}; pass another --prefix"
    os.makedirs(out_dir, exist_ok=True)
    with open(out, "w") as f:
        for ln in lines:
            f.write(json.dumps(ln) + "\n")
    os.makedirs(kdir, exist_ok=True)
    km = dict(info, file=os.path.relpath(os.path.abspath(out), repo_root()), sha256=sha256(out), prefix=prefix,
              n_lines=len(lines), n_canary_copies=sum(v["canary_of"] is not None for v in ids.values()),
              built_by="src/make_jobs2.py", git_head=git_head(), ids=ids)
    with open(keymap, "w") as f:
        json.dump(km, f, indent=1)
    return lines, ids, update_manifest(out)


def main(argv=None):
    ap = argparse.ArgumentParser()
    ap.add_argument("--context", required=False)
    ap.add_argument("--stage", default="main", choices=["pilot", "main"])
    ap.add_argument("--models", default=None, help="Claude model ids (comma list); not with --astra")
    ap.add_argument("--arms", default=None)
    ap.add_argument("--reps", default=None, help="e.g. 0-11 or 0,3,5 (actual replicate numbers)")
    ap.add_argument("--per-arm", type=int, default=None, help="keep the first N units of each arm")
    ap.add_argument("--probes", action="store_true")
    ap.add_argument("--realism", action="store_true")
    ap.add_argument("--identity", action="store_true")
    ap.add_argument("--n-realism", type=int, default=2)
    ap.add_argument("--n-identity", type=int, default=3)
    ap.add_argument("--timeout", type=int, default=None, help="per-job timeout field (seconds) for run.py")
    ap.add_argument("--astra", action="store_true")
    ap.add_argument("--canaries", type=int, default=0)
    ap.add_argument("--prefix", default=None)
    ap.add_argument("--keymap", default=None)
    ap.add_argument("--out", required=False)
    ap.add_argument("--selftest", action="store_true")
    a = ap.parse_args(argv)
    if a.selftest:
        return selftest()
    if not (a.context and a.out):
        ap.error("--context and --out are required")
    contexts = a.context.split(",")
    reps = set(rep_range(a.reps)) if a.reps else None
    units = collect(contexts, a.stage, a.probes, a.realism, a.identity, a.arms, reps, a.per_arm, a.n_realism,
                    a.n_identity, a.astra)
    sources = [s for s in ("probes", "realism", "identity") if getattr(a, s)] or ["units"]
    seed = shuffle_seed(",".join(contexts), a.stage, ",".join(sources), os.path.basename(a.out))
    os.makedirs(os.path.dirname(os.path.abspath(a.out)), exist_ok=True)
    if a.astra:
        assert not a.models, "--astra files are model-free; drop --models"
        stem = os.path.splitext(os.path.basename(a.out))[0]
        prefix = a.prefix or "s2" + hashlib.sha1(stem.encode()).hexdigest()[:3]
        keymap = a.keymap or os.path.join(PROJECT, "study2", f"astra_keymap_{stem}.json")
        info = dict(contexts=contexts, stage=a.stage, sources=sources, arms=a.arms, reps=a.reps, per_arm=a.per_arm)
        lines, ids, mpath = write_astra(units, a.out, keymap, prefix, a.canaries, seed, info)
        print(f"{len(lines)} lines ({len(units)} units + {len(lines) - len(units)} canary copies) in "
              f"{len({ln['block'] for ln in lines})} blocks -> {a.out}\nkeymap -> {keymap}\nmanifest -> {mpath}")
    else:
        assert a.models, "--models is required for Claude jobs (or pass --astra)"
        jobs = claude_jobs(units, a.models.split(","), a.timeout, seed)
        with open(a.out, "w") as f:
            for j in jobs:
                f.write(json.dumps(j) + "\n")
        print(f"{len(jobs)} jobs ({len(units)} units x {len(a.models.split(','))} models) -> {a.out}")
    for (c, arm), n in sorted(Counter((u["context"], u["arm"]) for u in units).items()):
        print(f"  {c:10s} {arm:28s} {n:4d} units")
    return 0


# ------------------------------------------------------------------ selftest

def fake_module():
    m = types.ModuleType("s2_fake")
    m.CONTEXT = "fake"
    m.ARMS = ["floor", "target", "self"]
    desc = {"floor": "Example Surveys is a market-research firm. It runs phone surveys for corporate clients.",
            "target": "Example Advocates is a nonprofit group. It runs phone banks for a policy campaign.",
            "self": f"{DEVELOPER}'s release team is assessing {MODEL_NAME}. It decides on wider deployment."}
    reps = {"floor": 4, "target": 4, "self": 2}

    def units(stage):
        out = []
        for r in range(4 if stage == "main" else 1):
            prompt = f"Answer the questions for dataset {r}. Q1: how many rows?"
            for arm in m.ARMS:
                if r < (reps[arm] if stage == "main" else 1):
                    out.append(dict(unit=f"fake__{arm}__r{r:02d}", context="fake", arm=arm, rep=r,
                                    system=system_with_identity("You are the assistant for this organisation.\n\n"
                                                                + desc[arm]),
                                    prompt=prompt, meta=dict(seed=3000 + r, answer=r * 10)))
        return out

    def probes(stage):
        return [dict(unit=f"fake__credence__c{c}__r{r:02d}", context="fake", arm="credence", rep=r, system=IDENTITY,
                     prompt=f"Here is a claim: \"claim {c}\". How likely is it to be true?", meta=dict(claim=c))
                for r in range(2) for c in range(3)]

    m.units, m.probes = units, probes
    return m


def selftest():
    MODULES["fake"] = fake_module()
    tmp = tempfile.mkdtemp(prefix="mj2_")
    try:
        # unit collection and filters
        u = collect(["fake"], "main")
        assert len(u) == 10 and Counter(x["arm"] for x in u) == {"floor": 4, "target": 4, "self": 2}
        assert len(collect(["fake"], "main", arms="floor,self")) == 6
        assert len(collect(["fake"], "main", arms="fake:target", reps={0, 1})) == 2
        assert len(collect(["fake"], "main", per_arm=1)) == 3
        assert len(collect(["fake"], "pilot")) == 3
        for bad in ("nope", "other:floor"):
            try:
                collect(["fake"], "main", arms=bad)
                raise RuntimeError("bad --arms accepted")
            except AssertionError:
                pass
        p = collect(["fake"], "main", probes=True)
        assert len(p) == 6 and all(x["meta"]["probe"] == "probe" and x["meta"]["claim"] in (0, 1, 2) for x in p)
        r = collect(["fake"], "main", realism=True)
        assert len(r) == 6 and all(x["system"] == IDENTITY and x["meta"]["probe"] == "realism" for x in r)
        i = collect(["fake"], "main", identity=True)
        assert [x["arm"] for x in i] == ["floor"] * 3 and i[0]["prompt"] == s2_judge.IDENTITY_Q
        assert [x["arm"] for x in collect(["fake"], "main", identity=True, arms="self", n_identity=1)] == ["self"]
        assert len(collect(["fake"], "main", probes=True, arms="credence", reps={1})) == 3

        # Claude jobs: filled, ordered by replicate, deterministic
        jobs = claude_jobs(u, ["claude-haiku-4-5", "claude-opus-5-5"], timeout=1800, seed=7)
        assert len(jobs) == 20 and len({j["id"] for j in jobs}) == 20
        assert [j["rep"] for j in jobs] == sorted(j["rep"] for j in jobs)
        assert jobs == claude_jobs(u, ["claude-haiku-4-5", "claude-opus-5-5"], timeout=1800, seed=7)
        assert [j["id"] for j in jobs] != [j["id"] for j in claude_jobs(u, ["claude-haiku-4-5", "claude-opus-5-5"],
                                                                        seed=8)]
        j = next(j for j in jobs if j["arm"] == "self" and j["model"] == "claude-opus-5-5")
        assert j["id"] == f"{j['unit']}__claude-opus-5-5" and j["timeout"] == 1800 and j["meta"]["seed"] == 3000 + j["rep"]
        assert "Anthropic's release team is assessing Claude Opus 5.5." in j["system"]
        for rep in range(4):  # identical user message across arms (and models) within a replicate
            assert len({j["prompt"] for j in jobs if j["rep"] == rep}) == 1
        try:
            claude_jobs(u, ["claude-opus-4-1"])
            raise RuntimeError("unknown model accepted")
        except AssertionError:
            pass

        MODULES["fake"].astra_units = lambda stage: MODULES["fake"].units(stage)[:2]
        assert len(collect(["fake"], "main", astra=True)) == 2 and len(collect(["fake"], "main")) == 10
        del MODULES["fake"].astra_units

        # Astra file, keymap, canaries, manifest
        hand, study = os.path.join(tmp, "handoff"), os.path.join(tmp, "study2")
        out, km = os.path.join(hand, "s2_fake.jsonl"), os.path.join(study, "astra_keymap_s2_fake.json")
        lines, ids, mpath = write_astra(u, out, km, "s2z", 2, 11, dict(contexts=["fake"]))
        assert len(lines) == 12 and [json.loads(x) for x in open(out)] == lines
        assert [ln["block"] for ln in lines] == sorted(ln["block"] for ln in lines)
        assert all(ln["id"].startswith("s2z_") and set(ln) == {"id", "block", "system", "prompt"} for ln in lines)
        assert all(ln["system"].startswith(IDENTITY) for ln in lines)
        assert any(MODEL_NAME in ln["system"] for ln in lines), "placeholders must stay unfilled"
        kmd = json.load(open(km))
        assert set(kmd["ids"]) == {ln["id"] for ln in lines} and kmd["sha256"] == sha256(out)
        canary = [(k, v) for k, v in kmd["ids"].items() if v["canary_of"]]
        assert len(canary) == 2
        byid = {ln["id"]: ln for ln in lines}
        for k, v in canary:
            orig = byid[v["canary_of"]]
            assert (orig["system"], orig["prompt"], orig["block"]) == (byid[k]["system"], byid[k]["prompt"],
                                                                       byid[k]["block"])
            assert kmd["ids"][v["canary_of"]]["unit"] == v["unit"]
        assert {v["unit"] for v in kmd["ids"].values()} == {x["unit"] for x in u}
        for ln in lines:  # the keymap restores each line's unit exactly
            src = next(x for x in u if x["unit"] == kmd["ids"][ln["id"]]["unit"])
            assert (src["system"], src["prompt"], src["rep"]) == (ln["system"], ln["prompt"], ln["block"])
        assert write_astra(u, out, km, "s2z", 2, 11, dict(contexts=["fake"]))[0] == lines  # deterministic
        man = open(mpath).read().splitlines()
        root = repo_root()
        want = {os.path.relpath(out, root): sha256(out), os.path.relpath(RUNNER, root): sha256(RUNNER)}
        assert {ln.split("  ", 1)[1]: ln.split("  ", 1)[0] for ln in man} == want, man
        if shutil.which("sha256sum"):
            res = subprocess.run(["sha256sum", "-c", mpath], cwd=root, capture_output=True, text=True)
            assert res.returncode == 0, res.stdout + res.stderr
        out2 = os.path.join(hand, "s2_fake_probes.jsonl")
        write_astra(r, out2, os.path.join(study, "astra_keymap_s2_fake_probes.json"), "s2y", 0, 3, {})
        assert len(open(mpath).read().splitlines()) == 3  # manifest updated, earlier entry kept
        for bad_km, bad_prefix in ((os.path.join(hand, "astra_keymap_x.json"), "s2w"),
                                   (os.path.join(study, "astra_keymap_x.json"), "s2z")):
            try:  # keymap inside the handoff dir, or ids clashing with another keymap
                write_astra(u, os.path.join(hand, "x.jsonl"), bad_km, bad_prefix, 0, 1, {})
                raise RuntimeError("bad astra build accepted")
            except AssertionError:
                pass

        # a module whose template lacks the identity line, or carries a date, is rejected
        bad = MODULES["fake"] = fake_module()
        for sysx in ("Hi", IDENTITY + "\n\nSee you on Monday."):
            bad.units = lambda stage, s=sysx: [dict(unit="fake__floor__r00", context="fake", arm="floor", rep=0,
                                                    system=s, prompt="x", meta={})]
            try:
                collect(["fake"], "main")
                raise RuntimeError("bad template accepted")
            except AssertionError:
                pass
    finally:
        MODULES.pop("fake", None)
        shutil.rmtree(tmp, ignore_errors=True)
    print("make_jobs2 selftest OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
