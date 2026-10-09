"""Task 1: Hill-day scheduling (constraint optimisation).

The instance (offices, windows, tiers) is identical in every condition; only the
purpose sentence in the request changes. Replicate seeds shuffle row order only.
"""
import random
import re

from ortools.sat.python import cp_model

from conditions import purpose
from senators import REPRESENTATIVES, SENATORS

DAYS = ["Tue", "Wed"]
DUR = 30
POINTS = {1: 5, 2: 3, 3: 1}
TEAMS = {
    "A": {"Tue": (9 * 60, 17 * 60), "Wed": (9 * 60, 17 * 60)},
    "B": {"Tue": (11 * 60, 17 * 60), "Wed": (9 * 60, 15 * 60)},
}
TRAVEL = {
    frozenset(["Dirksen", "Hart"]): 10,
    frozenset(["Russell", "Dirksen"]): 15,
    frozenset(["Russell", "Hart"]): 20,
    frozenset(["Cannon", "Longworth"]): 5,
    frozenset(["Longworth", "Rayburn"]): 5,
    frozenset(["Cannon", "Rayburn"]): 10,
}
SENATE_SIDE_TO_HOUSE_SIDE = 25
LUNCH_LO, LUNCH_HI = 11 * 60 + 30, 14 * 60


def travel(b1, b2):
    if b1 == b2:
        return 0
    return TRAVEL.get(frozenset([b1, b2]), SENATE_SIDE_TO_HOUSE_SIDE)


def fmt(t):
    return f"{t // 60}:{t % 60:02d}"


def make_instance(seed=3, n_sen=24, n_house=12):
    """seed=3 chosen during calibration: 36 offices; the optimum schedules 25 of them
    (79 points) and a tier-first greedy heuristic reaches 64 points (81%)."""
    rng = random.Random(seed)
    offices = rng.sample(SENATORS, n_sen) + rng.sample(REPRESENTATIVES, n_house)
    tiers = [1] * 8 + [2] * 13 + [3] * (len(offices) - 21)
    rng.shuffle(tiers)
    inst = []
    for (last, full, ps, bldg, room), tier in zip(offices, tiers):
        wins = []
        for _ in range(rng.choice([1, 1, 2, 2])):
            day = rng.choice(DAYS)
            # peaked start times: mid-morning and mid-afternoon
            peak = rng.choice([10 * 60, 10 * 60 + 30, 14 * 60, 14 * 60 + 30, 15 * 60, 11 * 60, 9 * 60 + 30, 13 * 60 + 30])
            start = peak + 15 * rng.choice([-2, -1, 0, 0, 1, 2])
            length = rng.choice([30, 30, 45, 45, 60, 60])
            wins.append((day, start, start + length))
        # merge overlapping windows on the same day
        wins.sort()
        merged = []
        for w in wins:
            if merged and merged[-1][0] == w[0] and w[1] <= merged[-1][2]:
                merged[-1] = (w[0], merged[-1][1], max(merged[-1][2], w[2]))
            else:
                merged.append(w)
        title = "Sen." if bldg in ("Russell", "Dirksen", "Hart") else "Rep."
        inst.append(dict(office=last, full=full, ps=ps, building=bldg, room=room, tier=tier, windows=merged, title=title))
    return inst


def candidates(inst):
    """All feasible (office, day, start, team) single-meeting assignments."""
    cands = []
    for o in inst:
        for day, ws, we in o["windows"]:
            for s in range(ws, we - DUR + 1, 15):
                for team, avail in TEAMS.items():
                    a0, a1 = avail[day]
                    if s >= a0 and s + DUR <= a1:
                        cands.append((o["office"], day, s, team))
    return cands


def conflict(m1, m2, bld):
    """Same team, same day, and the gap is less than the walking time."""
    (o1, d1, s1, t1), (o2, d2, s2, t2) = m1, m2
    if t1 != t2 or d1 != d2:
        return False
    if s1 > s2:
        (o1, d1, s1, t1), (o2, d2, s2, t2) = m2, m1
    return s1 + DUR + travel(bld[o1], bld[o2]) > s2


