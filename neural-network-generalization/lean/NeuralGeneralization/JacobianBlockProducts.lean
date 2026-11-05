import NeuralGeneralization.JacobianTriangularTransport

/-! Exact signed block products of the clean triangular transport. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open WithLp
namespace NeuralGeneralization.JacobianCertificate
variable {N r : ℕ}

abbrev Block (N : ℕ) := EuclideanSpace ℝ (Fin N)

def block (X : Stack N r) (s : Fin (r+1)) : Block N := toLp 2 (fun i => X (s,i))

def layerOperator (C : Fin r → Fin N → Fin N → ℝ) (s : Fin r) : Block N →L[ℝ] Block N :=
  coordinateMatrixOperator (fun ij => C s ij.1 ij.2)

@[simp] lemma layerOperator_apply (C : Fin r → Fin N → Fin N → ℝ)
    (s : Fin r) (v : Block N) (i : Fin N) :
    layerOperator C s v i = ∑ j,C s i j*v j := rfl

/-- Blocks of the lower-triangular inverse: zero above the diagonal, identity
on the diagonal, and left multiplication by each intervening layer below it. -/
def blockProduct (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) :
    Fin (r+1) → (Block N →L[ℝ] Block N) :=
  Fin.induction (if j=0 then 1 else 0)
    (fun s prev => layerOperator C s * prev + if j=s.succ then 1 else 0)

@[simp] lemma blockProduct_zero (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) :
    blockProduct C j 0 = if j=0 then 1 else 0 := rfl

@[simp] lemma blockProduct_succ (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) (s : Fin r) :
    blockProduct C j s.succ = layerOperator C s * blockProduct C j s.castSucc +
      if j=s.succ then 1 else 0 := rfl

lemma blockProduct_above (C : Fin r → Fin N → Fin N → ℝ)
    (j s : Fin (r+1)) (hs : s < j) : blockProduct C j s = 0 := by
  induction s using Fin.induction with
  | zero => simp [show j ≠ 0 by intro h; subst j; exact (lt_irrefl _ hs)]
  | succ s ih =>
    rw [blockProduct_succ,ih (Fin.castSucc_lt_succ.trans hs)]
    simp [show j ≠ s.succ by intro h; subst j; exact (lt_irrefl _ hs)]

lemma blockProduct_diagonal (C : Fin r → Fin N → Fin N → ℝ) (j : Fin (r+1)) :
    blockProduct C j j = 1 := by
  induction j using Fin.cases with
  | zero => simp
  | succ s => rw [blockProduct_succ,blockProduct_above C s.succ s.castSucc Fin.castSucc_lt_succ]; simp

/-- Below the diagonal this recurrence is exactly the ordered product
C_s C_(s-1) ... C_(j+1), preserving signs and cancellations. -/
lemma blockProduct_below (C : Fin r → Fin N → Fin N → ℝ)
    (j : Fin (r+1)) (s : Fin r) (hj : j < s.succ) :
    blockProduct C j s.succ = layerOperator C s * blockProduct C j s.castSucc := by
  simp [blockProduct_succ,show j ≠ s.succ from ne_of_lt hj]

lemma transport_solution (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r) :
    transport C X = shift C (transport C X)+X := by
  have hh := congrArg (fun F : Stack N r →L[ℝ] Stack N r => F X) (mul_transport C)
  change transport C X - shift C (transport C X) = X at hh
  exact (sub_eq_iff_eq_add.mp hh).trans (add_comm _ _)

lemma transport_first_block (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r) :
    block (transport C X) 0 = block X 0 := by
  ext i
  have hh := congrArg (fun Y : Stack N r => Y (0,i)) (transport_solution C X)
  simpa [block] using hh

lemma transport_succ_block (C : Fin r → Fin N → Fin N → ℝ) (X : Stack N r) (s : Fin r) :
    block (transport C X) s.succ = layerOperator C s (block (transport C X) s.castSucc)+block X s.succ := by
  ext i
  have hh := congrArg (fun Y : Stack N r => Y (s.succ,i)) (transport_solution C X)
  simpa [block] using hh

lemma identity_block_sum (X : Stack N r) (t : Fin (r+1)) :
    (∑ j : Fin (r+1), (if j=t then (1 : Block N →L[ℝ] Block N) else 0) (block X j)) = block X t := by
  have he (j : Fin (r+1)) : (if j=t then (1 : Block N →L[ℝ] Block N) else 0) (block X j) =
      if j=t then block X j else 0 := by split <;> simp_all
  simp_rw [he]
  simp

/-- The blocks of K are precisely the signed products above. -/
theorem transport_block_decomposition (C : Fin r → Fin N → Fin N → ℝ)
    (X : Stack N r) (s : Fin (r+1)) :
    block (transport C X) s = ∑ j,blockProduct C j s (block X j) := by
  induction s using Fin.induction with
  | zero => rw [transport_first_block]; simp only [blockProduct_zero,identity_block_sum]
  | succ s ih =>
    rw [transport_succ_block,ih]
    simp only [blockProduct_succ,ContinuousLinearMap.add_apply,
      ContinuousLinearMap.mul_apply,map_sum,Finset.sum_add_distrib]
    rw [identity_block_sum]

end NeuralGeneralization.JacobianCertificate
