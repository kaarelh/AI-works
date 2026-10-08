# nd.py -- a small proof checker for classical first-order natural deduction in sequent form, used to measure
# the size of explicit derivations between equivalent axiomatisations (track "pa", notes.md section 1).
#
# Syntax (tuples, named variables):
#   terms     ('var',x) ('0',) ('S',t) ('+',t,u) ('*',t,u)
#   formulas  ('=',t,u) ('<',t,u) ('in',t,u) ('pred',P,(t1,..,tk)) ('bot',)
#             ('not',A) ('and',A,B) ('or',A,B) ('imp',A,B) ('iff',A,B) ('all',x,A) ('ex',x,A)
# A predicate symbol ('pred','P',args) stands for a formula metavariable: a derivation that uses P is schematic,
# and substituting a formula for P (with the usual capture conditions) gives a derivation of each instance.
#
# Each proof line is a sequent  Gamma |- A  (Gamma a finite set of formulas, up to alpha-equivalence).  Rules:
#   hyp A                         A |- A
#   ax name [motive]              |- axiom (closed sentence, or instance of a schema at a motive)
#   tc i1..ik  B                  union of hyps |- B,  if  A1 & .. & Ak -> B  is a propositional tautology
#                                 (atoms: maximal subformulas whose head is not a connective, up to alpha)
#   impI i A                      Gamma |- B   ==>  Gamma - {A} |- A -> B
#   allE i t                      Gamma |- all x A  ==>  Gamma |- A[t/x]     (t free for x in A)
#   allI i x                      Gamma |- A  ==>  Gamma |- all x A          (x not free in Gamma)
#   exI i x A t                   Gamma |- A[t/x]  ==>  Gamma |- ex x A
#   exE i j w                     Gamma |- ex x A,  Delta |- B,  A[w/x] in Delta, w not free in ex x A, B,
#                                 Delta - {A[w/x]}   ==>  Gamma u (Delta - {A[w/x]}) |- B
#   refl t                        |- t = t
#   subst i j z A                 Gamma |- s = t,  Delta |- A[s/z]  ==>  Gamma u Delta |- A[t/z]
# The rules are those of a standard sound and complete calculus (classical natural deduction with the
# tautological-consequence rule of Enderton and Shoenfield in place of the propositional introduction and
# elimination rules).  Soundness of each rule is checked by the side conditions below.
import itertools, math

PROP = ('not', 'and', 'or', 'imp', 'iff', 'bot')
QUANT = ('all', 'ex')
ATOMIC = ('=', '<', 'in', 'pred')

class ProofError(Exception):
    pass

# ----------------------------------------------------------------------------------------------- syntax helpers
def V(x): return ('var', x)
Z = ('0',)
def S(t): return ('S', t)
def add(a, b): return ('+', a, b)
def mul(a, b): return ('*', a, b)
def eq(a, b): return ('=', a, b)
def lt(a, b): return ('<', a, b)
def mem(a, b): return ('in', a, b)
def pred(name, *args): return ('pred', name, tuple(args))
def NOT(a): return ('not', a)
def AND(a, b): return ('and', a, b)
def OR(a, b): return ('or', a, b)
def IMP(a, b): return ('imp', a, b)
def IFF(a, b): return ('iff', a, b)
def ALL(x, a): return ('all', x, a)
def EX(x, a): return ('ex', x, a)
BOT = ('bot',)

def is_term(t):
    return t[0] in ('var', '0', 'S', '+', '*')

def fv(e):
    h = e[0]
    if h == 'var': return {e[1]}
    if h in ('0', 'bot'): return set()
    if h in ('S', 'not'): return fv(e[1])
    if h in ('+', '*', '=', '<', 'in', 'and', 'or', 'imp', 'iff'): return fv(e[1]) | fv(e[2])
    if h == 'pred':
        s = set()
        for a in e[2]: s |= fv(a)
        return s
    if h in QUANT: return fv(e[2]) - {e[1]}
    raise ValueError(e)

def allvars(e):
    h = e[0]
    if h == 'var': return {e[1]}
    if h in ('0', 'bot'): return set()
    if h in ('S', 'not'): return allvars(e[1])
    if h in ('+', '*', '=', '<', 'in', 'and', 'or', 'imp', 'iff'): return allvars(e[1]) | allvars(e[2])
    if h == 'pred':
        s = set()
        for a in e[2]: s |= allvars(a)
        return s
    if h in QUANT: return allvars(e[2]) | {e[1]}
    raise ValueError(e)

