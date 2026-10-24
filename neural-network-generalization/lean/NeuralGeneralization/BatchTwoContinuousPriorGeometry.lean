import NeuralGeneralization.BatchTwoContinuousCloning
import NeuralGeneralization.BatchTwoParameterPriorRate

/-! Uniform regression tubes, explicit teacher energy, and genuine small-prior
concentration. Compactness is used for openness of the full-domain tube. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel BatchTwoParameterPriorRate

def teacherEnergyBound (d C r : ℕ) (B : ℝ) : ℝ :=
  ((d : ℝ)*(d+1)+(r+1)*(C : ℝ)^2)*B^2

theorem bounded_teacher_energy {d C r : ℕ} (hC : 0 < C) {B : ℝ} (hB : 0 ≤ B)
    (w : Weights d C r) (hw : boundedWeights B w) :
    weightedSquaredNorm w ≤ teacherEnergyBound d C r B := by
  have hCR : 0 < (C : ℝ) := by exact_mod_cast hC
  have hs (i : WeightIndex d C r) : w i^2 ≤ B^2 := by
    simpa only [sq_abs] using (sq_le_sq₀ (abs_nonneg (w i)) hB).mpr (hw i)
  have hf : (∑ i : Fin C, ∑ j : Fin (d+1), w (Sum.inl (i,j))^2) ≤ (C : ℝ)*(d+1)*B^2 := by
    calc
      _ ≤ ∑ _i : Fin C, ∑ _j : Fin (d+1), B^2 := Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => hs _
      _ = _ := by simp; ring
  have hi : (∑ s : Fin r, ∑ i : Fin C, ∑ j : Fin C, w (Sum.inr (Sum.inl (s,i,j)))^2) ≤ (r : ℝ)*C^2*B^2 := by
    calc
      _ ≤ ∑ _s : Fin r, ∑ _i : Fin C, ∑ _j : Fin C, B^2 :=
        Finset.sum_le_sum fun s _ => Finset.sum_le_sum fun i _ => Finset.sum_le_sum fun j _ => hs _
      _ = _ := by simp; ring
  have ho : (∑ i : Fin C, w (Sum.inr (Sum.inr i))^2) ≤ (C : ℝ)*B^2 := by
    calc
      _ ≤ ∑ _i : Fin C, B^2 := Finset.sum_le_sum fun i _ => hs _
      _ = _ := by simp
  have hf' := mul_le_mul_of_nonneg_left hf (show 0 ≤ (d : ℝ)/C by positivity)
  have ho' := mul_le_mul_of_nonneg_left ho hCR.le
  have hcancel : (d : ℝ)/C*((C : ℝ)*(d+1)*B^2)=(d : ℝ)*(d+1)*B^2 := by field_simp
  rw [hcancel] at hf'
  unfold weightedSquaredNorm teacherEnergyBound
  push_cast
  nlinarith

def uniformTube {d N r : ℕ} (φ : ℝ → ℝ) (f : RealInput d → ℝ)
    (X : Set (RealInput d)) (ρ : ℝ) : Set (Weights d N r) :=
  {w | ∀ x ∈ X, |output φ w x-f x| < ρ}

theorem isOpen_uniformTube {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ)
    {f : RealInput d → ℝ} (hf : Continuous f) (X : Set (RealInput d)) (hX : IsCompact X) (ρ : ℝ) :
    IsOpen (uniformTube (N := N) (r := r) φ f X ρ) := by
  apply isOpen_iff_mem_nhds.mpr
  intro w hw
  apply hX.eventually_forall_of_forall_eventually
  intro x hx
  have hopen : IsOpen {p : Weights d N r × RealInput d | |output φ p.1 p.2-f p.2| < ρ} :=
    isOpen_lt (((continuous_output_joint hφ).sub (hf.comp continuous_snd)).abs) continuous_const
  exact hopen.mem_nhds (hw x hx)

theorem uniformTube_subset_training {d N r n : ℕ} (φ : ℝ → ℝ) (f : RealInput d → ℝ)
    (X : Set (RealInput d)) (ρ : ℝ) (sample : Fin n → RealInput d) (hs : ∀ i, sample i ∈ X) :
    uniformTube (N := N) (r := r) φ f X ρ ⊆ trainingEvent φ f ρ sample := fun _ hw i => hw _ (hs i)

