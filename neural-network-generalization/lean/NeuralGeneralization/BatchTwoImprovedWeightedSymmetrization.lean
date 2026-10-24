import NeuralGeneralization.BatchTwoImprovedWeightedExpectation

/-! # Exact symmetrization for arbitrary finite sampling laws -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoImprovedWeightedSampling
open SquaredSampling
variable {α U : Type*} [Fintype α] [Fintype U] [Nonempty U]

theorem ghost_symmetrization (w : α → ℝ) (hw : ∀ x, 0 ≤ w x)
    (hm : ∑ x, w x = 1) (X : α → U → ℝ) :
    mean w (fun x => envelope (fun u => X x u-mean w (fun y => X y u))) ≤
      mean w (fun x => mean w (fun y => envelope (fun u => X x u-X y u))) := by
  apply mean_mono w hw
  intro x
  apply envelope_le
  intro u
  have he : X x u-mean w (fun y => X y u) = mean w (fun y => X x u-X y u) := by
    rw [mean_sub, mean_const w hm]
  rw [he]
  exact (abs_mean_le w hw _).trans (mean_mono w hw
    (fun y => le_envelope_finite (fun v => X x v-X y v) u))

theorem mean_sampleTotal (w : α → ℝ) (hm : ∑ x, w x = 1)
    (n : ℕ) (F : U → α → ℝ) (u : U) :
    mean (iidWeight w n) (fun s => sampleTotal F s u) = n*mean w (F u) := by
  unfold sampleTotal
  rw [mean_sum]
  simp_rw [mean_iidWeight_eval w hm]
  simp

theorem weighted_rademacher_symmetrization (w : α → ℝ)
    (hw : ∀ x, 0 ≤ w x) (hm : ∑ x, w x = 1)
    (n : ℕ) (F : U → α → ℝ) :
    mean (iidWeight w n) (fun s =>
      envelope (fun u => sampleTotal F s u-n*mean w (F u))) ≤
      2*mean (iidWeight w n) (fun s =>
        finiteMean (fun ε : Fin n → Bool => envelope (signedTotal F ε s))) := by
  let v := iidWeight w n
  have hv : ∀ s, 0 ≤ v s := iidWeight_nonneg w hw n
  have hvm : ∑ s, v s = 1 := iidWeight_mass w hm n
  have hghost := ghost_symmetrization v hv hvm (sampleTotal (n := n) F)
  have hsigned (ε : Fin n → Bool) :
      mean v (fun s => mean v (fun t =>
        envelope (fun u => sampleTotal F s u-sampleTotal F t u))) ≤
      2*mean v (fun s => envelope (signedTotal F ε s)) := by
    rw [← mean_prod v v (fun p : (Fin n → α) × (Fin n → α) =>
      envelope (fun u => sampleTotal F p.1 u-sampleTotal F p.2 u))]
    rw [← mean_equiv (fun p : (Fin n → α) × (Fin n → α) => v p.1*v p.2)
      (signSwap ε) (iidWeight_signSwap w n ε)
      (fun p => envelope (fun u => sampleTotal F p.1 u-sampleTotal F p.2 u))]
    simp_rw [sampleTotal_signSwap]
    have hsub (p : (Fin n → α) × (Fin n → α)) :
        envelope (fun u => signedTotal F ε p.1 u-signedTotal F ε p.2 u) ≤
          envelope (signedTotal F ε p.1)+envelope (signedTotal F ε p.2) := by
      obtain ⟨a, ha⟩ := Finite.exists_max (fun u => |signedTotal F ε p.1 u|)
      obtain ⟨b, hb⟩ := Finite.exists_max (fun u => |signedTotal F ε p.2 u|)
      exact envelope_sub_le _ _ ha hb
    apply (mean_mono (fun p => v p.1*v p.2) (fun p => mul_nonneg (hv _) (hv _)) hsub).trans_eq
    rw [mean_add, mean_prod, mean_prod]
    simp_rw [mean_const v hvm]
    ring
  have havg := finiteMean_mono hsigned
  rw [finiteMean_const, finiteMean_mul, ← mean_finiteMean_comm] at havg
  have h := hghost.trans havg
  simpa only [v, mean_sampleTotal w hm] using h

end NeuralGeneralization.BatchTwoImprovedWeightedSampling
