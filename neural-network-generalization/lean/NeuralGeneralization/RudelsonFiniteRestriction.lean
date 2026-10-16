import NeuralGeneralization.FiniteCoordinateSymmetrization
import NeuralGeneralization.SquaredResponseScaling
import NeuralGeneralization.RankOneRademacherBound

/-!
# Finite random-restriction bound from actual rank-one chaining

The selectors are independent draws from a finite uniform space followed
by an arbitrary Boolean selection rule. Thus the result includes every
rational Bernoulli parameter. No matrix concentration result is assumed.
-/
noncomputable section
namespace NeuralGeneralization.SquaredSampling
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

variable {m D : ℕ} {U α : Type*} [Fintype U] [Nonempty U]

def restrictionLog (m D : ℕ) : ℝ :=
  Real.log (8*(m:ℝ))+(dimensionCutoff D+1 : ℕ)

theorem restrictionLog_ge_one (hm : 0 < m) : 1 ≤ restrictionLog m D := by
  have h := rankGrowth_log_nonneg m hm
  have hd : (0:ℝ) ≤ dimensionCutoff D := Nat.cast_nonneg _
  unfold restrictionLog
  push_cast
  linarith

/-- A homogeneous form of the actual finite rank-one Rademacher estimate,
with any positive upper bound on the full row energy. -/
theorem finite_row_rademacher_bound (a : Fin m → Fin D → ℝ)
    (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀=0)
    (V R : ℝ) (hm : 0 < m) (hV : 0 < V) (hR : 0 < R)
    (ha : ∀ i, (∑ j, a i j^2) ≤ V)
    (hp : ∀ u, (∑ j, p u j^2) ≤ 1)
    (hrow : ∀ u, (∑ i, linearEvaluation (a i) (p u)^2) ≤ R) :
    finiteMean (fun ε : Fin m → Bool => envelope (fun u =>
      ∑ i, cubeCoordinateSign (ε i)*linearEvaluation (a i) (p u)^2)) ≤
      268435456*Real.sqrt (V*restrictionLog m D)*Real.sqrt R := by
  let b := fun i j => a i j / Real.sqrt R
  have hb (i : Fin m) : (∑ j, b i j^2) ≤ V/R := by
    simp only [b, div_pow, ← Finset.sum_div, Real.sq_sqrt hR.le]
    exact div_le_div_of_nonneg_right (ha i) hR.le
  have hr (u : U) : (∑ i, linearEvaluation (b i) (p u)^2) ≤ 1 := by
    simp only [b, linearEvaluation_row_div, div_pow, ← Finset.sum_div, Real.sq_sqrt hR.le]
    exact (div_le_one hR).mpr (hrow u)
  have h := finite_squared_response_rademacher b p u₀ hroot (V/R) hm
    (div_pos hV hR) hb hp hr id rfl (fun x y => le_rfl)
  have he (ε : Fin m → Bool) (u : U) :
      (∑ i, cubeCoordinateSign (ε i)*linearEvaluation (a i) (p u)^2) =
      R*(∑ i, cubeCoordinateSign (ε i)*linearEvaluation (b i) (p u)^2) := by
    simp only [b, linearEvaluation_row_div, div_pow, Real.sq_sqrt hR.le]
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    field_simp
  simp_rw [he, envelope_const_mul _ R hR.le]
  rw [finiteMean_mul]
  have hh := mul_le_mul_of_nonneg_left h hR.le
  change _ ≤ R*(268435456*Real.sqrt ((V/R)*restrictionLog m D)) at hh
  have hi := sqrt_normalization_identity V (restrictionLog m D) R hV.le
    ((show (0:ℝ) ≤ 1 by norm_num).trans (restrictionLog_ge_one hm)) hR
  calc
    _ ≤ R*(268435456*Real.sqrt ((V/R)*restrictionLog m D)) := hh
    _ = _ := by nlinarith only [hi]

/-- Literal retained rows; the common marginal retention probability is
`finiteMean (fun x => if choose x then 1 else 0)`. -/
def selectedRows (a : Fin m → Fin D → ℝ) (choose : α → Bool)
    (s : Fin m → α) : Fin m → Fin D → ℝ :=
  fun i j => if choose (s i) then a i j else 0

