import NeuralGeneralization.BatchTwoActivationCutoffFeatures
import NeuralGeneralization.BatchTwoActivationJointDistance

/-! The actual cutoff/residual decomposition of one Gaussian layer.
All features below are constructed from its actual preactivation rows. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
variable {I : Type*} [Fintype I] [Nonempty I] [DecidableEq I] {N n : ℕ}

def cutoffTailWeight (a T : ℝ) (z : I → ℝ) : ℝ := 1 - (smoothCutoff a T z)^2

theorem cutoffTailWeight_bounds (a T : ℝ) (z : I → ℝ) :
    0 ≤ cutoffTailWeight a T z ∧ cutoffTailWeight a T z ≤ 1 := by
  have h := smoothCutoff_bounds a T z
  unfold cutoffTailWeight
  constructor <;> nlinarith [sq_nonneg (smoothCutoff a T z)]

theorem cutoffTailWeight_large_source {a T B S δ : ℝ} (ha : 0<a) (hT : 0<T)
    (hscale : Real.log (2*Fintype.card I) ≤ a*T) (hBT : 2*B ≤ T)
    (z u : I → ℝ) (he : ∀i, |z i-u i| ≤ B) (hu : ∀i, |u i| ≤ S*δ)
    (hw : 0 < cutoffTailWeight a T z) : T ≤ 2*S*δ := by
  have hex : ∃i, T < |z i| := by
    by_contra h
    have hz : ∀i, |z i| ≤ T := fun i => le_of_not_gt (fun hi => h ⟨i,hi⟩)
    have hh := smoothCutoff_eq_one ha hT hscale z hz
    simp [cutoffTailWeight,hh] at hw
  obtain ⟨i,hi⟩ := hex
  have ht := abs_sub_le (z i) (u i) 0
  simp only [sub_zero] at ht
  have he' := he i
  have hu' := hu i
  nlinarith

theorem empirical_cutoff_residual_covariance {φ : ℝ → ℝ} {ℓ a B S T A : ℝ}
    (hφ : zeroLipschitzActivation ℓ φ) (hℓ : 0≤ℓ) (ha : 0<a)
    (hB : 0≤B) (hS : 0≤S) (hT : 0<T) (hBT : 2*B≤T)
    (hscale : Real.log (2*Fintype.card I) ≤ a*T)
    (z u : Fin N → I → ℝ) (δ : Fin N → ℝ) (hN : 0<N)
    (hδ : ∀j, 0≤δ j) (he : ∀j i, |z j i-u j i|≤B)
    (hu : ∀j i, |u j i|≤S*δ j) (henergy : ∑j,(δ j)^2 ≤ (N:ℝ)*A) (i k : I) :
    |(∑j,φ (z j i)*φ (z j k))/(N:ℝ) -
      ((∑j,actualCutoffFeature φ a T i (z j)*actualCutoffFeature φ a T k (z j))/(N:ℝ)+
        (∑j,cutoffTailWeight a T (z j)*φ (u j i)*φ (u j k))/(N:ℝ))| ≤
      6*ℓ^2*B*S^2*A/T := by
  have hh := empirical_bulk_covariance hφ hℓ hB hS hT hBT z u δ
    (fun j => cutoffTailWeight a T (z j)) hδ
    (fun j => (cutoffTailWeight_bounds a T (z j)).1)
    (fun j => (cutoffTailWeight_bounds a T (z j)).2)
    (fun j hw => cutoffTailWeight_large_source ha hT hscale hBT (z j) (u j) (he j) (hu j) hw)
    he hu (by simpa using henergy) i k
  have hid (j : Fin N) :
      (1-cutoffTailWeight a T (z j))*φ (z j i)*φ (z j k) =
      actualCutoffFeature φ a T i (z j)*actualCutoffFeature φ a T k (z j) := by
    unfold cutoffTailWeight actualCutoffFeature
    ring
  simp_rw [hid] at hh
  rw [Finset.sum_sub_distrib,Finset.sum_add_distrib] at hh
  simp only [Fintype.card_fin] at hh
  have hNr : 0<(N:ℝ) := Nat.cast_pos.mpr hN
  have heq : |(∑j,φ (z j i)*φ (z j k))/(N:ℝ) -
      ((∑j,actualCutoffFeature φ a T i (z j)*actualCutoffFeature φ a T k (z j))/(N:ℝ)+
        (∑j,cutoffTailWeight a T (z j)*φ (u j i)*φ (u j k))/(N:ℝ))| =
      |(∑j,φ (z j i)*φ (z j k))-
        ((∑j,actualCutoffFeature φ a T i (z j)*actualCutoffFeature φ a T k (z j))+
          ∑j,cutoffTailWeight a T (z j)*φ (u j i)*φ (u j k))|/(N:ℝ) := by
    rw [←add_div,←sub_div,abs_div,abs_of_pos hNr]
  rw [heq]
  exact (div_le_iff₀ hNr).2 (by simpa only [mul_comm] using hh)

theorem gaussian_layer_cutoff_decomposition (c : I → Fin n → ℝ) (x : Fin N → Fin n → ℝ)
    {φ : ℝ → ℝ} {ℓ M a T A : ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hℓ : 0≤ℓ) (hM : 0<M) (ha : 0<a) (hT : 0<T)
    (hBT : 2*gaussianBulkThreshold I M≤T)
    (hscale : Real.log (2*Fintype.card I)≤a*T)
    (hvar : ∀i, (∑j,(c i j)^2)≤M) (hN : 0<N)
    (henergy : ∑j, ‖gaussianResidualSource c M (x j)‖^2≤(N:ℝ)*A) (i k : I) :
    let z := fun j i => linearObservation c (WithLp.toLp 2 (x j)) i
    let u := fun j i => linearObservation c (gaussianResidualSource c M (x j)) i
    |(∑j,φ (z j i)*φ (z j k))/(N:ℝ) -
      ((∑j,actualCutoffFeature φ a T i (z j)*actualCutoffFeature φ a T k (z j))/(N:ℝ)+
        (∑j,cutoffTailWeight a T (z j)*φ (u j i)*φ (u j k))/(N:ℝ))| ≤
      6*ℓ^2*gaussianBulkThreshold I M*M*A/T := by
  dsimp only
  have he (j : Fin N) (p : I) :
      |linearObservation c (WithLp.toLp 2 (x j)) p -
        linearObservation c (gaussianResidualSource c M (x j)) p|≤gaussianBulkThreshold I M := by
    rw [gaussianBulkSource_add_residual c M (x j) p,add_sub_cancel_right]
    exact gaussianBulkSource_bound c M (x j) p
  have hh := empirical_cutoff_residual_covariance hφ hℓ ha (Real.sqrt_nonneg _)
    (Real.sqrt_nonneg M) hT hBT hscale
    (fun j i => linearObservation c (WithLp.toLp 2 (x j)) i)
    (fun j i => linearObservation c (gaussianResidualSource c M (x j)) i)
    (fun j => ‖gaussianResidualSource c M (x j)‖) hN (fun j => norm_nonneg _) he
    (fun j p => linearObservation_abs_le c hM.le hvar _ p) henergy i k
  simpa only [Real.sq_sqrt hM.le,gaussianBulkThreshold] using hh

end NeuralGeneralization.BatchTwoActivation
