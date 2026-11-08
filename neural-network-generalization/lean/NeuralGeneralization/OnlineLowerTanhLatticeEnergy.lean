import NeuralGeneralization.OnlineLowerTanhOptimizerLattice
import Mathlib.Analysis.InnerProductSpace.PiL2

/-! # The actual normalized incoming energy of a localized lattice sequence -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma sqrt_sum_sq_lipschitz {n : ℕ} (u v : Fin n → ℝ) :
    |Real.sqrt (∑ i,(u i)^2)-Real.sqrt (∑ i,(v i)^2)| ≤
      Real.sqrt (∑ i,(u i-v i)^2) := by
  have h := abs_norm_sub_norm_le (WithLp.toLp 2 u : EuclideanSpace ℝ (Fin n)) (WithLp.toLp 2 v)
  simpa [EuclideanSpace.norm_eq,Real.norm_eq_abs,sq_abs] using h

lemma sqrt_empiricalSecondMoment {n : ℕ} (q : Fin n → ℕ) :
    Real.sqrt (empiricalSecondMoment q)=
      Real.sqrt (∑ i,(q i:ℝ)^2)/Real.sqrt (n:ℝ) := by
  have he : empiricalSecondMoment q=(∑ i,(q i:ℝ)^2)/(n:ℝ) := by
    unfold empiricalSecondMoment
    ring
  rw [he,Real.sqrt_div (Finset.sum_nonneg (fun _ _ => sq_nonneg _))]

lemma lattice_normalized_root_difference {n : ℕ} (hn : 0 < n)
    (u : Fin n → ℝ) (q : Fin n → ℕ) (a K : ℝ) (ha : 0 ≤ a)
    (hres : (∑ i,(|u i|-a*(q i:ℝ))^2) ≤ K) :
    |Real.sqrt (incomingEnergy u)/Real.sqrt (n:ℝ)-a*Real.sqrt (empiricalSecondMoment q)|
      ≤ Real.sqrt K/Real.sqrt (n:ℝ) := by
  have hraw := sqrt_sum_sq_lipschitz (fun i => |u i|) (fun i => a*(q i:ℝ))
  have hleft : (∑ i,|u i|^2)=incomingEnergy u := by simp [incomingEnergy,sq_abs]
  have hright : (∑ i,(a*(q i:ℝ))^2)=a^2*(∑ i,(q i:ℝ)^2) := by
    simp_rw [mul_pow]
    rw [Finset.mul_sum]
  rw [hleft,hright,Real.sqrt_mul (sq_nonneg a),Real.sqrt_sq ha] at hraw
  have hle := hraw.trans (Real.sqrt_le_sqrt hres)
  have hdiv := div_le_div_of_nonneg_right hle (Real.sqrt_nonneg (n:ℝ))
  rw [sqrt_empiricalSecondMoment]
  calc
    _ = |(Real.sqrt (incomingEnergy u)-a*Real.sqrt (∑ i,(q i:ℝ)^2))/Real.sqrt (n:ℝ)| := by
      congr 1
      ring
    _ = |Real.sqrt (incomingEnergy u)-a*Real.sqrt (∑ i,(q i:ℝ)^2)|/Real.sqrt (n:ℝ) := by
      rw [abs_div,abs_of_nonneg (Real.sqrt_nonneg (n:ℝ))]
    _ ≤ _ := hdiv

/-- Bounded total residual energy has no effect on the limiting normalized
incoming norm, even when the lattice labels are unbounded. -/
theorem normalized_lattice_root_tendsto
    (N : ℕ → ℕ) (hpos : ∀ k, 0 < N k) (hN : Tendsto N atTop atTop)
    (u : ∀ k, Fin (N k) → ℝ) (q : ∀ k, Fin (N k) → ℕ)
    (a : ℕ → ℝ) (a₀ Q K : ℝ) (ha : ∀ k, 0 ≤ a k)
    (hres : ∀ k, (∑ i,(|u k i|-a k*(q k i:ℝ))^2) ≤ K)
    (ha₀ : Tendsto a atTop (𝓝 a₀))
    (hQ : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 Q)) :
    Tendsto (fun k => Real.sqrt (incomingEnergy (u k))/Real.sqrt (N k:ℝ))
      atTop (𝓝 (a₀*Real.sqrt Q)) := by
  have ht : Tendsto (fun k => Real.sqrt K/Real.sqrt (N k:ℝ)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (Real.tendsto_sqrt_atTop.comp (tendsto_natCast_atTop_atTop.comp hN))
  have hd : Tendsto (fun k => Real.sqrt (incomingEnergy (u k))/Real.sqrt (N k:ℝ)-
      a k*Real.sqrt (empiricalSecondMoment (q k))) atTop (𝓝 0) := by
    apply squeeze_zero_norm' _ ht
    exact Eventually.of_forall (fun k => by
      simpa only [Real.norm_eq_abs] using lattice_normalized_root_difference (hpos k) (u k) (q k) (a k) K (ha k) (hres k))
  have hm := ha₀.mul (Real.continuous_sqrt.continuousAt.tendsto.comp hQ)
  have hh := hd.add hm
  simpa only [Function.comp_apply,sub_add_cancel,zero_add] using hh

/-- Consequently the full incoming energy retains exactly the limiting
empirical second moment, including any moment that escaped the pointwise law. -/
theorem normalized_lattice_energy_tendsto
    (N : ℕ → ℕ) (hpos : ∀ k, 0 < N k) (hN : Tendsto N atTop atTop)
    (u : ∀ k, Fin (N k) → ℝ) (q : ∀ k, Fin (N k) → ℕ)
    (a : ℕ → ℝ) (a₀ Q K : ℝ) (ha : ∀ k, 0 ≤ a k)
    (hres : ∀ k, (∑ i,(|u k i|-a k*(q k i:ℝ))^2) ≤ K)
    (ha₀ : Tendsto a atTop (𝓝 a₀))
    (hQ : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 Q)) :
    Tendsto (fun k => incomingEnergy (u k)/(N k:ℝ)) atTop (𝓝 (a₀^2*Q)) := by
  have hQ0 : 0 ≤ Q := ge_of_tendsto hQ (Eventually.of_forall (fun k => empiricalSecondMoment_nonneg (q k)))
  have hh := (normalized_lattice_root_tendsto N hpos hN u q a a₀ Q K ha hres ha₀ hQ).pow 2
  simpa only [div_pow,mul_pow,Real.sq_sqrt (incomingEnergy_nonneg _),
    Real.sq_sqrt (Nat.cast_nonneg _),Real.sq_sqrt hQ0] using hh

end NeuralGeneralization.OnlineLowerTanh