theorem teacher_tube_energy {d C N r : ℕ} (hC : 0 < C) (hCN : C ≤ N)
    (φ : ℝ → ℝ) (w : Weights d C r) {B ρ : ℝ} (hB : 0 ≤ B) (hw : boundedWeights B w)
    (X : Set (RealInput d)) (hρ : 0 < ρ) :
    (uniformTube (N := N) (r := r) φ (output φ w) X ρ).Nonempty ∧
      eventEnergy (uniformTube (N := N) (r := r) φ (output φ w) X ρ) ≤ teacherEnergyBound d C r B := by
  obtain ⟨v,hv,henergy⟩ := exists_real_clone_at_every_width hC hCN φ w
  have hmem : v ∈ uniformTube φ (output φ w) X ρ := by
    intro x _
    simpa only [hv x,sub_self,abs_zero] using hρ
  refine ⟨⟨v,hmem⟩,?_⟩
  have h := bounded_teacher_energy hC hB w hw
  have hE := eventEnergy_le hmem
  linarith

theorem nonGaussian_tube_eventually_pos (ν : BatchTwoNonGaussian.CoordinateLaw)
    {d C N r : ℕ} (hd : 0 < d) (hC : 0 < C) (hCN : C ≤ N)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (w : Weights d C r) {B ρ : ℝ}
    (hB : 0 ≤ B) (hw : boundedWeights B w) (X : Set (RealInput d)) (hX : IsCompact X) (hρ : 0 < ρ) :
    ∀ᶠ σ in 𝓝[>] (0 : ℝ), 0 < (BatchTwoNonGaussian.smallPrior ν d N r σ).real
      (uniformTube φ (output φ w) X ρ) := by
  have hN : 0 < N := hC.trans_le hCN
  let V := uniformTube (N := N) (r := r) φ (output φ w) X ρ
  have hV := isOpen_uniformTube (N := N) (r := r) hφ (continuous_output_input hφ w) X hX ρ
  have hne := (teacher_tube_energy hC hCN φ w hB hw X hρ).1
  have hr := rescale_rate ν.upperCurvature_pos (gaussian_open_rate hd hN V hV hne)
  filter_upwards [hr.eventually_pos] with σ hσ
  exact (mul_pos (pow_pos (ν.comparisonFactor_pos _ ν.upperCurvature_pos) _) hσ).trans_le
    (nonGaussian_lower ν hd hN σ V)

theorem nonGaussian_tube_tail_ratio (ν : BatchTwoNonGaussian.CoordinateLaw)
    {d C N r : ℕ} (hd : 0 < d) (hC : 0 < C) (hCN : C ≤ N)
    {φ : ℝ → ℝ} (hφ : Continuous φ) (w : Weights d C r) {B ρ K : ℝ}
    (hB : 0 ≤ B) (hw : boundedWeights B w) (X : Set (RealInput d)) (hX : IsCompact X)
    (hρ : 0 < ρ) (hK : ν.upperCurvature*teacherEnergyBound d C r B < ν.lowerCurvature*K/2) :
    Tendsto (fun σ => (BatchTwoNonGaussian.smallPrior ν d N r σ).real {v | K < weightedSquaredNorm v}/
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real (uniformTube φ (output φ w) X ρ))
      (𝓝[>] (0 : ℝ)) (𝓝 0) := by
  have hN : 0 < N := hC.trans_le hCN
  let U : Set (Weights d N r) := {v | K < weightedSquaredNorm v}
  let V := uniformTube (N := N) (r := r) φ (output φ w) X ρ
  by_cases hUne : U.Nonempty
  · have hU : IsOpen U := by
      apply isOpen_lt continuous_const
      unfold weightedSquaredNorm
      fun_prop
    obtain ⟨hVne,hVE⟩ := teacher_tube_energy hC hCN φ w hB hw X hρ
    apply nonGaussian_open_ratio ν hd hN U V hU hUne
      (isOpen_uniformTube hφ (continuous_output_input hφ w) X hX ρ) hVne
    have hu := eventEnergy_ge hUne (fun v hv => le_of_lt hv)
    have hmV := mul_le_mul_of_nonneg_left hVE ν.upperCurvature_pos.le
    have hmU := mul_le_mul_of_nonneg_left hu ν.lowerCurvature_pos.le
    nlinarith
  · have hempty : U=∅ := Set.not_nonempty_iff_eq_empty.mp hUne
    have heq : (fun σ => (BatchTwoNonGaussian.smallPrior ν d N r σ).real U/
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real V)=(fun _ : ℝ => 0) := by simp [hempty]
    change Tendsto (fun σ => (BatchTwoNonGaussian.smallPrior ν d N r σ).real U/
      (BatchTwoNonGaussian.smallPrior ν d N r σ).real V) _ _
    rw [heq]
    exact tendsto_const_nhds

end NeuralGeneralization.BatchTwoContinuous
