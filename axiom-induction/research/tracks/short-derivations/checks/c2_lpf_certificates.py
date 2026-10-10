"""c2: certificates for the least-prime-factor data of Example 6.5 (short-derivations/notes.md).

Data: phi_{N,i} := "bit i of the least prime factor of N is 1", for N >= 2 and 0 <= i < bitlength(lpf(N)).
Certificate for N: its factorisation N = p_1^e_1 ... p_k^e_k with p_1 < ... < p_k, and a Pratt certificate for each p_j
(Pratt 1975: p is prime iff some a has a^(p-1) = 1 mod p and a^((p-1)/r) != 1 mod p for every prime r | p-1, the primes r
certified recursively; p = 2 is the base case). The label of phi_{N,i} is bit i of p_1.

The verifier below is independent of sympy: it checks products, order, and the Pratt conditions with Python's pow.
sympy is used only to *generate* test cases (primes, and factorisations of p-1 when building certificates).

Claims checked (they illustrate known facts; nothing here is a proof):
  (1) the verifier accepts every honest certificate, and the label it reads off equals bit i of the true least prime
      factor;
  (2) it rejects tampered certificates: a composite (including Carmichael numbers) presented as prime with any base,
      a non-generator base, a missing prime of p-1, a wrong product, unsorted factors, a non-least first factor;
  (3) certificate size (total bits of all numbers in it) grows like O(log^2 N): the ratio bits / bitlength(N)^2 stays
      bounded; verifier work (modular multiplications) grows polynomially: work / bitlength(N)^3 stays bounded;
  (4) contrast: trial division needs about lpf(N) / 2 divisions, i.e. 2^(bitlength(N)/2 - 1) on balanced semiprimes.
"""
import random
from sympy import isprime, factorint

SEED = 1009
rng = random.Random(SEED)
out = []
WORK = [0]


def mpow(a, e, m):
    WORK[0] += e.bit_length() + bin(e).count('1')
    return pow(a, e, m)


def rand_prime(bits):
    while True:
        p = rng.getrandbits(bits) | (1 << (bits - 1)) | 1
        if bits <= 2:
            p = rng.choice([2, 3])
        if isprime(p):
            return p


