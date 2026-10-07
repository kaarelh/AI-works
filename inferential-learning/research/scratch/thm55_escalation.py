# Thm 5.5 with "escalation answers follow the practice": practices differ between the scenarios,
# so a practice-following labeller y(q)=1[q in R^P] separates them with one query.
def imp(a,b): return ('>',a,b)
def is_MP(st):  (P,c)=st; return len(P)==2 and any(isinstance(f,tuple) and f[0]=='>' and f[1] in P and f[2]==c for f in P)
def is_AC(st):  (P,c)=st; return len(P)==2 and any(isinstance(f,tuple) and f[0]=='>' and f[2] in P and f[1]==c and f!=f[2] for f in P)
def is_AndI(st):(P,c)=st; return isinstance(c,tuple) and c[0]=='&' and set(P)=={c[1],c[2]}
PRACTICE={1:[is_AndI,is_AC,is_MP], 2:[is_AndI,is_AC]}
m_star=(('p',imp('p','F')),'F')            # an MP instance
s=(('q',imp('p','q')),'p')                 # an AC instance outside Sound(R_{AndI,MP})
for sc in (1,2):
    y=int(any(r(m_star) for r in PRACTICE[sc]))
    accepts_s = (y==0)                     # learner: accept AC-instances from t=1 iff the label says 'MP not in practice'
    print('scenario %d: label(m*)=%d  learner accepts s at t=1: %s'%(sc,y,accepts_s))
print('scenario 1 (AC fallacy): error 0 <= delta for every delta; scenario 2: accepts s w.p. 1 at t=1,')
print('but Thm 5.5 claims Pr_2 <= delta*(1-pi)^(-1), i.e. 0 for delta=0.')
