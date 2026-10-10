"""c3: certificate-carrying axioms (Theorem 4.2(b) of the time-followup notes.md and notes-final.md) on a toy NP-and-coNP language.

Language: X := {n >= 2 : the least prime factor of n is 1 mod 4}.  Sentences phi_n := R(bin(n)).  Both membership and
non-membership have short certificates: the prime factorisation of n (nondecreasing primes, Elias-gamma coded), whose
primes are checked by deterministic Miller-Rabin (bases 2..37, valid below 3.3e24).  V(phi_n, c) = acc if c is a valid
factorisation and its least prime is 1 mod 4, rej if valid and not, None otherwise.  Unique factorisation makes the
assigner f_V consistent (exactly one of acc/rej for each n >= 2).

Axioms: A_V := {phi & theta_c : V(phi, c) = acc} u {~phi & theta_c : V(phi, c) = rej}, |c| <= d(|phi|) := 3|phi| + 8,
with theta_c a valid sentence spelling the bits of c: theta(empty) = tau_E, theta(b c') = (tau_b & theta(c')),
tau_0 = Ax(x=x), tau_1 = ~~Ax(x=x), tau_E = (Ax(x=x)>Ax(x=x)).  All binary connectives are parenthesised.
Decider: parse chi = (psi & theta), read c off theta, check |c| <= d, run V.  It never searches for a factorisation.

Claims checked:
  (1) unique parsing: parse(psi & theta_c) == (psi, c) for random formulas psi (nested conjunctions, negations, the tau
      tokens themselves) and random c;
  (2) the decider accepts phi_n & theta_c (n in X) or ~phi_n & theta_c (n not in X) for the true certificate, and
      rejects the wrong polarity, tampered certificates (a composite or wrong factor, unsorted, wrong product), and
      over-long certificates;
  (3) |chi| <= |psi| + 12 |c| + 20 (a bit costs a token of <= 9 characters plus '(', '&', ')') and
      |c| <= 3|phi| + 8: axiom length, hence the derivation (cite chi, one fixed
      tautology-schema derivation of (B & C) > B, MP), is linear in |phi|;
  (4) decider work (modular multiplications in Miller-Rabin + characters parsed) grows polynomially in |chi|;
  (5) contrast: a deterministic assigner by trial division needs about sqrt(least prime factor) divisions, so the
      unpadded Craig axiom psi^(k+1) for it has length about k |phi|, exponential in |phi| on hard n (products of
      two primes of similar size).
"""
import math
import random

SEED = 31337
rng = random.Random(SEED)
out = []
T0, T1, TE = "Ax(x=x)", "~~Ax(x=x)", "(Ax(x=x)>Ax(x=x))"
MR_BASES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
WORK = [0]


def is_prime(p):
    if p < 2:
        return False
    for q in MR_BASES:
        if p % q == 0:
            return p == q
    d, s = p - 1, 0
    while d % 2 == 0:
        d //= 2
        s += 1
    for a in MR_BASES:
        WORK[0] += d.bit_length() + s
        x = pow(a, d, p)
        if x in (1, p - 1):
            continue
        for _ in range(s - 1):
            x = x * x % p
            if x == p - 1:
                break
        else:
            return False
    return True


def gamma(n):
    b = bin(n)[2:]
    return '0' * (len(b) - 1) + b


def ungamma_all(bits):
    res, i = [], 0
    while i < len(bits):
        z = 0
        while i < len(bits) and bits[i] == '0':
            z += 1
            i += 1
        if i + z + 1 > len(bits):
            return None
        res.append(int(bits[i:i + z + 1], 2))
        i += z + 1
    return res


def pollard_rho(n):
    if n % 2 == 0:
        return 2
    r = random.Random(n)
    while True:
        x = y = r.randrange(2, n)
        c = r.randrange(1, n)
        d = 1
        while d == 1:
            x = (x * x + c) % n
            y = (y * y + c) % n
            y = (y * y + c) % n
            d = math.gcd(abs(x - y), n)
        if d != n:
            return d


