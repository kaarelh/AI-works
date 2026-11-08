import NeuralGeneralization.OnlineLowerTanhOptimizerLimit
import NeuralGeneralization.OnlineLowerTanhLatticeConcentration

/-! # Full RMS concentration of actual global tanh parity maximizers -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh
namespace OptimizerLatticeLimit
variable {r : ℕ → ℕ} {u : ∀ k,Fin (2*r k+1) → ℝ} (O : OptimizerLatticeLimit r u)

/-- The full incoming vector, including all coordinates outside each finite
alphabet, concentrates in normalized squared distance at the balanced gain. -/
theorem rms_concentration (hr : Tendsto r atTop atTop) (hu : ∀ k,IsIntrinsicMaximizer (u k)) :
    Tendsto (fun k => ((2*r (O.map k)+1:ℕ):ℝ)⁻¹*
      (∑ i,(|u (O.map k) i|-limitingGain)^2)) atTop (𝓝 0) := by
  obtain ⟨g,hg,hgOdd,hQ,ha,hp⟩ := O.classified hr hu
  have hm : Tendsto (fun k => empiricalSecondMoment (O.data.label (O.map k))) atTop (𝓝 ((g:ℝ)^2)) :=
    hQ ▸ O.moment_tendsto
  have hf : Tendsto (fun k => empiricalMass (O.data.label (O.map k)) g) atTop (𝓝 1) := by
    have h := O.frequency_tendsto g
    simpa [hp] using h
  have h := incoming_common_variance_tendsto (fun k => 2*r (O.map k)+1) (fun _ => by omega)
    (O.degree_tendsto hr) (fun k => u (O.map k)) (fun k => O.data.label (O.map k))
    (fun k => O.data.spacing (O.map k)) O.a₀ O.data.residualBound g O.a_tendsto
    (fun k => O.data.residual_le (O.map k)) hm hf
  rwa [ha] at h

end OptimizerLatticeLimit

lemma complement_card_fraction {n : ℕ} (hn : 0 < n) (A : Finset (Fin n)) :
    (n:ℝ)⁻¹*(Aᶜ.card:ℝ)=1-(n:ℝ)⁻¹*(A.card:ℝ) := by
  have hc : (A.card:ℝ)+(Aᶜ.card:ℝ)=n := by
    exact_mod_cast (show A.card+Aᶜ.card=n by simpa only [Fintype.card_fin] using Finset.card_add_card_compl A)
  have hnR : (n:ℝ)≠0 := by exact_mod_cast hn.ne'
  field_simp
  linarith

lemma complement_energy_bound {n : ℕ} (u : Fin n → ℝ) (A : Finset (Fin n)) (a : ℝ) :
    (∑ i ∈ Aᶜ,(u i)^2) ≤ 2*(∑ i,(|u i|-a)^2)+2*a^2*(Aᶜ.card:ℝ) := by
  have hp (i : Fin n) : (u i)^2 ≤ 2*(|u i|-a)^2+2*a^2 := by
    nlinarith [sq_abs (u i),sq_nonneg (|u i|-2*a)]
  have hs := Finset.sum_le_sum (s := Aᶜ) (fun i _ => hp i)
  simp only [Finset.sum_add_distrib,←Finset.mul_sum,Finset.sum_const,nsmul_eq_mul] at hs
  have hvar := Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ Aᶜ)
    (fun i _ _ => sq_nonneg (|u i|-a))
  nlinarith only [hs,hvar]

/-- Every subset of asymptotic full cardinality contains all but a vanishing
fraction of the actual incoming energy once full RMS concentration holds. -/
theorem complement_energy_fraction_tendsto
    (N : ℕ → ℕ) (hN : ∀ k,0 < N k) (u : ∀ k,Fin (N k) → ℝ)
    (A : ∀ k,Finset (Fin (N k))) (a : ℝ)
    (hcard : Tendsto (fun k => (N k:ℝ)⁻¹*((A k).card:ℝ)) atTop (𝓝 1))
    (hvar : Tendsto (fun k => (N k:ℝ)⁻¹*(∑ i,(|u k i|-a)^2)) atTop (𝓝 0)) :
    Tendsto (fun k => (N k:ℝ)⁻¹*(∑ i ∈ (A k)ᶜ,(u k i)^2)) atTop (𝓝 0) := by
  have hc : Tendsto (fun k => (N k:ℝ)⁻¹*((A k)ᶜ.card:ℝ)) atTop (𝓝 0) := by
    simp_rw [complement_card_fraction (hN _)]
    simpa only [sub_self] using (tendsto_const_nhds (x:=(1:ℝ))).sub hcard
  have hup := (hvar.const_mul 2).add (hc.const_mul (2*a^2))
  simp only [mul_zero,zero_add] at hup
  apply squeeze_zero (fun k => by positivity) _ hup
  intro k
  have h := mul_le_mul_of_nonneg_left (complement_energy_bound (u k) (A k) a)
    (show 0 ≤ (N k:ℝ)⁻¹ by positivity)
  nlinarith only [h]

end NeuralGeneralization.OnlineLowerTanh
