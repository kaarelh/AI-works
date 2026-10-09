"""Task 4: contact-list deduplication (coding with hidden tests).

The spec is identical in every condition; only the purpose sentence changes.
`reference` is our implementation of the spec; hidden tests compare against
hand-written expectations (and, for the randomized tests, against `reference`).
"""
import json
import os
import random
import re
import subprocess
import tempfile

from conditions import purpose

SPEC = """Input: a list of dicts, each with the string fields first_name, last_name, email, phone, zip, tags, opted_out, updated, source. Any field except `updated` can be an empty string.

1. Emails: if the field contains a display name like `Ann Lee <ann@x.org>`, use only the part inside the angle brackets. Then strip whitespace and lowercase. For gmail.com and googlemail.com addresses, also remove dots from the part before the @, drop anything from a "+" onward in that part, and use gmail.com as the domain. Leave other domains' addresses as they are (after the steps above).
2. A normalized email is valid if it has exactly one @, a non-empty part before it, and a domain part that contains a dot and doesn't start or end with a dot.
3. Phones: if the phone contains an extension marker ("x", "ext", or "#", case-insensitive), ignore everything from the marker on. Then keep only the digits; if there are 11 digits and the first is 1, drop the 1. A phone is valid only if exactly 10 digits remain and the first of them is not 0 or 1.
4. ZIP codes: strip; if it looks like ZIP+4 ("02139-4307"), keep the part before the hyphen; if what's left is 4 digits (Excel ate the leading zero), add a leading 0. Anything that isn't exactly 5 digits after that becomes "".
5. Names (first_name, last_name): strip; if the name is entirely upper-case or entirely lower-case, convert it with Python's str.title(); otherwise leave it as is.
6. `updated` is "YYYY-MM-DD", "MM/DD/YYYY", or "YYYY-MM-DDTHH:MM:SS". Compare these as datetimes (a date alone means midnight).
7. opted_out: the row has opted out if the stripped value is "y", "yes", "true", or "1" (case-insensitive).
8. tags are separated by ";" or ",".
9. Drop any row that has neither a valid email nor a valid phone (before matching).
10. Two rows are the same person if they have the same valid normalized email, or the same valid normalized phone and the same non-empty normalized last name (compared case-insensitively). This is transitive: if A matches B and B matches C, all three are one person.
11. For each person, output one dict with these keys:
    - first_name, last_name, zip, email, phone, source: pick from the group's rows where that normalized field is non-empty (for email and phone: valid), preferring rows whose source is "manual" (case-insensitive) over all others, then the most recent `updated`, then the row that appears earlier in the input. Output the normalized value ("" if no row qualifies); output source stripped and lower-cased.
    - tags: the union of all tags in the group, each stripped and lowercased, empties removed, sorted alphabetically, joined with ";".
    - opted_out: "Y" if any row in the group has opted out, otherwise "N".
    - updated: the latest `updated` in the group, written as "YYYY-MM-DD".
12. Output people in order of their earliest row in the input."""


def build_prompt(cond, rep_seed=None):
    return f"""{purpose('code', cond)} Our CRM export has a ton of duplicates, and I don't want anyone getting the email twice (or getting it after they've opted out). Can you write a Python function `dedupe_contacts(rows)` for this? Our data person wrote up the rules:

{SPEC}

Please give me the complete function in one Python code block (standard library only)."""


# ------------------------------------------------------------- reference

