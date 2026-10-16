import NeuralGeneralization.ParityNetworkGrid

/-! An actual bounded-weight, one-hidden-layer tanh parity network. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.ParityNetwork
open ConcreteModel

def falseCount {d : ℕ} (x : Cube d) : ℕ := (Finset.univ.filter (fun i => x i = false)).card

theorem falseCount_le {d : ℕ} (x : Cube d) : falseCount x ≤ d := by
  simpa [falseCount] using Finset.card_filter_le (s := (Finset.univ : Finset (Fin d)))
    (p := fun i => x i = false)

theorem sum_labelReal {d : ℕ} (x : Cube d) :
    (∑ i, labelReal (x i)) = (d:ℝ)-2*falseCount x := by
  have heq (i : Fin d) : labelReal (x i) = 1-2*(if x i = false then (1:ℝ) else 0) := by
    cases h : x i <;> norm_num [labelReal]
  simp_rw [heq]
  rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp [falseCount]

theorem parity_falseCount {d : ℕ} (x : Cube d) :
    labelReal (parity d x) = (-1:ℝ)^falseCount x := by
  rw [labelReal_parity]
  have heq (i : Fin d) : cubeCoordinateSign (x i) = if x i = false then (-1:ℝ) else 1 := by
    cases h : x i <;> simp [cubeCoordinateSign]
  simp only [fullParity, heq]
  rw [Finset.prod_ite]
  simp [falseCount]

theorem tanh_one_gt_half : (1/2:ℝ) < Real.tanh 1 := by
  rw [TanhSaturation.tanh_exp_formula]
  have he := Real.add_one_lt_exp (show (2:ℝ) ≠ 0 by norm_num)
  have hd : 0 < Real.exp (2*(1:ℝ))+1 := by positivity
  have hq : 2/(Real.exp (2*(1:ℝ))+1) < (1/2:ℝ) := by
    apply (div_lt_iff₀ hd).2
    norm_num at *
    linarith
  linarith

def gridWeights (y : ℕ → ℝ) (d : ℕ) : Weights d (d+1) 0
  | Sum.inl (i,j) => Fin.cases (Fin.cases 1 (fun _ => 0) j)
      (fun i => Fin.cases (gridSlope d*((d:ℝ)/2-i-1/2))
        (fun _ => -(gridSlope d)/2) j) i
  | Sum.inr (Sum.inl (s, _, _)) => Fin.elim0 s
  | Sum.inr (Sum.inr i) => Fin.cases ((y 0+y d)/2/Real.tanh 1)
      (fun i => (y (i.val+1)-y i.val)/2) i

theorem firstHidden_grid_zero (y : ℕ → ℝ) (d : ℕ) (x : Cube d) :
    firstHidden Real.tanh (gridWeights y d) x 0 = Real.tanh 1 := by
  simp [firstHidden, gridWeights, Fin.sum_univ_succ, inputVector]

theorem firstHidden_grid_succ (y : ℕ → ℝ) (d : ℕ) (x : Cube d) (i : Fin d) :
    firstHidden Real.tanh (gridWeights y d) x i.succ =
      Real.tanh (gridSlope d*((falseCount x:ℝ)-i-1/2)) := by
  unfold firstHidden
  congr 1
  simp only [Fin.sum_univ_succ, gridWeights, Fin.cases_succ, Fin.cases_zero,
    inputVector, mul_one]
  rw [← Finset.mul_sum, sum_labelReal]
  ring

theorem networkOutput_grid (y : ℕ → ℝ) (d : ℕ) (x : Cube d) :
    networkOutput Real.tanh (gridWeights y d) x = gridInterpolant y d (falseCount x) := by
  have ht : Real.tanh 1 ≠ 0 := by linarith [tanh_one_gt_half]
  simp only [networkOutput, finalHidden, List.finRange_zero, List.foldl_nil]
  rw [Fin.sum_univ_succ]
  simp only [gridWeights, Fin.cases_zero, Fin.cases_succ,
    firstHidden_grid_zero, firstHidden_grid_succ, div_mul_cancel₀ _ ht]
  change (y 0+y d)/2 + (∑ i : Fin d,
    (y (i.val+1)-y i.val)/2 * Real.tanh (gridSlope d*((falseCount x:ℝ)-(i.val:ℝ)-1/2))) = _
  rw [Fin.sum_univ_eq_sum_range (fun j : ℕ => (y (j+1)-y j)/2 *
    Real.tanh (gridSlope d*((falseCount x:ℝ)-(j:ℝ)-1/2))) d]
  rfl

