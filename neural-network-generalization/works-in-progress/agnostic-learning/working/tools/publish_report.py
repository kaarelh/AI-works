"""Publish a staged check/referee report of the width or depth-two note into verification/, with its scripts.
usage: publish_report.py <stage-name-without-.md> <published-name-without-.md> <stage-dir-or-''> <checks-dir-name> <kind>
kind: 'check' (revision check of a note) or 'referee' (a referee report on the final candidate)"""
import re, sys, os, subprocess, shutil
S='/tmp/claude-0/-workspace/e8ce7448-1256-507d-9f63-d716a14ba11f/scratchpad/agnostic'
R='/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning'
src, dst, sdir, cdir, kind = sys.argv[1:6]
tmp=f'{S}/tools/_tmp_{dst}.md'
subprocess.run(['python3', f'{S}/tools/rewrite_paths2.py', 'verification', 'N', f'{S}/stage/{src}.md', tmp], check=True)
t=open(tmp).read()
MAP_MD={'check-width-r1':'small-learner-width-revision-check-1','check-width-r2':'small-learner-width-revision-check-2',
        'rereferee-depth2-scope-r1':'depth-two-referee-scope-1','rereferee-depth2-scope-r2':'depth-two-referee-scope-2',
        'rereferee-depth2-logic-computation-r1':'depth-two-referee-logic-computation-1','rereferee-depth2-logic-computation-r2':'depth-two-referee-logic-computation-2'}
MAP_DIR={'check-width-r1':'revision-check-small-learner-width-1','check-width-r2':'revision-check-small-learner-width-2',
         'rereferee-depth2-scope-r1':'depth-two-referee-scope-1','rereferee-depth2-scope-r2':'depth-two-referee-scope-2',
         'rereferee-depth2-lc-r1':'depth-two-referee-logic-computation-1','rereferee-depth2-lc-r2':'depth-two-referee-logic-computation-2'}
for k,v in MAP_MD.items():
    t=re.sub(r'(?:stage/)?'+re.escape(k)+r'\.md', v+'.md', t)
for k,v in MAP_DIR.items():
    t=re.sub(r'(?:stage/)?'+re.escape(k)+r'/', '../checks/'+v+'/', t)
if kind=='check':
    note="*Published record of a check of the revised note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed. This check's scripts and outputs are in the `../checks/revision-check-*` folder named below. Re-runs of the note's own scripts, which some reports keep in a `rerun/` subfolder, are not published; each report says whether they reproduced the recorded outputs.*\n\n"
else:
    note="*Published record of a referee report on the final candidate of the note, made during finalization. Paths under `stage/` refer to the lead's unpublished working copies; the pre-revision text there is the version that the second-round referee reports reviewed. The referee's scripts and outputs are in the `../checks/depth-two-referee-*` folder named below. Re-runs of the note's own scripts (`author_rerun/` and similar subfolders) are not published; the report says whether they reproduced the recorded outputs.*\n\n"
lines=t.split('\n',1)
t=lines[0]+'\n\n'+note+(lines[1].lstrip('\n') if len(lines)>1 else '')
open(f'{R}/verification/{dst}.md','w').write(t)
os.remove(tmp)
if sdir:
    d=f'{S}/stage/{sdir}'; out=f'{R}/checks/{cdir}'
    os.makedirs(out, exist_ok=True)
    for f in os.listdir(d):
        p=os.path.join(d,f)
        if os.path.isfile(p) and f.endswith(('.py','.out','.txt')):
            shutil.copy(p, out)
left=re.findall(r"(/tmp/claude[^\s)`]*|scratchpad[^\s)`]*|/workspace/ai-works[^\s)`]*)", t)
print(dst, 'leftover:', left[:5])
