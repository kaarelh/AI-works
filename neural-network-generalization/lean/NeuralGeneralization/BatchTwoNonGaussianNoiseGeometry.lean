import NeuralGeneralization.BatchTwoNonGaussianNoiseCylinder
import NeuralGeneralization.BatchTwoNonGaussianScaleComparison

/-! The actual scaled non-Gaussian noise cylinder preserves the target's
classification margin at every input after translation by a cloned teacher. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1600000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel NetworkLayerSplit

theorem noiseCylinder_iff {C k p N : ℕ} (d : ℕ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) :
    ∀ r (w : Weights d N r), w ∈ noiseCylinder d e ρ b r ↔
      (∀ i j, |w (.inl (i,j))| ≤ ρ) ∧
      (∀ i, |w (.inr (.inr i))| ≤ ρ) ∧
      ∀ s : Fin r, (fun ij => w (.inr (.inl (s,ij.1,ij.2)))) ∈ matrixNoiseCylinder e ρ b := by
  intro r
  induction r with
  | zero =>
    intro w
    constructor
    · intro hw
      refine ⟨fun i j => abs_le.mpr (hw.1 (i,j) (Set.mem_univ _)),
        fun i => abs_le.mpr (hw.2 i (Set.mem_univ _)), fun s => Fin.elim0 s⟩
    · rintro ⟨hf,hr,_⟩
      exact ⟨fun ij _ => abs_le.mp (hf ij.1 ij.2), fun i _ => abs_le.mp (hr i)⟩
  | succ r ih =>
    intro w
    constructor
    · rintro ⟨hp,hl⟩
      obtain ⟨hf,hr,hm⟩ := (ih (previousWeights w)).mp hp
      refine ⟨hf,hr,fun s => ?_⟩
      refine Fin.lastCases ?_ (fun t => ?_) s
      · exact hl
      · exact hm t
    · rintro ⟨hf,hr,hm⟩
      refine ⟨(ih (previousWeights w)).mpr ⟨hf,hr,fun s => ?_⟩,hm (Fin.last r)⟩
      exact hm s.castSucc

theorem matrixNoiseCylinder_neg {C k p N : ℕ}
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) (z : Fin N × Fin N → ℝ) :
    -z ∈ matrixNoiseCylinder e ρ b ↔ z ∈ matrixNoiseCylinder e ρ b := by
  have hgroup : -z ∈ matrixGroupEvent e ρ ↔ z ∈ matrixGroupEvent e ρ := by
    simp [matrixGroupEvent,groupCylinder,normalizedSum,Finset.sum_neg_distrib,neg_div]
  have haction : -z ∈ matrixActionEvent N b ↔ z ∈ matrixActionEvent N b := by
    simp [matrixActionEvent,matrixActionBound,Finset.sum_neg_distrib]
  exact and_congr hgroup haction

theorem noiseCylinder_neg {C k p N : ℕ} (d : ℕ)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (ρ b : ℝ) (r : ℕ) (w : Weights d N r) :
    -w ∈ noiseCylinder d e ρ b r ↔ w ∈ noiseCylinder d e ρ b r := by
  rw [noiseCylinder_iff,noiseCylinder_iff]
  simp only [Pi.neg_apply,abs_neg]
  apply and_congr Iff.rfl
  apply and_congr Iff.rfl
  apply forall_congr'
  intro s
  exact matrixNoiseCylinder_neg e ρ b (fun ij => w (.inr (.inl (s,ij.1,ij.2))))

theorem sigma_sqrt_width_le_one {N : ℕ} {σ : ℝ} (hσ : 0 ≤ σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) : σ*Real.sqrt N ≤ 1 := by
  have hs := Real.sq_sqrt (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
  have hsq : (σ*Real.sqrt N)^2 ≤ 1 := by rw [mul_pow,hs]; nlinarith
  nlinarith [mul_nonneg hσ (Real.sqrt_nonneg (N : ℝ))]

theorem smallScale_first_le_one {d N : ℕ} (hd : 0 < d) {σ : ℝ} (hσ : 0 ≤ σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) : σ*Real.sqrt ((N : ℝ)/d) ≤ 1 := by
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hfrac : (N : ℝ)/d ≤ N := div_le_self (Nat.cast_nonneg _) hdR
  exact (mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hfrac) hσ).trans
    (sigma_sqrt_width_le_one hσ hscale)

def translatedNoise {d N r : ℕ} (v : Weights d N r) (σ : ℝ) (z : Weights d N r) : Weights d N r :=
  fun q => v q+smallScale d N r σ q*z q

