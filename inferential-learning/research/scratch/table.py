import re, glob, os, collections
here='/home/user/AI-works/inferential-learning/paper'
files=sorted(f for f in glob.glob(here+'/bib/*.bib') if not f.endswith('all.bib'))
first={}; alld=collections.defaultdict(list); info={}
for f in files:
    t=open(f).read()
    for m in re.finditer(r'(?ms)^@(\w+)\s*\{\s*([^,\s]+)\s*,(.*?)(?=^@|\Z)', t):
        k=m.group(2); b=os.path.basename(f)
        alld[k].append(b)
        if k not in first:
            first[k]=b
            body=m.group(3)
            def g(fld):
                mm=re.search(r'\b'+fld+r'\s*=\s*\{(.*)\}\s*,?\s*$', body, re.M|re.I)
                return re.sub(r'[{}\\]','',mm.group(1)) if mm else ''
            au=g('author').split(' and ')[0].split(',')[0].strip()
            info[k]=(au, g('year'))
web={'rivest1988learning','cohen2020pessimism','sawin2013computable','shinohara1994rich','easwaran2015rebutting','incurvati2017maximally','edgington1997vagueness','strevens2008depth','garrabrant2016logical','kivinen1995learning','laymon1987scott','stephan2001learning','odenbaugh2011buyer','cohen2022fully','motoki1991correct','wiedijk2000debruijn','avigad2021reliability','lange1992types','shepherdson1964nonstandard','barzdin1972prediction','gardenfors2006representation','tennenbaum1959non','kuipers1986qualitative','rautenberg1981two','armstrong2018occam','vereshchagin2004kolmogorov'}
flag={'rivest1988reliable':'DUPLICATE of rivest1988learning','elyaniv2010selective':'DUPLICATE of elyaniv2010foundations','li2008kwik':'DUPLICATE of li2008knows','cohen1981irrationality':'DUPLICATE of cohen1981can (pages differ)','cohen1981can':'kept copy; pages 317--370 = article+commentaries','rivest1988learning':'pages 635--640, not 635--639','jiang2023draft':'uncited (harmless)','azzouni2004derivation':'uncited (harmless)'}
byfile=collections.defaultdict(list)
for k,b in first.items(): byfile[b].append(k)
out=[]
for b in sorted(byfile):
    out.append(f"\n**bib/{b}** ({len(byfile[b])} entries kept from this file)\n")
    out.append("| key | first author, year | also defined in | status |\n|---|---|---|---|")
    for k in sorted(byfile[b]):
        au,yr=info[k]; also=', '.join(x for x in alld[k][1:]) or '-'
        st= flag.get(k, 'real; checked by web search' if k in web else 'real; checked from knowledge')
        if k in flag and k in web: st=flag[k]+' (web-checked)'
        out.append(f"| `{k}` | {au} {yr} | {also} | {st} |")
open('/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/table.md','w').write('\n'.join(out))
print(len(first))
