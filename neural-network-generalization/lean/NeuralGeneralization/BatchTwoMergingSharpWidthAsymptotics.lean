import NeuralGeneralization.BatchTwoMergingSharpGrowth

/-! The fixed-depth width dependence of the exact manuscript budgets. -/
noncomputable section
open Filter Asymptotics
namespace NeuralGeneralization.BatchTwoMerging
open WidthGrowth

theorem sharpRadius_inverse_growth (ℓ κ b:ℝ) (d r:ℕ) (hℓ:1≤ℓ) (hκ:1≤κ) (hb:0≤b):
    WidthGrowth (fun C=>1/sharpRadius ℓ κ C b d r) (r+3) 0 := by
  have hs:WidthGrowth (fun C=>Real.sqrt (κ*C)) 1 0 := (width.const_mul κ).sqrt
  have hD:WidthGrowth (fun C=>sharpInputBudget ℓ d r C) 1 0 := by
    exact ((const (ℓ*((d:ℝ)+1))).mono (by omega) (by omega)).add
      ((width.sqrt).const_mul (ℓ*((r:ℝ)+1)))
  have hA:WidthGrowth (fun C=>sharpAmplification ℓ κ C b) 1 0 := by
    exact (((const (2*ℓ)).mono (by omega) (by omega)).add (hs.const_mul (2*ℓ))).add
      ((const (ℓ*b)).mono (by omega) (by omega))
  have hden:WidthGrowth (fun C=>256*Real.sqrt (κ*C)*sharpInputBudget ℓ d r C*
      sharpAmplification ℓ κ C b^(r+1)) (r+3) 0 := by
    convert ((hs.const_mul 256).mul hD).mul (hA.pow (r+1)) using 1 <;>
      simp only [Nat.one_mul,Nat.zero_mul,Nat.add_zero] <;> omega
  apply (((const 16).mono (Nat.zero_le _) (Nat.zero_le _)).max_growth hden).congr
  intro C hC
  have hCr:(1:ℝ)≤C := by exact_mod_cast hC
  have hp:=sharpRadius_control d r hℓ hκ hCr hb
  let D:=256*Real.sqrt (κ*C)*sharpInputBudget ℓ d r C*sharpAmplification ℓ κ C b^(r+1)
  have hℓ0:0<ℓ := by linarith
  have hκ0:0<κ := by linarith
  have hC0:(0:ℝ)<C := by exact_mod_cast hC
  have hD:0<D := by dsimp [D,sharpInputBudget,sharpAmplification];positivity
  change max 16 D=1/min (1/16) (1/D)
  by_cases hh:(1:ℝ)/16≤1/D
  · rw [min_eq_left hh]
    have hd:D≤16 := by nlinarith [(le_div_iff₀ hD).mp hh]
    rw [max_eq_left hd]
    norm_num
  · have hh':(1:ℝ)/D≤1/16 := le_of_not_ge hh
    rw [min_eq_right hh']
    have hd:16≤D := by nlinarith [(div_le_iff₀ hD).mp hh']
    rw [max_eq_right hd]
    field_simp

theorem sharp_target_growth (ℓ κ b:ℝ) (d r:ℕ) (hℓ:1≤ℓ) (hκ:1≤κ) (hb:0≤b):
    WidthGrowth (fun C=>sharpCylinderCost d r (d+κ*r*C+16*κ*C) C
      (sharpRadius ℓ κ C b d r)) 1 1 := by
  have hi:=sharpRadius_inverse_growth ℓ κ b d r hℓ hκ hb
  have ha:WidthGrowth (fun C=>Real.exp 1*Real.sqrt (2*Real.pi)/(2*sharpRadius ℓ κ C b d r)) (r+3) 0 := by
    apply (hi.const_mul (Real.exp 1*Real.sqrt (2*Real.pi)/2)).congr
    intro C hC
    ring
  have harg:∀C:ℕ,1≤C→1≤Real.exp 1*Real.sqrt (2*Real.pi)/(2*sharpRadius ℓ κ C b d r) := by
    intro C hC
    have hCr:(1:ℝ)≤C := by exact_mod_cast hC
    obtain ⟨hp,hp16,_,_,_⟩:=sharpRadius_control d r hℓ hκ hCr hb
    apply (le_div_iff₀ (by positivity : 0<2*sharpRadius ℓ κ C b d r)).mpr
    have hs:1≤Real.sqrt (2*Real.pi) := by
      have hh:=Real.sq_sqrt (by positivity : 0≤2*Real.pi)
      nlinarith [Real.sqrt_nonneg (2*Real.pi),Real.pi_gt_three]
    have he:1≤Real.exp (1:ℝ) := Real.one_le_exp (by norm_num)
    nlinarith [one_le_mul_of_one_le_of_one_le he hs]
  have hlog:=ha.log harg
  have hK:WidthGrowth (fun C=>(d:ℝ)+κ*r*C+16*κ*C) 1 0 :=
    (((const (d:ℝ)).mono (by omega) (by omega)).add (width.const_mul (κ*r))).add
      (width.const_mul (16*κ))
  have hq:WidthGrowth (fun C=>(d:ℝ)+2+r*C) 1 0 :=
    ((const ((d:ℝ)+2)).mono (by omega) (by omega)).add (width.const_mul r)
  exact ((hK.mono (by omega) (by omega)).add (by simpa using hq.mul hlog)).add
    ((const (Real.log 2)).mono (by omega) (by omega))

theorem sharpReluTargetCost_growth (d r:ℕ):WidthGrowth (fun C=>sharpReluTargetCost d C r) 1 1 := by
  have h:=sharp_target_growth 1 10 (sharpBulkBound r) d r (by norm_num) (by norm_num)
    (sharpBulkBound_nonneg r)
  convert h using 1
  funext C
  unfold sharpReluTargetCost sharpReluTeacherEnergy
  congr 2
  ring

theorem sharpGeluTargetCost_growth (d r:ℕ):WidthGrowth (fun C=>sharpGeluTargetCost d C r) 1 1 := by
  have h:=sharp_target_growth 2 100 (sharpBulkBound r) d r (by norm_num) (by norm_num)
    (sharpBulkBound_nonneg r)
  convert h using 1
  funext C
  unfold sharpGeluTargetCost sharpGeluTeacherEnergy
  congr 2
  ring

theorem sharpPopulationBound_growth {T:ℕ→ℝ} (hT:WidthGrowth T 1 1) (ε:ℝ):
    WidthGrowth (fun C=>(sharpPopulationBound (T C) ε:ℝ)) 1 1 := by
  have hB:WidthGrowth (fun C=>sharpReadoutBound (T C) ε) 1 1 := by
    exact ((const 8).mono (by omega) (by omega)).max_growth
      ((hT.add ((const (Real.log (4/ε))).mono (by omega) (by omega))).const_mul 8)
  exact (((const 1).mono (by omega) (by omega)).add (hB.const_mul 16)).ceil

theorem sharpEnergyBound_growth {T:ℕ→ℝ} (hT:WidthGrowth T 1 1) (d r:ℕ) (ε:ℝ):
    WidthGrowth (fun C=>sharpEnergyBound d r (T C) ε) 1 1 := by
  have hQ:=sharpPopulationBound_growth hT ε
  have hlQ:=hQ.log (fun C _=>by exact_mod_cast sharpPopulationBound_pos (T C) ε)
  have hent:WidthGrowth (fun C=>partitionEntropyBudget d r (sharpPopulationBound (T C) ε)) 1 1 := by
    have h1:WidthGrowth (fun C=>2*((r:ℝ)+1)*Real.log (sharpPopulationBound (T C) ε)) 1 1 :=
      (hlQ.const_mul (2*((r:ℝ)+1))).mono (by omega) (by omega)
    have h2:WidthGrowth (fun C=>((d:ℝ)+2+r*(sharpPopulationBound (T C) ε:ℝ))*(Real.log 2/2)) 1 1 := by
      apply ((((const ((d:ℝ)+2)).mono (by omega) (by omega)).add (hQ.const_mul r)).const_mul (Real.log 2/2)).congr
      intro C hC
      ring
    apply (h1.add h2).congr
    intro C hC
    unfold partitionEntropyBudget
    ring
  exact ((hT.add ((const (Real.log (4/ε))).mono (by omega) (by omega))).add hent).const_mul 4

theorem sharpRadiusBound_growth {T:ℕ→ℝ} (hT:WidthGrowth T 1 1) (d r:ℕ) (ε:ℝ):
    WidthGrowth (fun C=>1+Real.sqrt (sharpEnergyBound d r (T C) ε)) 1 1 :=
  ((const 1).mono (by omega) (by omega)).add (sharpEnergyBound_growth hT d r ε).sqrt

theorem sharpEntropy_growth {T:ℕ→ℝ} (hT:WidthGrowth T 1 1) (d r:ℕ) (ε:ℝ):
    WidthGrowth (fun C=>sharpReluEntropy d r (T C) ε) 2 3 ∧
    WidthGrowth (fun C=>sharpGeluEntropy d r (T C) ε) 2 3 := by
  let Q:=fun C=>sharpPopulationBound (T C) ε
  let R:=fun C=>1+Real.sqrt (sharpEnergyBound d r (T C) ε)
  have hQ:WidthGrowth (fun C=>(Q C:ℝ)) 1 1 := sharpPopulationBound_growth hT ε
  have hR:WidthGrowth R 1 1 := sharpRadiusBound_growth hT d r ε
  have hA:WidthGrowth (fun C=>gridAmplification d (Q C) (R C)) 2 2 :=
    (((const ((d:ℝ)+1)).mono (by omega) (by omega)).add hQ).mul
      (hR.add ((const 1).mono (by omega) (by omega)))
  have hAg:WidthGrowth (fun C=>geluGridAmplification d (Q C) (R C)) 2 2 := by
    apply (hA.const_mul 4).congr
    intro C hC
    unfold geluGridAmplification gridAmplification
    ring
  have logBound (A:ℕ→ℝ) (hg:WidthGrowth A 2 2) (ha:∀C,1≤A C):
      WidthGrowth (fun C=>Real.log (3+4*R C/sharpGridMesh r (A C))) 0 1 := by
    have hh:WidthGrowth (fun C=>3+4*R C/sharpGridMesh r (A C)) (1+2*(r+2)) (1+2*(r+2)) := by
      apply (((const 3).mono (by omega) (by omega)).add
        ((hR.const_mul (4*32*((r:ℝ)+2))).mul (hg.pow (r+2)))).congr
      intro C hC
      unfold sharpGridMesh
      simp only [div_div_eq_mul_div,div_one]
      ring
    apply hh.log
    intro C hC
    have hr:1≤R C := by dsimp [R];linarith [Real.sqrt_nonneg (sharpEnergyBound d r (T C) ε)]
    have hmesh:0<sharpGridMesh r (A C) := by unfold sharpGridMesh;have hx:=ha C;positivity
    have hx:0≤4*R C/sharpGridMesh r (A C) := by positivity
    linarith
  have hl:=logBound _ hA (fun C=>(gridAmplification_bounds _ _ (by dsimp [R];linarith [Real.sqrt_nonneg (sharpEnergyBound d r (T C) ε)])).1)
  have hlg:=logBound _ hAg (fun C=>(geluGridAmplification_bounds _ _ (by dsimp [R];linarith [Real.sqrt_nonneg (sharpEnergyBound d r (T C) ε)])).1)
  have hP:WidthGrowth (fun C=>(Q C:ℝ)*(d+2)+r*(Q C:ℝ)^2) 2 2 := by
    have hh:WidthGrowth (fun C=>(Q C:ℝ)*(d+2)) 2 2 := by
      apply ((hQ.const_mul ((d:ℝ)+2)).mono (by omega) (by omega)).congr
      intro C hC
      ring
    exact hh.add ((hQ.pow 2).const_mul r)
  constructor
  · exact hP.mul hl
  · exact (hP.add ((hQ.const_mul ((r:ℝ)+1)).mono (by omega) (by omega))).mul hlg

/-- At fixed d,r,ε,δ the literal ReLU sufficient sample budget is quadratic
in circuit width, with exactly three logarithmic factors. -/
theorem manuscript_relu_sample_bound_isBigO (d r:ℕ) (ε δ:ℝ):
    (fun C=>2/ε*(sharpReluEntropy d r (sharpReluTargetCost d C r) ε+Real.log (1/δ)))
      =O[atTop] (fun C=>(C:ℝ)^2*Real.log ((C:ℝ)+2)^3) := by
  have h:WidthGrowth (fun C=>sharpReluEntropy d r (sharpReluTargetCost d C r) ε) 2 3 :=
    (sharpEntropy_growth (sharpReluTargetCost_growth d r) d r ε).1
  exact ((h.add ((const (Real.log (1/δ))).mono (by omega) (by omega))).const_mul (2/ε)).isBigO

/-- The factor-two GELU compiler preserves the same O(C² log³(C+2)) width rate. -/
theorem manuscript_gelu_sample_bound_isBigO (d r:ℕ) (ε δ:ℝ):
    (fun C=>2/ε*(sharpGeluEntropy d r (sharpGeluTargetCost d (2*C) r) ε+Real.log (1/δ)))
      =O[atTop] (fun C=>(C:ℝ)^2*Real.log ((C:ℝ)+2)^3) := by
  have h:WidthGrowth (fun C=>sharpGeluEntropy d r (sharpGeluTargetCost d C r) ε) 2 3 :=
    (sharpEntropy_growth (sharpGeluTargetCost_growth d r) d r ε).2
  have hh:=h.comp_mul (by omega : 1≤(2:ℕ))
  exact ((hh.add ((const (Real.log (1/δ))).mono (by omega) (by omega))).const_mul (2/ε)).isBigO

end NeuralGeneralization.BatchTwoMerging
