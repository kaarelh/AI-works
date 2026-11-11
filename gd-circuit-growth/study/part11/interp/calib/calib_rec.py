"""Recorder for dfg13_instr.py, the instrumented copy of DFG v1.3 used by calib.py (Part 11, calibration and compute).

dfg13_instr.py is dfg13.py (md5 69cabe5c...) with lines ADDED and none changed or removed (calib.py checks this with
difflib before every run).  Every added line is a call into the object REC below, and every such call only reads: the
FLOP counter fl[0], the process clock, and statistics the learner has just computed; it appends to REC's own lists and
returns None.  So the instrumented fits are the frozen fits (calib.py also checks test errors and FLOP totals against
the frozen module and against the evaluation's result files).

Two kinds of record:
  regions (always on while REC.on): DFG._fit is cut into consecutive regions by REC.enter(name); everything between two
          enter() calls (FLOP-counter increments and CPU seconds) is attributed to the region entered first, so the
          regions of one _fit call add up to its whole FLOP count and its whole CPU time.  The recorder's own detail
          work is excluded from the region times (its CPU time is subtracted).
  detail  (REC.detail = True): per round and candidate class, the number of distinct candidates that pass their test
          and the largest ratio |statistic| / threshold (the z-ratio; >= 1 means it passes); the linear block's chi^2
          ratio, the spectral block's top eigenvalue over its edge, every sum-block search's T / threshold; every
          admission (characters by the class whose test gave them their score, the linear block, spectral features,
          sum blocks by the code path that accepted them, forced features), and the origin of every feature of the
          model, aligned with DFG's own feature list F.
"""
import time, math
import numpy as np


def _bits(T):
    return np.array([sum(1 << int(i) for i in S) for S in T], dtype=np.int64)


