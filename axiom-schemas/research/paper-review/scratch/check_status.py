import re,sys,os
d='/home/user/AI-works/axiom-schemas/paper/sections/'
files=['setting','app-setting','single','app-single','universal','app-universal','zfc','app-zfc','many','app-many','experiments','app-experiments']
envs='theorem|proposition|lemma|corollary|conjecture|definition|example|assumption|remark'
for f in files:
    s=open(d+f+'.tex').read()
    for m in re.finditer(r'\\begin\{('+envs+r')\}(\[[^\]]*\])?',s):
        start=m.end()
        # find end of env
        end=s.find('\\end{'+m.group(1)+'}',start)
        head=s[start:start+400]
        line=s[:m.start()].count('\n')+1
        lab=re.search(r'\\label\{([^}]*)\}',s[m.start():end])
        st=re.search(r'\\status\{([^}]*)\}',head)
        sr=re.search(r'\\src\{([^}]*)\}',head)
        issues=[]
        if not st: issues.append('NO-STATUS')
        if not sr: issues.append('NO-SRC')
        print(f"{f}:{line} {m.group(1)} {lab.group(1) if lab else '-'} status={st.group(1) if st else None} src={sr.group(1) if sr else None} {' '.join(issues)}")
