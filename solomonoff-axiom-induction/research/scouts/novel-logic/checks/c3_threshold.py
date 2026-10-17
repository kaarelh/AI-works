"""c3_threshold.py -- finite checks of the dyadic threshold argument behind the Pi_1
derandomisation theorem (notes.md, section 4, Theorem A1) and of its failure for Sigma_1.

Seed 20261015. Output: c3_threshold.out.

Model. A finite tape space with dyadic weights. Each tape carries either an inconsistent theory
(which proves every sentence) or a consistent one. Sentences:
  * true Pi_1 sentences tp0..tp9 and false Pi_1 sentences fp0..fp4: a consistent theory extending Q
    never proves a false Pi_1 sentence (its negation is a true Sigma_1 sentence, provable in Q);
  * Sigma_1 sentences in exclusive pairs (sa_i, sb_i): no consistent theory proves both members.
For a sentence phi: mu(V_phi) = Pr[theory proves phi] (inconsistent tapes included),
Inc = Pr[inconsistent], F(phi) = mu(V_phi) - Inc = Pr[consistent and proves phi].

Checks, for k = 0..12, with I' := floor(2^(k+2) Inc) / 2^(k+2) and
E_k := {phi Pi_1 : mu(V_phi) > I' + 2^-(k+2)}:
  T1 E_k contains every Pi_1 phi with F(phi) >= 2^-k;
  T2 every member of E_k has F > 0, hence is a true Pi_1 sentence;
  T3 E_k is unchanged when mu(V_phi) is replaced by the limit of increasing lower approximations
     (tapes revealed in a random order; the enumeration only ever adds members);
  T4 (sharpness) the same threshold set formed from Sigma_1 sentences contains both members of an
     exclusive pair in some instances, so it can be inconsistent.
"""
import random
from fractions import Fraction

SEED = 20261015
random.seed(SEED)

TP = [f"tp{i}" for i in range(10)]
FP = [f"fp{i}" for i in range(5)]
SIG = [(f"sa{i}", f"sb{i}") for i in range(6)]
ALL = TP + FP + [s for p in SIG for s in p]


def random_instance():
    ntapes = random.randint(8, 30)
    # dyadic weights: random positive integers over a power of two, total <= 1
    denom = 2 ** 12
    raw = [random.randint(1, 40) for _ in range(ntapes)]
    scale = max(1, sum(raw) // denom + 1)
    weights = [Fraction(r, denom * scale) for r in raw]
    tapes = []
    for w in weights:
        if random.random() < 0.15:
            tapes.append((w, None))  # inconsistent
        else:
            th = {s for s in TP if random.random() < 0.4}
            for a, b in SIG:
                u = random.random()
                if u < 0.3:
                    th.add(a)
                elif u < 0.6:
                    th.add(b)
            tapes.append((w, th))
    return tapes


def proves(th, s):
    return th is None or s in th


def run(trials=300):
    t1 = t2 = t3 = 0
    t4_pairs = 0
    t4_inst = 0
    for _ in range(trials):
        tapes = random_instance()
        inc = sum(w for w, th in tapes if th is None)
        mu = {s: sum(w for w, th in tapes if proves(th, s)) for s in ALL}
        F = {s: mu[s] - inc for s in ALL}
        order = list(range(len(tapes)))
        random.shuffle(order)
        found_pair_this_instance = False
        for k in range(13):
            scale = 2 ** (k + 2)
            Ip = Fraction(int(inc * scale), scale)
            thr = Ip + Fraction(1, scale)
            Ek = {s for s in TP + FP if mu[s] > thr}
            # T1
            for s in TP + FP:
                if F[s] >= Fraction(1, 2 ** k) and s not in Ek:
                    t1 += 1
            # T2
            for s in Ek:
                if not (F[s] > 0 and s in TP):
                    t2 += 1
            # T3: enumerate with increasing lower approximations
            enumerated = set()
            partial = {s: Fraction(0) for s in TP + FP}
            for idx in order:
                w, th = tapes[idx]
                for s in TP + FP:
                    if proves(th, s):
                        partial[s] += w
                for s in TP + FP:
                    if partial[s] > thr:
                        enumerated.add(s)
            if enumerated != Ek:
                t3 += 1
            # T4: Sigma_1 analogue
            Sk = {s for p in SIG for s in p if mu[s] > thr}
            for a, b in SIG:
                if a in Sk and b in Sk:
                    t4_pairs += 1
                    found_pair_this_instance = True
        t4_inst += found_pair_this_instance
    print(f"seed {SEED}; {trials} random instances, k = 0..12")
    print(f"T1 violations (some Pi_1 phi with F >= 2^-k missing from E_k): {t1}")
    print(f"T2 violations (a member of E_k with F = 0 or false): {t2}")
    print(f"T3 violations (enumeration by lower approximations differs from E_k): {t3}")
    print(f"T4 Sigma_1 threshold sets containing both members of an exclusive pair: {t4_pairs} "
          f"(pair, k) cases in {t4_inst} of {trials} instances")
    assert t1 == 0 and t2 == 0 and t3 == 0 and t4_inst > 0
    print("all assertions passed")


if __name__ == "__main__":
    run()