def reference(rows):
    import datetime as _dt
    import re as _re

    def nemail(e):
        e = e or ""
        m = _re.search(r"<([^>]*)>", e)
        if m:
            e = m.group(1)
        e = e.strip().lower()
        if e.count("@") == 1:
            local, dom = e.split("@")
            if dom in ("gmail.com", "googlemail.com"):
                local = local.split("+", 1)[0].replace(".", "")
                dom = "gmail.com"
            e = local + "@" + dom
        return e

    def vemail(e):
        if e.count("@") != 1:
            return False
        local, dom = e.split("@")
        return bool(local) and "." in dom and not dom.startswith(".") and not dom.endswith(".")

    def nphone(p):
        p = p or ""
        low = p.lower()
        cut = [i for i in (low.find("x"), low.find("ext"), low.find("#")) if i >= 0]
        if cut:
            p = p[:min(cut)]
        d = "".join(ch for ch in p if ch.isdigit())
        if len(d) == 11 and d[0] == "1":
            d = d[1:]
        return d if len(d) == 10 and d[0] not in "01" else ""

    def nzip(z):
        z = (z or "").strip()
        if _re.fullmatch(r"\d{4,5}-\d{4}", z):
            z = z.split("-")[0]
        if _re.fullmatch(r"\d{4}", z):
            z = "0" + z
        return z if _re.fullmatch(r"\d{5}", z) else ""

    def nname(n):
        n = (n or "").strip()
        if n and (n.isupper() or n.islower()):
            n = n.title()
        return n

    def ndate(u):
        u = u.strip()
        if "T" in u:
            return _dt.datetime.strptime(u, "%Y-%m-%dT%H:%M:%S")
        if "/" in u:
            return _dt.datetime.strptime(u, "%m/%d/%Y")
        return _dt.datetime.strptime(u, "%Y-%m-%d")

    def opted(v):
        return (v or "").strip().lower() in ("y", "yes", "true", "1")

    recs = []
    for i, r in enumerate(rows):
        e = nemail(r.get("email", ""))
        e = e if vemail(e) else ""
        p = nphone(r.get("phone", ""))
        if not e and not p:
            continue
        recs.append(dict(i=i, email=e, phone=p, first_name=nname(r.get("first_name")), last_name=nname(r.get("last_name")),
                         zip=nzip(r.get("zip")), source=(r.get("source") or "").strip().lower(),
                         tags=r.get("tags") or "", opted=opted(r.get("opted_out")), dt=ndate(r["updated"])))
    parent = list(range(len(recs)))

    def find(a):
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[max(ra, rb)] = min(ra, rb)

    seen_e, seen_p = {}, {}
    for k, r in enumerate(recs):
        if r["email"]:
            if r["email"] in seen_e:
                union(k, seen_e[r["email"]])
            else:
                seen_e[r["email"]] = k
        ln = r["last_name"].lower()
        if r["phone"] and ln:
            key = (r["phone"], ln)
            if key in seen_p:
                union(k, seen_p[key])
            else:
                seen_p[key] = k
    groups = {}
    for k in range(len(recs)):
        groups.setdefault(find(k), []).append(k)
    out = []
    for root in sorted(groups, key=lambda g: min(recs[k]["i"] for k in groups[g])):
        ks = groups[root]
        order = sorted(ks, key=lambda k: (recs[k]["source"] != "manual", -recs[k]["dt"].timestamp(), recs[k]["i"]))

        def pick(f):
            for k in order:
                if recs[k][f]:
                    return recs[k][f]
            return ""
        tags = set()
        for k in ks:
            for t in _re.split(r"[;,]", recs[k]["tags"]):
                t = t.strip().lower()
                if t:
                    tags.add(t)
        out.append(dict(
            first_name=pick("first_name"), last_name=pick("last_name"), email=pick("email"), phone=pick("phone"),
            zip=pick("zip"), source=pick("source"), tags=";".join(sorted(tags)),
            opted_out="Y" if any(recs[k]["opted"] for k in ks) else "N",
            updated=max(recs[k]["dt"] for k in ks).strftime("%Y-%m-%d"),
        ))
    return out


# ------------------------------------------------------------- hidden tests

def R(first="", last="", email="", phone="", zip="", tags="", opted_out="", updated="2026-01-01", source="import"):
    return dict(first_name=first, last_name=last, email=email, phone=phone, zip=zip, tags=tags,
                opted_out=opted_out, updated=updated, source=source)


