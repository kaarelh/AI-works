"""Check the power-posterior exponent quoted in prop:teacher:concentration's proof idea and in app-teacher
(paragraph after the proof of prop:teacher:concentration): -n*eps + (J_g + eps)/c at c=1e-4, eps=1e-3,
n=1e6, kappa=0, with J_g(c) = c(d + kappa_g) + H(p), kappa_g = 2 log d + 2 log r. Deterministic."""
from math import log2
d, r, c, eps, n = 100, 10, 1e-4, 1e-3, 1e6
p = 2.0 ** -r
H = -p * log2(p) - (1 - p) * log2(1 - p)
kg = 2 * log2(d) + 2 * log2(r)
Jg = c * (d + kg) + H
print(f"J_g = {Jg:.6f}; (J_g+eps)/c = {(Jg+eps)/c:.2f}; exponent = {-n*eps + (Jg+eps)/c:.2f}")
print("paper: main text 'at most 2^-758'; app-teacher '-1000+242.3'")
