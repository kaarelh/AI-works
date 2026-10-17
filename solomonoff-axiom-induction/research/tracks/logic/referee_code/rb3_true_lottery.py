"""rb3_true_lottery.py -- referee B (thread `logic`): exhaustive propositional check of the
bookkeeping of Thm 2.9(b) (true lotteries) and of the case analysis in Cor 2.10(iii) (the random
lottery theory is Sigma_1-unsound).  Written independently of the developer's c1 (part A3).

No randomness.  Output: rb3_true_lottery.out (stdout).

Propositional model of one lottery k with tickets 0..N (N = N_k), faithful to the proof:
  * R_i (i <= N): the Sigma_1 sentence Ref(k,i) = "B + W_k refutes theta_{k,i}"; R = {i : R_i true}.
    True Sigma_1 sentences are provable in Q (Sigma_1-completeness), so every true R_i is a
    premise; false R_i are free atoms.
  * A_j: the Sigma_1 sentence A(<k,j>), false for every j (Lemma 2.8(ii)/(iii)); free atoms.
  * M: the false Sigma_1 sentence "not N" (N is the true Pi_1 sentence of Lemma 2.8(iii)); free.
  * theta_j  ==  A_j  v  ( ~M  &  Psi_j ),  Psi_j == (R_j & AND_{i<j} ~R_i)  v  (j = 0 & AND_{i<=N} ~R_i).
  * t := least i in R, or 0 if R is empty; theta_j is TRUE iff j = t (Lemma 2.8(ii)).
  W_k's behaviour at lottery k: (I) inconsistent (R = all tickets); (C1) consistent and proves
  Lot_k (R a proper subset); (C0) consistent, does not prove Lot_k (R arbitrary).
Checks, for N in {1, 3, 7} (lotteries 0, 1, 2) and every R and every behaviour (about 2 minutes):
  B1  j*_k (least j != t with j not in R in case C1; least j != t otherwise) exists;
  B2  the data are true: Lot_k = OR theta_j is true, ~theta_{j*} is true (j* != t);
  B3  W_k fails the data: in C1 it does not refute theta_{j*} (j* not in R); in C0 it does not
      prove Lot_k;
  B4  (Cor 2.10(iii)) for every winner J != t of the random theory (and J != j*: survival), the
      premises {theta_J} + {R_i : i in R} propositionally ENTAIL a false Sigma_1 sentence, namely
      the record's: A_J if R is nonempty and J > t; A_J v R_J otherwise; and Psi_J -> R_J follows
      from the premises in the case J = 0 < t (the record's "via Q |- R_t");
  B5  the random theory's whole output at lottery k, {Lot_k, theta_J, ~theta_j (j != J)}, together
      with the true R_i, is propositionally satisfiable (consistency; Lemma 2.8(i) gives it in
      arithmetic) -- and, when J != t, every satisfying assignment makes some false Sigma_1
      atom true (the theory cannot be true);
  B6  P(J = t | J != j*) = 1/N exactly (uniform J), so P(all true winners | survival) = prod 1/N_k.
"""
import itertools
from fractions import Fraction


def evaluate(N, R, J, assign):
    """Truth of theta_j under an assignment of the free atoms; R given (true atoms)."""
    A = assign["A"]
    M = assign["M"]
    Rv = [(i in R) or assign["R"][i] for i in range(N + 1)]

    def psi(j):
        first = Rv[j] and all(not Rv[i] for i in range(j))
        second = (j == 0) and all(not Rv[i] for i in range(N + 1))
        return first or second

    th = [A[j] or ((not M) and psi(j)) for j in range(N + 1)]
    return th, Rv, psi


def assignments(N, R):
    free_R = [i for i in range(N + 1) if i not in R]
    for Abits in itertools.product([False, True], repeat=N + 1):
        for M in (False, True):
            for Rbits in itertools.product([False, True], repeat=len(free_R)):
                Rassign = [False] * (N + 1)
                for i, b in zip(free_R, Rbits):
                    Rassign[i] = b
                yield {"A": list(Abits), "M": M, "R": Rassign}


def run():
    total = {k: 0 for k in ("B1", "B2", "B3", "B4", "B5", "B6")}
    viol = {k: 0 for k in total}
    for N in (1, 3, 7):
        for Rmask in range(1 << (N + 1)):
            R = {i for i in range(N + 1) if Rmask >> i & 1}
            t = min(R) if R else 0
            # actual truth: all free atoms false
            truth = {"A": [False] * (N + 1), "M": False, "R": [False] * (N + 1)}
            th_true, _, _ = evaluate(N, R, None, truth)
            assert th_true == [j == t for j in range(N + 1)], (N, R, th_true)
            for beh in ("I", "C1", "C0"):
                if beh == "I" and len(R) != N + 1:
                    continue
                if beh == "C1" and len(R) == N + 1:
                    continue
                total["B1"] += 1
                if beh == "C1":
                    cand = [j for j in range(N + 1) if j != t and j not in R]
                else:
                    cand = [j for j in range(N + 1) if j != t]
                if not cand:
                    viol["B1"] += 1
                    continue
                js = cand[0]
                total["B2"] += 1
                if not (any(th_true) and not th_true[js]):
                    viol["B2"] += 1
                total["B3"] += 1
                if beh == "C1" and js in R:
                    viol["B3"] += 1
                # B4/B5: the random theory with winner J
                if N <= 7:
                    for J in range(N + 1):
                        if J == js:
                            continue           # did not survive
                        sat_any = False
                        all_sat_unsound = True
                        entail_record = True
                        entail_psi = True
                        for asg in assignments(N, R):
                            th, Rv, psi = evaluate(N, R, J, asg)
                            # B4 premises: theta_J and the true R_i (built in)
                            if th[J]:
                                if J != t:
                                    concl = asg["A"][J] if (R and J > t) else (asg["A"][J] or Rv[J])
                                    if not concl:
                                        entail_record = False
                                    if J == 0 and t > 0 and psi(0) and not Rv[0]:
                                        entail_psi = False
                            # B5 whole output: Lot, theta_J, ~theta_j
                            whole = any(th) and th[J] and all(not th[j] for j in range(N + 1) if j != J)
                            if whole:
                                sat_any = True
                                false_atom_true = any(asg["A"]) or asg["M"] or any(asg["R"])
                                if J != t and not false_atom_true:
                                    all_sat_unsound = False
                        if J != t:
                            total["B4"] += 1
                            if not (entail_record and entail_psi):
                                viol["B4"] += 1
                        total["B5"] += 1
                        if not sat_any or (J != t and not all_sat_unsound):
                            viol["B5"] += 1
                # B6
                total["B6"] += 1
                surv = [J for J in range(N + 1) if J != js]
                if Fraction(sum(1 for J in surv if J == t), len(surv)) != Fraction(1, N):
                    viol["B6"] += 1
        print(f"  N={N}: done ({1 << (N + 1)} refutation sets)")
    for k in total:
        print(f"  {k}: {viol[k]} violations in {total[k]} cases")
    p = Fraction(1)
    for k in range(5):
        p *= Fraction(1, 2 ** (k + 1) - 1)
    print(f"  prod_(k<5) 1/N_k = {p}  (c1 A3 lists 1, 1/3, 1/21, 1/315 for K=1..4)")
    assert all(v == 0 for v in viol.values())


if __name__ == "__main__":
    print("rb3_true_lottery: exhaustive, no randomness")
    run()
    print("all assertions passed")
