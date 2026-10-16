"""c4_mars_pool.py -- the proof-requiring posterior over the historical pool of Mars theories.

Thread `philosophy`, target T4 (notes.md section 4.4).  Seed 20261015.  Writes c4_mars_pool.out
next to itself (run:  python c4_mars_pool.py > c4_mars_pool.out).

What it computes
----------------
PART A (heliocentric data; the data of scout P's c2).  Data: the in-plane heliocentric longitude
theta(t) of Mars, 1580.0-1600.0, daily (N = 7306), from ERFA eraPlan94, reduced to the best plane
through the Sun exactly as in scout P's c2_mars_models.py.  A datum is the interval sentence
"theta(t_i) lies within delta of v_i" with v_i = the plan94 value (guaranteed-tolerance regime,
measurement error 0).  A theory is LAW_F + ELEMENTS (numerals).  It proves every datum iff its
predicted longitudes are within delta of every v_i, and it then is consistent with the data, so the
proof-requiring weight of a theory is 2^-|text| if max_i |dlon_i| <= delta and 0 otherwise.

  Law forms F (the pool):  circle (2 elements), eccentric (4), bisected equant (4), vicarious
  hypothesis (5), ellipse = Kepler's equation (4); each with and without K3.  Parametrisation
  (mean longitude at the window midpoint, so that L and n decorrelate):
      mean longitude  L(t) = L + n (t - t_mid);  mean anomaly M(t) = L(t) - w.
  Prior box (the element ranges): e, e1, e2 in [0,1); w, L in [0,2pi); n in [0, 0.1) rad/day.

  Element syntax (written down): every element is a fixed-length 64-bit binary numeral for the
  midpoint of a cell of its range.  The total prior mass of the compatible element numerals of a
  form is then (number of compatible grid points) * 2^(-64 k) = V_F(delta) / prod(ranges) up to
  grid error 2^-64, where V_F(delta) is the volume of the compatible region in element space.  So
      C_F(delta) := -log2( V_F(delta) / prod(ranges) )   [bits; the Occam factor of form F]
  and the posterior of form F is proportional to 2^-( |LAW_F|_S + C_F(delta) ), |LAW_F|_S the
  length of the law text in syntax S.  (A variable-length numeral code changes C_F by roughly
  sum_k 2 log2(bits needed for element k), i.e. by an amount nearly equal across the 4-element
  forms; see the note printed with table A4.)

  Law-text syntaxes (written out below as s-expressions; |text| = tokens * ceil(log2 A_S), A_S the
  alphabet of syntax S):
      S1 arithmetic: +, -, *, /, sin, cos, atan2, sqrt, numerals; implicit definitions by "exists";
      S2 epicyclic: S1 plus the primitives uc(theta) (unit vector), dir(v) (direction of a vector),
         rc(Q, C, theta) (the point where the ray from Q at angle theta meets the unit circle about C);
      S3 Keplerian: S1 plus kep(e, M) (the true anomaly: solution of Kepler's equation).
  Every text is "forall b forall t: theta(b,t) = <expression in the elements of b and t>"; the
  common prefix is counted.

  Computation of V_F(delta): (i) minimax fit of each form (multi-start least squares, L_p refinement
  as in c2, then sequential-LP polishing of the minimax error); (ii) an axis-aligned box in element
  space from the LP extents of the linearised compatible polytope {x : |r0 + J x|_inf <= delta},
  enlarged by 30% and capped at the prior box; (iii) hit-or-miss Monte Carlo in the box with the
  EXACT nonlinear model on all 7306 data (early rejection on every 7th day); (iv) if any hit lies in
  the outer 3% of a box face that is not a cap, that side is enlarged and the estimate restarted.

PART B (geocentric data: what K3 is worth).  Data: the geocentric ecliptic longitude of Mars
(plan94 Mars minus plan94 Earth-Moon barycentre, J2000 ecliptic), 1580.0-1600.0, daily.  Hypothesis:
Kepler ellipses for Earth (in the ecliptic, a = 1) and Mars (plane fixed at the best heliocentric
plane of Part A; elements e, w, L, n and the size ratio rho = a_Ma/a_Ea), with rho a free element
(no K3) or rho := (n_Ea/n_Ma)^(2/3) (K3).  Reported: minimax errors with and without K3 (exact model);
at several delta, the volumes V9 (rho free) and V8 (K3) of the exact compatible regions, by hit-or-miss
with the exact model in a box aligned with the principal axes of the region (found from 300 hits of the
linearised region; the box is enlarged by 25% and grown where hits reach its faces); and the bits of
rho that K3 saves, log2(range_rho * V8 / V9) with range_rho = 4 (rho in [0,4)); against the text cost
of K3.

Usage: python c4_mars_pool.py [A|B|AB]   (default AB; the saved .out is the AB run).

Requirements: numpy, scipy, pyerfa (tested: numpy 2.4.6, scipy 1.17.1, pyerfa 2.0.1.5).
"""
import sys
import time
import math
import numpy as np
import erfa
import scipy
from scipy.optimize import least_squares, linprog

SEED = 20261015
RNG = np.random.default_rng(SEED)
JD2000 = 2451545.0
YEAR = 365.25
EPS0 = np.deg2rad(84381.448 / 3600.0)
ARCMIN = np.pi / (180 * 60)
TWO_PI = 2 * np.pi
T_START = time.time()


