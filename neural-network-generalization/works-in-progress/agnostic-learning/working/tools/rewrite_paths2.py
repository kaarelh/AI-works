"""Rewrite scratch-folder references to the repo layout of works-in-progress/agnostic-learning/.

usage: rewrite_paths2.py <where> <mode> <in> <out>
  where: 'notes'        (the output file lives in research-notes/)
         'verification' (the output file lives in verification/)
  mode:  'N'  general documents (B, C, E, red team, literature and their reports):
              A.md / A.r1.md -> the final A note; verify-A-<lens>.md -> first-version A reports
              (all of these documents were written before the A revision existed)
         'A1' A.r1.md itself, the first-version A reports, and the second-round A logic report:
              A.md -> A-first-version.md; verify-A-<lens>.md -> first-version A reports
         'A2' the second-round A computation and scope reports:
              A.md -> A-first-version.md; verify-A-<lens>.md -> second-round A reports
"""
import re, sys

where, mode, src, dst = sys.argv[1:5]
t = open(src).read()
PFX = r"(?:/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/)?(?:scratchpad/)?(?:agnostic/)?"
O = PFX + r"(?:out/)?"
notes = "" if where == "notes" else "../research-notes/"
ver = "../verification/" if where == "notes" else ""
NOTE = {"B": "B-tempered-likelihood.md", "C": "C-fixed-temperature-bayes.md", "E": "E-finite-prior-scale.md"}
A_FINAL = notes + "A-tight-conditioning-fails.md"
A_FIRST = ver + "A-first-version.md"

# ---- revision checks (lead's finalization pass)
t = re.sub(PFX + r"(?:stage/)?check-([ABCE])-r([0-9])/", lambda m: f"../checks/revision-check-{m.group(1)}-{m.group(2)}/", t)
t = re.sub(PFX + r"(?:stage/)?check-([ABCE])-r([0-9])\.md", lambda m: f"{ver}{m.group(1)}-revision-check-{m.group(2)}.md", t)
# ---- referee reports that live inside script folders (before the folder rules)
t = re.sub(O + r"(?:verify_A_r1_scope_scripts/)?round0_verify-A-scope\.md", ver + "A-first-version-scope.md", t)

# ---- script folders (specific before general)
t = re.sub(PFX + r"out/verify_A_r1_(logic|computation|scope)_scripts/?", lambda m: f"../checks/verify-A-{m.group(1)}/", t)
t = re.sub(PFX + r"out/verify_A_(logic|computation|scope)_scripts/?", lambda m: f"../checks/verify-A-first-version-{m.group(1)}/", t)
t = re.sub(PFX + r"out/verify_([BCE])_(logic|computation|scope)_scripts/?", lambda m: f"../checks/verify-{m.group(1)}-{m.group(2)}/", t)
t = re.sub(PFX + r"out/verify_RT_([a-z0-9]+)_(logic|computation)_r1_scripts/?", lambda m: f"../checks/verify-RT-{m.group(1)}-{m.group(2)}-revised/", t)
t = re.sub(PFX + r"out/verify_RT_([a-z0-9]+)_(logic|computation)_scripts/?", lambda m: f"../checks/verify-RT-{m.group(1)}-{m.group(2)}/", t)
RTNOTE = {"width": "small-learner-width", "depth2": "depth-two"}
t = re.sub(PFX + r"out/RT_([a-z0-9]+)_fixed_scripts/?", lambda m: f"../checks/{RTNOTE.get(m.group(1), 'RT-' + m.group(1) + '-revised')}/", t)
t = re.sub(PFX + r"out/A_r1_scripts/?", "../checks/A/", t)
t = re.sub(PFX + r"out/([ACE])_scripts/?", lambda m: f"../checks/{m.group(1)}/", t)
t = re.sub(PFX + r"out/B_checks/?", "../checks/B/", t)
t = re.sub(PFX + r"out/scripts/?", "../checks/red-team-and-literature/", t)
t = re.sub(PFX + r"out/(check_[a-z_]+\.out)", r"../checks/red-team-and-literature/\1", t)
t = re.sub(r"(?<![\w/.-])(check_(?:atom_trainloss|atoms_and_cloning|expconcave_mixable|progressive_mixture)\.out)", r"../checks/red-team-and-literature/\1", t)