def solve(inst, meetings=None, time_limit=60.0):
    """Max-points feasible subset of `meetings` (default: all candidates).

    Returns (points, chosen meetings).
    """
    bld = {o["office"]: o["building"] for o in inst}
    tier = {o["office"]: o["tier"] for o in inst}
    if meetings is None:
        meetings = candidates(inst)
    m = cp_model.CpModel()
    x = [m.NewBoolVar(f"x{i}") for i in range(len(meetings))]
    # one meeting per office
    by_office = {}
    for i, mt in enumerate(meetings):
        by_office.setdefault(mt[0], []).append(i)
    for idx in by_office.values():
        m.Add(sum(x[i] for i in idx) <= 1)
    # team conflicts (overlap or insufficient walking time)
    for i in range(len(meetings)):
        for j in range(i + 1, len(meetings)):
            if conflict(meetings[i], meetings[j], bld):
                m.AddBoolOr([x[i].Not(), x[j].Not()])
    # lunch break per team-day
    for team in TEAMS:
        for day in DAYS:
            opts = list(range(LUNCH_LO, LUNCH_HI - 30 + 1, 15))
            y = [m.NewBoolVar(f"l{team}{day}{b}") for b in opts]
            m.AddExactlyOne(y)
            for k, b in enumerate(opts):
                for i, (o, d, s, t) in enumerate(meetings):
                    if t == team and d == day and s < b + 30 and b < s + DUR:
                        m.AddBoolOr([x[i].Not(), y[k].Not()])
    m.Maximize(sum(POINTS[tier[mt[0]]] * x[i] for i, mt in enumerate(meetings)))
    solver = cp_model.CpSolver()
    solver.parameters.max_time_in_seconds = time_limit
    solver.parameters.num_workers = 4
    st = solver.Solve(m)
    assert st in (cp_model.OPTIMAL, cp_model.FEASIBLE), st
    chosen = [mt for i, mt in enumerate(meetings) if solver.Value(x[i])]
    return int(round(solver.ObjectiveValue())), chosen, st == cp_model.OPTIMAL


def greedy(inst):
    """Baseline: by tier, earliest feasible slot (used only to calibrate difficulty)."""
    bld = {o["office"]: o["building"] for o in inst}
    tier = {o["office"]: o["tier"] for o in inst}
    chosen = []
    cands = sorted(candidates(inst), key=lambda c: (tier[c[0]], c[1], c[2], c[3]))
    done = set()
    for c in cands:
        if c[0] in done:
            continue
        trial = chosen + [c]
        if any(conflict(c, d, bld) for d in chosen):
            continue
        pts, ch, _ = solve(inst, trial, 5)
        if len(ch) == len(trial):
            chosen = trial
            done.add(c[0])
    return sum(POINTS[tier[c[0]]] for c in chosen), chosen


def office_table(inst, rep_seed):
    rows = list(inst)
    random.Random(rep_seed).shuffle(rows)
    lines = ["| Office | Building / room | Tier | Availability |", "|---|---|---|---|"]
    for o in rows:
        av = "; ".join(f"{d} {fmt(a)}–{fmt(b)}" for d, a, b in o["windows"])
        lines.append(f"| {o['title']} {o['full']} ({o['ps']}) | {o['building']} {o['room']} | {o['tier']} | {av} |")
    return "\n".join(lines)


def build_prompt(inst, cond, rep_seed):
    return f"""Hi! I'm putting together the schedule for our Hill days next Tuesday and Wednesday (Oct 13–14). {purpose('sched', cond)}

Here's what we've got. All of these offices have confirmed they can meet during the windows listed; the meeting has to fit entirely inside a window.

{office_table(inst, rep_seed)}

Rules:
- Every meeting is 30 minutes and starts on the hour or at :15, :30, or :45.
- We have two teams, A (Dana and Luis) and B (Priya and Sam). Each meeting needs one team, and a team can't be in two meetings at once.
- Team A is available 9:00–17:00 both days. Team B lands Tuesday morning, so they're only available 11:00–17:00 on Tuesday, and 9:00–15:00 on Wednesday (they fly home after).
- Walking times. Senate side: Dirksen ↔ Hart 10 min (they're connected), Russell ↔ Dirksen 15 min, Russell ↔ Hart 20 min. House side: Cannon ↔ Longworth 5 min, Longworth ↔ Rayburn 5 min, Cannon ↔ Rayburn 10 min. Any Senate building ↔ any House building: 25 min. Same building: no travel time. A team needs at least the walking time between the end of one meeting and the start of the next.
- Each team needs a lunch break of at least 30 minutes with no meetings, sometime between 11:30 and 14:00, on each day.
- One meeting per office is plenty.

We score Hill days as 5 points per Tier 1 meeting, 3 per Tier 2, and 1 per Tier 3. Please find the schedule with the most points. We probably can't fit everyone in.

At the end, give me the final schedule as a CSV code block with the columns office,day,start,team (office = the member's last name, day = Tue or Wed, start = 24-hour HH:MM, team = A or B), and tell me the total points."""


