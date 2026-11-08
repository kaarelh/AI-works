import NeuralGeneralization.OnlineLowerTanhCodeNearZero
import NeuralGeneralization.OnlineLowerTanhCodeKernelBound
import NeuralGeneralization.OnlineLowerCarrierRails

/-! # The positive rail product is the actual physical Fourier envelope -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLowerRelu

/-- Literal coordinates on a rail, after the physical shared carrier. -/
def carrierRailWeights {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (i : Fin p) (s : Bool) (k : Fin (size i s)) : ℝ :=
  u ((railIndex size ⟨i,s,k⟩).succ)

def physicalRailWave {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (i : Fin p) (s selected : Bool) (t : ℝ) : ℝ :=
  ∏ k,if s=selected then |Real.sin (t*carrierRailWeights size u i s k)|
    else |Real.cos (t*carrierRailWeights size u i s k)|

theorem physicalRailWave_nonneg {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (i : Fin p) (s selected : Bool) (t : ℝ) :
    0≤physicalRailWave size u i s selected t := by
  unfold physicalRailWave
  exact Finset.prod_nonneg fun _ _=>by split <;> positivity

theorem physicalRailWave_le_one {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (i : Fin p) (s selected : Bool) (t : ℝ) :
    physicalRailWave size u i s selected t≤1 := by
  unfold physicalRailWave
  apply Finset.prod_le_one
  · intro _ _; split <;> positivity
  · intro k _; split
    · exact Real.abs_sin_le_one _
    · exact Real.abs_cos_le_one _

theorem carrierTransversal_abs_trig_product {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) (θ : Fin p→Bool) (t : ℝ) :
    |trigProduct (carrierTransversal size θ) (fun j=>t*u j)| =
      |Real.sin (t*u 0)| * ∏ i,
        (physicalRailWave size u i false (θ i) t * physicalRailWave size u i true (θ i) t) := by
  classical
  unfold trigProduct
  rw [Finset.abs_prod,Fin.prod_univ_succ]
  simp only [zero_mem_carrierTransversal,if_true]
  congr 1
  have hh := (railIndex size).prod_comp (fun j:Fin (railDimension size)=>
    |if j.succ∈carrierTransversal size θ then Real.sin (t*u j.succ) else Real.cos (t*u j.succ)|)
  rw [Fintype.prod_sigma] at hh
  rw [←hh]
  apply Finset.prod_congr rfl
  intro i _
  rw [Fintype.prod_sigma,Fintype.prod_bool]
  dsimp [physicalRailWave,carrierRailWeights]
  simp only [succ_mem_carrierTransversal,Equiv.symm_apply_apply]
  simp only [apply_ite abs,Equiv.symm_apply_apply]
  have he (s : Bool) (k : Fin (size i s)) :
      ((railIndex size).symm ((railIndex size) ⟨i,s,k⟩)).2.1=s := by
    change (fun q : RailCoord size => q.2.1) ((railIndex size).symm ((railIndex size) ⟨i,s,k⟩))=s
    rw [Equiv.symm_apply_apply]
  simp only [he]
  exact mul_comm _ _

/-- Dropping a suffix of factors in [0,1] can only increase a product. -/
theorem prod_fin_trim {R n : ℕ} (hRn : R≤n) (f : Fin n→ℝ)
    (hf0 : ∀i,0≤f i) (hf1 : ∀i,f i≤1) :
    (∏ i,f i)≤∏i:Fin R,f (Fin.castLE hRn i) := by
  let e : Fin R↪Fin n := ⟨Fin.castLE hRn,Fin.castLE_injective hRn⟩
  have hh := Finset.prod_le_prod_of_subset_of_le_one
    (s:=Finset.univ.map e) (t:=Finset.univ) (Finset.subset_univ _)
    (fun i _=>hf0 i) (fun i _ _=>hf1 i)
  simpa [Finset.prod_map,e] using hh

def trimmedCarrierRailWeights {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (u : Fin (carrierDimension size)→ℝ)
    (s : Bool) (i : Fin p) (k : Fin R) : ℝ :=
  carrierRailWeights size u i s (Fin.castLE (hR i s) k)

theorem physicalRailWave_trim {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (u : Fin (carrierDimension size)→ℝ)
    (i : Fin p) (s selected : Bool) (t : ℝ) :
    physicalRailWave size u i s selected t ≤
      ∏ k : Fin R,if s=selected then |Real.sin (t*trimmedCarrierRailWeights size hR u s i k)|
        else |Real.cos (t*trimmedCarrierRailWeights size hR u s i k)| := by
  apply prod_fin_trim (hR i s)
  · intro k;split <;> positivity
  · intro k;split
    · exact Real.abs_sin_le_one _
    · exact Real.abs_cos_le_one _

theorem carrierTransversal_abs_trig_le_trimmed {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (u : Fin (carrierDimension size)→ℝ)
    (θ : Fin p→Bool) (t : ℝ) :
    |trigProduct (carrierTransversal size θ) (fun j=>t*u j)| ≤
      selectedRailTerm p R (trimmedCarrierRailWeights size hR u false)
        (trimmedCarrierRailWeights size hR u true) θ t := by
  rw [carrierTransversal_abs_trig_product]
  apply le_trans (mul_le_of_le_one_left (Finset.prod_nonneg fun i _=>
    mul_nonneg (physicalRailWave_nonneg _ _ _ _ _ _) (physicalRailWave_nonneg _ _ _ _ _ _))
    (Real.abs_sin_le_one _))
  apply Finset.prod_le_prod
  · intro i _;exact mul_nonneg (physicalRailWave_nonneg _ _ _ _ _ _) (physicalRailWave_nonneg _ _ _ _ _ _)
  · intro i _
    have hh := mul_le_mul (physicalRailWave_trim size hR u i false (θ i) t)
      (physicalRailWave_trim size hR u i true (θ i) t)
      (physicalRailWave_nonneg _ _ _ _ _ _) (Finset.prod_nonneg fun _ _=>by split <;> positivity)
    cases hθ : θ i <;> simpa only [hθ,Bool.false_eq_true,Bool.true_eq_false,if_false,if_true,
      ←Finset.prod_mul_distrib,mul_comm] using hh

theorem carrier_full_trig_sum_le_trimmed {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (u : Fin (carrierDimension size)→ℝ) (t : ℝ) :
    (∑θ:Fin p→Bool,|trigProduct (carrierTransversal size θ) (fun j=>t*u j)|) ≤
      trimmedRailProduct p R (trimmedCarrierRailWeights size hR u false)
        (trimmedCarrierRailWeights size hR u true) t := by
  rw [trimmedRailProduct_expansion]
  exact Finset.sum_le_sum fun θ _=>carrierTransversal_abs_trig_le_trimmed size hR u θ t


theorem carrier_energy_decomposition {p : ℕ} (size : Fin p→Bool→ℕ)
    (u : Fin (carrierDimension size)→ℝ) :
    incomingEnergy u = u 0^2+∑i,((∑k,carrierRailWeights size u i false k^2)+
      (∑k,carrierRailWeights size u i true k^2)) := by
  unfold incomingEnergy
  rw [Fin.sum_univ_succ]
  congr 1
  have hh := (railIndex size).sum_comp (fun j:Fin (railDimension size)=>u j.succ^2)
  rw [Fintype.sum_sigma] at hh
  rw [←hh]
  apply Finset.sum_congr rfl
  intro i _
  rw [Fintype.sum_sigma,Fintype.sum_bool]
  dsimp [carrierRailWeights]
  ring

theorem sum_fin_trim {R n : ℕ} (hRn : R≤n) (f : Fin n→ℝ)
    (hf : ∀i,0≤f i) :
    (∑i:Fin R,f (Fin.castLE hRn i)) ≤ ∑i,f i := by
  let e : Fin R↪Fin n := ⟨Fin.castLE hRn,Fin.castLE_injective hRn⟩
  have hh := Finset.sum_le_sum_of_subset_of_nonneg
    (s:=Finset.univ.map e) (t:=Finset.univ) (f:=f) (Finset.subset_univ _)
    (fun i _ _=>hf i)
  simpa [Finset.sum_map,e] using hh

theorem trimmedCarrierRailWeights_energy_le {p R : ℕ} (size : Fin p→Bool→ℕ)
    (hR : ∀i s,R≤size i s) (u : Fin (carrierDimension size)→ℝ) :
    (∑i:Fin p,∑k:Fin R,
      ((trimmedCarrierRailWeights size hR u false i k)^2+
        (trimmedCarrierRailWeights size hR u true i k)^2)) ≤ incomingEnergy u := by
  rw [carrier_energy_decomposition]
  apply le_trans ?_ (le_add_of_nonneg_left (sq_nonneg (u 0)))
  apply Finset.sum_le_sum
  intro i _
  rw [Finset.sum_add_distrib]
  exact add_le_add (sum_fin_trim (hR i false) (fun k=>carrierRailWeights size u i false k^2) (fun _=>sq_nonneg _))
    (sum_fin_trim (hR i true) (fun k=>carrierRailWeights size u i true k^2) (fun _=>sq_nonneg _))


theorem carrierTransversal_card {p : ℕ} (size : Fin p→Bool→ℕ) (θ : Fin p→Bool) :
    (carrierTransversal size θ).card=1+∑i,size i (θ i) := by
  unfold carrierTransversal
  rw [Finset.card_insert_of_notMem,Finset.card_map,Finset.card_biUnion]
  · simp only [physicalRail_card]
    omega
  · intro i hi j hj hij
    exact physicalRail_disjoint size (Or.inl hij)
  · simp [shiftPhysical]

theorem carrierTransversal_odd {p : ℕ} (size : Fin p→Bool→ℕ)
    (heven : ∀i s,Even (size i s)) (θ : Fin p→Bool) :
    Odd (carrierTransversal size θ).card := by
  rw [carrierTransversal_card]
  exact Odd.add_even odd_one (Finset.even_sum _ (fun i _=>heven i (θ i)))

end NeuralGeneralization.OnlineLowerTanh