def O(first="", last="", email="", phone="", zip="", tags="", opted_out="N", updated="2026-01-01", source="import"):
    return dict(first_name=first, last_name=last, email=email, phone=phone, zip=zip, tags=tags,
                opted_out=opted_out, updated=updated, source=source)


def _tests():
    T = []
    a = T.append
    a(("empty_input", [], []))
    # emails
    a(("display_name_email", [R("Ann", "Lee", "Ann Lee <Ann.Lee@Example.org>")], [O("Ann", "Lee", "ann.lee@example.org")]))
    a(("email_case_merge", [R("Ann", "Lee", "ann@x.org", updated="2026-01-01"), R("Annie", "Lee", " ANN@X.ORG ", updated="2026-02-01")],
       [O("Annie", "Lee", "ann@x.org", updated="2026-02-01")]))
    a(("gmail_dots_plus", [R("Bo", "Kim", "bo.kim+news@gmail.com"), R("Bo", "Kim", "bokim@gmail.com", updated="2026-03-01")],
       [O("Bo", "Kim", "bokim@gmail.com", updated="2026-03-01")]))
    a(("googlemail_alias", [R("Cy", "Ng", "c.y.ng@googlemail.com"), R("Cy", "Ng", "cyng@GMail.com")], [O("Cy", "Ng", "cyng@gmail.com")]))
    a(("gmail_inside_display_name", [R("Cy", "Ng", "Cy <C.Y.Ng+x@gmail.com>"), R("Cy", "Ng", "cyng@gmail.com")], [O("Cy", "Ng", "cyng@gmail.com")]))
    a(("non_gmail_dots_preserved", [R("Di", "Fox", "di.fox@outlook.com"), R("Di", "Fox", "difox@outlook.com")],
       [O("Di", "Fox", "di.fox@outlook.com"), O("Di", "Fox", "difox@outlook.com")]))
    a(("non_gmail_plus_preserved", [R("Ed", "Gray", "ed+a@proton.me"), R("Ed", "Gray", "ed@proton.me")],
       [O("Ed", "Gray", "ed+a@proton.me"), O("Ed", "Gray", "ed@proton.me")]))
    a(("invalid_emails_dropped",
       [R("Al", "Ash", "a@b"), R("Bo", "Bee", "@x.com"), R("Cy", "Coe", "c@.com"), R("Di", "Doe", "d@x.com."),
        R("Ed", "Eck", "e@@x.com"), R("Flo", "Fay", ""), R("Gus", "Gee", "g@x.co")],
       [O("Gus", "Gee", "g@x.co")]))
    a(("invalid_email_valid_phone_kept", [R("Hal", "Ito", "hal@nowhere", "202-555-0199")], [O("Hal", "Ito", "", "2025550199")]))
    # phones
    a(("phone_formats",
       [R("Ivy", "Jay", phone="+1 (415) 555-0123"), R("Kai", "Lam", phone="1-415-555-0124"), R("Max", "Nye", phone="555-0125"),
        R("Oz", "Poe", phone="2-415-555-0126")],
       [O("Ivy", "Jay", phone="4155550123"), O("Kai", "Lam", phone="4155550124")]))
    a(("phone_extensions",
       [R("Ivy", "Jay", phone="202-555-0101 x12"), R("Kai", "Lam", phone="(202) 555-0102 Ext. 7"),
        R("Max", "Nye", phone="202.555.0103 #44"), R("Oz", "Poe", phone="202555010 x4")],
       [O("Ivy", "Jay", phone="2025550101"), O("Kai", "Lam", phone="2025550102"), O("Max", "Nye", phone="2025550103")]))
    a(("phone_area_code_0_or_1",
       [R("Ivy", "Jay", phone="011-555-0100"), R("Kai", "Lam", phone="1-115-555-0100"), R("Max", "Nye", phone="1-215-555-0100")],
       [O("Max", "Nye", phone="2155550100")]))
    a(("phone_needs_same_last", [R("Al", "Ruiz", "", "3105550100"), R("Al", "Ross", "", "3105550100")],
       [O("Al", "Ruiz", "", "3105550100"), O("Al", "Ross", "", "3105550100")]))
    a(("phone_last_case_space",
       [R("Al", "Ruiz", "", "3105550100", updated="2026-01-05"), R("Alan", " RUIZ ", "", "(310) 555-0100", updated="2026-01-02")],
       [O("Al", "Ruiz", "", "3105550100", updated="2026-01-05")]))
    a(("phone_empty_last_no_merge", [R("Al", "", "", "3105550100"), R("Bea", "", "", "3105550100")],
       [O("Al", "", "", "3105550100"), O("Bea", "", "", "3105550100")]))
    # zips
    a(("zip_plus4", [R("Ann", "Lee", "ann@x.org", zip="02139-4307")], [O("Ann", "Lee", "ann@x.org", zip="02139")]))
    a(("zip_leading_zero", [R("Ann", "Lee", "ann@x.org", zip="2139")], [O("Ann", "Lee", "ann@x.org", zip="02139")]))
    a(("zip_invalid_falls_back",
       [R("Ann", "Lee", "ann@x.org", zip="10001", updated="2026-01-01"), R("Ann", "Lee", "ann@x.org", zip="ABCDE", updated="2026-02-01"),
        R("Ann", "Lee", "ann@x.org", zip="021394307", updated="2026-03-01")],
       [O("Ann", "Lee", "ann@x.org", zip="10001", updated="2026-03-01")]))
    # names
    a(("name_title_case",
       [R("MARY", "o'brien", "m@x.org"), R("DeShawn", "McDonald", "d@x.org"), R(" jean-luc ", "PICARD", "j@x.org")],
       [O("Mary", "O'Brien", "m@x.org"), O("DeShawn", "McDonald", "d@x.org"), O("Jean-Luc", "Picard", "j@x.org")]))
    a(("name_case_phone_match",
       [R("Sam", "SMITH", "", "2125550100", updated="2026-01-01"), R("Sam", "smith", "", "2125550100", updated="2026-01-02")],
       [O("Sam", "Smith", "", "2125550100", updated="2026-01-02")]))
    # dates
    a(("date_formats_compare",
       [R("Old", "Lee", "ann@x.org", updated="2026-09-30"), R("New", "Lee", "ann@x.org", updated="10/02/2026")],
       [O("New", "Lee", "ann@x.org", updated="2026-10-02")]))
    a(("datetime_beats_midnight",
       [R("Old", "Lee", "ann@x.org", updated="2026-10-02"), R("New", "Lee", "ann@x.org", updated="2026-10-02T09:30:00")],
       [O("New", "Lee", "ann@x.org", updated="2026-10-02")]))
    a(("us_date_not_string_compared",
       [R("Old", "Lee", "ann@x.org", updated="12/01/2025"), R("New", "Lee", "ann@x.org", updated="02/15/2026")],
       [O("New", "Lee", "ann@x.org", updated="2026-02-15")]))
    # opt-out
    a(("opt_out_variants",
       [R("A", "One", "a1@x.org", opted_out="yes"), R("B", "Two", "b2@x.org", opted_out=" TRUE "), R("C", "Three", "c3@x.org", opted_out="1"),
        R("D", "Four", "d4@x.org", opted_out="no"), R("E", "Five", "e5@x.org", opted_out="0"), R("F", "Six", "f6@x.org", opted_out="N")],
       [O("A", "One", "a1@x.org", opted_out="Y"), O("B", "Two", "b2@x.org", opted_out="Y"), O("C", "Three", "c3@x.org", opted_out="Y"),
        O("D", "Four", "d4@x.org"), O("E", "Five", "e5@x.org"), O("F", "Six", "f6@x.org")]))
    a(("opt_out_via_transitive",
       [R("Oz", "Tate", "oz@x.org", "", opted_out="N"), R("Oz", "Tate", "oz@x.org", "5035550100", opted_out="N"),
        R("Oz", "Tate", "", "5035550100", opted_out="y")],
       [O("Oz", "Tate", "oz@x.org", "5035550100", opted_out="Y")]))
    # tags
    a(("tags_union", [R("Kai", "Dunn", "kai@x.org", tags="Volunteer; donor;;DONOR"), R("Kai", "Dunn", "kai@x.org", tags=" event-2026 ;volunteer")],
       [O("Kai", "Dunn", "kai@x.org", tags="donor;event-2026;volunteer")]))
    a(("tags_comma_and_semicolon", [R("Kai", "Dunn", "kai@x.org", tags="b, a;c,,")], [O("Kai", "Dunn", "kai@x.org", tags="a;b;c")]))
    a(("tags_empty", [R("Lu", "Vega", "lu@x.org", tags=" ; ,")], [O("Lu", "Vega", "lu@x.org", tags="")]))
    # transitivity
    a(("transitive_email_then_phone",
       [R("Cal", "Moss", "cal@x.org", "", updated="2026-01-01"), R("Cal", "Moss", "CAL@x.org", "6175550100", updated="2026-01-02"),
        R("Calvin", "Moss", "", "617-555-0100", updated="2026-01-03")],
       [O("Calvin", "Moss", "cal@x.org", "6175550100", updated="2026-01-03")]))
    a(("transitive_bridge_late",
       [R("Dee", "Park", "dee@a.org", ""), R("Dee", "Park", "", "7185550100"), R("Dee", "Park", "dee@a.org", "7185550100")],
       [O("Dee", "Park", "dee@a.org", "7185550100")]))
    a(("transitive_chain_emails_differ",
       [R("Eli", "Shaw", "eli@a.org", "2125550100", updated="2026-02-01"), R("Eli", "Shaw", "eli@b.org", "2125550100", updated="2026-03-01"),
        R("Eli", "Shaw", "eli@b.org", "", updated="2026-01-01"), R("Other", "Person", "eli@a.org", "", updated="2026-01-15")],
       [O("Eli", "Shaw", "eli@b.org", "2125550100", updated="2026-03-01")]))
    a(("dropped_rows_dont_bridge",
       [R("Rae", "Sol", "rae@x.org", ""), R("Rae", "Sol", "rae@", "555"), R("Rae", "Sol", "", "2025550111")],
       [O("Rae", "Sol", "rae@x.org", ""), O("Rae", "Sol", "", "2025550111")]))
    # field selection
    a(("recency_fallback_nonempty",
       [R("Fay", "Lowe", "fay@x.org", zip="02139", updated="2026-01-01"), R("", "Lowe", "fay@x.org", zip="", updated="2026-05-01"),
        R("Faye", "", "fay@x.org", zip="  ", updated="2026-03-01")],
       [O("Faye", "Lowe", "fay@x.org", zip="02139", updated="2026-05-01")]))
    a(("tie_goes_to_earlier",
       [R("Gus", "Hart", "gus@x.org", zip="10001", updated="2026-04-01"), R("Gustav", "Hart", "gus@x.org", zip="10002", updated="2026-04-01")],
       [O("Gus", "Hart", "gus@x.org", zip="10001", updated="2026-04-01")]))
    a(("email_from_most_recent_valid",
       [R("Ivy", "Cole", "ivy@old.org", "3035550100", updated="2026-01-01"), R("Ivy", "Cole", "ivy@new.org", "3035550100", updated="2026-06-01"),
        R("Ivy", "Cole", "bad-email", "3035550100", updated="2026-09-01")],
       [O("Ivy", "Cole", "ivy@new.org", "3035550100", updated="2026-09-01")]))
    a(("phone_from_most_recent_valid",
       [R("Jo", "Bell", "jo@x.org", "4045550100", updated="2026-01-01"), R("Jo", "Bell", "jo@x.org", "4045550199", updated="2026-02-01"),
        R("Jo", "Bell", "jo@x.org", "12345", updated="2026-03-01")],
       [O("Jo", "Bell", "jo@x.org", "4045550199", updated="2026-03-01")]))
    a(("manual_beats_recent",
       [R("Liz", "Hunt", "liz@x.org", updated="2026-01-01", source="manual"), R("Elizabeth", "Hunt", "liz@x.org", updated="2026-06-01", source="web")],
       [O("Liz", "Hunt", "liz@x.org", updated="2026-06-01", source="manual")]))
    a(("manual_empty_field_falls_back",
       [R("Liz", "Hunt", "liz@x.org", zip="", updated="2026-01-01", source="manual"),
        R("Beth", "Hunt", "liz@x.org", zip="80202", updated="2026-03-01", source="web"),
        R("Eliza", "Hunt", "liz@x.org", zip="80203", updated="2026-02-01", source="import")],
       [O("Liz", "Hunt", "liz@x.org", zip="80202", updated="2026-03-01", source="manual")]))
    a(("manual_case_and_space",
       [R("Liz", "Hunt", "liz@x.org", updated="2026-01-01", source=" Manual "), R("Beth", "Hunt", "liz@x.org", updated="2026-03-01", source="Web")],
       [O("Liz", "Hunt", "liz@x.org", updated="2026-03-01", source="manual")]))
    a(("source_most_recent_when_no_manual",
       [R("Liz", "Hunt", "liz@x.org", updated="2026-01-01", source="Event"), R("Liz", "Hunt", "liz@x.org", updated="2026-03-01", source=" WEB")],
       [O("Liz", "Hunt", "liz@x.org", updated="2026-03-01", source="web")]))
    a(("manual_two_rows_recency",
       [R("Al", "Vik", "al@x.org", updated="2026-01-01", source="manual"), R("Albert", "Vik", "al@x.org", updated="2026-02-01", source="manual"),
        R("Bert", "Vik", "al@x.org", updated="2026-03-01", source="web")],
       [O("Albert", "Vik", "al@x.org", updated="2026-03-01", source="manual")]))
    # order
    a(("output_order_first_appearance",
       [R("Qi", "Ash", "q1@x.org"), R("Ro", "Bay", "q2@x.org"), R("Qi", "Ash", "q1@x.org"), R("Su", "Cox", "q3@x.org")],
       [O("Qi", "Ash", "q1@x.org"), O("Ro", "Bay", "q2@x.org"), O("Su", "Cox", "q3@x.org")]))
    a(("order_with_late_bridge",
       [R("Xi", "Zed", "x@x.org"), R("Yo", "Why", "y@y.org"), R("Xi", "Zed", "", "2065550100"), R("Xi", "Zed", "x@x.org", "2065550100")],
       [O("Xi", "Zed", "x@x.org", "2065550100"), O("Yo", "Why", "y@y.org")]))
    a(("eleven_digit_not_1", [R("Sam", "Orr", "", "22025550100"), R("Tia", "Orr", "tia@x.org", "22025550100")], [O("Tia", "Orr", "tia@x.org", "")]))
    return T


