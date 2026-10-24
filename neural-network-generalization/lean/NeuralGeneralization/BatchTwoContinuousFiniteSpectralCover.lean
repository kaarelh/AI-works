import NeuralGeneralization.BatchTwoContinuousCover
import NeuralGeneralization.SpectralFunctionClass
import NeuralGeneralization.SpectralWidthThreshold

/-! Uniform real-input approximation by a finite class after removing a small
operator-norm bulk. This is the actual network, at arbitrary accuracy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteSpectral
open ConcreteModel CompressionSampling

@[simp] theorem freeze_truncateInternal {d N r : ℕ} (x : RealInput d)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) :
    freezeInput x (truncateInternal w H)=truncateInternal (freezeInput x w) H := by
  funext i
  cases i with
  | inl i => rfl
  | inr i => cases i <;> rfl

theorem truncated_output_error_sq {d N r : ℕ} (hN : 0<N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ) {K a : ℝ}
    (hK : 0≤K) (hH : ∀ s, (∑ i,∑ j,H s i j^2)≤K)
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) a)
    (hread : (N : ℝ)*(∑ i,w (Sum.inr (Sum.inr i))^2)≤K) (x : RealInput d) :
    (output φ w x-output φ (truncateInternal w H) x)^2≤K*a^2*(2*K+3)^r := by
  have hh := truncated_networkOutput_error_sq hN φ hφ (freezeInput x w) H K a hK hH
    hres hread (fun _ => false)
  rw [←freeze_truncateInternal] at hh
  simpa only [output_freeze] using hh

def inverseRadius (r K R : ℕ) : ℕ := 3*R*(K*(2*K+3)^r+1)
def radius (r K R : ℕ) : ℝ := (inverseRadius r K R : ℝ)⁻¹

theorem inverseRadius_pos (r K : ℕ) {R : ℕ} (hR : 0<R) : 0 < inverseRadius r K R := by
  unfold inverseRadius
  positivity

theorem radius_pos (r K : ℕ) {R : ℕ} (hR : 0<R) : 0<radius r K R := by
  unfold radius
  exact inv_pos.mpr (by exact_mod_cast inverseRadius_pos r K hR)