def wrap(x):
    return (x + np.pi) % TWO_PI - np.pi


def eq_to_ecl(p):
    c, s = np.cos(EPS0), np.sin(EPS0)
    x, y, z = p[..., 0], p[..., 1], p[..., 2]
    return np.stack([x, c * y + s * z, -s * y + c * z], axis=-1)


# ------------------------------------------------------------------------------------------ data
def helio(body, t):
    pv = erfa.plan94(JD2000 + np.zeros_like(t), t, body)
    return eq_to_ecl(pv["p"])


def mars_helio_plane(t):
    p = helio(4, t)
    _, s, vt = np.linalg.svd(p, full_matrices=False)
    nrm = vt[2]
    if nrm[2] < 0:
        nrm = -nrm
    ex = np.cross([0.0, 0.0, 1.0], nrm)
    ex /= np.linalg.norm(ex)
    ey = np.cross(nrm, ex)
    x, y, z = p @ ex, p @ ey, p @ nrm
    theta = np.unwrap(np.arctan2(y, x))
    incl = np.arccos(nrm[2])
    node = np.arctan2(ex[1], ex[0])
    return theta, np.hypot(x, y), incl, node, np.max(np.abs(z) / np.linalg.norm(p, axis=1))


# ------------------------------------------------------------------------------------------ models
NAMES = {"circle": ["L", "n"], "eccentric": ["e", "w", "L", "n"], "equant": ["e", "w", "L", "n"],
         "vicarious": ["e1", "e2", "w", "L", "n"], "ellipse": ["e", "w", "L", "n"]}
RANGE = {"e": (0.0, 1.0), "e1": (0.0, 1.0), "e2": (0.0, 1.0), "w": (None, TWO_PI),
         "L": (None, TWO_PI), "n": (0.0, 0.1)}          # None: an angle (periodic, full range 2pi)
FORMS = ["circle", "eccentric", "equant", "vicarious", "ellipse"]


def kepler_E(M, e):
    E = M + e * np.sin(M)
    for _ in range(60):
        f = E - e * np.sin(E) - M
        dE = f / (1 - e * np.cos(E))
        dE = np.clip(dE, -1.0, 1.0)
        E = E - dE
        if np.max(np.abs(dE)) < 1e-14:
            break
    return E


def true_anom(E, e):
    return 2 * np.arctan2(np.sqrt(1 + e) * np.sin(E / 2), np.sqrt(1 - e) * np.cos(E / 2))


def lon(form, P, tt):
    """P: (B,k) elements; tt: (N,) times relative to t_mid.  Returns (B,N) heliocentric longitudes."""
    P = np.atleast_2d(P)
    if form == "circle":
        L, n = P[:, 0:1], P[:, 1:2]
        return L + n * tt
    if form == "ellipse":
        e, w, L, n = (P[:, i:i + 1] for i in range(4))
        M = L + n * tt - w
        return w + true_anom(kepler_E(M, e), e)
    if form == "vicarious":
        e1, e2, w, L, n = (P[:, i:i + 1] for i in range(5))
    else:
        e, w, L, n = (P[:, i:i + 1] for i in range(4))
        if form == "eccentric":
            e1, e2 = e, 0.0 * e
        else:                                   # bisected equant
            e1, e2 = e, e
    Lt = L + n * tt
    M = Lt - w
    s = e2 * np.cos(M) + np.sqrt(np.maximum(1 - (e2 * np.sin(M)) ** 2, 0.0))
    eq = e1 + e2
    return np.arctan2(-eq * np.sin(w) + s * np.sin(Lt), -eq * np.cos(w) + s * np.cos(Lt))


def res(form, p, tt, th):
    return wrap(lon(form, p, tt)[0] - th)


def maxerr(form, p, tt, th):
    return np.max(np.abs(res(form, p, tt, th)))


def jac(form, p, tt, th, h=1e-7):
    k = len(p)
    J = np.empty((len(tt), k))
    for i in range(k):
        dp = np.zeros(k)
        step = h * (1e-3 if NAMES[form][i] == "n" else 1.0)
        dp[i] = step
        J[:, i] = (wrap(lon(form, p + dp, tt)[0] - lon(form, p - dp, tt)[0])) / (2 * step)
    return J


def slp_polish(form, p, tt, th, iters=60):
    """sequential LP: minimise the max residual in the linearisation, with a trust region."""
    k = len(p)
    cur = maxerr(form, p, tt, th)
    tr = np.array([1e-3 if NAMES[form][i] != "n" else 1e-7 for i in range(k)])
    for _ in range(iters):
        J = jac(form, p, tt, th)
        r0 = res(form, p, tt, th)
        N = len(tt)
        # variables x (k), s ; minimise s ; r0 + Jx <= s ; -(r0 + Jx) <= s
        c = np.zeros(k + 1)
        c[-1] = 1.0
        A = np.vstack([np.hstack([J, -np.ones((N, 1))]), np.hstack([-J, -np.ones((N, 1))])])
        b = np.concatenate([-r0, r0])
        bounds = [(-tr[i], tr[i]) for i in range(k)] + [(0, None)]
        sol = linprog(c, A_ub=A, b_ub=b, bounds=bounds, method="highs")
        if sol.status != 0:
            tr /= 2
            continue
        pn = p + sol.x[:k]
        new = maxerr(form, pn, tt, th)
        if new < cur - 1e-15:
            p, cur = pn, new
            tr *= 1.5
        else:
            tr /= 2
        if np.all(tr < 1e-13):
            break
    return p, cur