def subst(e, x, t):
    """e[t/x], capture-avoiding by refusal: raises ProofError if t is not free for x in e."""
    tv = fv(t)
    def go(e, bound):
        h = e[0]
        if h == 'var':
            if e[1] == x:
                if tv & bound:
                    raise ProofError('capture: %s not free for %s' % (show(t), x))
                return t
            return e
        if h in ('0', 'bot'): return e
        if h in ('S', 'not'): return (h, go(e[1], bound))
        if h in ('+', '*', '=', '<', 'in', 'and', 'or', 'imp', 'iff'):
            return (h, go(e[1], bound), go(e[2], bound))
        if h == 'pred': return ('pred', e[1], tuple(go(a, bound) for a in e[2]))
        if h in QUANT:
            if e[1] == x: return e            # x bound here: no free occurrence below
            return (h, e[1], go(e[2], bound | {e[1]}))
        raise ValueError(e)
    return go(e, frozenset())

def akey(e, env=()):
    """alpha-normal key (de Bruijn for bound variables)."""
    h = e[0]
    if h == 'var':
        for i, y in enumerate(reversed(env)):
            if y == e[1]: return ('bv', i)
        return e
    if h in ('0', 'bot'): return e
    if h in ('S', 'not'): return (h, akey(e[1], env))
    if h in ('+', '*', '=', '<', 'in', 'and', 'or', 'imp', 'iff'): return (h, akey(e[1], env), akey(e[2], env))
    if h == 'pred': return ('pred', e[1], tuple(akey(a, env) for a in e[2]))
    if h in QUANT: return (h, akey(e[2], env + (e[1],)))
    raise ValueError(e)

def aeq(a, b): return akey(a) == akey(b)

def size(e):
    """symbol count: every node 1, a quantifier counts 2 (quantifier and its variable)."""
    h = e[0]
    if h in ('var', '0', 'bot'): return 1
    if h in ('S', 'not'): return 1 + size(e[1])
    if h in ('+', '*', '=', '<', 'in', 'and', 'or', 'imp', 'iff'): return 1 + size(e[1]) + size(e[2])
    if h == 'pred': return 1 + sum(size(a) for a in e[2])
    if h in QUANT: return 2 + size(e[2])
    raise ValueError(e)

def count_pred(e, names):
    h = e[0]
    if h in ('var', '0', 'bot'): return 0
    if h in ('S', 'not'): return count_pred(e[1], names)
    if h in ('+', '*', '=', '<', 'in', 'and', 'or', 'imp', 'iff'):
        return count_pred(e[1], names) + count_pred(e[2], names)
    if h == 'pred': return (1 if e[1] in names else 0) + sum(count_pred(a, names) for a in e[2])
    if h in QUANT: return count_pred(e[2], names)
    raise ValueError(e)

def show(e):
    h = e[0]
    if h == 'var': return e[1]
    if h == '0': return '0'
    if h == 'bot': return 'F'
    if h == 'S': return 'S' + show(e[1])
    if h in ('+', '*'): return '(%s%s%s)' % (show(e[1]), h, show(e[2]))
    if h in ('=', '<'): return '%s%s%s' % (show(e[1]), h, show(e[2]))
    if h == 'in': return '%s in %s' % (show(e[1]), show(e[2]))
    if h == 'pred': return '%s(%s)' % (e[1], ','.join(show(a) for a in e[2]))
    if h == 'not': return '~' + show(e[1])
    op = {'and': ' & ', 'or': ' v ', 'imp': ' -> ', 'iff': ' <-> '}
    if h in op: return '(%s%s%s)' % (show(e[1]), op[h], show(e[2]))
    if h == 'all': return 'A%s.%s' % (e[1], show(e[2]))
    if h == 'ex': return 'E%s.%s' % (e[1], show(e[2]))
    raise ValueError(e)

# ----------------------------------------------------------------------------------------------- tautologies
def _atoms(e, acc):
    h = e[0]
    if h == 'bot': return
    if h == 'not': _atoms(e[1], acc); return
    if h in ('and', 'or', 'imp', 'iff'): _atoms(e[1], acc); _atoms(e[2], acc); return
    acc.setdefault(akey(e), len(acc))

