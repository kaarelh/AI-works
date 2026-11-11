"""Assemble hyb_portfolio2 by the integration rule of PROTOCOL.md: the chosen image learner (a copy of the Part 8 portfolio
plus one image member) with its DFG member switched to DFG v1.2 (p9_sum/dfg12.py).  Two textual changes only: the DFG
module path and the default name; the docstring gains a header.  usage: python make_v2.py <p9_gates|p9_bank>"""
import os, sys, hashlib
HERE = os.path.dirname(os.path.abspath(__file__))
src = sys.argv[1]
s = open(os.path.join(HERE, src, "learner.py")).read()
old = 'sp2 = importlib.util.spec_from_file_location("hp_dfg", os.path.join(STUDY, "discrete_learner", "dfg.py"))'
assert s.count(old) == 1
s = s.replace(old, 'sp2 = importlib.util.spec_from_file_location("hp_dfg12", os.path.join(STUDY, "part9", "p9_sum", "dfg12.py"))')
assert s.count(f'name="{src}"') == 1
s = s.replace(f'name="{src}"', 'name="hyb_portfolio2"')
md5 = lambda p: hashlib.md5(open(p, "rb").read()).hexdigest()
head = ('"""hyb_portfolio2 (Part 9): the Part 8 portfolio with (i) its DFG member switched to DFG v1.2 = DFG v1.1 + sum-feature\n'
        f'blocks (part9/p9_sum/dfg12.py, md5 {md5(os.path.join(HERE, "p9_sum", "dfg12.py"))}) and (ii) the image member of {src}\n'
        f'(part9/{src}/learner.py, md5 {md5(os.path.join(HERE, src, "learner.py"))}), chosen by the integration rule of PROTOCOL.md.\n'
        f'This file is {src}/learner.py with two changes: the DFG module path and the default name.\n\n')
assert s.startswith('"""')
s = head + s[3:]
os.makedirs(os.path.join(HERE, "hyb_portfolio2"), exist_ok=True)
open(os.path.join(HERE, "hyb_portfolio2", "learner.py"), "w").write(s)
open(os.path.join(HERE, "hyb_portfolio2", "__init__.py"), "w").close()
print("hyb_portfolio2/learner.py md5", md5(os.path.join(HERE, "hyb_portfolio2", "learner.py")))
