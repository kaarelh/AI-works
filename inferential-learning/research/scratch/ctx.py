import re, glob, os
here='/home/user/AI-works/inferential-learning/paper'
for f in sorted(glob.glob(here+'/sections/*.tex')):
    lines=open(f).read().split('\n')
    for i,l in enumerate(lines):
        if re.search(r'\\cite', l):
            ctx=' '.join(x.strip() for x in lines[max(0,i-1):i+2])
            print(f"{os.path.basename(f)}:{i+1}: {ctx[:700]}")
            print()