def fit_minimax(form, tt, th, starts):
    best = None
    for p0 in starts:
        try:
            sol = least_squares(lambda p: res(form, p, tt, th), p0, method="lm",
                                xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=20000)
        except Exception:
            continue
        x = sol.x
        mx = maxerr(form, x, tt, th)
        for q in (4, 16, 64):
            def f(p, s=mx, q=q):
                return np.abs(res(form, p, tt, th) / s) ** (q / 2.0)
            s2 = least_squares(f, x, method="lm", xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=20000)
            m2 = maxerr(form, s2.x, tt, th)
            if m2 < mx:
                x, mx = s2.x, m2
        if best is None or mx < best[1]:
            best = (x, mx)
    x, mx = slp_polish(form, best[0], tt, th)
    return x, mx


# ------------------------------------------------------------------------------------------ volumes
def lp_extents(J, r0, delta):
    """for each coordinate, min and max of x_i over {x : |r0 + J x|_inf <= delta} (linearised)."""
    N, k = J.shape
    A = np.vstack([J, -J])
    b = np.concatenate([delta - r0, delta + r0])
    lo, hi = np.empty(k), np.empty(k)
    for i in range(k):
        for sgn in (1, -1):
            c = np.zeros(k)
            c[i] = sgn
            sol = linprog(c, A_ub=A, b_ub=b, bounds=[(None, None)] * k, method="highs")
            if sol.status != 0:
                return None, None
            if sgn == 1:
                lo[i] = sol.x[i]
            else:
                hi[i] = sol.x[i]
    return lo, hi


def whitening(J):
    """R with x = R z and J R = U (orthonormal columns): the residual map is an isometry in z."""
    U_, s, Vt = np.linalg.svd(J, full_matrices=False)
    R = Vt.T / s
    return R, float(np.prod(1.0 / s))           # |det R|


def in_prior(names, center):
    lims = []
    for nm, c in zip(names, center):
        a, b = RANGE[nm]
        lims.append((c - np.pi, c + np.pi) if a is None else (a, b))
    lo = np.array([l[0] for l in lims])
    hi = np.array([l[1] for l in lims])
    return lambda P: np.all((P >= lo) & (P < hi), axis=1)


def mc_volume(hit_fn, names, center, J, r0, delta, rng, target_hits=2000, max_samples=3_000_000,
              batch=20000, margin=1.3, max_rounds=10):
    """hit-or-miss volume of {p in the prior box : hit_fn(p)}, sampling uniformly in a box in the
    whitened coordinates z (x = p - centre = R z) built from the LP extents of the linearised polytope;
    a side of the box with hits in its outer 3% is enlarged and the estimate restarted.
    Returns (V, se, hits, n, rounds, (zlo, zhi))."""
    k = len(center)
    R, detR = whitening(J)
    Uz = J @ R
    lo, hi = lp_extents(Uz, r0, delta)
    if lo is None:
        lo, hi = -np.full(k, 1e-3), np.full(k, 1e-3)
    zlo = margin * np.minimum(lo, 0) - 1e-9
    zhi = margin * np.maximum(hi, 0) + 1e-9
    inside = in_prior(names, center)
    for rnd in range(max_rounds):
        width = zhi - zlo
        vol_box = float(np.prod(width)) * detR
        hits, n = 0, 0
        near = np.zeros((k, 2), bool)
        while hits < target_hits and n < max_samples:
            Uu = rng.random((batch, k))
            Z = zlo + Uu * width
            P = center + Z @ R.T
            h = inside(P)
            idx = np.nonzero(h)[0]
            if len(idx):
                h[idx] = hit_fn(P[idx])
            hits += int(h.sum())
            n += batch
            if h.any():
                Uh = Uu[h]
                near[:, 0] |= (Uh < 0.03).any(axis=0)
                near[:, 1] |= (Uh > 0.97).any(axis=0)
        if not near.any():
            frac = hits / n
            V = frac * vol_box
            se = vol_box * math.sqrt(max(frac * (1 - frac), 1e-300) / n)
            return V, se, hits, n, rnd, (zlo.copy(), zhi.copy())
        for i in range(k):
            if near[i, 0]:
                zlo[i] -= 0.6 * width[i]
            if near[i, 1]:
                zhi[i] += 0.6 * width[i]
    return None


def make_hit_fn(lon_fn, tt, th, delta, step=7):
    sub = np.arange(0, len(tt), step)
    tt_s, th_s = tt[sub], th[sub]

    def hit(P):
        ok = np.max(np.abs(wrap(lon_fn(P, tt_s) - th_s)), axis=1) <= delta
        idx = np.nonzero(ok)[0]
        if len(idx):
            full = np.max(np.abs(wrap(lon_fn(P[idx], tt) - th)), axis=1) <= delta
            ok[idx] = full
        return ok
    return hit


# ------------------------------------------------------------------------------------------ law texts
# s-expressions; atoms are strings.  Each text is (forall b (forall t (= (theta b t) EXPR))).
def pre(expr):
    return ["forall", "b", ["forall", "t", ["=", ["theta", "b", "t"], expr]]]


