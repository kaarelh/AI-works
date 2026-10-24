import NeuralGeneralization.BatchTwoNeuralConverseDirectSum

/-! The gain restriction is preserved by the actual neuron cloning construction. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical
open ConcreteModel
variable {d C N r k p : ℕ}

def cloneRow (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (h : Fin C → ℝ) : Fin N → ℝ :=
  fun i => match e.symm i with
  | Sum.inl (a,_) => h a/(k : ℝ)
  | Sum.inr _ => 0

def averageSlopes (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (D : Slopes N r) : Slopes C r :=
  fun s a => (∑ c : Fin k, D s (e (Sum.inl (a,c))))/(k : ℝ)

theorem averageSlopes_mem (hk : 0<k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (D : Slopes N r) (hD : D ∈ slopeCube N r) : averageSlopes e D ∈ slopeCube C r := by
  have hkR : (0 : ℝ)<k := by exact_mod_cast hk
  constructor
  · intro s a
    exact div_nonneg (Finset.sum_nonneg (fun c _ => hD.1 s _)) hkR.le
  · intro s a
    apply (div_le_iff₀ hkR).mpr
    have hs := Finset.sum_le_sum (s := Finset.univ) (fun (c : Fin k) _ => hD.2 s (e (Sum.inl (a,c))))
    simpa using hs

theorem sum_clone_index (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (F : Fin C → Fin k → ℝ) :
    (∑ i, match e.symm i with | Sum.inl (a,c) => F a c | Sum.inr _ => 0) = ∑ a, ∑ c, F a c := by
  let G : ((Fin C × Fin k) ⊕ Fin p) → ℝ := fun i => match i with
    | Sum.inl (a,c) => F a c
    | Sum.inr _ => 0
  change (∑ i, G (e.symm i)) = _
  rw [e.symm.sum_comp]
  simp [G,Fintype.sum_prod_type]

theorem pathRow_cloned (hk : 0<k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (w : Weights d C r) (D : Slopes N r) (ss : List (Fin r)) :
    pathRow (clonedWeights e w) D ss = cloneRow e (pathRow w (averageSlopes e D) ss) := by
  have hkR : (k : ℝ)≠0 := by exact_mod_cast hk.ne'
  induction ss with
  | nil => funext i; cases hi : e.symm i <;> simp [pathRow,clonedWeights,cloneRow,hi]
  | cons s ss ih =>
    funext j
    simp only [pathRow,ih]
    cases hj : e.symm j with
    | inr z => simp [cloneRow,clonedWeights,hj]
    | inl ac =>
      have he : (∑ i, cloneRow e (pathRow w (averageSlopes e D) ss) i*D s i*
          clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))) =
          ∑ a, ∑ c, (pathRow w (averageSlopes e D) ss a/(k : ℝ))*
            D s (e (Sum.inl (a,c)))*(w (Sum.inr (Sum.inl (s,a,ac.1)))/(k : ℝ)) := by
        calc
          _ = ∑ i, match e.symm i with
              | Sum.inl (a,c) => (pathRow w (averageSlopes e D) ss a/(k : ℝ))*
                  D s (e (Sum.inl (a,c)))*(w (Sum.inr (Sum.inl (s,a,ac.1)))/(k : ℝ))
              | Sum.inr _ => 0 := by
            apply Finset.sum_congr rfl
            intro i _
            cases hi : e.symm i with
            | inr z => simp [cloneRow,clonedWeights,hi]
            | inl ab =>
              have hei : i=e (Sum.inl ab) := by simpa using congrArg e hi
              simp [cloneRow,clonedWeights,hi,hj,←hei]
          _ = _ := sum_clone_index e _
      rw [he]
      simp only [cloneRow,hj]
      rw [Finset.sum_div]
      apply Finset.sum_congr rfl
      intro a _
      unfold averageSlopes
      simp only [← Finset.mul_sum,← Finset.sum_mul]
      ring

theorem cloneRow_square_sum (hk : 0<k) (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N)
    (h : Fin C → ℝ) : (∑ i, (cloneRow e h i)^2) = (∑ a, (h a)^2)/(k : ℝ) := by
  have hkR : (k : ℝ)≠0 := by exact_mod_cast hk.ne'
  calc
    _ = ∑ i, match e.symm i with | Sum.inl (a,_) => (h a/(k : ℝ))^2 | Sum.inr _ => 0 := by
      apply Finset.sum_congr rfl
      intro i _
      cases hi : e.symm i <;> simp [cloneRow,hi]
    _ = (k : ℝ)*∑ a, (h a/(k : ℝ))^2 := sum_copies e _
    _ = _ := by simp_rw [div_pow,←Finset.sum_div]; field_simp

theorem gainEnergy_cloned (hC : 0<C) (hk : 0<k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) (D : Slopes N r) :
    gainEnergy (clonedWeights e w) D =
      ((N : ℝ)/((C : ℝ)*k))*gainEnergy w (averageSlopes e D) := by
  have hCR : (C : ℝ)≠0 := by exact_mod_cast hC.ne'
  have hkR : (k : ℝ)≠0 := by exact_mod_cast hk.ne'
  unfold gainEnergy
  simp_rw [pathRow_cloned hk,cloneRow_square_sum hk,←Finset.sum_div]
  field_simp

theorem gainSq_cloned_le (hC : 0<C) (hk : 0<k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    gainSq (clonedWeights e w) ≤ ((N : ℝ)/((C : ℝ)*k))*gainSq w := by
  change sSup (gainEnergy (clonedWeights e w) '' slopeCube N r) ≤ _
  apply csSup_le ((slopeCube_nonempty N r).image _)
  rintro _ ⟨D,hD,rfl⟩
  rw [gainEnergy_cloned hC hk]
  exact mul_le_mul_of_nonneg_left
    (gainEnergy_le_gainSq w _ (averageSlopes_mem hk e D hD)) (by positivity)

theorem readoutEnergy_cloned (hC : 0<C) (hk : 0<k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r) :
    readoutEnergy (clonedWeights e w) = ((N : ℝ)/((C : ℝ)*k))*readoutEnergy w := by
  have hCR : (C : ℝ)≠0 := by exact_mod_cast hC.ne'
  unfold readoutEnergy
  rw [readout_squaredSum_cloned hk]
  field_simp

theorem gain_strict_cloned (hC : 0<C) (hk : 0<k) (hN : 0<N)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r)
    (Λ : ℝ) (hw : gainSq w < Λ^2*((r : ℝ)+1)*readoutEnergy w) :
    gainSq (clonedWeights e w) < Λ^2*((r : ℝ)+1)*readoutEnergy (clonedWeights e w) := by
  have hCR : (0 : ℝ)<C := by exact_mod_cast hC
  have hkR : (0 : ℝ)<k := by exact_mod_cast hk
  have hNR : (0 : ℝ)<N := by exact_mod_cast hN
  have hm := mul_lt_mul_of_pos_left hw (div_pos hNR (mul_pos hCR hkR))
  have hg := gainSq_cloned_le hC hk e w
  rw [readoutEnergy_cloned hC hk]
  nlinarith

theorem gainSupport_cloned (hC : 0<C) (hk : 0<k) (hN : 0<N)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (w : Weights d C r)
    (Λ U : ℝ) (hw : w ∈ gainSupport Λ U) : clonedWeights e w ∈ gainSupport Λ U := by
  refine ⟨?_,gain_strict_cloned hC hk hN e w Λ hw.2⟩
  intro x
  simpa only [networkOutput_cloned hk] using hw.1 x

end
end NeuralGeneralization.BatchTwoNeuralConverse