def _ev(e, val):
    h = e[0]
    if h == 'bot': return False
    if h == 'not': return not _ev(e[1], val)
    if h == 'and': return _ev(e[1], val) and _ev(e[2], val)
    if h == 'or': return _ev(e[1], val) or _ev(e[2], val)
    if h == 'imp': return (not _ev(e[1], val)) or _ev(e[2], val)
    if h == 'iff': return _ev(e[1], val) == _ev(e[2], val)
    return val[akey(e)]

def tautology(prems, concl):
    acc = {}
    for p in prems: _atoms(p, acc)
    _atoms(concl, acc)
    keys = list(acc)
    if len(keys) > 18: raise ProofError('too many atoms')
    for bits in itertools.product((False, True), repeat=len(keys)):
        val = dict(zip(keys, bits))
        if all(_ev(p, val) for p in prems) and not _ev(concl, val):
            return False
    return True

# ----------------------------------------------------------------------------------------------- proofs
class Line:
    __slots__ = ('hyps', 'concl', 'rule', 'refs', 'written')
    def __init__(self, hyps, concl, rule, refs, written):
        self.hyps = hyps          # dict akey -> formula
        self.concl = concl
        self.rule = rule
        self.refs = refs          # indices of premise lines
        self.written = written    # list of syntax objects the prover must write down (for size accounting)

