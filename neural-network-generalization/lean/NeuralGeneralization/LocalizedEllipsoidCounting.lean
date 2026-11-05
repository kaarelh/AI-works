import NeuralGeneralization.LocalizedQuadraticCounting

/-! Actual ellipsoidal cylinders, with variable centers and matrices, belong
to one finite quadratic-pattern family. Intersections of their exteriors
have the manuscript's logarithmic cardinality bound. -/
noncomputable section
open scoped BigOperators
open Classical
namespace NeuralGeneralization.RobustLocalized
open ConcreteModel BatchTwoShallow

/-- A possibly singular matrix gives an ellipsoidal cylinder. The augmented
center is unrestricted, so this also includes all ordinary input centers. -/
def ellipsoidDistanceSq {d m : ℕ} (A : Fin m → Fin (d+1) → ℝ)
    (center : Fin (d+1) → ℝ) (x : Cube d) : ℝ :=
  ∑ i,(∑ j,A i j*(inputVector x j-center j))^2

lemma ellipsoid_quadratic {d m : ℕ} (A : Fin m → Fin (d+1) → ℝ)
    (center : Fin (d+1) → ℝ) (ρ : ℝ) :
    ∃ M : Fin (d+1) → Fin (d+1) → ℝ,∀ x : Cube d,
      (∑ i,∑ j,M i j*inputVector x i*inputVector x j) = ellipsoidDistanceSq A center x-ρ := by
  let B : Fin m → Fin (d+1) → ℝ := fun i j =>
    A i j-(if j=0 then ∑ k,A i k*center k else 0)
  have hB (i : Fin m) (x : Cube d) :
      (∑ j,B i j*inputVector x j) = ∑ j,A i j*(inputVector x j-center j) := by
    simp only [B,sub_mul,mul_sub,Finset.sum_sub_distrib,ite_mul,zero_mul]
    simp [inputVector]
  let Q : Fin (d+1) → Fin (d+1) → ℝ := fun i j => ∑ l,B l i*B l j
  have hQ (x : Cube d) :
      (∑ i,∑ j,Q i j*inputVector x i*inputVector x j) = ellipsoidDistanceSq A center x := by
    have hs (l : Fin m) : (∑ i,B l i*inputVector x i)^2 =
        ∑ i,∑ j,(B l i*B l j)*inputVector x i*inputVector x j := by
      rw [pow_two,Finset.sum_mul]
      simp_rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i _
      apply Finset.sum_congr rfl
      intro j _
      ring
    symm
    calc
      ellipsoidDistanceSq A center x = ∑ l,(∑ i,B l i*inputVector x i)^2 := by
        simp only [ellipsoidDistanceSq,hB]
      _ = ∑ l,∑ i,∑ j,(B l i*B l j)*inputVector x i*inputVector x j := by simp_rw [hs]
      _ = ∑ i,∑ j,∑ l,(B l i*B l j)*inputVector x i*inputVector x j := by
        rw [Finset.sum_comm]
        apply Finset.sum_congr rfl
        intro i _
        rw [Finset.sum_comm]
      _ = _ := by simp only [Q,Finset.sum_mul]
  refine ⟨fun i j => Q i j-(if i=0 ∧ j=0 then ρ else 0),fun x => ?_⟩
  simp only [sub_mul,Finset.sum_sub_distrib,ite_mul,zero_mul]
  rw [hQ]
  congr 1
  simp [ite_and,inputVector]

/-- Strict exteriors of arbitrary ellipsoids are actual members of the
fixed finite family; neither the row dimension nor the matrix is fixed. -/
theorem ellipsoid_exterior_mem {d m : ℕ} (A : Fin m → Fin (d+1) → ℝ)
    (center : Fin (d+1) → ℝ) (ρ : ℝ) :
    (Finset.univ.filter fun x : Cube d => ρ < ellipsoidDistanceSq A center x) ∈ quadraticPatterns d := by
  obtain ⟨M,hM⟩ := ellipsoid_quadratic A center ρ
  have hh := quadratic_pattern_mem M
  simpa only [hM,sub_pos] using hh