lemma selectedRows_evaluation (a : Fin m → Fin D → ℝ) (choose : α → Bool)
    (s : Fin m → α) (i : Fin m) (u : Fin D → ℝ) :
    linearEvaluation (selectedRows a choose s i) u =
      if choose (s i) then linearEvaluation (a i) u else 0 := by
  by_cases h : choose (s i) = true <;> simp [selectedRows, h, linearEvaluation]

lemma selectedRows_variance (a : Fin m → Fin D → ℝ) (choose : α → Bool)
    (s : Fin m → α) (V : ℝ) (hV : 0 ≤ V)
    (ha : ∀ i, (∑ j, a i j^2) ≤ V) (i : Fin m) :
    (∑ j, selectedRows a choose s i j^2) ≤ V := by
  by_cases h : choose (s i) = true
  · simpa [selectedRows, h] using ha i
  · simpa [selectedRows, h] using hV

lemma unit_row_square_bound (a u : Fin D → ℝ) (V : ℝ)
    (ha : (∑ j, a j^2) ≤ V) (hu : (∑ j, u j^2) ≤ 1) :
    linearEvaluation a u^2 ≤ V := by
  have h := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ a u
  have hA : 0 ≤ ∑ j, a j^2 := Finset.sum_nonneg (fun j _ => sq_nonneg _)
  have hm := mul_le_mul_of_nonneg_left hu hA
  change linearEvaluation a u^2 ≤ _ at h
  nlinarith only [h, hm, ha]

variable [Fintype α] [Nonempty α]