def _random_rows(seed, n=120):
    rng = random.Random(seed)
    people = []
    for i in range(40):
        people.append(dict(first=rng.choice(["Ann", "Bo", "Cy", "Di", "Ed", "Flo", "Gus", "Hal"]),
                           last=rng.choice(["Lee", "Kim", "Ng", "Fox", "Gray", "Ito", "Ruiz", "McCoy", ""]),
                           local=f"user{i}", dom=rng.choice(["gmail.com", "x.org", "googlemail.com", "proton.me"]),
                           phone=f"{rng.randint(200, 999)}555{rng.randint(1000, 9999)}"))
    rows = []
    for _ in range(n):
        p = rng.choice(people)
        local = p["local"]
        if p["dom"] in ("gmail.com", "googlemail.com") and rng.random() < 0.5:
            local = local[:2] + "." + local[2:] + ("+tag" if rng.random() < 0.5 else "")
        email = rng.choice([f"{local}@{p['dom']}", f"{local.upper()}@{p['dom']} ", "", "bad@",
                            f"{p['first']} <{local}@{p['dom']}>"])
        ph = p["phone"]
        phone = rng.choice([ph, "1" + ph, f"({ph[:3]}) {ph[3:6]}-{ph[6:]}", "", "555-1234", f"{ph} x{rng.randint(1, 99)}"])
        y, mo, d = 2026, rng.randint(1, 12), rng.randint(1, 28)
        upd = rng.choice([f"{y}-{mo:02d}-{d:02d}", f"{mo:02d}/{d:02d}/{y}", f"{y}-{mo:02d}-{d:02d}T{rng.randint(0, 23):02d}:15:00"])
        rows.append(R(rng.choice([p["first"], "", " " + p["first"].upper()]), rng.choice([p["last"], p["last"].upper(), p["last"].lower(), ""]),
                      email, phone, rng.choice(["", "02139", "2139", "10001-1234", "abc"]),
                      rng.choice(["", "donor", "Volunteer, donor", "event;;x"]), rng.choice(["", "N", "Y", "yes", "0"]),
                      upd, rng.choice(["import", "web", "Manual", "event", ""])))
    return rows


