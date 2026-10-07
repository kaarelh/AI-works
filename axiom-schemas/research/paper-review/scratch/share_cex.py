import sys
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from dtrc.syntax import parse, pp
from dtrc.dtrc import DTRC
from dtrc.refute import TemplateRefuter
from dtrc.templates import covers
U_add0 = parse('?t+0=?t'); U_0add = parse('0+?t=?t'); T3 = parse('1+?t=S?t')
D = [parse(s) for s in ['0+0=0', '0+2=2', '1+0=1', '1+1=2']]
for d in D:
    print(pp(d), 'in U_add0/U_0add/T3:', covers(U_add0, d), covers(U_0add, d), covers(T3, d))
m = DTRC(TemplateRefuter('PA', budget=80), share=True).fit(D)
for c in m.clusters:
    print('cluster', [pp(x) for x in c.data], 'acc templates', [pp(T) for T in (c.acc or [])] if isinstance(c.acc, list) else c.acc)
for q in ['2+0=2', '3+0=3', '0+3=3', '1+3=4']:
    print('accepts', q, m.accepts(parse(q)))
# membership-labelled tagged learner for U_add0 sees {0+0=0, 1+0=1}: an anchor (heads 0 and S)
from dtrc.mincover import aligned_min
mins, _ = aligned_min([parse('0+0=0'), parse('1+0=1')])
print('Min of U_add0 membership data:', [pp(T) for T in mins])