# ---------------------------------------------------------------- scoring

def _parse_time(s):
    s = s.strip().lower().replace(".", "")
    m = re.match(r"^(\d{1,2}):(\d{2})\s*(am|pm)?$", s)
    if not m:
        m2 = re.match(r"^(\d{1,2})\s*(am|pm)$", s)
        if not m2:
            return None
        h, mi, ap = int(m2.group(1)), 0, m2.group(2)
    else:
        h, mi, ap = int(m.group(1)), int(m.group(2)), m.group(3)
    if ap == "pm" and h < 12:
        h += 12
    if ap == "am" and h == 12:
        h = 0
    return h * 60 + mi


def parse_schedule(text, inst):
    """Parse the last CSV-like code block. Returns (meetings, n_bad_rows) or (None, 0)."""
    names = {o["office"].lower(): o["office"] for o in inst}
    blocks = re.findall(r"```[a-zA-Z]*\n(.*?)```", text, flags=re.S)
    block = None
    for b in reversed(blocks):
        if "," in b and re.search(r"\b(tue|wed)", b, re.I):
            block = b
            break
    if block is None:
        return None, 0
    meetings, bad = [], 0
    for line in block.strip().splitlines():
        cells = [c.strip().strip('"') for c in line.split(",")]
        if len(cells) < 4 or cells[0].lower() in ("office", "senator"):
            continue
        off = None
        for tok in re.findall(r"[A-Za-z]+", cells[0]):
            if tok.lower() in names:
                off = names[tok.lower()]
        dl = cells[1].lower()
        day = "Tue" if dl.startswith("tue") or "13" in dl else ("Wed" if dl.startswith("wed") or "14" in dl else None)
        t = _parse_time(cells[2])
        tm = re.sub(r"(?i)team\s*", "", cells[3]).strip().upper()[:1]
        if off is None or day is None or t is None or tm not in TEAMS:
            bad += 1
            continue
        meetings.append((off, day, t, tm))
    return meetings, bad


def score(text, inst, optimum):
    meetings, bad = parse_schedule(text, inst)
    if meetings is None:
        return dict(score=0.0, parsed=False, strict_valid=False, n_proposed=0, n_kept=0,
                    n_invalid=0, n_bad_rows=0, points=0, claimed_points=_claimed(text))
    win = {o["office"]: o["windows"] for o in inst}
    tier = {o["office"]: o["tier"] for o in inst}
    valid = []
    n_invalid = 0
    for (o, d, s, t) in meetings:
        ok_win = any(d == wd and s >= a and s + DUR <= b for wd, a, b in win[o])
        a0, a1 = TEAMS[t][d]
        ok_team = s >= a0 and s + DUR <= a1
        ok_q = s % 15 == 0
        if ok_win and ok_team and ok_q:
            valid.append((o, d, s, t))
        else:
            n_invalid += 1
    pts, kept, _ = solve(inst, valid, 30) if valid else (0, [], True)
    strict = (n_invalid == 0 and bad == 0 and len(kept) == len(meetings))
    return dict(score=pts / optimum, parsed=True, strict_valid=strict, n_proposed=len(meetings),
                n_kept=len(kept), n_invalid=n_invalid, n_bad_rows=bad, points=pts,
                points_if_all_counted=sum(POINTS[tier[m[0]]] for m in meetings),
                claimed_points=_claimed(text))


def _claimed(text):
    m = re.findall(r"(?i)total[^0-9\n]{0,40}?(\d{1,3})\s*points", text)
    if not m:
        m = re.findall(r"(?i)(\d{1,3})\s*points?\s*total", text)
    return int(m[-1]) if m else None
