"""Numbers for the proposed page-1 example (Cmin chain, quantifier-free phi, c = 0.3).
H_all = {forall x phi}: cite (1-c) -> outputs forall x phi; or forall-E (c) then cite -> phi(t), t ~ Q.
H_sch = {phi(z)}: cite -> phi(t) only (forall-E needs a leading forall, so the chain must cite).
Normalised law L1 = mu_T / Z_T (universal Prop U1, Thm U2; paper prop:univ:factor, thm:univ:odds)."""
from math import log, exp
c = 0.3
Z_sch = (1 - c)                  # sum_{k<=m} c^k with m = 0 leading quantifiers
Z_all = (1 - c) + c * Z_sch
P_all_self = (1 - c) / Z_all     # probability that H_all's datum is forall x phi itself
P_all_inst_factor = c * Z_sch / Z_all   # P_all(phi(t)) / Q(t)
P_sch_inst_factor = Z_sch / Z_sch       # = 1
print(f"Z_sch={Z_sch:.4f} Z_all={Z_all:.4f}")
print(f"P_Hall(forall x phi) = {P_all_self:.4f}  (= 1/(1+c) = {1/(1+c):.4f})")
print(f"P_Hall(phi(t)) / Q(t) = {P_all_inst_factor:.4f}  (= c/(1+c) = {c/(1+c):.4f});  P_Hsch(phi(t))/Q(t) = {P_sch_inst_factor:.1f}")
for n in (1, 5, 10, 20):
    print(f"n={n:2d}: odds H_all:H_sch fall by (c/(1+c))^n = {(c/(1+c))**n:.3e}  ({n*log((1+c)/c)/log(2):.1f} bits)")
print(f"per-datum KL ln((1+c)/c) = {log((1+c)/c):.3f} nats = {log((1+c)/c)/log(2):.3f} bits")
# unnormalised mu_T and Lmax: factor c per datum
print(f"unnormalised factor c = {c}; per datum {log(1/c)/log(2):.3f} bits")
