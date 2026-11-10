"""Checks of the C enumerator against the brute-force reference, and of basic identities."""
import os
import subprocess
import tempfile
from fractions import Fraction

import bf8

HERE = os.path.dirname(os.path.abspath(__file__))


def c_mixture(LC, N, T0, T1, cellmod):
    with tempfile.TemporaryDirectory() as d:
        out = os.path.join(d, "m.txt")
        subprocess.run([os.path.join(HERE, "bf8enum"), str(LC), str(N), str(T0), str(T1), str(cellmod), out],
                       check=True, capture_output=True)
        return bf8.load_mixture(out)


def test_matches_bruteforce():
    for LC, N, T0, T1, cm in [(3, 10, 0, 6, 16), (4, 12, 0, 9, 16), (4, 12, 3, 4, 4), (5, 9, 0, 12, 8)]:
        a = c_mixture(LC, N, T0, T1, cm)
        b = bf8.mixture_bruteforce(LC, N, T0, T1, cm)
        assert a == b, (LC, N, T0, T1, cm)


def test_semimeasure():
    m = c_mixture(6, 14, 0, 10, 16)
    assert m["0"] + m["1"] <= 1
    for x, v in m.items():
        assert m.get(x + "0", 0) + m.get(x + "1", 0) <= v


def test_known_programs():
    # '+[:]' prints 1 forever with 4 commands read; '.]' needs a nonzero cell to loop, so it prints one 0
    out, reads = bf8.run(bf8.parse("+[:]"), 6, 0, 10)
    assert out == [1] * 6 and reads == [3, 4, 4, 4, 4, 4]
    out, _ = bf8.run(bf8.parse("+[:+]"), 40, 0, 10, cellmod=16)
    assert out == [1] * 15          # the cell wraps to 0 after 15 increments and the loop ends
    # the two programs behind the capture example of the paper
    out, _ = bf8.run(bf8.parse("+[.+.+]"), 48, 0, 24)
    assert out == [1, 0] * 24       # prints the alternating stream forever
    out, _ = bf8.run(bf8.parse("+[.+]"), 48, 0, 24)
    assert out == ([1, 0] * 8)[:15]  # prints its first 15 bits and then leaves the loop


if __name__ == "__main__":
    test_matches_bruteforce(); test_semimeasure(); test_known_programs(); print("ok")