/-- The L2 random-row operator bound, first stated for a finite collection
of unit coefficient vectors. Its logarithmic loss comes entirely from the
proved rank-one chaining theorem. -/
theorem finite_selected_square_envelope (a : Fin m → Fin D → ℝ)
    (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀=0)
    (choose : α → Bool) (V B : ℝ) (hm : 0 < m) (hV : 0 < V) (hB : 0 ≤ B)
    (ha : ∀ i, (∑ j, a i j^2) ≤ V)
    (hp : ∀ u, (∑ j, p u j^2) ≤ 1)
    (hrow : ∀ u, (∑ i, linearEvaluation (a i) (p u)^2) ≤ B) :
    Real.sqrt (finiteMean (fun s : Fin m → α =>
      empiricalSquareEnvelope (selectedRows a choose s) p)) ≤
      536870913*Real.sqrt (V*restrictionLog m D)+
        Real.sqrt ((finiteMean (fun x : α => if choose x then (1:ℝ) else 0))*B) := by
  let q := finiteMean (fun x : α => if choose x then (1:ℝ) else 0)
  have hq : 0 ≤ q := finiteMean_nonneg (fun x => by split_ifs <;> norm_num)
  let F := fun i u x => if choose x then linearEvaluation (a i) (p u)^2 else 0
  let S := fun s : Fin m → α => empiricalSquareEnvelope (selectedRows a choose s) p
  let Z := fun s : Fin m → α => envelope (fun u =>
    coordinateTotal F s u - ∑ i, finiteMean (F i u))
  let A := 268435456*Real.sqrt (V*restrictionLog m D)
  have hA : 0 ≤ A := by dsimp [A]; positivity
  have hS (s : Fin m → α) : 0 ≤ S s := empiricalSquareEnvelope_nonneg _ _
  have hF : ∀ i u x, |F i u x| ≤ V := by
    intro i u x
    dsimp only [F]
    split_ifs
    · rw [abs_of_nonneg (sq_nonneg _)]
      exact unit_row_square_bound (a i) (p u) V (ha i) (hp u)
    · simpa using hV.le
  have htotal (s : Fin m → α) (u : U) :
      coordinateTotal F s u = ∑ i, linearEvaluation (selectedRows a choose s i) (p u)^2 := by
    unfold coordinateTotal
    apply Finset.sum_congr rfl
    intro i _
    rw [selectedRows_evaluation]
    dsimp only [F]
    split_ifs <;> simp
  have hmean (i : Fin m) (u : U) :
      finiteMean (F i u) = q*linearEvaluation (a i) (p u)^2 := by
    have he (x : α) : F i u x = linearEvaluation (a i) (p u)^2*
        (if choose x then (1:ℝ) else 0) := by dsimp [F]; split_ifs <;> simp
    change finiteMean (fun x : α => F i u x) = _
    simp_rw [he]
    rw [finiteMean_mul]
    ring
  have hpop (u : U) : (∑ i, finiteMean (F i u)) ≤ q*B := by
    simp_rw [hmean]
    rw [← Finset.mul_sum]
    exact mul_le_mul_of_nonneg_left (hrow u) hq
  have hSZ (s : Fin m → α) : S s ≤ q*B+Z s := by
    apply envelope_le
    intro u
    have hval : 0 ≤ coordinateTotal F s u := by
      rw [htotal]
      exact Finset.sum_nonneg (fun i _ => sq_nonneg _)
    change |∑ i, linearEvaluation (selectedRows a choose s i) (p u)^2| ≤ _
    rw [← htotal, abs_of_nonneg hval]
    have hz := le_envelope_finite (fun u => coordinateTotal F s u-∑ i,finiteMean (F i u)) u
    have habs := le_abs_self (coordinateTotal F s u-∑ i,finiteMean (F i u))
    have hh := hpop u
    change _ ≤ q*B+envelope _
    linarith only [hz, habs, hh]
  have hrad (s : Fin m → α) :
      finiteMean (fun ε : Fin m → Bool => envelope (signedCoordinateTotal F ε s)) ≤
        A*Real.sqrt (S s+V) := by
    have hR : 0 < S s+V := by linarith only [hS s, hV]
    have hr := finite_row_rademacher_bound (selectedRows a choose s) p u₀ hroot
      V (S s+V) hm hV hR (selectedRows_variance a choose s V hV.le ha) hp
      (fun u => (rowEnergy_le_empiricalSquareEnvelope _ p u).trans (by
        change S s ≤ S s+V
        linarith only [hV]))
    have he (ε : Fin m → Bool) (u : U) :
        signedCoordinateTotal F ε s u =
        ∑ i, cubeCoordinateSign (ε i)*linearEvaluation (selectedRows a choose s i) (p u)^2 := by
      unfold signedCoordinateTotal
      apply Finset.sum_congr rfl
      intro i _
      rw [selectedRows_evaluation]
      dsimp only [F]
      split_ifs <;> simp
    change finiteMean (fun ε : Fin m → Bool => envelope (fun u => signedCoordinateTotal F ε s u)) ≤ _
    simp_rw [he]
    exact hr
  have hZmean : finiteMean Z ≤ 2*A*finiteMean (fun s => Real.sqrt (S s+V)) := by
    have hsym := finite_coordinate_symmetrization_centered m F hF
    rw [finiteMean_comm] at hsym
    have hh := finiteMean_mono hrad
    rw [finiteMean_mul] at hh
    change finiteMean Z ≤ _ at hsym
    linarith only [hsym, hh]
  have hSmean : finiteMean S ≤ q*B+2*A*finiteMean (fun s => Real.sqrt (S s+V)) := by
    have hh := finiteMean_mono hSZ
    rw [finiteMean_add, finiteMean_const] at hh
    linarith only [hh, hZmean]
  let W := Real.sqrt (finiteMean S+V)
  have hW : 0 ≤ W := Real.sqrt_nonneg _
  have hmean0 : 0 ≤ finiteMean S := finiteMean_nonneg hS
  have hWsq : W^2 = finiteMean S+V := Real.sq_sqrt (by linarith only [hmean0,hV])
  have hY : finiteMean (fun s => Real.sqrt (S s+V)) ≤ W := by
    have hh := finiteMean_sqrt_square (fun s => S s+V) (fun s => by linarith only [hS s,hV])
    rw [finiteMean_add, finiteMean_const] at hh
    have hy0 := finiteMean_nonneg (fun s : Fin m → α => Real.sqrt_nonneg (S s+V))
    nlinarith only [hh, hWsq, hW, hy0]
  have hquad : W^2 ≤ (q*B+V)+2*A*W := by
    have hh := mul_le_mul_of_nonneg_left hY (show 0 ≤ 2*A by positivity)
    nlinarith only [hWsq,hSmean,hh]
  have hbound := square_bootstrap A (q*B+V) W hA (by positivity) hW hquad
  have hsqrt : Real.sqrt (q*B+V) ≤ Real.sqrt (q*B)+Real.sqrt V := by
    have h1 := Real.sq_sqrt (mul_nonneg hq hB)
    have h2 := Real.sq_sqrt hV.le
    have h3 := Real.sq_sqrt (show 0 ≤ q*B+V by positivity)
    have h4 := Real.sqrt_nonneg (q*B)
    have h5 := Real.sqrt_nonneg V
    have h6 := Real.sqrt_nonneg (q*B+V)
    nlinarith only [h1,h2,h3,h4,h5,h6,mul_nonneg h4 h5]
  have hVbound : Real.sqrt V ≤ Real.sqrt (V*restrictionLog m D) :=
    Real.sqrt_le_sqrt (by nlinarith only [restrictionLog_ge_one (D:=D) hm,hV])
  have hfirst : Real.sqrt (finiteMean S) ≤ W := Real.sqrt_le_sqrt (by linarith only [hV])
  change Real.sqrt (finiteMean S) ≤ 536870913*Real.sqrt (V*restrictionLog m D)+Real.sqrt (q*B)
  dsimp only [A] at hbound
  linarith only [hfirst,hbound,hsqrt,hVbound]