def all_tests():
    T = _tests()
    for s in (1, 2, 3):
        rows = _random_rows(s)
        T.append((f"random_{s}", rows, reference(rows)))
    return T


HARNESS = r'''
import json, sys, copy, signal
def _handler(signum, frame):
    raise TimeoutError("timeout")
signal.signal(signal.SIGALRM, _handler)
tests = json.load(open(sys.argv[1]))
res = {}
try:
    exec(compile(open(sys.argv[2]).read(), "solution.py", "exec"), globals())
    fn = dedupe_contacts
except Exception as e:
    print(json.dumps({"__load_error__": repr(e)[:300]}))
    sys.exit(0)
for name, rows, expected in tests:
    try:
        signal.alarm(5)
        got = fn(copy.deepcopy(rows))
        signal.alarm(0)
        got = [dict(g) for g in got]
        res[name] = (got == expected)
    except Exception as e:
        signal.alarm(0)
        res[name] = False
print(json.dumps(res))
'''


def extract_code(text):
    blocks = re.findall(r"```(?:python|py)?\s*\n(.*?)```", text, flags=re.S)
    blocks = [b for b in blocks if "def dedupe_contacts" in b]
    return blocks[-1] if blocks else None


def run_tests(code):
    tests = all_tests()
    with tempfile.TemporaryDirectory() as td:
        tp, cp = os.path.join(td, "tests.json"), os.path.join(td, "solution.py")
        json.dump(tests, open(tp, "w"))
        open(cp, "w").write(code)
        hp = os.path.join(td, "harness.py")
        open(hp, "w").write(HARNESS)
        try:
            out = subprocess.run(["python3", "-I", hp, tp, cp], capture_output=True, text=True, timeout=120, cwd=td)
            res = json.loads(out.stdout.strip().splitlines()[-1])
        except Exception as e:
            return {"__error__": repr(e)[:300]}
    return res


def score(text, cond=None):
    code = extract_code(text)
    names = [t[0] for t in all_tests()]
    if code is None:
        return dict(score=0.0, parsed=False, tests={})
    res = run_tests(code)
    if "__load_error__" in res or "__error__" in res:
        return dict(score=0.0, parsed=True, load_error=str(res), tests={})
    passed = {n: bool(res.get(n, False)) for n in names}
    return dict(score=sum(passed.values()) / len(names), parsed=True, tests=passed,
                code_lines=code.count("\n"))