class Rec:
    def __init__(self):
        self.on, self.detail, self.calls = False, False, []
        self._c, self._rd, self._fl = None, None, None
        self._masks = {}

    # ------------------------------------------------------------------------------------------------ control
    def reset(self, detail=False):
        self.on, self.detail, self.calls, self._c, self._rd = True, bool(detail), [], None, None

    def stop(self):
        self.on = False

    # ------------------------------------------------------------------------------------------------ regions
    def start(self, fl, n, d, force, hi, scale, GD):
        if not self.on:
            return
        c = dict(n=int(n), d=int(d), force=bool(force), hi=bool(hi), scale=float(scale), GD=float(GD), reg={},
                 rounds=[], origins=[("const", None, 0, ())], acc_kind={}, ovh=0.0)
        self.calls.append(c); self._c, self._fl, self._rd = c, fl, None
        self._region, self._f, self._t = "init", fl[0], time.process_time()

    def enter(self, name):
        if not self.on or self._c is None:
            return
        t = time.process_time(); f = self._fl[0]
        r = self._c["reg"].setdefault(self._region, [0.0, 0.0, 0])
        r[0] += f - self._f; r[1] += t - self._t; r[2] += 1
        self._region, self._f = name, f
        self._t = time.process_time()

    def finish(self, info):
        if not self.on or self._c is None:
            return
        self.enter("_end"); c = self._c
        c["flops"] = float(self._fl[0]); c["rounds_done"] = int(info.get("rounds", 0)); c["size"] = int(info.get("size", 0))
        c["train_err"] = float(info.get("train_err", float("nan")))
        self._c = None

    # helpers: exclude the recorder's own detail work from the region clock
    def _t0(self):
        return time.process_time()

    def _t1(self, t0):
        dt = time.process_time() - t0; self._t += dt
        if self._c is not None:
            self._c["ovh"] += dt

    # ------------------------------------------------------------------------------------------------ rounds
    def round_start(self, rnd):
        if not self.on or self._c is None:
            return
        rd = dict(rnd=int(rnd), stage="start", s=None, cls={}, best={}, passed={}, top=(0.0, None, None), sub={},
                  lin=None, quad=None, bs=[], acc=[], forced=None, sel=None, added=[], fl0=float(self._fl[0]))
        self._c["rounds"].append(rd); self._rd = rd

    def stage(self, s, val=None):
        if self.on and self._rd is not None:
            self._rd["stage"] = s
            if val is not None:
                self._rd["s"] = float(val)

    def sub(self, cl, m, n):
        """The subsample size m of a subsampled class (degrees 3-6, two-input extensions)."""
        if self.on and self._rd is not None:
            self._rd["sub"].setdefault(cl, []).append(int(m))

    def _cls(self, cl):
        return self._rd["cls"].setdefault(cl, dict(maxz=0.0, npass=0, noff=0, arg=None))

    def offer(self, S, v, t, have):
        """Mirrors DFG's offer(): a candidate S not yet in the model passes if |v| > t; its score is |v| / t, kept as in
        DFG's cand dict (replaced only by a larger score); the class is the region the offer is made from."""
        if not (self.on and self.detail and self._rd is not None):
            return
        t0 = self._t0()
        if S not in have:
            cl = self._region; z = abs(float(v)) / float(t); st = self._cls(cl); st["noff"] += 1
            if z > st["maxz"]:
                st["maxz"], st["arg"] = z, tuple(int(i) for i in S)
            if z > self._rd["top"][0]:
                self._rd["top"] = (z, tuple(int(i) for i in S), cl)
            if abs(v) > t:
                ps = self._rd["passed"].setdefault(cl, set())
                if S not in ps:
                    ps.add(S); st["npass"] += 1
                b = self._rd["best"].get(S)
                if b is None or b[0] < z:
                    self._rd["best"][S] = (z, cl)
        self._t1(t0)

    def hi_max(self, k, G, T1, T2, t):
        """Degrees 5-6: the largest |coefficient| / threshold over the disjoint (T1, T2) pairs, i.e. over every degree-k
        character of the subsample (DFG offers only the passing ones)."""
        if not (self.on and self.detail and self._rd is not None):
            return
        t0 = self._t0(); key = (len(T1), len(T2), tuple(T1[-1]), tuple(T2[-1]))
        M = self._masks.get(key)
        if M is None:
            b1, b2 = _bits(T1), _bits(T2); M = (b1[:, None] & b2[None, :]) == 0; self._masks[key] = M
        z = float(np.max(np.abs(G[M]))) / float(t); st = self._cls(f"g{k}")
        if z > st["maxz"]:
            st["maxz"] = z
        self._t1(t0)

    def ext1(self, e1, S, t1, have):
        if not (self.on and self.detail and self._rd is not None):
            return
        t0 = self._t0(); st = self._cls("ext1")
        z = [abs(float(e1[j])) / t1 for j in range(len(e1)) if j not in S and tuple(sorted(S + (j,))) not in have]
        if z and max(z) > st["maxz"]:
            st["maxz"] = max(z)
        self._t1(t0)

    def ext2(self, E2, S, t2, have):
        if not (self.on and self.detail and self._rd is not None):
            return
        t0 = self._t0(); st = self._cls("ext2"); A = np.abs(np.asarray(E2)).copy()
        A[list(S), :] = 0.0; A[:, list(S)] = 0.0
        z = float(A.max()) / t2 if A.size else 0.0
        if z > st["maxz"]:
            st["maxz"] = z
        self._t1(t0)

    def local(self, h, tl, V, have):
        if not (self.on and self.detail and self._rd is not None):
            return
        t0 = self._t0(); st = self._cls("local"); L = len(V); best = 0.0
        for m in range(1, 1 << L):
            S = tuple(V[q] for q in range(L) if m >> q & 1)
            if S in have:
                continue
            z = abs(float(h[m])) / tl[len(S)]
            if z > best:
                best = z
        if best > st["maxz"]:
            st["maxz"] = best
        self._t1(t0)

    def lin(self, T1, k, tt, room_ok, lin0):
        if self.on and self.detail and self._rd is not None:
            thr = k + 2 * math.sqrt(k * tt) + 2 * tt
            self._rd["lin"] = dict(T=float(T1), k=int(k), thr=float(thr), ratio=float(T1) / thr, room_ok=bool(room_ok),
                                   accepted=False)

    def quad(self, lam, edge, big, qs):
        if self.on and self.detail and self._rd is not None:
            self._rd["quad"] = dict(ratio=float(np.max(np.abs(lam))) / float(edge), n_ok=bool(big), nq=len(qs))

    # ------------------------------------------------------------------------------------------------ sum blocks
    def bs(self, kind, b, T, thr, ok, TS=None):
        """One _block_search call: its best candidate's statistic over the threshold (on all n), and whether it passed
        (for additive searches also the statistic on the residual projected off this round's characters)."""
        if self.on and self.detail and self._rd is not None:
            self._rd["bs"].append(dict(kind=kind, ratio=float(T / thr) if (b is not None and thr > 0) else None,
                                       ratioS=None if TS is None or thr <= 0 else float(TS / thr), ok=bool(ok),
                                       k=None if b is None else int(len(b.S)), inner=None if b is None else b.inner is not None))

    def tag(self, obj, kind):
        if self.on and self._c is not None:
            self._c["acc_kind"][id(obj)] = kind

    def acc(self, kind, obj=None):
        """An accepted block move: 'linear', 'quad', or a sum block with the code path that accepted it."""
        if not (self.on and self._rd is not None):
            return
        if kind == "sum_prodsplit":
            kind = self._c["acc_kind"].get(id(obj), "sum_prod")
        if kind.startswith("sum"):
            self._c["acc_kind"][id(obj)] = kind
        self._rd["acc"].append(dict(kind=kind, desc=None if obj is None or not hasattr(obj, "desc") else obj.desc()))
        if kind == "linear" and self._rd["lin"] is not None:
            self._rd["lin"]["accepted"] = True

    def forced(self, what, obj):
        if self.on and self._rd is not None:
            if what == "block":
                self._c["acc_kind"][id(obj)] = "forced_block"
                self._rd["forced"] = dict(kind="block", desc=obj.desc())
            else:
                self._rd["forced"] = dict(kind="char", S=tuple(int(i) for i in obj), cls=self._rd["top"][2])

    def sel(self, new, blk, room):
        if self.on and self._rd is not None:
            self._rd["sel"] = dict(n_new=len(new), n_blk=len(blk), room=int(room), stop=bool((not new and not blk) or room <= 0))
            self._rd["stage"] = "sel"

    # ------------------------------------------------------------------------------------------------ features
    def feat_chi(self, S):
        """A character appended to the model (from this round's admitted list): origin = forced, or the class whose
        test gave it its score."""
        if not (self.on and self._c is not None):
            return
        rd = self._rd; S = tuple(int(i) for i in S)
        if rd is not None and rd["forced"] is not None and rd["forced"].get("kind") == "char" and rd["forced"]["S"] == S:
            o = "forced"
        else:
            b = rd["best"].get(S) if rd is not None else None
            o = b[1] if b is not None else "unknown"
        self._c["origins"].append(("chi", o, rd["rnd"] if rd else -1, S))
        if rd is not None:
            rd["added"].append(("chi", o, S))

    def feat(self, kind, obj=None):
        if not (self.on and self._c is not None):
            return
        rd = self._rd
        if kind == "sum":
            o = self._c["acc_kind"].get(id(obj), "sum_unknown")
        else:
            o = "linear" if kind == "lin" else kind
        S = tuple(int(i) for i in obj) if kind == "lin" else None
        self._c["origins"].append((kind if kind != "lin" else "chi", o, rd["rnd"] if rd else -1, S))
        if rd is not None:
            rd["added"].append((kind, o, S))

    def block_added(self, obj, nuse):
        if self.on and self._rd is not None:
            self._rd.setdefault("blocks_added", []).append(dict(kind=self._c["acc_kind"].get(id(obj), "sum_unknown"),
                                                               desc=obj.desc(), nfeat=int(nuse)))

    def round_end(self):
        if self.on and self._rd is not None:
            self._rd["stage"] = "done"


REC = Rec()
