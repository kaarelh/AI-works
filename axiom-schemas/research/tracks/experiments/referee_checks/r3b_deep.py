"""R3b: check the logged ZF verdicts with quantifier depth 5-6 in finite structures (memoised brute force)."""
import sys, pickle, random, time
sys.path.insert(0, '.')
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/code')
from indep_eval import Struct, qdepth, strip_close
from dtrc.syntax import pp

def fv(f, cut=0, acc=None):
    if acc is None: acc = set()
    h = f[0]
    if h == 'v':
        if f[1] >= cut: acc.add(f[1] - cut)
        return acc
    if h in ('p', '0'): return acc
    if h in ('all', 'ex'): return fv(f[1], cut + 1, acc)
    for k in f[1:]: fv(k, cut, acc)
    return acc

class MemoStruct(Struct):
    def truth(self, s):
        self.memo = {}; self.fvc = {}
        return self.ev2(strip_close(s), [])
    def ev2(self, f, env):
        h = f[0]
        if h == 'in': return self.mem(env[f[1][1]], env[f[2][1]])
        if h == '=': return env[f[1][1]] == env[f[2][1]]
        k = self.fvc.get(f)
        if k is None:
            k = tuple(sorted(fv(f))); self.fvc[f] = k
        key = (f, tuple(map(lambda i: env[i] if isinstance(env[i], str) else ('hf', env[i]), k)))
        r = self.memo.get(key)
        if r is not None: return r
        if h == 'not': r = not self.ev2(f[1], env)
        elif h == 'and': r = self.ev2(f[1], env) and self.ev2(f[2], env)
        elif h == 'or': r = self.ev2(f[1], env) or self.ev2(f[2], env)
        elif h == 'imp': r = (not self.ev2(f[1], env)) or self.ev2(f[2], env)
        elif h == 'iff': r = self.ev2(f[1], env) == self.ev2(f[2], env)
        elif h == 'all': r = all(self.ev2(f[1], [x] + env) for x in self.M)
        elif h == 'ex': r = any(self.ev2(f[1], [x] + env) for x in self.M)
        self.memo[key] = r
        return r

uniq = pickle.load(open('log_ZF.pkl', 'rb'))
rng = random.Random(11)
structs = [MemoStruct(rng, 7, 0.0, 0.0), MemoStruct(rng, 7, 0.4, 0.4)]
checked = bad = 0; t0 = time.time(); depths = {}
for (lang, s), r in uniq.items():
    if r is None: continue
    d = qdepth(strip_close(s))
    if d <= 4: continue
    depths[d] = depths.get(d, 0) + 1
    checked += 1
    for M in structs:
        if M.truth(s) != r:
            bad += 1; print('CONTRADICTION', r, pp(s)); break
print('deep ZF verdicts checked', checked, 'by depth', depths, 'contradictions', bad, '%.0fs' % (time.time() - t0))