def factor(n):
    """Prime factorisation (nondecreasing) by small trial division and Pollard rho; used only to MAKE certificates."""
    f = []
    for p in (2, 3, 5, 7, 11, 13):
        while n % p == 0:
            f.append(p)
            n //= p
    stack = [n] if n > 1 else []
    while stack:
        m = stack.pop()
        if is_prime(m):
            f.append(m)
        else:
            d = pollard_rho(m)
            stack += [d, m // d]
    return sorted(f)


def trial_division_steps(n):
    """Number of trial divisors 2, 3, ... a deterministic assigner tries before it finds the least prime factor
    (or passes sqrt(n)): computed from the factorisation instead of by running it."""
    lpf = factor(n)[0]
    return lpf - 1 if lpf * lpf <= n else math.isqrt(n) - 1


def theta(c):
    s = TE
    for b in reversed(c):
        s = "(" + (T0 if b == '0' else T1) + "&" + s + ")"
    return s


def split_top(chi):
    """chi = (A & B) with A, B well-parenthesised: return (A, B) or None."""
    if not (chi.startswith("(") and chi.endswith(")")):
        return None
    depth = 0
    for i, ch in enumerate(chi):
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif ch == "&" and depth == 1:
            return chi[1:i], chi[i + 1:-1]
    return None


def parse_theta(th):
    bits = []
    while th != TE:
        sp = split_top(th)
        if sp is None or sp[0] not in (T0, T1):
            return None
        bits.append('0' if sp[0] == T0 else '1')
        th = sp[1]
    return ''.join(bits)


def parse(chi):
    sp = split_top(chi)
    if sp is None:
        return None
    c = parse_theta(sp[1])
    return None if c is None else (sp[0], c)


def atom_value(phi):
    if phi.startswith("R(") and phi.endswith(")") and set(phi[2:-1]) <= {'0', '1'} and phi[2:3] == '1':
        return int(phi[2:-1], 2)
    return None


def d_bound(m):
    return 3 * m + 8


def V(phi, c):
    n = atom_value(phi)
    if n is None or n < 2:
        return None
    ps = ungamma_all(c)
    if not ps or any(ps[i] > ps[i + 1] for i in range(len(ps) - 1)) or math.prod(ps) != n:
        return None
    if not all(is_prime(p) for p in ps):
        return None
    return 'acc' if ps[0] % 4 == 1 else 'rej'


def decide(chi):
    WORK[0] += len(chi)
    pc = parse(chi)
    if pc is None:
        return False
    psi, c = pc
    if V(psi, c) == 'acc' and len(c) <= d_bound(len(psi)):
        return True
    if psi.startswith("~"):
        phi = psi[1:]
        return len(c) <= d_bound(len(phi)) and V(phi, c) == 'rej'
    return False


def cert(n):
    return ''.join(gamma(p) for p in factor(n))


def random_formula(depth):
    r = rng.random()
    if depth == 0 or r < 0.3:
        return rng.choice([T0, T1, TE, f"R({bin(rng.randrange(1, 999))[2:]})"])
    if r < 0.5:
        return "~" + random_formula(depth - 1)
    return "(" + random_formula(depth - 1) + rng.choice(["&", ">"]) + random_formula(depth - 1) + ")"


out.append(f"c3_certificate  (seed {SEED})")
# (1) unique parsing
okp = True
for _ in range(3000):
    psi = random_formula(4)
    c = ''.join(rng.choice('01') for _ in range(rng.randrange(0, 40)))
    okp &= parse("(" + psi + "&" + theta(c) + ")") == (psi, c)
out.append(f"(1) unique parsing on 3000 random (psi, c): {okp}")

# (2), (3), (4) on random n, including hard semiprimes
ok2 = ok3a = ok3b = True
rows = []
cases = []
for bits in (12, 20, 28, 36, 44, 52, 60):
    for _ in range(25):
        cases.append(rng.randrange(2 ** (bits - 1), 2 ** bits))
    for _ in range(5):   # semiprimes with two primes of bits/2 bits
        while True:
            p = rng.randrange(2 ** (bits // 2 - 1), 2 ** (bits // 2)) | 1
            q = rng.randrange(2 ** (bits // 2 - 1), 2 ** (bits // 2)) | 1
            if is_prime(p) and is_prime(q):
                break
        cases.append(p * q)
by_len = {}
for n in cases:
    phi = f"R({bin(n)[2:]})"
    c = cert(n)
    inX = factor(n)[0] % 4 == 1
    good = "(" + (phi if inX else "~" + phi) + "&" + theta(c) + ")"
    bad = "(" + ("~" + phi if inX else phi) + "&" + theta(c) + ")"
    WORK[0] = 0
    acc_good = decide(good)
    w = WORK[0]
    ok2 &= acc_good and not decide(bad)
    fs = factor(n)
    tampered = []
    if len(fs) >= 2:
        tampered.append(''.join(gamma(p) for p in reversed(fs)) if fs[0] != fs[-1] else None)  # unsorted
        tampered.append(''.join(gamma(p) for p in [fs[0] * fs[1]] + fs[2:]))                  # composite factor
    tampered.append(''.join(gamma(p) for p in fs[:-1] + [fs[-1] + 2]))                         # wrong product
    tampered.append(c + '0' * (d_bound(len(phi)) + 1))                                         # over-long / garbled
    for t in tampered:
        if t is None:
            continue
        for pol in (phi, "~" + phi):
            ok2 &= not decide("(" + pol + "&" + theta(t) + ")")
    ok3a &= len(good) <= len(phi) + 1 + 12 * len(c) + 20
    ok3b &= len(c) <= d_bound(len(phi))
    by_len.setdefault(len(phi), []).append((len(good), w, trial_division_steps(n)))
out.append(f"(2) decider accepts the right polarity, rejects wrong polarity and tampered certificates: {ok2}")
out.append(f"(3) |chi| <= |psi| + 12|c| + 20: {ok3a};  |c| <= 3|phi| + 8: {ok3b}  (all {len(cases)} cases)")
ok3 = ok3a and ok3b
out.append("")
out.append(f"{'|phi|':>6} {'mean |chi|':>11} {'|chi|/|phi|':>12} {'max work':>10} {'work/|chi|^3':>13} "
           f"{'max trial-div steps':>20} {'Craig axiom len ~ k|phi|':>25}")
for L in sorted(by_len):
    xs = by_len[L]
    mc = sum(x[0] for x in xs) / len(xs)
    mw = max(x[1] for x in xs)
    r3 = max(x[1] / x[0] ** 3 for x in xs)
    td = max(x[2] for x in xs)
    rows.append((L, mc, mw, r3, td))
    out.append(f"{L:>6} {mc:>11.1f} {mc / L:>12.2f} {mw:>10} {r3:>13.2e} {td:>20} {td * L:>25.2e}")
ok4 = max(r[3] for r in rows) < 1.0
out.append("")
out.append(f"(4) decider work <= |chi|^3 on every case: {ok4}")
out.append("(5) the last two columns: trial division (a deterministic assigner) needs up to ~2^(|phi|/2) steps on")
out.append("    semiprimes, so its Craig axioms are exponentially long, while the certificate axioms stay ~linear in |phi|.")
out.append(f"verdict: {'all checks pass' if okp and ok2 and ok3 and ok4 else 'SOME CHECK FAILS'}")

text = "\n".join(out)
print(text)
open(__file__.replace('.py', '.out'), 'w').write(text + "\n")