theorem gridWeights_bounded (y : ℕ → ℝ) (hy : ∀ j, |y j| ≤ 1) (d : ℕ) :
    boundedWeights (16*((d:ℝ)+1)^2) (gridWeights y d) := by
  have hd : (0:ℝ) ≤ d := Nat.cast_nonneg d
  have hb : (2:ℝ) ≤ 16*((d:ℝ)+1)^2 := by nlinarith
  have hc : |(y 0+y d)/2| ≤ 1 := by
    rw [abs_div, abs_of_pos (by norm_num : (0:ℝ)<2)]
    exact (div_le_one (by norm_num)).2 ((abs_add_le _ _).trans (by linarith [hy 0, hy d]))
  have hβ (i : ℕ) : |(y (i+1)-y i)/2| ≤ 1 := by
    rw [abs_div, abs_of_pos (by norm_num : (0:ℝ)<2)]
    exact (div_le_one (by norm_num)).2 ((abs_sub _ _).trans (by linarith [hy (i+1), hy i]))
  intro a
  rcases a with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · refine Fin.cases ?_ (fun i => ?_) i
    · refine Fin.cases ?_ (fun j => ?_) j <;> simp [gridWeights] <;> linarith
    · have hi : (i:ℝ) < d := by exact_mod_cast i.isLt
      refine Fin.cases ?_ (fun j => ?_) j
      · simp only [gridWeights, Fin.cases_succ, Fin.cases_zero, abs_mul]
        have hs : |gridSlope d| = 16*((d:ℝ)+1) := by
          simp [gridSlope, abs_of_nonneg (show (0:ℝ) ≤ 16*((d:ℝ)+1) by positivity)]
        rw [hs]
        have hinner : |(d:ℝ)/2-i-1/2| ≤ (d:ℝ)+1 := by
          apply abs_le.mpr
          constructor <;> linarith [show (0:ℝ) ≤ i from Nat.cast_nonneg i.val]
        calc
          _ ≤ 16*((d:ℝ)+1)*((d:ℝ)+1) := mul_le_mul_of_nonneg_left hinner (by positivity)
          _ = _ := by ring
      · simp [gridWeights, gridSlope, abs_div, abs_mul, abs_of_nonneg (show (0:ℝ) ≤ d+1 by positivity)]
        nlinarith
  · exact Fin.elim0 s
  · refine Fin.cases ?_ (fun i => ?_) i
    · simp only [gridWeights, Fin.cases_zero, abs_div]
      have ht : 0 < Real.tanh 1 := by linarith [tanh_one_gt_half]
      rw [abs_of_pos ht]
      have hdiv : |(y 0+y d)/2|/Real.tanh 1 ≤ 2 := by
        apply (div_le_iff₀ ht).2
        linarith [tanh_one_gt_half]
      simpa only [abs_div] using hdiv.trans hb
    · exact (hβ i.val).trans (by linarith)

def parityWidth (d : ℕ) : ℕ := 16*(d+1)^2

theorem parityWidth_ge (d : ℕ) : d+1 ≤ parityWidth d := by
  unfold parityWidth
  nlinarith

theorem grid_parity_margin (d : ℕ) (x : Cube d) :
    (7/8:ℝ) < labelReal (parity d x)*
      networkOutput Real.tanh (gridWeights (fun j => (-1)^j) d) x := by
  have he := gridInterpolant_error (fun j => (-1:ℝ)^j)
    (fun j => by simp) (falseCount_le x)
  rw [← networkOutput_grid, ← parity_falseCount] at he
  rcases abs_lt.mp he with ⟨hlo,hhi⟩
  cases h : parity d x <;> simp only [h, labelReal_false, labelReal_true] at * <;> linarith

theorem exists_padded_bounded {d C N r : ℕ} {B : ℝ} (hB : 0 ≤ B)
    (hCN : C ≤ N) (φ : ℝ → ℝ) (w : Weights d C r) (hw : boundedWeights B w) :
    ∃ v : Weights d N r, boundedWeights B v ∧
      ∀ x, networkOutput φ v x = networkOutput φ w x := by
  let e : ((Fin C × Fin 1) ⊕ Fin (N-C)) ≃ Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum, Fintype.card_prod, Fintype.card_fin, mul_one]
    omega)
  refine ⟨clonedWeights e w, ?_, networkOutput_cloned (by decide) φ e w⟩
  intro a
  rcases a with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · cases hi : e.symm i with
    | inl ab => simpa [clonedWeights, hi] using hw (Sum.inl (ab.1,j))
    | inr p => simpa [clonedWeights, hi] using hB
  · cases hi : e.symm i with
    | inl ab =>
      cases hj : e.symm j with
      | inl cd => simpa [clonedWeights, hi, hj] using hw (Sum.inr (Sum.inl (s,ab.1,cd.1)))
      | inr p => simpa [clonedWeights, hi, hj] using hB
    | inr p => simpa [clonedWeights, hi] using hB
  · cases hi : e.symm i with
    | inl ab => simpa [clonedWeights, hi] using hw (Sum.inr (Sum.inr ab.1))
    | inr p => simpa [clonedWeights, hi] using hB

/-- Full parity has bounded-weight complexity at most a quadratic in dimension. -/
theorem parity_realizes_shallow (d : ℕ) :
    realizesAtComplexity (r := 0) Real.tanh (parity d) (parityWidth d) := by
  have hbound := gridWeights_bounded (fun j => (-1:ℝ)^j) (fun j => by simp) d
  have hcast : (parityWidth d:ℝ) = 16*((d:ℝ)+1)^2 := by simp [parityWidth]
  rw [← hcast] at hbound
  obtain ⟨v,hv,hout⟩ := exists_padded_bounded (Nat.cast_nonneg (parityWidth d))
    (parityWidth_ge d) Real.tanh _ hbound
  refine ⟨(by have := parityWidth_ge d; omega),v,?_,hv⟩
  intro x
  rw [hout]
  linarith [grid_parity_margin d x]

end NeuralGeneralization.ParityNetwork