theorem scaled_matrix_action {N : ℕ} {σ b : ℝ} (hσ : 0 ≤ σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) (z : Fin N × Fin N → ℝ)
    (hz : z ∈ matrixActionEvent N b) :
    matrixActionBound (fun i j => σ*z (i,j)) b := by
  intro v
  have h := mul_le_mul_of_nonneg_left (hz v) (sq_nonneg σ)
  have hs := Real.sq_sqrt (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
  have he : (∑ i, (∑ j, σ*z (i,j)*v j)^2)=σ^2*(∑ i, (∑ j, z (i,j)*v j)^2) := by
    simp_rw [mul_assoc,← Finset.mul_sum,mul_pow]
    rw [← Finset.mul_sum]
  rw [he]
  apply h.trans
  have hm := mul_le_mul_of_nonneg_right hscale
    (show 0 ≤ b^2*(∑ j, v j^2) by positivity)
  simpa only [mul_pow,hs,one_mul,mul_assoc,mul_left_comm,mul_comm] using hm

theorem noiseCylinder_output_error {d C k p N r : ℕ} (hd : 0 < d) (hN : 0 < N) (hk : 0 < k)
    (e : ((Fin C × Fin k) ⊕ Fin p) ≃ Fin N) (teacher : Weights d C r)
    {K b σ : ℝ} (hK : 0 ≤ K) (hb : 0 ≤ b) (hσ : 0 ≤ σ)
    (hscale : (N : ℝ)*σ^2 ≤ 1) (hv : weightedSquaredNorm (clonedWeights e teacher) ≤ K)
    (z : Weights d N r)
    (hz : z ∈ noiseCylinder d e (cylinderRadius d r K C (2*(b+C+1))) b r)
    (x : Cube d) :
    |networkOutput Real.tanh (translatedNoise (clonedWeights e teacher) σ z) x-
      networkOutput Real.tanh (clonedWeights e teacher) x| ≤ 1/2 := by
  let ρ := cylinderRadius d r K C (2*(b+C+1))
  have hρ : 0 < ρ := cylinderRadius_pos d r hK (Nat.cast_nonneg C)
  have hρ1 : ρ ≤ 1 := cylinderRadius_le_one d r hK (Nat.cast_nonneg C)
  obtain ⟨hfirst,hread,hmat⟩ := (noiseCylinder_iff d e ρ b r z).mp hz
  let Z := fun (s : Fin r) (i j : Fin N) => z (.inr (.inl (s,i,j)))
  let R := fun (s : Fin r) (i j : Fin N) => groupRow e σ (Z s i) j
  let E := fun (s : Fin r) (i j : Fin N) => σ*Z s i j-R s i j
  apply cylinder_networkOutput_error hN Real.tanh tanh_admissible
    (translatedNoise (clonedWeights e teacher) σ z) (clonedWeights e teacher)
    R E K C (2*(b+C+1)) hK (Nat.cast_nonneg C)
  · intro s i j
    dsimp [translatedNoise,smallScale,R,E,Z]
    ring
  · exact hv
  · intro s
    exact groupRow_matrix_energy_le hk e σ (Z s) hρ.le (hmat s).1 hscale
  · intro s
    exact groupResidual_action_bound hk e σ (Z s) hρ.le hρ1 hb (hmat s).1 hscale
      (scaled_matrix_action hσ hscale _ (hmat s).2)
  · intro i j
    change |clonedWeights e teacher (.inl (i,j))+σ*Real.sqrt ((N : ℝ)/d)*z (.inl (i,j))-
      clonedWeights e teacher (.inl (i,j))| ≤ ρ
    rw [add_sub_cancel_left,abs_mul,abs_of_nonneg (by positivity)]
    exact (mul_le_mul (smallScale_first_le_one hd hσ hscale) (hfirst i j)
      (abs_nonneg _) zero_le_one).trans_eq (one_mul _)
  · intro i
    change |clonedWeights e teacher (.inr (.inr i))+σ/Real.sqrt N*z (.inr (.inr i))-
      clonedWeights e teacher (.inr (.inr i))| ≤ ρ/N
    rw [add_sub_cancel_left,abs_mul,abs_of_nonneg (by positivity)]
    have hs : 0 < Real.sqrt (N : ℝ) := Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)
    have hs2 := Real.sq_sqrt (Nat.cast_nonneg N : (0 : ℝ) ≤ N)
    have hcoeff : σ/Real.sqrt N ≤ 1/(N : ℝ) := by
      apply (div_le_div_iff₀ hs (Nat.cast_pos.mpr hN)).mpr
      have hm := mul_le_mul_of_nonneg_right (sigma_sqrt_width_le_one hσ hscale) hs.le
      nlinarith
    exact (mul_le_mul hcoeff (hread i) (abs_nonneg _) (by positivity)).trans_eq (by ring)
  · intro y ss s i
    rw [firstHidden_cloned,hiddenFold_cloned hk]
    exact groupRow_annihilation hk e σ (Z s i) _ Real.tanh (by simp)

end NeuralGeneralization.BatchTwoNonGaussian
