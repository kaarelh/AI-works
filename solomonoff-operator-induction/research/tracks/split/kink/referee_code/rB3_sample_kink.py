"""rB3 (referee B): simulations of notes.md Section 5 (a sample from nu has a kink at l0).

Sampling scheme (wor): n inputs uniformly WITHOUT replacement from X0 = {0,1}^d (M = 2^d), labels
y_i ~ nu(.|x_i), nu = noisy parity (a*, flip prob p = 1/4).  mu = uniform on X0.

Class (prefix code; Kraft sum <= 5/8): 3-bit tag, then
  rate code: '0' = deterministic (flip prob 0), or '1' + gamma(b) + (b-1) bits for q = j/2^b, j odd,
             b <= BMAX;  F0 det additionally names its constant (1 bit)
  F0  constant Bern(q) for label 1                       3 + rate
  F1  parity a' in {0,1}^d with flip prob q               3 + d + rate          (pi* = F1(a*, p))
  F2  partial parity: last v coords unknown (v >= 1), per-input mixture over completions
                                                          3 + gamma(v) + (d-v) + rate
  F3  F1(a', q) plus a named set J of j inputs ANYWHERE in X0 (index among C(M, j)), on which the
      label is deterministically f_a'(x) xor 1           3 + d + rate + gamma(j) + ceil(log2 C(M, j))
  F4  lookup table                                        3 + M
Only F1(a*, p) is mu-a.e. equal to nu, so l0 = l(pi*).

E1 (d = 8, BMAX = 4): Lemma 5.2 checked EXACTLY over the WHOLE class, including F3 programs whose
   exceptions lie outside the sample (they have a large Hellinger gap but the same fit) and the
   lookup tables, through a closed-form minimisation over J by input classes; Ville; Prop 5.8 against
   the empirical identification frequency; lambda-MAP frequencies including lambda = 1.
E2 (d = 12, BMAX = 3): Thm 5.4 (i)-(iii), Cor 5.5, Thm 5.6 (with W_near counted exactly over the
   class, F3 included) against the exact hull of each sample; lambda = 1 and the right slope as n -> M.

Seeded: numpy default_rng(4242) (E1) and default_rng(4343) (E2).
"""
import math
import numpy as np

LOG2E = math.log2(math.e)
P_TRUE = 0.25


def gamma(k):
    return 2 * int(math.floor(math.log2(k))) + 1


def log2C(n, k):
    return (math.lgamma(n + 1) - math.lgamma(k + 1) - math.lgamma(n - k + 1)) / math.log(2)


def rate_list(bmax):
    out = [(0.0, 1)]
    for b in range(1, bmax + 1):
        for j in range(1, 2 ** b, 2):
            out.append((j / 2 ** b, 1 + gamma(b) + b - 1))
    return out


def h(r, p=P_TRUE):
    """per-input squared Hellinger distance between nu(.|x) (prob 1-p on c = f*(x)) and a program
    giving probability r to c and 1-r to the other label."""
    return 1.0 - math.sqrt((1 - p) * r) - math.sqrt(p * (1 - r))


def fit(mis, tot, q):
    """-log2 likelihood of tot labels, mis of which disagree with the predicted bit, flip prob q;
    numpy-friendly."""
    mis = np.asarray(mis, dtype=float)
    tot = np.asarray(tot, dtype=float)
    if q == 0.0:
        return np.where(mis == 0, 0.0, np.inf)
    return -(mis * math.log2(q) + (tot - mis) * math.log2(1 - q))


def wht(v):
    hh = np.asarray(v, dtype=np.int64).copy()
    n = len(hh)
    s = 1
    while s < n:
        hh = hh.reshape(-1, 2, s)
        a, b = hh[:, 0, :].copy(), hh[:, 1, :].copy()
        hh[:, 0, :], hh[:, 1, :] = a + b, a - b
        hh = hh.reshape(n)
        s *= 2
    return hh


def parity_bits(a, d):
    x = np.arange(2 ** d, dtype=np.int64)
    v = np.zeros(2 ** d, dtype=np.int64)
    aa = a
    k = 0
    while aa:
        if aa & 1:
            v ^= (x >> k) & 1
        aa >>= 1
        k += 1
    return v


