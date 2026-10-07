import re,sys
S='/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/'
def words(p):
    t=open(S+'bb%d.html'%p).read()
    ws=re.findall(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">([^<]*)</word>',t)
    return [(float(a),float(b),float(c),float(d),w) for a,b,c,d,w in ws]
start=end=None
for p in range(38,57):
    ws=words(p)
    top=76.2; bot=720.2
    for i,w in enumerate(ws):
        if w[4]=='Implementation' and i+2<len(ws) and ws[i+1][4]=='and' and ws[i+2][4]=='experiments' and start is None and ws[i-1][4]=='7':
            start=(p,(bot-w[1])/(bot-top))
        if w[4]=='Discussion' and i>0 and ws[i-1][4]=='8' and end is None:
            end=(p,(w[1]-top)/(bot-top))
print(start,end, 'pages=', (end[0]-start[0]-1)+start[1]+end[1])