# ---- referee reports
t = re.sub(O + r"verify-A-(logic|computation|scope)\.round1\.md", lambda m: f"{ver}A-first-version-{m.group(1)}.md", t)
if mode in ("N", "A1"):
    t = re.sub(O + r"verify-A-(logic|computation|scope)\.md", lambda m: f"{ver}A-first-version-{m.group(1)}.md", t)
else:
    t = re.sub(O + r"verify-A-(logic|computation|scope)\.md", lambda m: f"{ver}A-{m.group(1)}.md", t)
t = re.sub(O + r"verify-([BCE])-(logic|computation|scope)\.md", lambda m: f"{ver}{m.group(1)}-{m.group(2)}.md", t)
t = re.sub(O + r"verify-([ABCE])-\*\.md", lambda m: f"{ver}{m.group(1)}-*.md", t)
t = re.sub(O + r"verify-RT-([a-z0-9]+)-(logic|computation)-r1\.md", lambda m: f"{ver}RT-{m.group(1)}-{m.group(2)}-revised.md", t)
t = re.sub(O + r"verify-RT-([a-z0-9]+)-(logic|computation)\.md", lambda m: f"{ver}RT-{m.group(1)}-{m.group(2)}.md", t)
t = re.sub(O + r"verify-RT-([a-z0-9*]+)-\*\.md", lambda m: f"{ver}RT-{m.group(1)}-*.md", t)
t = re.sub(O + r"RT-([a-z0-9]+)\.fixed\.md", lambda m: f"{notes}{RTNOTE[m.group(1)]}.md", t)

# ---- notes
t = re.sub(O + r"redteam\.md\b", notes + "red-team.md", t)
t = re.sub(O + r"literature\.md\b", notes + "literature.md", t)
t = re.sub(PFX + r"out/A\.r1\.md", A_FINAL, t)
t = re.sub(r"(?<![\w/.-])A\.r1\.md\b", A_FINAL, t)
A_SELF = A_FINAL if mode == "N" else A_FIRST
t = re.sub(PFX + r"out/A\.md", A_SELF, t)
t = re.sub(r"(?<![\w/.-])A\.md\b", A_SELF, t)
t = re.sub(PFX + r"out/([BCE])\.md", lambda m: notes + NOTE[m.group(1)], t)
t = re.sub(r"(?<![\w/.-])([BCE])\.md\b", lambda m: notes + NOTE[m.group(1)], t)
t = re.sub(PFX + r"BRIEF\.md", notes + "problem-brief.md", t)
t = re.sub(r"(?<![\w/.-])out/", "../checks/", t)  # any leftover bare out/ reference
t = re.sub(r"(?<![\w/.-])scratchpad/agnostic/", "", t)
# absolute repository paths -> NNG/ (the project folder neural-network-generalization/ of this repository)
t = re.sub(r"/workspace/ai-works/neural-network-generalization/(?=\S)", "NNG/", t)
t = re.sub(r"/workspace/ai-works/neural-network-generalization/?", "neural-network-generalization/ (the project folder of this repository)", t)
t = re.sub(r"NNG/works-in-progress/agnostic-learning/research-notes/", notes if notes else "", t)
t = re.sub(r"NNG/works-in-progress/agnostic-learning/verification/", ver if ver else "", t)
t = re.sub(r"NNG/works-in-progress/agnostic-learning/checks/", "../checks/", t)
t = re.sub(r"NNG/works-in-progress/agnostic-learning/README\.md", "../README.md", t)
open(dst, "w").write(t)
left = re.findall(r"(/tmp/claude[^\s)`]*|scratchpad[^\s)`]*|/workspace/ai-works[^\s)`]*)", t)
if left:
    print("LEFTOVER in", dst, sorted(set(left))[:8])