/-- Squared form of the actual finite random-restriction estimate. It also
includes zero row bound, so it can be averaged over a second independent
restriction without a positivity exception. -/
theorem finite_selected_square_envelope_mean (a : Fin m → Fin D → ℝ)
    (p : U → Fin D → ℝ) (u₀ : U) (hroot : p u₀=0)
    (choose : α → Bool) (V B : ℝ) (hm : 0 < m) (hV : 0 ≤ V) (hB : 0 ≤ B)
    (ha : ∀ i, (∑ j, a i j^2) ≤ V)
    (hp : ∀ u, (∑ j, p u j^2) ≤ 1)
    (hrow : ∀ u, (∑ i, linearEvaluation (a i) (p u)^2) ≤ B) :
    finiteMean (fun s : Fin m → α => empiricalSquareEnvelope (selectedRows a choose s) p) ≤
      2*(536870913:ℝ)^2*V*restrictionLog m D+
        2*(finiteMean (fun x : α => if choose x then (1:ℝ) else 0))*B := by
  let q := finiteMean (fun x : α => if choose x then (1:ℝ) else 0)
  have hq : 0 ≤ q := finiteMean_nonneg (fun x => by split_ifs <;> norm_num)
  by_cases hVp : 0 < V
  · have hh := finite_selected_square_envelope a p u₀ hroot choose V B hm hVp hB ha hp hrow
    let T := finiteMean (fun s : Fin m → α => empiricalSquareEnvelope (selectedRows a choose s) p)
    have hT : 0 ≤ T := finiteMean_nonneg (fun s => empiricalSquareEnvelope_nonneg _ _)
    have hVL : 0 ≤ V*restrictionLog m D := mul_nonneg hV
      ((show (0:ℝ) ≤ 1 by norm_num).trans (restrictionLog_ge_one hm))
    have hqB : 0 ≤ q*B := mul_nonneg hq hB
    change Real.sqrt T ≤ 536870913*Real.sqrt (V*restrictionLog m D)+Real.sqrt (q*B) at hh
    change T ≤ _
    calc
      T = Real.sqrt T^2 := (Real.sq_sqrt hT).symm
      _ ≤ (536870913*Real.sqrt (V*restrictionLog m D)+Real.sqrt (q*B))^2 :=
        (sq_le_sq₀ (Real.sqrt_nonneg _) (by positivity)).mpr hh
      _ ≤ 2*(536870913*Real.sqrt (V*restrictionLog m D))^2+2*Real.sqrt (q*B)^2 := by
        nlinarith only [sq_nonneg (536870913*Real.sqrt (V*restrictionLog m D)-Real.sqrt (q*B))]
      _ = _ := by rw [mul_pow, Real.sq_sqrt hVL, Real.sq_sqrt hqB]; dsimp only [q]; ring
  · have hVz : V=0 := le_antisymm (le_of_not_gt hVp) hV
    have haz (i : Fin m) (j : Fin D) : a i j=0 := by
      have hs := Finset.single_le_sum (s := Finset.univ)
        (fun k _ => sq_nonneg (a i k)) (Finset.mem_univ j)
      have hi := ha i
      rw [hVz] at hi
      nlinarith only [hs,hi,sq_nonneg (a i j)]
    have hsz (s : Fin m → α) : empiricalSquareEnvelope (selectedRows a choose s) p=0 := by
      simp [empiricalSquareEnvelope,selectedRows,haz,linearEvaluation,envelope]
    simp only [hsz,finiteMean_const,hVz,mul_zero,zero_mul,zero_add]
    change 0 ≤ 2*q*B
    positivity

end NeuralGeneralization.SquaredSampling
