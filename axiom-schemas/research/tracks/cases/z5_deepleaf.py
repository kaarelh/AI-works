# Track "cases", Part 2(c): no finite union of first-order schemas covers the non-FO schemas without a false
# member.  Deep-leaf lemma (notes.md, Lemma C1): if tau is a first-order schema with |tau| < depth(l),
# s in inst(tau), and every subterm of s at a proper prefix of l occurs only once in s, then for the metavariable
# occurrence q of tau on the path to l:  s[q <- v] in inst(tau) for every closed formula v.
# This script (1) checks the uniqueness hypothesis along the designated path for the families s_n, n <= 10;
# (2) records, for each prefix q, the replacement v in {TOP, BOT} used in the hand proof, and the shape of s|q;
# (3) tests the lemma's conclusion on 3000 random first-order generalisations tau of s_n with |tau| < depth(l).
import sys, random
sys.path.insert(0, '/home/user/AI-works/inferential-learning/research/theory/T1-code')
from terms import match, size as tsize, vars_of
from st_core import *

def negs(k, f):
    for _ in range(k): f = NOT(f)
    return f

# families (bodies with holes): designated leaf = the occurrence whose argument variable differs from the others
FAM = {
    'EInd/named': ('EInd', 'named', lambda n: negs(2 * n, ALL(NOT(IN(V(0), H(0))))), 1),       # leaf in occ 1 (phi(y))
    'ReplJ/named': ('ReplJ', 'named', lambda n: negs(2 * n, IN(H(0), H(1))), 2),             # leaf in occ 2 (phi(x,u))
    'ReplJ/dB': ('ReplJ', 'db', lambda n: negs(2 * n, IN(H(0), H(1))), 2),
    'Coll/dB': ('Coll', 'db', lambda n: negs(2 * n, AND(EQ(H(1), H(0)), IN(H(0), H(2)))), 2),  # leaf A in occ 2
    'ReplU/dB': ('ReplU', 'db', lambda n: negs(2 * n, AND(EQ(H(1), H(0)), IN(H(0), H(2)))), 2),
    'ReplS/dB': ('ReplS', 'db', lambda n: negs(2 * n, AND(EQ(H(1), H(0)), IN(H(0), H(2)))), 3),  # leaf A in occ 3
}
TOPn = ('all', ('w9',), ('eq', ('w9',), ('w9',))); BOTn = ('not', TOPn)
TOPd = to_db(TOP); BOTd = to_db(BOT)

def positions(t, p=()):
    yield p
    if len(t) > 1 and t[0] != '?':
        for i, k in enumerate(t[1:]):
            yield from positions(k, p + (i,))
def at(t, p):
    for i in p: t = t[1 + i]
    return t
def replace(t, p, v):
    if not p: return v
    i = p[0]
    return t[:1 + i] + (replace(t[1 + i], p[1:], v),) + t[2 + i:]
def count_sub(t, u):
    c = 1 if t == u else 0
    if len(t) > 1 and t[0] != '?':
        for k in t[1:]: c += count_sub(k, u)
    return c

def slot_positions(nm, enc):
    """positions (in the T1 encoding) of the P-occurrences, in order"""
    ns = n_slots(nm); sv = ['s%d' % i for i in range(ns)]
    F = named_frame_term(nm, sv) if enc == 'named' else db_frame_term(nm, sv)
    out = {}
    for p in positions(F):
        u = at(F, p)
        if u[0] == '?': out[int(u[1][1:])] = p
    return [out[i] for i in range(ns)]

def leaf_path(s, slotpos):
    """deepest leaf inside the slot, following the chain; returns the full position of the leaf"""
    p = slotpos
    u = at(s, p)
    while len(u) > 1:
        # follow not-chains / binders / last child (the leaf of interest is the last variable of the atom)
        i = len(u) - 2
        p = p + (i,); u = u[1 + i]
    return p

rng = random.Random(5)
for key, (nm, enc, fam, occ) in FAM.items():
    print(key)
    for n in (1, 2, 4, 6, 8, 10):
        body = fam(n)
        s = named_instance(nm, body) if enc == 'named' else to_db(instance(nm, body))
        sp = slot_positions(nm, enc)[occ - 1]
        lp = leaf_path(s, sp)
        prefixes = [lp[:i] for i in range(len(lp))]
        uniq = all(count_sub(s, at(s, q)) == 1 for q in prefixes)
        # random first-order generalisations tau of s with |tau| < depth(leaf): replace an antichain of
        # positions (including one on the path above depth |tau|) by metavariables, equal subterms possibly shared
        ok = tried = 0
        if n in (2, 4, 8):
            for trial in range(500):
                cut = rng.randrange(0, min(len(lp), 12))
                taupos = [lp[:cut]]
                # extra metavariables elsewhere
                allp = [p for p in positions(s) if not (p[:len(lp[:cut])] == lp[:cut]) and not (lp[:cut][:len(p)] == p)]
                rng.shuffle(allp)
                chosen = list(taupos)
                for p in allp[:rng.randrange(0, 6)]:
                    if all(not (p[:len(c)] == c or c[:len(p)] == p) for c in chosen): chosen.append(p)
                tau = s; names = {}
                for i, p in enumerate(sorted(chosen, key=len, reverse=True)):
                    u = at(s, p)
                    nmv = names.setdefault(u, 'm%d' % len(names)) if rng.random() < 0.7 else 'm%d_%d' % (len(names), i)
                    tau = replace(tau, p, ('?', nmv))
                if tsize(tau) >= len(lp): continue
                tried += 1
                assert match(tau, s) is not None
                q = lp[:cut]
                v = TOPn if enc == 'named' else TOPd
                w = BOTn if enc == 'named' else BOTd
                ok += (match(tau, replace(s, q, v)) is not None) and (match(tau, replace(s, q, w)) is not None)
        print('   n=%2d depth(leaf)=%3d |s|=%4d  subterms along the path unique: %s%s' % (
            n, len(lp), tsize(s), uniq, ('   random tau with |tau|<depth: %d/%d contain s[q<-TOP] and s[q<-BOT]' % (ok, tried)) if tried else ''))
    # shapes of s|q for n = 3
    body = fam(3)
    s = named_instance(nm, body) if enc == 'named' else to_db(instance(nm, body))
    sp = slot_positions(nm, enc)[occ - 1]
    lp = leaf_path(s, sp)
    shapes = []
    for i in range(len(lp)):
        u = at(s, lp[:i])
        shapes.append(u[0] if len(u) > 1 else u[0])
    print('   heads along the path (n=3):', ' '.join(shapes))
