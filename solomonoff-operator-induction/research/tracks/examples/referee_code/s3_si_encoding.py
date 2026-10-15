"""s3 (referee, run 2): SI's label loss in the cyclic example (H5) depends on the encoding.

The track's Prop 2.6 encodes the history x_1 y_1 x_2 y_2 ... as raw n-bit blocks with no
delimiters and bounds SI's expected label loss by K(n) + c.  The history track's common
convention codes every string s as 1^{|s|} 0 s (prefix-free).  The referee report proves that
with this code the expected label loss of M is O(1) uniformly in n.

This script illustrates the difference with an exact, computable SI proxy: a Bayes mixture,
at the level of bits, of the true processes mu_{n'} for n' = 1..12 (prior w(n') proportional to
1/(n'(n'+1))) plus an i.i.d. fair-bit null model (weight 0.1).  For each true n and each of
3 random cyclic permutations it computes the proxy's label loss (bits of the label blocks
only) in the two encodings.

Seed 20261012.  Output: s3_si_encoding_output.txt (next to this file).
"""
import math
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = []


def say(*a):
    s = " ".join(str(x) for x in a)
    print(s, flush=True)
    OUT.append(s)


def bits(v, n):
    return [(v >> (n - 1 - i)) & 1 for i in range(n)]


def true_bits(n, order, code):
    """Binary encoding of x_1 y_1 ... x_N y_N, and a mask marking label bits."""
    N = 2 ** n
    xs = list(order) + [0]
    ys = [0] + xs[:-1]
    out, mask = [], []
    for x, y in zip(xs, ys):
        for v, is_label in ((x, False), (y, True)):
            b = bits(v, n)
            if code == "prefix":
                b = [1] * n + [0] + b
            out += b
            mask += [is_label] * len(b)
    return out, mask


class Hyp:
    """The true process mu_{m} for block length m, read bit by bit in a given encoding.
    Inputs: uniform over unused nonzero m-bit strings for steps 1..2^m - 1, then 0^m;
    labels: previous input (0^m first).  After the cycle closes: fair bits."""

    def __init__(self, m, code):
        self.m = m
        self.code = code
        self.N = 2 ** m
        self.step = 0            # completed (x,y) pairs
        self.in_x = True
        self.hdr = 0             # header bits read in the current block (prefix code)
        self.r = 0               # body bits read in the current block
        self.prefix = 0          # value of body bits read so far (x block)
        self.used = {}           # (length, prefix value) -> number of used strings with that prefix
        self.prev_x = 0
        self.cur_x = 0
        self.dead = False

    def used_count(self, length, val):
        return self.used.get((length, val), 0)

    def prob(self, b):
        """Probability of next bit b given the past (under this hypothesis)."""
        if self.dead:
            return 0.0
        m = self.m
        if self.step >= self.N:
            return 0.5
        if self.code == "prefix" and self.hdr <= m:
            want = 1 if self.hdr < m else 0
            return 1.0 if b == want else 0.0
        if self.in_x:
            if self.step == self.N - 1:          # last input is 0^m
                return 1.0 if b == 0 else 0.0
            r = self.r
            p = self.prefix

            def count(length, val):
                c = 2 ** (m - length) - self.used_count(length, val)
                if val == 0:
                    c -= 1                        # exclude 0^m
                return c
            c0 = count(r, p)
            c1 = count(r + 1, 2 * p + b)
            return max(0.0, c1 / c0) if c0 > 0 else 0.0
        else:
            want = bits(self.prev_x, m)[self.r]
            return 1.0 if b == want else 0.0

    def update(self, b):
        m = self.m
        if self.dead or self.step >= self.N:
            return
        if self.code == "prefix" and self.hdr <= m:
            self.hdr += 1
            return
        self.r += 1
        if self.in_x:
            self.prefix = 2 * self.prefix + b
            if self.r == m:
                x = self.prefix
                if self.step < self.N - 1:
                    for L in range(m + 1):
                        key = (L, x >> (m - L))
                        self.used[key] = self.used.get(key, 0) + 1
                self.cur_x = x
                self.in_x = False
                self.r = 0
                self.hdr = 0
                self.prefix = 0
        else:
            if self.r == m:
                self.prev_x = self.cur_x
                self.step += 1
                self.in_x = True
                self.r = 0
                self.hdr = 0


def label_loss(n, order, code, mmax=12, w_null=0.1):
    B, mask = true_bits(n, order, code)
    hyps = [Hyp(m, code) for m in range(1, mmax + 1)]
    raw = [1.0 / (m * (m + 1)) for m in range(1, mmax + 1)]
    Z = sum(raw)
    lw = [math.log2((1 - w_null) * x / Z) for x in raw] + [math.log2(w_null)]
    loss = 0.0
    for b, is_lab in zip(B, mask):
        ps = [h.prob(b) for h in hyps] + [0.5]
        # predictive = sum_h 2^{lw_h} p_h / sum_h 2^{lw_h}
        mx = max(lw)
        den = sum(2 ** (l - mx) for l in lw)
        num = sum(2 ** (l - mx) * p for l, p in zip(lw, ps))
        if is_lab:
            loss += -math.log2(num / den)
        lw = [l + (math.log2(p) if p > 0 else -math.inf) for l, p in zip(lw, ps)]
        for h, p in zip(hyps, ps):
            if p <= 0:
                h.dead = True
            h.update(b)
    return loss


def main():
    rng = random.Random(20261012)
    say("s3_si_encoding.py  (referee, run 2; seed 20261012)")
    say("SI proxy: bitwise Bayes mixture of mu_m (m = 1..12, w(m) ~ 1/(m(m+1)), total 0.9) and fair bits (0.1).")
    say("Label loss in bits over the full cycle (all 2^n steps), 3 random cyclic permutations per n.")
    say("   n | raw n-bit blocks (no delimiters)     | prefix code 1^|s| 0 s          | -log2 w(n) | log2(sum_{m>=n} w(m)/w(n))")
    raw = [1.0 / (m * (m + 1)) for m in range(1, 13)]
    Z = sum(raw)
    for n in range(2, 9):
        N = 2 ** n
        rl, pl = [], []
        for _ in range(3):
            order = rng.sample(range(1, N), N - 1)
            rl.append(label_loss(n, order, "raw"))
            pl.append(label_loss(n, order, "prefix"))
        wn = 0.9 * raw[n - 1] / Z
        tail = sum(0.9 * raw[m - 1] / Z for m in range(n, 13))
        say(f"  {n:2d} | {' '.join(f'{x:9.4f}' for x in rl)} | {' '.join(f'{x:9.2e}' for x in pl)} | "
            f"{-math.log2(wn):9.3f} | {math.log2(tail / wn):9.3f}")
    say("Reading: with delimiter-free blocks the proxy pays about 1-9 bits of label loss, varying with the")
    say("permutation: it must infer where the blocks end, and hypotheses with other block lengths survive for")
    say("a while.  With the prefix code it reads n from the first header, before any label, and pays < 0.1 bits")
    say("(the residual weight of the null model) for every n.  The proxy prior is not universal, so the raw")
    say("column illustrates the mechanism only; it is not evidence about the growth rate K(n).")
    with open(os.path.join(HERE, "s3_si_encoding_output.txt"), "w") as fh:
        fh.write("\n".join(OUT) + "\n")


if __name__ == "__main__":
    main()
