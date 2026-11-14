import NeuralGeneralization.OnlineLowerFamilyStability
import NeuralGeneralization.OnlineLowerReluRaySaturation

/-! # Literal equality classification in the unequal-rail atom theorem

A balanced ray includes its zero endpoint and every coordinate sign choice.
The theorem below identifies equality for the actual affine ReLU Fourier
mass, rather than assuming a geometric equality certificate.
-/

set_option maxHeartbeats 800000

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu
open OnlineLower OnlineLowerGeometry

/-- The union of zero-bias signed balanced rays on the full physical rail code. -/
def IsFullBalancedRay {p : ℕ} (size : Fin p → Bool → ℕ)
    (bias : ℝ) (u : Fin (railDimension size) → ℝ) : Prop :=
  bias = 0 ∧ ∃ (τ : Finset (Fin p)) (c : ℝ), 0 ≤ c ∧
    ∀ i, |u i| = if i ∈ fullRailSupport size τ then c else 0

/-- Full sharp equality classification, including the zero ray. This uses
exactly the rail-size assumptions of the proved quantitative atom theorem. -/
theorem full_rail_norm_eq_iff_balanced {p : ℕ} (hp : 2 ≤ p)
    (size : Fin p → Bool → ℕ) (htwo : ∀ i side, 2 ≤ size i side)
    (heven : ∀ i side, Even (size i side))
    (R Δ U : ℝ) (hΔ : 0 ≤ Δ) (hR : 6 * Δ ≤ R)
    (hRpos : 0 < R) (hU : 2 ≤ U) (hUR : U ≤ 2 * R)
    (hmin : ∀ i side, R ≤ (size i side : ℝ))
    (hmax : ∀ i side, (size i side : ℝ) ≤ U)
    (hdiff : ∀ i, |(size i true : ℝ) - size i false| ≤ Δ)
    (u : Fin (railDimension size) → ℝ) (bias : ℝ) :
    retainedFourierMass (fullRailSupport size) (fullRailCost size)
        (fun x => max (cubeAffine bias u x) 0) =
      Real.sqrt (bias ^ 2 + ∑ i, u i ^ 2) ↔ IsFullBalancedRay size bias u := by
  classical
  constructor
  · intro heq
    obtain ⟨τ,c,v,hc,hv,hd⟩ := full_rail_stability_of_size hp size htwo heven
      R Δ U hΔ hR hRpos hU hUR hmin hmax hdiff u bias
    rw [heq, sub_self, mul_zero] at hd
    have hsum : 0 ≤ ∑ i, (u i-v i)^2 := Finset.sum_nonneg fun _ _ => sq_nonneg _
    have hb : bias = 0 := by nlinarith [sq_nonneg bias]
    have huv : u = v := by
      funext i
      have hi : (u i-v i)^2 ≤ ∑ j, (u j-v j)^2 :=
        Finset.single_le_sum (fun j _ => sq_nonneg (u j-v j)) (Finset.mem_univ i)
      nlinarith [sq_nonneg (u i-v i),sq_nonneg bias]
    exact ⟨hb,τ,c,hc,by simpa only [huv] using hv⟩
  · rintro ⟨rfl,τ,c,hc,hu⟩
    apply le_antisymm (full_rail_norm_of_size hp size htwo heven R Δ hΔ hR hmin hdiff u 0)
    have hs := even_support_ray_saturation (fullRailSupport size τ)
      (fullRailSupport_two_le (by omega) size htwo τ)
      (fullRailSupport_even size heven τ) u c hc hu
    have hsingle : fullRailCost size τ *
        |walshCoefficients (fun x => max (cubeAffine 0 u x) 0) (fullRailSupport size τ)| ≤
      retainedFourierMass (fullRailSupport size) (fullRailCost size)
        (fun x => max (cubeAffine 0 u x) 0) :=
      Finset.single_le_sum
        (f := fun s : Finset (Fin p) => fullRailCost size s *
          |walshCoefficients (fun x => max (cubeAffine 0 u x) 0) (fullRailSupport size s)|)
        (fun s _ => mul_nonneg (fullRailCost_nonneg size s) (abs_nonneg _))
        (Finset.mem_univ τ)
    simpa only [fullRailCost, hs, zero_pow (by decide : 2 ≠ 0), zero_add] using hsingle

end NeuralGeneralization.OnlineLowerRelu
