import re,glob,os
os.chdir('/home/user/AI-works/inferential-learning/paper/sections')
for f in sorted(glob.glob('*.tex')):
    txt=open(f).read()
    for m in re.finditer(r'\\label\{([^}]*)\}',txt):
        lab=m.group(1)
        # look back up to 400 chars for \begin{env} and \src
        start=max(0,m.start()-500)
        pre=txt[start:m.start()]
        b=list(re.finditer(r'\\begin\{(\w+)\}',pre))
        env=b[-1].group(1) if b else ''
        seg=pre[b[-1].start():] if b else pre[-150:]
        s=re.findall(r'\\src\{((?:[^{}]|\{[^{}]*\})*)\}',seg)
        # also after label on same para
        post=txt[m.end():m.end()+200]
        s2=re.findall(r'\\src\{((?:[^{}]|\{[^{}]*\})*)\}',post.split('\n')[0])
        lean='leanok' if re.search(r'\\lean(ok|partial)?',txt[m.start():m.start()+3000].split('\\end{')[0]) else ''
        print(f"{f}\t{lab}\t{env}\t{'|'.join(s+s2)}")