theorem truncated_output_error {d N r K R : ℕ} (hN : 0<N) (hR : 0<R)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (H : Fin r → Fin N → Fin N → ℝ)
    (hH : ∀ s, (∑ i,∑ j,H s i j^2)≤(K : ℝ))
    (hres : ∀ s, matrixActionBound
      (fun i j => w (Sum.inr (Sum.inl (s,i,j)))-H s i j) (radius r K R))
    (hread : (N : ℝ)*(∑ i,w (Sum.inr (Sum.inr i))^2)≤(K : ℝ)) (x : RealInput d) :
    |output φ w x-output φ (truncateInternal w H) x|≤1/(3*(R : ℝ)) := by
  have hh := truncated_output_error_sq hN φ hφ w H (Nat.cast_nonneg K) hH hres hread x
  have hRr : (0 : ℝ)<R := by exact_mod_cast hR
  let P : ℝ := (K : ℝ)*(2*K+3)^r
  have hP : 0≤P := by dsimp[P]; positivity
  have hnum : (K : ℝ)*(radius r K R)^2*(2*K+3)^r≤(1/(3*(R : ℝ)))^2 := by
    have he : (K : ℝ)*(radius r K R)^2*(2*K+3)^r=P/(9*(R : ℝ)^2*(P+1)^2) := by
      unfold radius inverseRadius
      push_cast
      dsimp only [P]
      field_simp
      <;> ring
    rw [he]
    apply (div_le_iff₀ (by positivity : 0<9*(R : ℝ)^2*(P+1)^2)).mpr
    have he' : (1/(3*(R : ℝ)))^2*(9*(R : ℝ)^2*(P+1)^2)=(P+1)^2 := by field_simp; ring
    rw [he']
    nlinarith [sq_nonneg P]
  exact abs_le_of_sq_le_sq (hh.trans hnum) (by positivity)

abbrev Code (d r K R : ℕ) := UniformCoverCode d r ((r+2)*K) R

def codeOutput (d r K R : ℕ) (φ : ℝ → ℝ) (q : Code d r K R) : RealInput d → ℝ :=
  uniformCoverOutput d r ((r+2)*K) R φ q

def coverEvent (d N r K R : ℕ) (φ : ℝ → ℝ) (X : Set (RealInput d)) : Set (Weights d N r) :=
  {w | ∃ q : Code d r K R, ∀ x ∈ X, |output φ w x-codeOutput d r K R φ q x|≤2/(3*(R : ℝ))}

theorem isClosed_coverEvent (d N r K R : ℕ) (φ : ℝ → ℝ) (hφ : Continuous φ)
    (X : Set (RealInput d)) : IsClosed (coverEvent d N r K R φ X) := by
  classical
  have he : coverEvent d N r K R φ X=⋃ q : Code d r K R,
      ⋂ x : RealInput d, ⋂ _hx : x∈X,
      {w | |output φ w x-codeOutput d r K R φ q x|≤2/(3*(R : ℝ))} := by ext w; simp[coverEvent]
  rw[he]
  apply isClosed_iUnion_of_finite
  intro q
  apply isClosed_iInter
  intro x
  apply isClosed_iInter
  intro hx
  apply isClosed_le _ continuous_const
  exact ((continuous_output_weights hφ x).sub continuous_const).abs

theorem goodSpectralWeights_subset_coverEvent {d N r K R : ℕ}
    (hd : 1≤d) (hN : 0<N) (hK : 1≤K) (hR : 1≤R)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hball : ∀ x∈X, ∑ j,x j^2≤1)
    {a : ℝ} (ha : a≤radius r K R) :
    goodSpectralWeightsAtRadius d N r K a⊆coverEvent d N r K R φ X := by
  rintro w ⟨hfirst,hread,hmat⟩
  choose H hH hres using hmat
  let H' : Fin r → Fin N → Fin N → ℝ := fun s i j => H s (i,j)
  have hH' : ∀ s, (∑ i,∑ j,H' s i j^2)≤(K : ℝ) := by
    intro s
    simpa only [H',LowRankGrid.squaredSum,Fintype.sum_prod_type] using hH s
  have hv : weightedSquaredNorm (truncateInternal w H')≤(((r+2)*K : ℕ) : ℝ) := by
    simpa only [Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat] using
      truncateInternal_cost_le w H' K hfirst hread hH'
  obtain ⟨q,hq⟩ := exists_uniform_cover hd hN (show 1≤(r+2)*K by nlinarith) hR φ hφ
    (truncateInternal w H') hv X hX hball
  refine ⟨q,?_⟩
  intro x hx
  have he := truncated_output_error hN (by omega : 0<R) φ hφ w H' hH'
    (fun s y => matrix_residual_action_bound _ (H s) _ (radius_pos r K (by omega)).le
      ((hres s).trans ha) y) hread x
  have ht := abs_sub_le (output φ w x) (output φ (truncateInternal w H') x)
    (codeOutput d r K R φ q x)
  have hc := hq x hx
  change |output φ (truncateInternal w H') x-codeOutput d r K R φ q x|≤_ at hc
  have hid : 1/(3*(R : ℝ))+1/(3*(R : ℝ))=2/(3*(R : ℝ)) := by ring
  linarith

theorem matrixTruncationScale_le_radius {N : ℕ} (hN : 0<N)
    (γ : ℝ) (hγ : 1<γ) (r K R m : ℕ) (hR : 0<R)
    (hm : 2≤(m : ℝ)*((γ-1)/2)) (hwidth : (inverseRadius r K R)^m≤N) :
    matrixTruncationScale N γ≤radius r K R := by
  exact NeuralGeneralization.matrixTruncationScale_le_inverse hN γ _ hγ
    (by exact_mod_cast inverseRadius_pos r K hR) m hm (by exact_mod_cast hwidth)

end NeuralGeneralization.BatchTwoContinuous.FiniteSpectral