def el(name):
    return [name, "b"]


Lt = ["+", el("L"), ["*", el("n"), "t"]]          # mean longitude L(b) + n(b) t
Mt = ["-", Lt, el("w")]                             # mean anomaly
U = lambda ang: (["cos", ang], ["sin", ang])        # noqa: E731

TEXTS = {"S1": {}, "S2": {}, "S3": {}}
# circle: theta = L + n t
for S in TEXTS:
    TEXTS[S]["circle"] = pre(Lt)
# eccentric (S1, S3): theta = atan2(sin Lt - e sin w, cos Lt - e cos w)
ecc_S1 = ["atan2", ["-", ["sin", Lt], ["*", el("e"), ["sin", el("w")]]],
          ["-", ["cos", Lt], ["*", el("e"), ["cos", el("w")]]]]
TEXTS["S1"]["eccentric"] = pre(ecc_S1)
TEXTS["S3"]["eccentric"] = pre(ecc_S1)
TEXTS["S2"]["eccentric"] = pre(["dir", ["+", ["uc", Lt], ["*", ["-", el("e")], ["uc", el("w")]]]])


# equant / vicarious (S1, S3): exists s (s > 0 and s^2 - 2 e2 s cos M + e2^2 = 1 and
#   theta = atan2(-(e1+e2) sin w + s sin Lt, -(e1+e2) cos w + s cos Lt))
def eqv_S1(e1, e2):
    ee = e1 if e2 is None else ["+", e1, e2]
    ec = e1 if e2 is None else e2
    body = ["and", [">", "s", "0"],
            ["and", ["=", ["+", ["-", ["*", "s", "s"], ["*", "2", ["*", ec, ["*", "s", ["cos", Mt]]]]],
                           ["*", ec, ec]], "1"],
             ["=", ["theta", "b", "t"],
              ["atan2", ["+", ["-", ["*", ee, ["sin", el("w")]]], ["*", "s", ["sin", Lt]]],
                        ["+", ["-", ["*", ee, ["cos", el("w")]]], ["*", "s", ["cos", Lt]]]]]]]
    return ["forall", "b", ["forall", "t", ["exists", "s", body]]]


TEXTS["S1"]["equant"] = eqv_S1(["*", "2", el("e")], el("e"))
TEXTS["S3"]["equant"] = TEXTS["S1"]["equant"]
TEXTS["S1"]["vicarious"] = eqv_S1(["+", el("e1"), el("e2")], el("e2"))
TEXTS["S3"]["vicarious"] = TEXTS["S1"]["vicarious"]
# S2: theta = dir(rc(Q, C, Lt)) with Q = -(e1+e2) uc(w), C = -e1 uc(w)
TEXTS["S2"]["equant"] = pre(["dir", ["rc", ["*", ["-", ["*", "2", el("e")]], ["uc", el("w")]],
                                     ["*", ["-", el("e")], ["uc", el("w")]], Lt]])
TEXTS["S2"]["vicarious"] = pre(["dir", ["rc", ["*", ["-", ["+", el("e1"), el("e2")]], ["uc", el("w")]],
                                        ["*", ["-", el("e1")], ["uc", el("w")]], Lt]])
# ellipse (S1, S2): exists E (E - e sin E = M and theta = w + atan2(sqrt(1 - e e) sin E, cos E - e))
ell_body = ["and", ["=", ["-", "E", ["*", el("e"), ["sin", "E"]]], Mt],
            ["=", ["theta", "b", "t"],
             ["+", el("w"), ["atan2", ["*", ["sqrt", ["-", "1", ["*", el("e"), el("e")]]], ["sin", "E"]],
                             ["-", ["cos", "E"], el("e")]]]]]
TEXTS["S1"]["ellipse"] = ["forall", "b", ["forall", "t", ["exists", "E", ell_body]]]
TEXTS["S2"]["ellipse"] = TEXTS["S1"]["ellipse"]
TEXTS["S3"]["ellipse"] = pre(["+", el("w"), ["kep", el("e"), Mt]])
# K3: forall b forall b' (P(b)^2 a(b')^3 = P(b')^2 a(b)^3), with P = 2pi/n:  n(b')^2 a(b')^3 = n(b)^2 a(b)^3
K3 = ["forall", "b", ["forall", "c", ["=", ["*", ["*", ["n", "b"], ["n", "b"]], ["*", ["a", "b"], ["*", ["a", "b"], ["a", "b"]]]],
                                           ["*", ["*", ["n", "c"], ["n", "c"]], ["*", ["a", "c"], ["*", ["a", "c"], ["a", "c"]]]]]]]

ALPHABET_BASE = ["forall", "exists", "and", "=", ">", "+", "-", "*", "/", "sin", "cos", "atan2", "sqrt",
                 "0", "1", "2", "theta", "b", "c", "t", "s", "E", "L", "n", "w", "e", "e1", "e2", "a", "(", ")"]
ALPHABET = {"S1": ALPHABET_BASE, "S2": ALPHABET_BASE + ["uc", "dir", "rc"], "S3": ALPHABET_BASE + ["kep"]}


def tokens(x):
    """atoms plus one opening and one closing bracket per compound (a prefix-free serialisation)."""
    if isinstance(x, str):
        return 1
    return 2 + sum(tokens(y) for y in x)


