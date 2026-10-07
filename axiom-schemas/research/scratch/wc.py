import re,sys
s=open(sys.argv[1]).read()
s=s.replace('\\begin{abstract}','').replace('\\end{abstract}','').replace('\\noindent','')
s=re.sub(r'\$[^$]*\$','M',s)
s=s.replace('\\DTRC{}','DTRC').replace('~',' ')
s=re.sub(r'\\[a-zA-Z]+','',s)
print(len(s.split()))