def pratt(p):
    """Honest Pratt certificate: (p, a, [(r, e, cert_r), ...]) or (2,)."""
    if p == 2:
        return (2,)
    fac = factorint(p - 1)
    a = 2
    while True:
        if pow(a, p - 1, p) == 1 and all(pow(a, (p - 1) // r, p) != 1 for r in fac):
            break
        a += 1
    return (p, a, [(r, e, pratt(r)) for r, e in sorted(fac.items())])


def verify_pratt(c, depth=0):
    if depth > 200:
        return False
    if c == (2,):
        return True
    if len(c) != 3:
        return False
    p, a, parts = c
    if p < 3 or not (1 < a < p):
        return False
    prod = 1
    for r, e, cr in parts:
        if e < 1 or cr[0] != r:
            return False
        prod *= r ** e
    if prod != p - 1:
        return False
    if mpow(a, p - 1, p) != 1:
        return False
    for r, e, cr in parts:
        if mpow(a, (p - 1) // r, p) == 1:
            return False
        if not verify_pratt(cr, depth + 1):
            return False
    return True


def verify_N(N, cert):
    """cert: list of (p, e, pratt(p)) with p increasing. Returns lpf if valid, else None."""
    if N < 2 or not cert:
        return None
    prod, prev = 1, 1
    for p, e, cp in cert:
        if p <= prev or e < 1 or cp[0] != p:
            return None
        if not verify_pratt(cp):
            return None
        prod *= p ** e
        prev = p
    if prod != N:
        return None
    return cert[0][0]


def bits_of(c):
    if isinstance(c, int):
        return max(1, c.bit_length())
    return sum(bits_of(x) for x in c)


def nprimes(c):
    if c == (2,):
        return 1
    return 1 + sum(nprimes(cr) for _, _, cr in c[2])


def make_case(bits, kind):
    if kind == 'semiprime':
        p, q = rand_prime(bits // 2), rand_prime(bits - bits // 2)
        while p == q:
            q = rand_prime(bits - bits // 2)
        fac = {p: 1, q: 1}
    else:  # random shape: primes of random sizes until about `bits` bits
        fac, total = {}, 0
        while total < bits - 2:
            b = rng.randint(2, max(2, bits - total))
            p = rand_prime(b)
            fac[p] = fac.get(p, 0) + 1
            total += p.bit_length()
    N = 1
    for p, e in fac.items():
        N *= p ** e
    return N, fac


def main():
    out.append(f"c2_lpf_certificates  (seed {SEED})")
    out.append(f"{'bits':>5} {'kind':>10} {'#N':>4} {'max cert bits':>14} {'bits/b^2':>9} {'max #primes':>12} "
               f"{'work/b^3':>9} {'labels ok':>9} {'trial-div steps (max)':>22}")
    all_ok = True
    worst_b2, worst_b3 = 0.0, 0.0
    for bits in (16, 24, 32, 48, 64, 80, 96, 128):
        for kind in ('semiprime', 'random'):
            maxbits, maxpr, maxw, maxtd = 0, 0, 0.0, 0
            labels_ok = True
            ncase = 12
            for _ in range(ncase):
                N, fac = make_case(bits, kind)
                b = N.bit_length()
                cert = [(p, e, pratt(p)) for p, e in sorted(fac.items())]
                WORK[0] = 0
                lpf = verify_N(N, cert)
                w = WORK[0]
                if lpf != min(fac):
                    labels_ok = False
                for i in range(lpf.bit_length()):
                    if ((lpf >> i) & 1) != ((min(fac) >> i) & 1):
                        labels_ok = False
                cb = bits_of([(p, e, cp) for p, e, cp in cert])
                maxbits = max(maxbits, cb)
                worst_b2 = max(worst_b2, cb / b ** 2)
                maxpr = max(maxpr, sum(nprimes(cp) for _, _, cp in cert))
                maxw = max(maxw, w / b ** 3)
                worst_b3 = max(worst_b3, w / b ** 3)
                maxtd = max(maxtd, (min(fac) + 1) // 2)
            all_ok &= labels_ok
            out.append(f"{bits:>5} {kind:>10} {ncase:>4} {maxbits:>14} {maxbits / bits ** 2:>9.3f} {maxpr:>12} "
                       f"{maxw:>9.4f} {str(labels_ok):>9} {maxtd:>22.3e}")
    out.append(f"max over all cases: cert bits / b^2 = {worst_b2:.3f}; work / b^3 = {worst_b3:.4f}")
    out.append("")

    # tampering
    out.append("tampering (each must be rejected):")
    tests = []
    p, q = rand_prime(20), rand_prime(20)
    N = p * q
    honest = [(min(p, q), 1, pratt(min(p, q))), (max(p, q), 1, pratt(max(p, q)))]
    tests.append(("honest certificate (must be ACCEPTED)", verify_N(N, honest) is not None, True))
    # composite presented as prime: N itself with fake Pratt data, all bases a < 50
    fake_ok = False
    for a in range(2, 50):
        fac = factorint(N - 1)
        fake = (N, a, [(r, e, pratt(r)) for r, e in sorted(fac.items())])
        if verify_N(N, [(N, 1, fake)]) is not None:
            fake_ok = True
    tests.append(("composite N presented as a prime, bases 2..49", fake_ok, False))
    for carm in (561, 1105, 1729, 2465, 2821, 6601, 8911, 41041, 825265):
        acc = False
        fac = factorint(carm - 1)
        for a in range(2, 60):
            if verify_pratt((carm, a, [(r, e, pratt(r)) for r, e in sorted(fac.items())])):
                acc = True
        tests.append((f"Carmichael {carm} presented as a prime, bases 2..59", acc, False))
    pp = min(p, q)
    c = pratt(pp)
    a_bad = next(a for a in range(2, pp) if pow(a, pp - 1, pp) == 1 and
                 any(pow(a, (pp - 1) // r, pp) == 1 for r in factorint(pp - 1)))
    tests.append(("non-generator base", verify_pratt((pp, a_bad, c[2])), False))
    if len(c[2]) > 1:
        tests.append(("a prime of p-1 dropped", verify_pratt((pp, c[1], c[2][1:])), False))
    tests.append(("wrong product (N+2)", verify_N(N + 2, honest) is not None, False))
    tests.append(("unsorted factors", verify_N(N, honest[::-1]) is not None, False))
    r3 = rand_prime(8)
    N3 = N * r3
    tests.append(("smaller prime factor listed last (the first listed factor is not the least)",
                  verify_N(N3, honest + [(r3, 1, pratt(r3))]) is not None, False))
    for name, got, want in tests:
        ok = (got == want)
        all_ok &= ok
        out.append(f"  {name}: {'accepted' if got else 'rejected'}  {'ok' if ok else 'FAIL'}")
    out.append("")
    out.append(f"verdict: {'all checks pass' if all_ok else 'FAILURE'}")


if __name__ == '__main__':
    main()
    text = "\n".join(out)
    print(text)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(text + "\n")