def atoms(x, acc=None):
    acc = set() if acc is None else acc
    if isinstance(x, str):
        acc.add(x)
    else:
        for y in x:
            atoms(y, acc)
    return acc


def text_bits(S, x):
    A = len(ALPHABET[S])
    return tokens(x) * math.ceil(math.log2(A))


# ------------------------------------------------------------------------------------------ geocentric
def geo_lon(P, tt, incl, node):
    """P: (B,9) = Earth e,w,L,n ; Mars e,w,L,n ; rho.  Mars plane: inclination incl, node.
    Mars w is the in-plane perihelion angle measured from the node; L the in-plane mean longitude."""
    P = np.atleast_2d(P)
    eE, wE, LE, nE = (P[:, i:i + 1] for i in range(4))
    eM, wM, LM, nM = (P[:, i:i + 1] for i in range(4, 8))
    rho = P[:, 8:9]
    EE = kepler_E(LE + nE * tt - wE, eE)
    rE = 1 - eE * np.cos(EE)
    lE = wE + true_anom(EE, eE)
    xE, yE = rE * np.cos(lE), rE * np.sin(lE)
    EM = kepler_E(LM + nM * tt - wM, eM)
    rM = rho * (1 - eM * np.cos(EM))
    u = wM + true_anom(EM, eM)                     # argument of latitude
    ci, cO, sO = np.cos(incl), np.cos(node), np.sin(node)
    xM = rM * (cO * np.cos(u) - sO * np.sin(u) * ci)
    yM = rM * (sO * np.cos(u) + cO * np.sin(u) * ci)
    return np.arctan2(yM - yE, xM - xE)