abbrev QuadraticCode (d : ℕ) := {A : Finset (Cube d) // A ∈ quadraticPatterns d}

def quadraticIntersection {d k : ℕ} (code : Fin k → QuadraticCode d) : Finset (Cube d) :=
  Finset.univ.filter fun x => ∀ i,x ∈ (code i).val

def ellipsoidExceptionFamily (d k : ℕ) : Finset (Finset (Cube d)) :=
  Finset.univ.image (quadraticIntersection (d := d) (k := k))

lemma univ_mem_quadraticPatterns (d : ℕ) : Finset.univ ∈ quadraticPatterns d := by
  have hh := quadratic_pattern_mem (d := d) (fun i j => if i=0 ∧ j=0 then 1 else 0)
  simpa [ite_and,inputVector] using hh

/-- Missing slots allow unions of at most k cylinders. Each matrix may have
a different number of rows, and centers and radii may vary independently. -/
theorem ellipsoid_union_exception_mem {d k : ℕ} (m : Fin k → ℕ)
    (A : ∀ i,Fin (m i) → Fin (d+1) → ℝ) (centers : Fin k → Fin (d+1) → ℝ)
    (radiiSq : Fin k → ℝ) (active : Fin k → Bool) :
    (Finset.univ.filter fun x : Cube d =>
      ∀ i,active i=true → radiiSq i < ellipsoidDistanceSq (A i) (centers i) x) ∈
        ellipsoidExceptionFamily d k := by
  let code : Fin k → QuadraticCode d := fun i =>
    if active i=true then
      ⟨Finset.univ.filter (fun x => radiiSq i < ellipsoidDistanceSq (A i) (centers i) x),
        ellipsoid_exterior_mem (A i) (centers i) (radiiSq i)⟩
    else ⟨Finset.univ,univ_mem_quadraticPatterns d⟩
  apply Finset.mem_image.mpr
  refine ⟨code,Finset.mem_univ _,?_⟩
  ext x
  simp only [quadraticIntersection,Finset.mem_filter,Finset.mem_univ,true_and]
  apply forall_congr'
  intro i
  by_cases hi : active i=true <;> simp [code,hi]

theorem ellipsoid_exception_card (d k : ℕ) :
    (ellipsoidExceptionFamily d k).card ≤ (2^d+1)^(k*((d+1)*(d+2)/2+1)) := by
  have hh := Finset.card_image_le (s := Finset.univ)
    (f := quadraticIntersection (d := d) (k := k))
  have hcodes : (ellipsoidExceptionFamily d k).card ≤ (quadraticPatterns d).card^k := by
    simpa only [ellipsoidExceptionFamily,Finset.card_univ,Fintype.card_fun,QuadraticCode,
      Fintype.card_coe,Fintype.card_fin] using hh
  apply hcodes.trans
  rw [Nat.mul_comm k,pow_mul]
  exact Nat.pow_le_pow_left (quadratic_card d) k

theorem ellipsoid_exception_log_card (d k : ℕ) :
    Real.log ((ellipsoidExceptionFamily d k).card:ℝ) ≤
      (k:ℝ)*(((d+1)*(d+2)/2+1:ℕ):ℝ)*((d:ℝ)+1)*Real.log 2 := by
  have hh := ellipsoid_exception_card d k
  have hbase : 2^d+1 ≤ 2^(d+1) := by
    have hp : 1 ≤ 2^d := Nat.one_le_pow _ _ (by omega)
    rw [pow_succ]
    omega
  have hb := hh.trans (Nat.pow_le_pow_left hbase (k*((d+1)*(d+2)/2+1)))
  by_cases hz : (ellipsoidExceptionFamily d k).card=0
  · simp only [hz,Nat.cast_zero,Real.log_zero]
    positivity
  · have hp : (0:ℝ) < (ellipsoidExceptionFamily d k).card := by exact_mod_cast Nat.pos_of_ne_zero hz
    have hr : ((ellipsoidExceptionFamily d k).card:ℝ) ≤
        ((2:ℝ)^(d+1))^(k*((d+1)*(d+2)/2+1)) := by exact_mod_cast hb
    have hl := Real.log_le_log hp hr
    rw [Real.log_pow,Real.log_pow] at hl
    push_cast at hl
    push_cast
    nlinarith only [hl]

end NeuralGeneralization.RobustLocalized
