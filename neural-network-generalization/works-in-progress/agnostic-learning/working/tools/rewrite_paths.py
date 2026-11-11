"""Rewrite scratch-folder references to the repo layout of works-in-progress/agnostic-learning/.
usage: rewrite_paths.py <where> <in> <out>, where <where> is 'notes' (file lives in research-notes/)
or 'verification' (file lives in verification/)."""
import re, sys
where, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]
t = open(src).read()
PFX = r"(?:/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/)?(?:scratchpad/)?(?:agnostic/)?"
NOTE = {"A": "A-tight-conditioning-fails.md", "B": "B-tempered-likelihood.md",
        "C": "C-fixed-temperature-bayes.md", "E": "E-finite-prior-scale.md"}
notes = "" if where == "notes" else "../research-notes/"
ver = "../verification/" if where == "notes" else ""
# script folders
t = re.sub(PFX + r"out/verify_([ABCE])_(logic|computation|scope)_scripts/?", lambda m: f"../checks/verify-{m.group(1)}-{m.group(2)}/", t)
t = re.sub(PFX + r"out/([ACE])_scripts/?", lambda m: f"../checks/{m.group(1)}/", t)
t = re.sub(PFX + r"out/B_checks/?", "../checks/B/", t)
t = re.sub(PFX + r"out/scripts/?", "../checks/red-team-and-literature/", t)
t = re.sub(PFX + r"out/(check_[a-z_]+\.out)", r"../checks/red-team-and-literature/\1", t)
# referee reports
t = re.sub(PFX + r"out/verify-([ABCE])-(logic|computation|scope)\.md", lambda m: f"{ver}{m.group(1)}-{m.group(2)}.md", t)
# notes
t = re.sub(PFX + r"out/redteam\.md", notes + "red-team.md", t)
t = re.sub(PFX + r"out/literature\.md", notes + "literature.md", t)
t = re.sub(PFX + r"out/([ABCE])(?:\.r[0-9])?\.md", lambda m: notes + NOTE[m.group(1)], t)
t = re.sub(r"(?<![\w/.-])([ABCE])(?:\.r[0-9])?\.md\b", lambda m: notes + NOTE[m.group(1)], t)
t = re.sub(r"(?<![\w/.-])redteam\.md\b", notes + "red-team.md", t)
t = re.sub(PFX + r"BRIEF\.md", notes + "problem-brief.md", t)
t = re.sub(r"(?<![\w/.-])out/", "../checks/", t)  # any leftover bare out/ reference
open(dst, "w").write(t)
left = re.findall(r"(/tmp/claude[^\s)`]*|scratchpad[^\s)`]*)", t)
if left: print("LEFTOVER in", dst, left[:5])