def main(parts="AB"):
    print("# parts run: %s" % parts)
    print("# c4_mars_pool.py  seed=%d  numpy %s  scipy %s  pyerfa %s  python %s"
          % (SEED, np.__version__, scipy.__version__, erfa.__version__, sys.version.split()[0]))
    t = np.arange((1580.0 - 2000.0) * YEAR, (1600.0 - 2000.0) * YEAR + 1e-9, 1.0)
    N = len(t)
    t_mid = 0.5 * (t[0] + t[-1])
    tt = t - t_mid
    theta, r, incl, node, oop = mars_helio_plane(t)
    print("# data: plan94 Mars 1580.0-1600.0 daily, N = %d; best plane: inclination %.4f deg, node %.3f deg;"
          " largest out-of-plane angle %.3f'" % (N, np.degrees(incl), np.degrees(node) % 360, np.degrees(oop) * 60))
    print()

    # ---------------------------------------------------------------- A1 minimax fits
    n0 = TWO_PI / 686.98
    fits = {}
    i_min = np.argmin(r)
    w0 = theta[i_min] % TWO_PI
    L0 = theta[N // 2] % TWO_PI
    e0 = (r.max() - r.min()) / (r.max() + r.min())

    def starts(form, m=8):
        out = []
        for j in range(m):
            jit = RNG.normal(size=5)
            e = abs(e0 * (1 + 0.3 * jit[0]))
            w = w0 + 0.2 * jit[1]
            L = L0 + 0.05 * jit[2]
            n = n0 * (1 + 1e-4 * jit[3])
            if form == "circle":
                out.append(np.array([L, n]))
            elif form == "eccentric":
                out.append(np.array([2 * e, w, L, n]))
            elif form == "vicarious":
                out.append(np.array([1.2 * e, 0.8 * e * (1 + 0.3 * jit[4]), w, L, n]))
            else:
                out.append(np.array([e, w, L, n]))
        return out

    if "A" not in parts:
        fits["ellipse"] = fit_minimax("ellipse", tt, theta, starts("ellipse"))
    else:
        partA(tt, theta, starts, fits)
    if "B" in parts:
        partB(t, tt, N, incl, node, fits)
    print("# done in %.0f s" % (time.time() - T_START))


def partA(tt, theta, starts, fits):
    N = len(tt)
    print("## A1. minimax fits to heliocentric longitudes (multi-start LM, L_p refinement, sequential-LP polish)")
    print("%-10s %2s %13s %13s   %s" % ("form", "k", "minimax '", "c2 value '", "elements (e; w, L in deg; n rad/day)"))
    c2val = {"circle": 641.034, "eccentric": 23.455, "equant": 8.276, "vicarious": 1.495, "ellipse": 1.172}
    for f in FORMS:
        p, mx = fit_minimax(f, tt, theta, starts(f))
        fits[f] = (p, mx)
        els = ", ".join("%s=%.6g" % (nm, (np.degrees(v) % 360) if nm in ("w", "L") else v)
                        for nm, v in zip(NAMES[f], p))
        print("%-10s %2d %13.4f %13.3f   %s" % (f, len(p), mx / ARCMIN, c2val[f], els))
    print("# (the c2 values are L_p-refined least squares; the polished minimax is at most that.)")
    print()

    # ---------------------------------------------------------------- A2 volumes
    deltas = [720.0, 120.0, 60.0, 30.0, 20.0, 12.0, 9.0, 6.0, 4.0, 3.0, 2.0, 1.6, 1.3]
    rng = np.random.default_rng(SEED + 1)
    logV = {}
    print("## A2. Occam factor C_F(delta) = -log2(V_F(delta)/prod ranges) [bits]; '-' = incompatible "
          "(delta below the minimax error)")
    print("%-8s %-10s %10s %8s %8s %9s %6s %s" % ("delta'", "form", "C_F bits", "+-se", "hits", "samples",
                                                  "grow", "sampling parallelepiped: element ranges"))
    for d in deltas:
        D = d * ARCMIN
        for f in FORMS:
            p, mx = fits[f]
            if mx > D:
                logV[(d, f)] = None
                print("%-8g %-10s %10s" % (d, f, "-"))
                continue
            J = jac(f, p, tt, theta)
            r0 = res(f, p, tt, theta)
            hit = make_hit_fn(lambda P, x, f=f: lon(f, P, x), tt, theta, D)
            out = mc_volume(hit, NAMES[f], p, J, r0, D, rng)
            if out is None:
                print("%-8g %-10s  (volume estimate did not converge)" % (d, f))
                logV[(d, f)] = None
                continue
            V, se, hits, n, rounds, (zlo, zhi) = out
            R, _ = whitening(J)
            corners = np.array([[zlo[i] if (m >> i) & 1 == 0 else zhi[i] for i in range(len(p))]
                                for m in range(2 ** len(p))]) @ R.T
            blo, bhi = p + corners.min(axis=0), p + corners.max(axis=0)
            prior = 1.0
            for nm in NAMES[f]:
                a, b = RANGE[nm]
                prior *= (TWO_PI if a is None else b - a)
            C = -math.log2(V / prior)
            seb = se / V / math.log(2)
            logV[(d, f)] = C
            box = "; ".join("%s %.3g..%.3g" % (nm, a, b) for nm, a, b in zip(NAMES[f], blo, bhi))
            print("%-8g %-10s %10.2f %8.2f %8d %9d %6d %s" % (d, f, C, seb, hits, n, rounds, box))
        sys.stdout.flush()
    print()

    # ---------------------------------------------------------------- A3 texts
    print("## A3. law texts: tokens (atoms + brackets) and bits = tokens * ceil(log2 |alphabet|)")
    print("%-10s %8s %8s %8s %8s %8s %8s" % ("law", "S1 tok", "S1 bits", "S2 tok", "S2 bits", "S3 tok", "S3 bits"))
    lawbits = {}
    for f in FORMS + ["K3"]:
        row = []
        for S in ("S1", "S2", "S3"):
            x = K3 if f == "K3" else TEXTS[S][f]
            assert atoms(x) <= set(ALPHABET[S]), (S, f, atoms(x) - set(ALPHABET[S]))
            row += [tokens(x), text_bits(S, x)]
            lawbits[(S, f)] = text_bits(S, x)
        print("%-10s %8d %8d %8d %8d %8d %8d" % tuple([f] + row))
    print("# alphabet sizes: S1 %d, S2 %d, S3 %d symbols" % tuple(len(ALPHABET[S]) for S in ("S1", "S2", "S3")))
    print()

    # ---------------------------------------------------------------- A4 posterior
    print("## A4. posterior over the pool (proof-requiring, fixed-length numerals) by delta and syntax;")
    print("#     each K3 variant has exactly 2^-|K3| times the weight of its no-K3 form (one planet: K3 is")
    print("#     vacuous; also Prop 4.2 of notes.md); shares below are over the five no-K3 forms, and the")
    print("#     K3 share of the whole pool is 2^-|K3|/(1+2^-|K3|) in every row.")
    for S in ("S1", "S2", "S3"):
        print("# syntax %s" % S)
        print("%-8s " % "delta'" + " ".join("%11s" % f for f in FORMS) + "   MAP")
        for d in deltas:
            lw = {}
            for f in FORMS:
                C = logV[(d, f)]
                if C is not None:
                    lw[f] = -(lawbits[(S, f)] + C)
            if not lw:
                continue
            m = max(lw.values())
            Z = sum(2.0 ** (v - m) for v in lw.values())
            cells = []
            for f in FORMS:
                if f in lw:
                    sh = 2.0 ** (lw[f] - m) / Z
                    cells.append("%11.3g" % sh)
                else:
                    cells.append("%11s" % "0")
            print("%-8g " % d + " ".join(cells) + "   " + max(lw, key=lw.get))
        print()
    print("## A5. what the data decide and what the syntax decides: for each delta, the Occam-factor")
    print("#     differences C_G - C_F (bits) between compatible forms; form F beats form G iff")
    print("#     |LAW_F| - |LAW_G| < C_G - C_F.  Text differences |LAW_F| - |LAW_G| in S1/S2/S3 for comparison.")
    pairs = [("ellipse", "vicarious"), ("ellipse", "equant"), ("equant", "eccentric"), ("eccentric", "circle"),
             ("ellipse", "eccentric"), ("ellipse", "circle")]
    print("%-8s " % "delta'" + " ".join("%20s" % ("%s-%s" % (a[:4], b[:4])) for a, b in pairs))
    for d in deltas:
        cells = []
        for a, b in pairs:
            Ca, Cb = logV[(d, a)], logV[(d, b)]
            if Ca is None and Cb is None:
                cells.append("%20s" % "both out")
            elif Ca is None:
                cells.append("%20s" % ("%s out" % a[:4]))
            elif Cb is None:
                cells.append("%20s" % ("%s out" % b[:4]))
            else:
                cells.append("%20.2f" % (Cb - Ca))
        print("%-8g " % d + " ".join(cells))
    print("%-8s " % "text S1" + " ".join("%20d" % (lawbits[("S1", a)] - lawbits[("S1", b)]) for a, b in pairs))
    print("%-8s " % "text S2" + " ".join("%20d" % (lawbits[("S2", a)] - lawbits[("S2", b)]) for a, b in pairs))
    print("%-8s " % "text S3" + " ".join("%20d" % (lawbits[("S3", a)] - lawbits[("S3", b)]) for a, b in pairs))
    print("# Note: with a variable-length numeral code (an Elias-gamma length prefix per element) each")
    print("# element costs about 2*log2(b_k)+1 more bits, b_k ~ 4-27 bits needed (c2 table E): about 5-11")
    print("# bits per element, so ~25-35 bits per 4-element form and ~6-11 more for the 5-element vicarious")
    print("# hypothesis.  This shifts the vicarious-vs-4-element comparisons by ~6-11 bits and the 2-element")
    print("# circle against 4-element forms by ~12-20 bits; it does not change which forms are compatible.")
    print()
    sys.stdout.flush()


def partB(t, tt, N, incl, node, fits):
    # ---------------------------------------------------------------- PART B geocentric
    print("## B. geocentric longitudes of Mars, 1580.0-1600.0 daily (Mars - EMB, J2000 ecliptic): what K3 is worth")
    pM, pE = helio(4, t), helio(3, t)
    g = pM - pE
    thg = np.unwrap(np.arctan2(g[:, 1], g[:, 0]))
    thE = np.unwrap(np.arctan2(pE[:, 1], pE[:, 0]))
    rE = np.linalg.norm(pE[:, :2], axis=1)
    # Earth start: ellipse fit to Earth's heliocentric longitude (as a starting point only)
    pe0, _ = fit_minimax("ellipse", tt, thE, [np.array([0.0167, np.deg2rad(102.9), thE[N // 2] % TWO_PI, TWO_PI / 365.256])])
    # Mars start: in-plane ellipse fit (Part A) with w, L measured from the node
    pm = fits["ellipse"][0].copy()
    pm[1] = pm[1]          # in-plane angles of Part A are measured from the node already (ex = node direction)
    rho0 = (pe0[3] / pm[3]) ** (2.0 / 3.0)

    def geo9(P, x):
        return geo_lon(P, x, incl, node)

    def geo8(P, x):
        P = np.atleast_2d(P)
        rho = (P[:, 3:4] / P[:, 7:8]) ** (2.0 / 3.0)
        return geo_lon(np.hstack([P, rho]), x, incl, node)

    def fitgeo(fn, p0):
        k = len(p0)
        rfun = lambda p: wrap(fn(p, tt)[0] - thg)    # noqa: E731
        sol = least_squares(rfun, p0, method="lm", xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=50000)
        x = sol.x
        mx = np.max(np.abs(rfun(x)))
        for q in (4, 16, 64):
            s2 = least_squares(lambda p, s=mx, q=q: np.abs(rfun(p) / s) ** (q / 2.0), x, method="lm",
                               xtol=1e-15, ftol=1e-15, gtol=1e-15, max_nfev=50000)
            m2 = np.max(np.abs(rfun(s2.x)))
            if m2 < mx:
                x, mx = s2.x, m2
        # sequential LP polish
        tr = np.full(k, 1e-4)
        tr[[3, 7]] = 1e-8
        for _ in range(40):
            J = np.empty((N, k))
            for i in range(k):
                dp = np.zeros(k)
                hstep = 1e-7 * (1e-3 if i in (3, 7) else 1.0)
                dp[i] = hstep
                J[:, i] = wrap(fn(x + dp, tt)[0] - fn(x - dp, tt)[0]) / (2 * hstep)
            r0 = rfun(x)
            c = np.zeros(k + 1)
            c[-1] = 1
            A = np.vstack([np.hstack([J, -np.ones((N, 1))]), np.hstack([-J, -np.ones((N, 1))])])
            bb = np.concatenate([-r0, r0])
            sol = linprog(c, A_ub=A, b_ub=bb, bounds=[(-tr[i], tr[i]) for i in range(k)] + [(0, None)],
                          method="highs")
            if sol.status == 0:
                xn = x + sol.x[:k]
                mn = np.max(np.abs(rfun(xn)))
                if mn < mx:
                    x, mx = xn, mn
                    tr *= 1.5
                    continue
            tr /= 2
        return x, mx, J, rfun(x)

    p9_0 = np.concatenate([pe0, pm, [rho0]])
    x9, m9, J9, r9 = fitgeo(geo9, p9_0)
    x8, m8, J8, r8 = fitgeo(geo8, p9_0[:8])
    print("# Earth start from a heliocentric ellipse fit: e=%.5f, period %.3f d; Mars start from Part A; rho0 = %.5f"
          % (pe0[0], TWO_PI / pe0[3], rho0))
    print("  rho free (9 elements): minimax geocentric error %.3f'   rho = %.6f, K3 value (n_E/n_M)^(2/3) = %.6f"
          % (m9 / ARCMIN, x9[8], (x9[3] / x9[7]) ** (2 / 3)))
    print("  K3       (8 elements): minimax geocentric error %.3f'" % (m8 / ARCMIN))
    print("  (the planes are fixed: Earth in the J2000 ecliptic, Mars in the best heliocentric plane of Part A)")
    names9 = ["e", "w", "L", "n", "e", "w", "L", "n", "rho"]
    RANGE["rho"] = (0.0, 4.0)
    rngB = np.random.default_rng(SEED + 2)

    def pca_volume(J, r0, D, x0, names, fn):
        """volume of the EXACT compatible region {x in the prior box : max_i |fn(x)_i - thg_i| <= D}.
        Stage 1: hit-or-miss in the LINEARISED polytope {|r0 + J (x - x0)|_inf <= D}, sampled in the
        whitened LP box, until 300 hits: their principal axes and extents define a box.  Stage 2: hit-or-miss
        with the exact model (all data; early rejection on every 7th day) in that box enlarged by 25%,
        enlarging any side with hits in its outer 3%.  Returns (V, se, hits, n, rounds, frac of stage-1
        linearised hits that are exactly compatible)."""
        k = J.shape[1]
        R, detR = whitening(J)
        Uz = J @ R
        lo, hi = lp_extents(Uz, r0, D)
        zlo, zhi = 1.05 * np.minimum(lo, 0) - 1e-9, 1.05 * np.maximum(hi, 0) + 1e-9
        inside = in_prior(names, x0)
        sub = np.arange(0, N, 7)
        cloud, n1 = [], 0
        while len(cloud) < 300 and n1 < 20_000_000:
            Z = zlo + rngB.random((50000, k)) * (zhi - zlo)
            ok = np.max(np.abs(r0[sub][None, :] + Z @ Uz[sub].T), axis=1) <= D
            idx = np.nonzero(ok)[0]
            if len(idx):
                ok[idx] = np.max(np.abs(r0[None, :] + Z[idx] @ Uz.T), axis=1) <= D
            n1 += 50000
            cloud.extend(list((Z[ok] @ R.T)))
        X = np.array(cloud)
        ex1 = np.max(np.abs(wrap(fn(x0 + X, tt) - thg)), axis=1)
        lin_ok = float(np.mean(ex1 <= D))
        mu = X.mean(axis=0)
        _, _, Q = np.linalg.svd(X - mu, full_matrices=False)      # rows: principal axes
        Y = (X - mu) @ Q.T
        blo, bhi = 1.25 * Y.min(axis=0), 1.25 * Y.max(axis=0)
        hit = make_hit_fn(fn, tt, thg, D)
        for rnd in range(10):
            width = bhi - blo
            hits, n = 0, 0
            near = np.zeros((k, 2), bool)
            while hits < 1200 and n < 2_000_000:
                Uu = rngB.random((20000, k))
                P = x0 + mu + (blo + Uu * width) @ Q
                h = inside(P)
                idx = np.nonzero(h)[0]
                if len(idx):
                    h[idx] = hit(P[idx])
                hits += int(h.sum())
                n += 20000
                if h.any():
                    near[:, 0] |= (Uu[h] < 0.03).any(axis=0)
                    near[:, 1] |= (Uu[h] > 0.97).any(axis=0)
            if not near.any():
                vol = float(np.prod(width))
                f = hits / n
                return f * vol, vol * math.sqrt(max(f * (1 - f), 1e-300) / n), hits, n, rnd, lin_ok
            blo[near[:, 0]] -= 0.6 * width[near[:, 0]]
            bhi[near[:, 1]] += 0.6 * width[near[:, 1]]
        return None

    print("%-7s %9s %9s %9s %7s %9s %7s %9s %8s %8s   %s" % ("delta'", "rho lo", "rho hi", "log2 V9", "+-se", "log2 V8",
                                                         "+-se", "K3 saves", "hits9", "hits8",
                                                         "share of linearised hits exactly compatible (9 / 8)"))
    for d in [8.0, 4.0, 2.0, 1.0]:
        D = d * ARCMIN
        if D < max(m9, m8):
            continue
        lo9, hi9 = lp_extents(J9, r9, D)
        o9 = pca_volume(J9, r9, D, x9, names9, geo9)
        o8 = pca_volume(J8, r8, D, x8, names9[:8], geo8)
        if o9 is None or o8 is None:
            print("%-7g  (volume estimate did not converge)" % d)
            continue
        V9, V8 = o9[0], o8[0]
        saves = math.log2(4.0 * V8 / V9)
        print("%-7g %9.5f %9.5f %9.2f %7.2f %9.2f %7.2f %9.2f %8d %8d   %.3f / %.3f"
              % (d, x9[8] + lo9[8], x9[8] + hi9[8], math.log2(V9), o9[1] / V9 / math.log(2), math.log2(V8),
                 o8[1] / V8 / math.log(2), saves, o9[2], o8[2], o9[5], o8[5]))
        sys.stdout.flush()
    print("# 'K3 saves' = log2(range_rho * V8 / V9), range_rho = 4: the bits of the element rho that K3 makes")
    print("# unnecessary.  Posterior odds (with K3 : without K3) = 2^(saves - |K3|), |K3| in bits from table A3.")
    print("# rho lo/hi: the linearised LP extent of rho over the compatible region at that delta.")
    print()
    print("# done in %.0f s" % (time.time() - T_START))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else "AB")
