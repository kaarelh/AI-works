"""Prior weight of identity sets that contain a long term, and the resulting pinning bounds.

An identity set is written as a string: its terms in Polish notation, then an end marker. With
an alphabet of a symbols its weight is a^-(length). eps(m) is the total weight of the sets that
contain a term of more than m symbols:
    eps(m) = (1/a) * ( 1/(1 - q^2) - 1/(1 - q_m^2) ),
where q is the total weight a^-size of all terms and q_m that of the terms of size <= m.

Usage: python3 prior_tail.py
"""
from fractions import Fraction
from math import log2


def term_counts(arity, nvars, maxsize):
    T = [0, nvars + 1]
    for s in range(2, maxsize + 1):
        c = T[s - 1]                                   # S(t)
        if arity == 1:
            c += T[s - 1]                              # f(t)
        else:
            c += sum(T[a] * T[s - 1 - a] for a in range(1, s - 1))
        T.append(c)
    return T


def report(name, arity, nvars, core_size, threshold, ns):
    a = nvars + 4
    MAX = 4000
    T = term_counts(arity, nvars, MAX)
    partial = [Fraction(0)]
    for s in range(1, MAX + 1):
        partial.append(partial[-1] + Fraction(T[s], a ** s))
    q = float(partial[-1])                             # the terms beyond MAX weigh less than 1e-300
    print(f"== {name}: alphabet of {a} symbols, weight of all terms q = {q:.6f}, "
          f"weight of all identity sets = {1 / a / (1 - q * q):.6f} ==")
    log_core = -(core_size + 1) * log2(a)
    print(f"   the reference set has {core_size} symbols, weight {a}^-{core_size + 1} = 2^{log_core:.2f}")
    print(f"   {'n':>6s} {'largest harmless side':>22s} {'log2 eps':>10s} {'log2 bound on wrong belief':>27s} {'log2 n':>8s}")
    for n in ns:
        m = threshold(n)
        tail = partial[-1] - partial[m]                # exact weight of the terms of size > m
        qm = float(partial[m])
        log_tail = log2(tail.numerator) - log2(tail.denominator)
        # eps = (q^2 - qm^2) / ((1 - q^2)(1 - qm^2) a), and q^2 - qm^2 = tail * (q + qm)
        log_eps = log_tail + log2((q + qm) / ((1 - q * q) * (1 - qm * qm) * a))
        print(f"   {n:6d} {m:22d} {log_eps:10.1f} {min(log_eps - log_core, 0.0):27.1f} {log2(n):8.1f}")


if __name__ == "__main__":
    ns = [10, 20, 50, 100, 200, 500, 1000]
    # plus: data on [0,n)^2 make every side of at most n+1 symbols harmless
    report("plus (binary f, variables x y z)", 2, 3, 12, lambda n: n + 1, ns)
    # successor: data on [0,n) make every side of at most n symbols harmless
    report("successor (unary f, variables x y)", 1, 2, 4, lambda n: n, ns)
