# Reviewer checks: shared helpers. Encoding V of pa_common (premise-free axiom step ('st',A);
# induction step ('st',Sub,Sub,concl)), induction variable fixed to the constant x as in
# T7-checks/ind_sub_lgg.py, so sigma has metavariables P,A,B.
import sys, itertools, random
sys.path.insert(0,'/tmp/claude-0/-home-user-AI-works/c4435474-536f-5a96-a73c-7d0c5ea93659/scratchpad/pa-untagged')
from pa_common import *   # lgg_list, match, is_instance, show, Q, ax_V, ind_V, sigma_V, set_partitions_le_k

SIG = sigma_V(False)                     # x fixed: metavariables P, A, B
MVS = sorted(vars_of(SIG))
y_, n_ = C('y'), C('n')

def rand_term(rng, d):
    if d == 0 or rng.random() < 0.3:
        return rng.choice([x, x, Z, y_, n_])
    c = rng.choice(['S', 'add', 'mul'])
    if c == 'S': return S(rand_term(rng, d-1))
    return (c, rand_term(rng, d-1), rand_term(rng, d-1))

def rand_formula(rng, d, root=None, roots=('eq','lt','not','and','or','imp','all','ex')):
    r = root or rng.choice(roots if d > 0 else ('eq','lt'))
    if r in ('eq','lt'): return (r, rand_term(rng, 2), rand_term(rng, 2))
    if r == 'not': return NOT(rand_formula(rng, d-1, roots=roots))
    if r in ('and','or','imp'): return (r, rand_formula(rng, d-1, roots=roots), rand_formula(rng, d-1, roots=roots))
    return (r, rng.choice([y_, n_]), rand_formula(rng, d-1, roots=roots))

def free_in(f, v):
    if f == v: return True
    if len(f) == 1: return False
    if f[0] in ('all','ex') and f[1] == v: return False
    return any(free_in(a, v) for a in f[1:])

def ind(phi): return ind_V(phi, x)
def theta(step): return match(SIG, step)

def failure_sets(thetas):
    fs = set()
    for th in thetas:
        for v in MVS: fs.add(('root', v, th[v][0], len(th[v])))
        for u, v in itertools.combinations(MVS, 2):
            if th[u] == th[v]: fs.add(('eq', u, v))
    return sorted(fs)

def in_fs(th, F):
    if F[0] == 'root': return th[F[1]][0] == F[2] and len(th[F[1]]) == F[3]
    return th[F[1]] == th[F[2]]

def min_cover(thetas, cap=None):
    fs = failure_sets(thetas)
    for r in range(0, (cap or len(fs)) + 1):
        for c in itertools.combinations(fs, r):
            if all(any(in_fs(th, F) for F in c) for th in thetas): return r
    return None

def complete_hyp(slots):
    """a union of schemas contains inst(SIG) iff some slot is at least as general as SIG
    (finitely many proper specializations never cover inst(SIG) over an infinite signature)"""
    return any(match(s, SIG) is not None for s in slots)

def exact(D, k, neg=()):
    """Is the cautious H_k verifier exact, i.e. does every member of VS(D,neg) contain inst(SIG)?
    (ground data are in D, so they are covered.) Minimal members = unions of block-lggs over
    partitions of D into <=k blocks; a member excluded by neg is dropped (its supersets are too)."""
    D = list(dict.fromkeys(D))
    for part in set_partitions_le_k(D, k):
        L = [lgg_list(b) for b in part]
        if any(is_instance(s, l) for s in neg for l in L): continue
        if not complete_hyp(L): return False
    return True

def accepted(q, D, k, neg=()):
    D = list(dict.fromkeys(D))
    for part in set_partitions_le_k(D, k):
        L = [lgg_list(b) for b in part]
        if any(is_instance(s, l) for s in neg for l in L): continue
        if not any(is_instance(q, l) for l in L): return False
    return True
