import re,glob
aux=open('/home/user/AI-works/solomonoff-function-induction/paper/main.aux').read()
lab={}
for m in re.finditer(r'\\newlabel\{([^}@]+)@cref\}\{\{\[([a-z]+)\]\[[^]]*\]\[[^]]*\]([^}]*)\}',aux):
    lab[m.group(1)]=(m.group(2),m.group(3))
# intended mapping: (file, cited text) -> labels
intended={
 'Theorem~3.8':'thm:setting:universal','Theorem~3.11':'thm:setting:weakuniversal','Question~3.14':'q:setting:rpf',
 'Theorem~4.4':'thm:versions:chain','Proposition~4.6':'prop:versions:tape','Proposition~4.7':'prop:versions:shared','Remark~4.8':'rem:versions:sharedsize',
 'Theorem~5.3':'thm:learn:merging','Corollary~5.4':'cor:learn:mistakes','Proposition~5.6':'prop:learn:freshnoise','Proposition~5.7':'prop:learn:perquery',
 'Theorem~6.16':'thm:hist:representation','Corollary~6.17':'cor:hist:H4','Section~7.3':'sec:ex:eisenstat','Proposition~8.1':'prop:ood:hanni',
 'Section~9.1':'sec:comp:time','Theorem~9.10':'thm:comp:ladder','Proposition~10.1':'prop:nn:functionspace','Question~10.9':'q:nn:bridges',
 'Proposition~A.10':'prop:setting:computability','Remark~B.3':'rem:versions:hashing','Remark~G.11':'rem:comp:uniformties','Remark~H.2':'rem:nn:bridge'}
names={'theorem':'Theorem','proposition':'Proposition','remark':'Remark','corollary':'Corollary','question':'Question','section':'Section','subsection':'Section'}
ok=True
for k,l in intended.items():
    t,num=lab[l]
    want=names[t]+'~'+num
    print(('OK ' if want==k else 'BAD'),k,l,want); ok&=(want==k)
used=set()
for f in glob.glob('/home/user/AI-works/solomonoff-function-induction/paper-steeper/sections/*.tex'):
    for m in re.finditer(r'\\cite[tp]\[([^\]]*)\]\{claudeSFI2026fundamentals\}',open(f).read()):
        for x in re.findall(r'(Theorem|Proposition|Remark|Corollary|Question|Section)s?~([A-H0-9]+\.[0-9]+)',m.group(1)):
            used.add(x[0]+'~'+x[1])
print('used not in intended:',used-set(intended)); print('intended not used:',set(intended)-used)
print('ALL OK' if ok else 'MISMATCH')