class Instance:
    def __init__(self, d, bmax, astar):
        self.d, self.M = d, 2 ** d
        self.R = rate_list(bmax)
        self.astar = astar
        self.fstar = parity_bits(astar, d)
        self.q_p = next(c for q, c in self.R if q == P_TRUE)
        self.l0 = 3 + d + self.q_p
        self.F3len = {j: 3 + d + gamma(j) + math.ceil(log2C(self.M, j) - 1e-12) for j in range(1, self.M + 1)}

    # ---------------- population Hellinger gaps, by family and length
    def hel_programs(self):
        """yield (length, Hel, count, label) for every program family member (counts for symmetric
        groups); F3 handled by min over J (and exact counts of J with a given Hel)."""
        d, M = self.d, self.M
        out = []
        for q, c in self.R:
            if q == 0.0:
                out.append((3 + c + 1, (h(1.0) + h(0.0)) / 2, 2, "F0 det"))
            else:
                out.append((3 + c, (h(q) + h(1 - q)) / 2, 1, f"F0 q={q:g}"))
            out.append((3 + d + c, h(1 - q), 1, f"F1 a* q={q:g}"))
            out.append((3 + d + c, (h(1 - q) + h(q)) / 2, M - 1, f"F1 a'!=a* q={q:g}"))
            for v in range(1, d + 1):
                f0 = 2.0 ** -v
                L = 3 + gamma(v) + (d - v) + c
                out.append((L, f0 * h(1 - q) + (1 - f0) * h(0.5), 1, f"F2 v={v} true prefix q={q:g}"))
                if 2 ** (d - v) > 1:
                    out.append((L, f0 * (h(1 - q) + h(q)) / 2 + (1 - f0) * h(0.5), 2 ** (d - v) - 1, f"F2 v={v} other q={q:g}"))
        return out

    def f3_hel(self, q, j, same):
        """min Hel of F3(a', q, J) over J with |J| = j, and the log2-count of J attaining each value is
        not needed for the minimum; same = (a' == a*)."""
        M = self.M
        if same:
            base = h(1 - q)
            return ((M - j) * base + j * h(0.0)) / M
        # a' != a*: agreement half (base h(1-q), J-label gives h(0)) and disagreement half (base h(q),
        # J-label = f* gives h(1))
        deltas = sorted([(h(0.0) - h(1 - q), M // 2), (h(1.0) - h(q), M // 2)])
        tot = (M // 2) * (h(1 - q) + h(q))
        rem = j
        for dv, cnt in deltas:
            take = min(rem, cnt)
            tot += take * dv
            rem -= take
        return tot / M

    def gamma_profile(self, lmax):
        """gamma(l) = min{Hel > 0 : length l}, for l <= lmax (inf if none)."""
        g = {}
        for L, hel, cnt, lab in self.hel_programs():
            if hel > 1e-15 and L <= lmax:
                g[L] = min(g.get(L, math.inf), hel)
        for q, c in self.R:
            for j in range(1, self.M + 1):
                L = self.F3len[j] + c
                if L > lmax:
                    continue
                for same in (True, False):
                    hel = self.f3_hel(q, j, same)
                    if hel > 1e-15:
                        g[L] = min(g.get(L, math.inf), hel)
        if 3 + self.M <= lmax:
            g[3 + self.M] = min(g.get(3 + self.M, math.inf), h(1.0))
        return g

    def w_near(self, lam, gam, lbar):
        """W_near(lambda, gamma) = sum over near programs (0 < Hel < gamma), l0 < l <= lbar, of
        2^{-lambda (l - l0)}; F3 counted exactly by the composition of J."""
        l0, M = self.l0, self.M
        logs = []
        for L, hel, cnt, lab in self.hel_programs():
            if l0 < L <= lbar and 0 < hel < gam:
                logs.append(math.log2(cnt) - lam * (L - l0))
        for q, c in self.R:
            for j in range(1, M + 1):
                L = self.F3len[j] + c
                if L > lbar:
                    continue
                if L <= l0:
                    continue
                # a' = a*: all C(M, j) sets have the same Hel
                hel = ((M - j) * h(1 - q) + j * h(0.0)) / M
                if 0 < hel < gam:
                    logs.append(log2C(M, j) - lam * (L - l0))
                # a' != a*: i elements of J in the disagreement half
                for i in range(0, j + 1):
                    if i > M // 2 or j - i > M // 2:
                        continue
                    hel = ((M // 2) * (h(1 - q) + h(q)) + i * (h(1.0) - h(q)) + (j - i) * (h(0.0) - h(1 - q))) / M
                    if 0 < hel < gam:
                        logs.append(math.log2(M - 1) + log2C(M // 2, i) + log2C(M // 2, j - i) - lam * (L - l0))
        if not logs:
            return 0.0
        mx = max(logs)
        return 2.0 ** mx * sum(2.0 ** (x - mx) for x in logs)

    # ---------------- one sample
    def sample(self, rng, n):
        idx = rng.choice(self.M, size=n, replace=False)
        flips = (rng.random(n) < P_TRUE).astype(np.int64)
        y = self.fstar[idx] ^ flips
        return idx, y, flips

    def per_length_best(self, idx, y):
        """exact rho per length: dict length -> [min fit, label, number of programs attaining it]."""
        d, M, n = self.d, self.M, len(idx)
        best = {}

        def put(L, val, lab):
            cur = best.get(L)
            if cur is None or val < cur[0] - 1e-12:
                best[L] = [val, lab, 1]
            elif abs(val - cur[0]) <= 1e-12 and math.isfinite(val):
                cur[2] += 1

        n1 = int(y.sum())
        s = np.zeros(M, dtype=np.int64)
        s[idx] = 1 - 2 * y
        c = wht(s)
        m = (n - c) // 2  # mismatches of every parity on the sample
        U = np.unique(m)  # sorted distinct mismatch counts
        js = np.arange(1, M + 1)
        F3l = np.array([self.F3len[j] for j in range(1, M + 1)])
        # F3 with j named inputs: L depends on a' only through its mismatch count mm, and equals
        # fit(mm - min(j, mm), n - min(j, mm), q) if j <= mm + (M - n) (J holds min(j, mm) sampled
        # mismatches and the rest unsampled inputs), else +inf.  For fixed j and q this is monotone in mm
        # on {mm >= j} and on {mm < j}, so the minimum over a' is attained at one of: the smallest mm >= j,
        # the largest mm < j, the largest mm <= j, or the largest mm overall.
        i_ge = np.searchsorted(U, js, side="left")
        i_le = np.searchsorted(U, js, side="right") - 1
        cands = []
        cands.append(np.where(i_ge < len(U), U[np.minimum(i_ge, len(U) - 1)], -1))
        cands.append(np.where(i_ge - 1 >= 0, U[np.maximum(i_ge - 1, 0)], -1))
        cands.append(np.where(i_le >= 0, U[np.maximum(i_le, 0)], -1))
        cands.append(np.full(M, U[-1]))
        for q, cq in self.R:
            if q == 0.0:
                put(3 + cq + 1, 0.0 if n1 in (0, n) else math.inf, "F0 det")
            else:
                put(3 + cq, -(n1 * math.log2(q) + (n - n1) * math.log2(1 - q)), f"F0 q={q:g}")
            # F1: a* first (so that a tie with another parity is counted, not hidden)
            put(3 + d + cq, float(fit(m[self.astar], n, q)), f"F1 a'=a* q={q:g}")
            for ap in {int(np.argmin(m)), int(np.argmax(m))} - {self.astar}:
                put(3 + d + cq, float(fit(m[ap], n, q)), f"F1 a'={ap} q={q:g}")
            # F3: best over all a' (through mm) for each j
            Lbest = np.full(M, np.inf)
            for cm in cands:
                ok = (cm >= 0) & (js <= cm + (M - n))
                j1 = np.minimum(js, np.maximum(cm, 0))
                Lc = np.where(ok, fit(np.maximum(cm, 0) - j1, n - j1, q), np.inf)
                Lbest = np.minimum(Lbest, Lc)
            fin_ = np.isfinite(Lbest)
            for j, val in zip(js[fin_], Lbest[fin_]):
                put(int(F3l[j - 1]) + cq, float(val), f"F3 j={j} q={q:g}")
        # F2
        for v in range(1, d + 1):
            Nh = 2 ** (d - v)
            zt = idx < Nh
            nzt = int(zt.sum())
            ss = np.zeros(Nh, dtype=np.int64)
            ss[idx[zt]] = 1 - 2 * y[zt]
            msub = (nzt - wht(ss)) // 2 if Nh > 1 else np.array([int((y[zt] != 0).sum())])
            pmin, pmax = int(np.argmin(msub)), int(np.argmax(msub))
            for q, cq in self.R:
                for pre in {pmin, pmax}:
                    put(3 + gamma(v) + (d - v) + cq, (n - nzt) + float(fit(msub[pre], nzt, q)), f"F2 v={v} q={q:g}")
        put(3 + M, 0.0, "F4 table")
        # parity ties at l0: another parity with the same mismatch count as a* also attains L0
        if (m == m[self.astar]).sum() > 1 and best[self.l0][1].startswith("F1 a'=a*"):
            best[self.l0][2] = max(best[self.l0][2], int((m == m[self.astar]).sum()))
        return best, m

    def lemma52_slack(self, idx, y, flips, m):
        """S = min over the WHOLE class of (L - L0 - 2 log2e n Hel + 2 l)/2 (exact)."""
        d, M, n = self.d, self.M, len(idx)
        k = int(flips.sum())
        L0 = -(k * math.log2(P_TRUE) + (n - k) * math.log2(1 - P_TRUE))
        A = 2 * LOG2E * n
        best = math.inf
        fammin = {}

        def rec(cur, f, val):
            fammin[f] = min(fammin.get(f, math.inf), val)
            return min(cur, val)

        n1 = int(y.sum())
        for q, cq in self.R:
            # F0
            if q == 0.0:
                L = 0.0 if n1 in (0, n) else math.inf
                best = rec(best, "F0", L - L0 - A * (h(1.0) + h(0.0)) / 2 + 2 * (3 + cq + 1))
            else:
                L = -(n1 * math.log2(q) + (n - n1) * math.log2(1 - q))
                best = rec(best, "F0", L - L0 - A * (h(q) + h(1 - q)) / 2 + 2 * (3 + cq))
        # F2
        for v in range(1, d + 1):
            Nh = 2 ** (d - v)
            zt = idx < Nh
            nzt = int(zt.sum())
            ss = np.zeros(Nh, dtype=np.int64)
            ss[idx[zt]] = 1 - 2 * y[zt]
            msub = (nzt - wht(ss)) // 2 if Nh > 1 else np.array([int((y[zt] != 0).sum())])
            f0 = 2.0 ** -v
            truepre = self.astar & (Nh - 1)
            for q, cq in self.R:
                Ls = (n - nzt) + fit(msub, nzt, q)
                hel = np.full(Nh, f0 * (h(1 - q) + h(q)) / 2 + (1 - f0) * h(0.5))
                hel[truepre] = f0 * h(1 - q) + (1 - f0) * h(0.5)
                best = rec(best, "F2", float(np.min(Ls - L0 - A * hel)) + 2 * (3 + gamma(v) + (d - v) + cq))
        # F1 and F3, all a': class counts via WHT
        s_samp = np.zeros(M, dtype=np.int64)
        s_samp[idx] = 1
        s_flip = np.zeros(M, dtype=np.int64)
        s_flip[idx[flips == 1]] = 1
        Ws = wht(s_samp)  # indexed by b = a' xor a*
        Wf = wht(s_flip)
        js = np.arange(1, M + 1)
        F3l = np.array([self.F3len[j] for j in range(1, M + 1)], dtype=float)
        for b in range(M):
            ap = b ^ self.astar
            if b == 0:
                nA, kA = n, k
                uA, uD = M - n, 0
            else:
                nA = (n + int(Ws[b])) // 2
                kA = (k + int(Wf[b])) // 2
                uA, uD = M // 2 - nA, M // 2 - (n - nA)
            c1 = kA                      # sampled, agreement half, flipped: y = f_a' xor 1
            c2 = (n - nA) - (k - kA)     # sampled, disagreement half, not flipped: y = f* = f_a' xor 1
            mis = c1 + c2
            assert mis == m[ap]
            for q, cq in self.R:
                hq_a = h(1 - q)
                hq_d = h(q)
                hel_F1 = hq_a if b == 0 else (hq_a + hq_d) / 2
                l_F1 = 3 + d + cq
                if q > 0:
                    L_F1 = -(mis * math.log2(q) + (n - mis) * math.log2(1 - q))
                    best = rec(best, "F1", L_F1 - L0 - A * hel_F1 + 2 * l_F1)
                    lg = -math.log2(q)
                    cls = [(lg + A * (h(0.0) - hq_a) / M, c1), (lg + A * (h(1.0) - hq_d) / M, c2),
                           (A * (h(0.0) - hq_a) / M, uA), (A * (h(1.0) - hq_d) / M, uD)]
                    cls = sorted([cl for cl in cls if cl[1] > 0], key=lambda t: -t[0])
                    vals = np.concatenate([np.full(cnt, val) for val, cnt in cls]) if cls else np.zeros(0)
                    top = np.cumsum(vals)
                    jj = len(top)
                    if jj:
                        sl = (L_F1 - L0 - A * hel_F1) - top + 2 * (F3l[:jj] + cq)
                        best = rec(best, "F3", float(sl.min()))
                else:
                    # deterministic: J must contain all mis sampled mismatches; then add unsampled
                    base = -L0 - A * (hel_F1 + (c1 * (h(0.0) - hq_a) + c2 * (h(1.0) - hq_d)) / M)
                    cls = [(A * (h(0.0) - hq_a) / M, uA), (A * (h(1.0) - hq_d) / M, uD)]
                    cls = sorted([cl for cl in cls if cl[1] > 0], key=lambda t: -t[0])
                    vals = np.concatenate([[0.0]] + [np.full(cnt, val) for val, cnt in cls])
                    top = np.cumsum(vals)  # top[t] = value of t extra unsampled inputs
                    if mis == 0:
                        best = rec(best, "F1", base + 2 * l_F1)
                        jlist = np.arange(1, len(top))
                        if len(jlist):
                            sl = base - top[1:] + 2 * (F3l[jlist - 1] + cq)
                            best = rec(best, "F3", float(sl.min()))
                    else:
                        jlist = mis + np.arange(0, len(top))
                        ok = jlist <= M
                        sl = base - top[ok] + 2 * (F3l[jlist[ok] - 1] + cq)
                        best = rec(best, "F3", float(sl.min()))
        # F4: consistent table, unsampled labels chosen to maximise Hel
        hel_s = np.where(flips == 1, h(0.0), h(1.0)).sum()
        hel_T = (hel_s + (M - n) * max(h(0.0), h(1.0))) / M
        best = rec(best, "F4", 0.0 - L0 - A * hel_T + 2 * (3 + M))
        self.last_fam = min(fammin, key=fammin.get)
        return best / 2, L0


def hull_from_best(best):
    """lower-left hull vertices from the per-length best fits."""
    pts = sorted((L, v[0]) for L, v in best.items() if math.isfinite(v[0]))
    par = []
    cur = math.inf
    for l, f in pts:
        if f < cur - 1e-12:
            par.append((l, f))
            cur = f
    H_ = []
    for p in par:
        while len(H_) >= 2:
            (x1, y1), (x2, y2) = H_[-2], H_[-1]
            if (y2 - y1) * (p[0] - x1) >= (p[1] - y1) * (x2 - x1) - 1e-9:
                H_.pop()
            else:
                break
        H_.append(p)
    return H_


def map_label(best, lam):
    """(J, length, label) of the lambda-MAP point and whether the MAP is NOT a unique program (a tie
    across lengths, or several programs attaining the best fit at the MAP length)."""
    items = [(lam * l + v[0], l, v[1], v[2]) for l, v in best.items() if math.isfinite(v[0])]
    items.sort()
    top = items[0]
    tie = [it for it in items if it[0] <= top[0] + 1e-9]
    return top[:3], (len(set(it[1] for it in tie)) > 1) or top[3] > 1


def pistar_is_map(best, lam, l0, L0):
    m = min(lam * l + v[0] for l, v in best.items() if math.isfinite(v[0]))
    return lam * l0 + L0 <= m + 1e-9


def category(lab):
    if lab.startswith("F1 a'=a* q=0.25"):
        return "pi*"
    if lab.startswith("F1 a'=a*"):
        return "parity,other rate"
    if lab.startswith("F2"):
        return "partial parity"
    if lab.startswith("F3") or lab.startswith("F4"):
        return "memoriser/fill-in"
    if lab.startswith("F0"):
        return "constant"
    return "wrong parity"


def run_E0():
    """self-test of the closed forms: brute force over EVERY program of the class at d = 4."""
    print("=" * 110)
    print("E0: self-test at d = 4 (M = 16), BMAX = 2: closed-form Lemma 5.2 minimum and per-length fits")
    print("    against brute force over every program (all a', q, all 2^16 sets J, all 2^16 tables)")
    rng = np.random.default_rng(4141)
    d = 4
    ins = Instance(d, 2, 11)
    M = ins.M
    X = np.arange(M)
    masks = np.arange(2 ** M, dtype=np.int64)
    inJ = ((masks[:, None] >> X[None, :]) & 1).astype(bool)  # (2^M, M)
    jsz = inJ.sum(1)
    fst = ins.fstar
    maxdiff_S, maxdiff_rho, nchk = 0.0, 0.0, 0
    for n in (3, 6, 10, 16):
        for _ in range(4):
            idx, y, flips = ins.sample(rng, n)
            best, m = ins.per_length_best(idx, y)
            S, L0 = ins.lemma52_slack(idx, y, flips, m)
            A = 2 * LOG2E * n
            samp = np.zeros(M, bool)
            samp[idx] = True
            ylab = np.zeros(M, np.int64)
            ylab[idx] = y
            bf = {}
            bS = math.inf

            def rec(L, fitv, slack):
                nonlocal bS
                if fitv < bf.get(L, math.inf):
                    bf[L] = fitv
                bS = min(bS, slack)

            # F0, F1, F2 via explicit per-input probabilities
            for q, cq in ins.R:
                progs = []
                if q == 0.0:
                    for val in (0, 1):
                        progs.append((3 + cq + 1, np.full(M, val), np.zeros(M)))
                else:
                    # F0 Bern(q): predicted label 1, 'flipped' w.p. 1 - q, so P(label 1) = q
                    progs.append((3 + cq, np.ones(M, np.int64), np.full(M, 1 - q)))
                for ap in range(M):
                    progs.append((3 + d + cq, parity_bits(ap, d), np.full(M, q)))
                for v in range(1, d + 1):
                    Nh = 2 ** (d - v)
                    for pre in range(Nh):
                        lab = parity_bits(pre, d)
                        fl = np.where(X < Nh, q, 0.5)
                        progs.append((3 + gamma(v) + (d - v) + cq, lab, fl))
                for (L, lab, fl) in progs:
                    # program: label lab(x) w.p. 1 - fl(x), else the other label
                    pr_y = np.where(ylab == lab, 1 - fl, fl)
                    with np.errstate(divide="ignore"):
                        fitv = float(-np.log2(pr_y[samp]).sum())
                    r = np.where(lab == fst, 1 - fl, fl)
                    hel = float(np.mean([h(rr) for rr in r]))
                    rec(L, fitv, fitv - L0 - A * hel + 2 * L)
                # F3, all a' and all J
                for ap in range(M):
                    lab = parity_bits(ap, d)
                    base_pr_y = np.where(ylab == lab, 1 - q, q)  # outside J
                    with np.errstate(divide="ignore"):
                        nl_out = -np.log2(base_pr_y)
                    nl_in = np.where(ylab == (lab ^ 1), 0.0, np.inf)  # inside J: label lab^1 surely
                    per = np.where(inJ, nl_in[None, :], nl_out[None, :])
                    fitv = np.where(samp[None, :], per, 0.0).sum(1)
                    r_out = np.where(lab == fst, 1 - q, q)
                    r_in = np.where((lab ^ 1) == fst, 1.0, 0.0)
                    hv = np.vectorize(h)
                    hel = np.where(inJ, hv(r_in)[None, :], hv(r_out)[None, :]).mean(1)
                    for j in range(1, M + 1):
                        sel = jsz == j
                        L = ins.F3len[j] + cq
                        fj = fitv[sel]
                        if np.isfinite(fj).any():
                            rec(L, float(fj.min()), float((fj - L0 - A * hel[sel]).min() + 2 * L))
            # F4: all tables
            tab = inJ.astype(np.int64)  # table bit x = label at x
            cons = np.all(np.where(samp[None, :], tab == ylab[None, :], True), axis=1)
            r = np.where(tab == fst[None, :], 1.0, 0.0)
            hel = np.where(r == 1.0, h(1.0), h(0.0)).mean(1)
            rec(3 + M, 0.0, float((0.0 - L0 - A * hel[cons]).min() + 2 * (3 + M)))
            maxdiff_S = max(maxdiff_S, abs(bS / 2 - S))
            for L, v in best.items():
                if math.isfinite(v[0]) or math.isfinite(bf.get(L, math.inf)):
                    maxdiff_rho = max(maxdiff_rho, abs(v[0] - bf.get(L, math.inf)))
            assert set(L for L, v in best.items() if math.isfinite(v[0])) == set(L for L, v in bf.items() if math.isfinite(v))
            nchk += 1
    print(f"    {nchk} samples: max |S_closed - S_brute| = {maxdiff_S:.2e}; max |rho_closed - rho_brute| over lengths = {maxdiff_rho:.2e}")
    assert maxdiff_S < 1e-9 and maxdiff_rho < 1e-9


def run_E1():
    print("=" * 110)
    print("E1: d = 8 (M = 256), p = 1/4, BMAX = 4; Lemma 5.2 exactly over the WHOLE class; Ville; Prop 5.8")
    rng = np.random.default_rng(4242)
    d = 8
    ins = Instance(d, 4, int(rng.integers(1, 2 ** d)))
    print(f"  a* = {ins.astar}, l0 = l(pi*) = {ins.l0}; class rate grid: {len(ins.R)} rates")
    lams = [1.0, 1.25, 1.5, 2.0, 4.0, 8.0]
    # Prop 5.8 comparators: F1(a*, 1/2) and the coin F0(1/2)
    c_half = next(c for q, c in ins.R if q == 0.5)
    comps = [("F1(a*,1/2)", 3 + d + c_half), ("F0(1/2)", 3 + c_half)]
    Kbar = 1 - (-(P_TRUE * math.log2(P_TRUE) + (1 - P_TRUE) * math.log2(1 - P_TRUE)))
    NS = 400
    for n in (8, 16, 32, 64, 128, 256):
        Svals, Tvals = [], []
        cats = {lam: {} for lam in lams}
        uniq = {lam: 0 for lam in lams}
        ismap = {lam: 0 for lam in lams}
        famS = {}
        rslope = []
        for _ in range(NS):
            idx, y, flips = ins.sample(rng, n)
            best, m = ins.per_length_best(idx, y)
            S, L0 = ins.lemma52_slack(idx, y, flips, m)
            Svals.append(S)
            famS[ins.last_fam] = famS.get(ins.last_fam, 0) + 1
            Tvals.append(min(l + v[0] for l, v in best.items()) - L0)
            for lam in lams:
                top, tie = map_label(best, lam)
                cat = category(top[2])
                cats[lam][cat] = cats[lam].get(cat, 0) + 1
                if cat == "pi*" and not tie:
                    uniq[lam] += 1
                ismap[lam] += pistar_is_map(best, lam, ins.l0, L0)
            sec = [max(0.0, (L0 - v[0]) / (l - ins.l0)) for l, v in best.items() if l > ins.l0]
            rslope.append(max(sec))
        Svals, Tvals = np.array(Svals), np.array(Tvals)
        print(f"  n={n:4d} ({NS} samples): Lemma 5.2 P[S <= -t] for t = 1, 2, 3, log2(20): "
              + ", ".join(f"{np.mean(Svals <= -t):.3f}" for t in (1, 2, 3, math.log2(20)))
              + f"  (bounds 0.5, 0.25, 0.125, 0.05); min S = {Svals.min():.2f}; family attaining S: "
              + ", ".join(f"{k} {v}" for k, v in sorted(famS.items())))
        print(f"          Ville P[T <= -t], t = 1, 2, 3: " + ", ".join(f"{np.mean(Tvals <= -t):.3f}" for t in (1, 2, 3))
              + f"; right slope at (l0, L0): median {np.median(rslope):.3f}, max {np.max(rslope):.3f}")
        for lam in lams:
            cs = ", ".join(f"{k} {v / NS:.3f}" for k, v in sorted(cats[lam].items(), key=lambda t: -t[1]))
            line = f"          lambda={lam:<5g}: pi* unique MAP {uniq[lam] / NS:.3f}, pi* a MAP {ismap[lam] / NS:.3f} | {cs}"
            if lam > 1:
                bnds = []
                for nm, lc in comps:
                    Delta = ins.l0 - lc
                    bnds.append(f"{nm}: {min(1.0, (n * Kbar + LOG2E / math.e) / (lam * Delta)):.3f}")
                line += " | Prop 5.8 bounds " + ", ".join(bnds)
            print(line)


def run_E2():
    print("=" * 110)
    print("E2: d = 12 (M = 4096), p = 1/4, BMAX = 3, eps = 0.05: Thm 5.4, Cor 5.5, Thm 5.6 against exact hulls")
    rng = np.random.default_rng(4343)
    d = 12
    ins = Instance(d, 3, int(rng.integers(1, 2 ** d)))
    eps = 0.05
    le = math.log2(1 / eps)
    l0 = ins.l0
    gp = ins.gamma_profile(200)
    print(f"  a* = {ins.astar}, l0 = {l0}; margin profile gamma(l), l < l0: "
          + ", ".join(f"{l}:{gp[l]:.4g}" for l in sorted(gp) if l < l0))
    gl = lambda lbar: min(v for l, v in gp.items() if l <= lbar)
    gamma0 = gl(l0)
    print(f"  gamma_0 = min_(l <= l0) gamma(l) = {gamma0:.4g}; gamma_lbar for lbar = 21..30: "
          + ", ".join(f"{lb}:{gl(lb):.3g}" for lb in range(21, 31)))
    caps = [21, 22, 24, 26]
    thr = {lb: (lb + le) / (LOG2E * gl(lb)) for lb in caps}
    print("  Thm 5.4(iii) sample-size thresholds n > (lbar + log(1/eps))/(log e gamma_lbar): "
          + ", ".join(f"lbar={lb}: {thr[lb]:.0f}" for lb in caps) + f"  (M = {ins.M})")
    lams = [1.0, 1.5, 2.0, 4.0, 8.0, 16.0, 32.0]
    print("  Cor 5.5 and Thm 5.6 (gamma = gamma_0) sample sizes:")
    n05, n56 = {}, {}
    for lam in lams[1:]:
        lb = l0 + (l0 + le) / (lam - 1)
        g = gl(lb)
        n05[lam] = ((max(0.0, 2 - lam)) * lb + lam * l0 + 2 * le) / (2 * LOG2E * g)
        n56[lam] = ((max(0.0, 2 - lam)) * lb + lam * l0 + 2 * le) / (2 * LOG2E * gamma0)
        W = ins.w_near(lam, gamma0, lb)
        print(f"    lambda={lam:<4g}: lbar_lambda={lb:6.1f}, gamma_lbar={g:.3g}, Cor 5.5 n0={n05[lam]:.3g}"
              f"{' (> M: never applies under wor)' if n05[lam] > ins.M else ''}; Thm 5.6 n0={n56[lam]:.0f}, "
              f"W_near={W:.4f}, guarantee >= {1 - 2 * eps - W:.3f}")
    NS = 200
    for n in (64, 128, 256, 512, 1024, 2048, 3072, 4096):
        stats = {"vertex": 0, "left_ok": 0, "left_applicable": 0}
        iii = {lb: [0, 0, 0, 0] for lb in caps}  # applicable, flat+secants hold, sigma_n > tau, MAP=pi* there
        ident = {lam: 0 for lam in lams}
        cat1 = {}
        lefts, rights = [], []
        for _ in range(NS):
            idx, y, flips = ins.sample(rng, n)
            best, m = ins.per_length_best(idx, y)
            k = int(flips.sum())
            L0 = -(k * math.log2(P_TRUE) + (n - k) * math.log2(1 - P_TRUE))
            assert abs(best[l0][0] - L0) < 1e-9 or best[l0][0] < L0
            # left steepness and right slope at (l0, L0), from the per-length minima
            left = min((v[0] - L0) / (l0 - l) for l, v in best.items() if l < l0)
            right = max([0.0] + [(L0 - v[0]) / (l - l0) for l, v in best.items() if l > l0])
            lefts.append(left)
            rights.append(right)
            V = hull_from_best(best)
            isv = any(l == l0 and abs(f - L0) < 1e-9 for l, f in V) and abs(best[l0][0] - L0) < 1e-9
            stats["vertex"] += isv
            # Thm 5.4(i), profile form
            sig_n = min((2 * LOG2E * n * gp[l] - 2 * l - 2 * le) / (l0 - l) for l in gp if l < l0)
            if sig_n > 0:
                stats["left_applicable"] += 1
                stats["left_ok"] += left >= sig_n - 1e-9
            for lb in caps:
                if n > thr[lb]:
                    iii[lb][0] += 1
                    tau = 1 + (l0 + le) / (lb - l0)
                    flat = all(v[0] > L0 - 1e-9 for l, v in best.items() if l <= lb and l != l0) and abs(best[l0][0] - L0) < 1e-9
                    sec_ok = all((L0 - v[0]) / (l - l0) < tau for l, v in best.items() if l > lb)
                    iii[lb][1] += flat and sec_ok
                    if sig_n > tau:
                        iii[lb][2] += 1
                        ok = True
                        for lam in (tau * 1.0001, math.sqrt(tau * sig_n), sig_n * 0.9999):
                            top, tie = map_label(best, lam)
                            ok = ok and category(top[2]) == "pi*" and not tie
                        iii[lb][3] += ok
            for lam in lams:
                top, tie = map_label(best, lam)
                if category(top[2]) == "pi*" and not tie:
                    ident[lam] += 1
            top, tie = map_label(best, 1.0)
            c = category(top[2])
            cat1[c] = cat1.get(c, 0) + 1
        print(f"  n={n:5d} (n/M={n / ins.M:.3f}, {NS} samples): (l0,L0) vertex {stats['vertex'] / NS:.3f}; "
              f"left steepness median {np.median(lefts):.2f} (min {np.min(lefts):.2f}); right slope median "
              f"{np.median(rights):.3f} (max {np.max(rights):.3f})")
        print(f"          Thm 5.4(i) profile bound positive in {stats['left_applicable']}/{NS}, holds in "
              f"{stats['left_ok']}/{max(1, stats['left_applicable'])}")
        for lb in caps:
            a_, b_, c_, e_ = iii[lb]
            if a_:
                tau = 1 + (l0 + le) / (lb - l0)
                print(f"          Thm 5.4(iii) lbar={lb}: n above threshold in {a_}/{NS}; flat part and secants < tau={tau:.2f} "
                      f"hold in {b_}/{a_}; sigma_n > tau in {c_}/{a_}, and there MAP = pi* at three lambdas in (tau, sigma_n) in {e_}/{c_}")
        print("          pi* unique lambda-MAP: " + ", ".join(f"lambda={lam:g}: {ident[lam] / NS:.3f}" for lam in lams)
              + f"; lambda = 1 MAP: " + ", ".join(f"{k} {v / NS:.3f}" for k, v in sorted(cat1.items(), key=lambda t: -t[1])))


if __name__ == "__main__":
    print("rB3: Section 5 simulations (referee B)")
    run_E0()
    run_E1()
    run_E2()