class Proof:
    """Builds and checks a proof line by line. `axioms`: name -> closed formula;
    `schemas`: name -> function(motive...) -> formula."""
    RULES = ('hyp', 'ax', 'tc', 'impI', 'allE', 'allI', 'exI', 'exE', 'refl', 'subst')

    def __init__(self, axioms, schemas=None, metas=('P', 'R')):
        self.axioms = axioms
        self.schemas = schemas or {}
        self.lines = []
        self.metas = metas
        self.cited = []

    def _add(self, hyps, concl, rule, refs, written):
        self.lines.append(Line(hyps, concl, rule, refs, written))
        return len(self.lines) - 1

    def L(self, i): return self.lines[i]

    # -- rules
    def hyp(self, A):
        return self._add({akey(A): A}, A, 'hyp', [], [A])

    def ax(self, name, *motive):
        if name in self.axioms:
            assert not motive
            A = self.axioms[name]
            if fv(A): raise ProofError('axiom %s not closed' % name)
            written = []
        elif name in self.schemas:
            # a motive is (vars, formula): vars a tuple of distinguished variable names; only the formula is written
            A = self.schemas[name](*motive)
            written = [m[1] for m in motive]
        else:
            raise ProofError('unknown axiom %s' % name)
        self.cited.append(name)
        return self._add({}, A, 'ax', [], written)

    def tc(self, refs, B):
        prems = [self.lines[i].concl for i in refs]
        if not tautology(prems, B):
            raise ProofError('tc fails: %s => %s' % ([show(p) for p in prems], show(B)))
        hyps = {}
        for i in refs: hyps.update(self.lines[i].hyps)
        return self._add(hyps, B, 'tc', list(refs), [B])

    def impI(self, i, A):
        ln = self.lines[i]
        hyps = {k: v for k, v in ln.hyps.items() if k != akey(A)}
        return self._add(hyps, IMP(A, ln.concl), 'impI', [i], [A])

    def allE(self, i, t):
        ln = self.lines[i]
        if ln.concl[0] != 'all': raise ProofError('allE on non-universal')
        x, A = ln.concl[1], ln.concl[2]
        return self._add(dict(ln.hyps), subst(A, x, t), 'allE', [i], [t])

    def allI(self, i, x):
        ln = self.lines[i]
        for h in ln.hyps.values():
            if x in fv(h): raise ProofError('allI: %s free in hypothesis %s' % (x, show(h)))
        return self._add(dict(ln.hyps), ALL(x, ln.concl), 'allI', [i], [V(x)])

    def exI(self, i, x, A, t):
        ln = self.lines[i]
        if not aeq(subst(A, x, t), ln.concl):
            raise ProofError('exI: %s[%s/%s] != %s' % (show(A), show(t), x, show(ln.concl)))
        return self._add(dict(ln.hyps), EX(x, A), 'exI', [i], [A, t])

    def exE(self, i, j, w):
        li, lj = self.lines[i], self.lines[j]
        if li.concl[0] != 'ex': raise ProofError('exE on non-existential')
        x, A = li.concl[1], li.concl[2]
        Aw = subst(A, x, V(w))
        kw = akey(Aw)
        if kw not in lj.hyps: raise ProofError('exE: %s not a hypothesis of line %d' % (show(Aw), j))
        rest = {k: v for k, v in lj.hyps.items() if k != kw}
        if w in fv(li.concl) or w in fv(lj.concl) or any(w in fv(h) for h in rest.values()):
            raise ProofError('exE: eigenvariable %s not fresh' % w)
        hyps = dict(li.hyps); hyps.update(rest)
        return self._add(hyps, lj.concl, 'exE', [i, j], [V(w)])

    def refl(self, t):
        return self._add({}, eq(t, t), 'refl', [], [t])

    def subst(self, i, j, z, A):
        li, lj = self.lines[i], self.lines[j]
        if li.concl[0] != '=': raise ProofError('subst: line %d is not an equation' % i)
        s, t = li.concl[1], li.concl[2]
        if not aeq(subst(A, z, s), lj.concl):
            raise ProofError('subst: %s[%s/%s] != %s' % (show(A), show(s), z, show(lj.concl)))
        hyps = dict(li.hyps); hyps.update(lj.hyps)
        return self._add(hyps, subst(A, z, t), 'subst', [i, j], [A])

    # -- results
    def conclusion(self, i=None):
        ln = self.lines[-1 if i is None else i]
        return ln.hyps, ln.concl

    def check_closed(self, goal):
        hyps, concl = self.conclusion()
        if hyps: raise ProofError('open hypotheses: %s' % [show(h) for h in hyps.values()])
        if not aeq(concl, goal): raise ProofError('wrong conclusion: %s vs %s' % (show(concl), show(goal)))
        return True

    # -- size accounting
    def stats(self, metas=None):
        metas = metas or self.metas
        n = len(self.lines)
        W = sum(size(w) for ln in self.lines for w in ln.written)
        K = sum(count_pred(w, metas) for ln in self.lines for w in ln.written if not is_term(w))
        # K counts written occurrences of the metavariables: under the "naive" code, in which every written
        # formula is written out in full at the instance, each such occurrence is re-coded once per use.
        refs = sum(len(ln.refs) for ln in self.lines)
        return {'lines': n, 'written': W, 'meta_occ': K, 'refs': refs,
                'axiom_lines': sum(1 for ln in self.lines if ln.rule == 'ax')}

    def bits(self, lam, n_axioms):
        """proof-text code length: per line, log2(#rules) for the rule, log2(#axioms) for an axiom citation,
        log2(line index) per premise reference, lam per written symbol."""
        b = 0.0
        for idx, ln in enumerate(self.lines):
            b += math.log2(len(self.RULES))
            if ln.rule == 'ax': b += math.log2(n_axioms)
            for r in ln.refs: b += math.log2(max(idx, 1))
            b += lam * sum(size(w) for w in ln.written)
        return b

    def bits_decodable(self, lam, n_axioms):
        """bits() plus what a decoder also needs (referee issue m4): the number of lines (Elias gamma), the number
        of premises of each tc line (Elias gamma of k+1), and the variable named by each subst line (z) and each exI
        line (the bound variable x), lam bits each.  With these fields the proof text can be parsed back, given the
        theory's axiom list and schema constructors."""
        gamma = lambda k: 2 * math.floor(math.log2(k)) + 1
        b = self.bits(lam, n_axioms) + gamma(len(self.lines))
        for ln in self.lines:
            if ln.rule == 'tc': b += gamma(len(ln.refs) + 1)
            if ln.rule in ('subst', 'exI'): b += lam
        return b

    def dump(self):
        out = []
        for i, ln in enumerate(self.lines):
            out.append('%3d %-6s %-10s {%s} |- %s' % (i, ln.rule, ','.join(map(str, ln.refs)),
                                                    '; '.join(show(h) for h in ln.hyps.values()), show(ln.concl)))
        return '\n'.join(out)
