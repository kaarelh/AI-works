import NeuralGeneralization.OnlineLowerTanhLatticeEnergy

/-! # From empirical moment equality to full RMS concentration -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter Set
namespace NeuralGeneralization.OnlineLowerTanh

def empiricalLatticeVariance {n : ℕ} (q : Fin n → ℕ) (g : ℕ) : ℝ :=
  (n:ℝ)⁻¹*∑ i,((q i:ℝ)-g)^2

lemma empiricalLatticeVariance_nonneg {n : ℕ} (q : Fin n → ℕ) (g : ℕ) :
    0 ≤ empiricalLatticeVariance q g := by unfold empiricalLatticeVariance; positivity

lemma empiricalLatticeVariance_le {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ) (g : ℕ) :
    empiricalLatticeVariance q g ≤
      2*empiricalSecondMoment q+2*(g:ℝ)^2-4*(g:ℝ)^2*empiricalMass q g := by
  have hpoint (i : Fin n) : ((q i:ℝ)-g)^2 ≤
      2*(q i:ℝ)^2+2*(g:ℝ)^2-4*(g:ℝ)^2*(if q i=g then 1 else 0) := by
    by_cases hi : q i=g
    · simp [hi]
      ring_nf
      exact le_rfl
    · simp only [if_neg hi,mul_zero,sub_zero]
      nlinarith [sq_nonneg ((q i:ℝ)+(g:ℝ))]
  have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ => hpoint i)
  have hh := mul_le_mul_of_nonneg_left hs (show 0 ≤ (n:ℝ)⁻¹ by positivity)
  simp only [Finset.sum_sub_distrib,Finset.sum_add_distrib,←Finset.mul_sum,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] at hh
  unfold empiricalLatticeVariance empiricalSecondMoment empiricalMass
  have hnR : (n:ℝ)≠0 := by exact_mod_cast hn.ne'
  exact hh.trans_eq (by field_simp [hnR])

lemma empiricalLatticeVariance_tendsto
    (N : ℕ → ℕ) (hN : ∀ k,0 < N k) (q : ∀ k,Fin (N k) → ℕ) (g : ℕ)
    (hmoment : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 ((g:ℝ)^2)))
    (hmass : Tendsto (fun k => empiricalMass (q k) g) atTop (𝓝 1)) :
    Tendsto (fun k => empiricalLatticeVariance (q k) g) atTop (𝓝 0) := by
  have h := ((hmoment.const_mul 2).add_const (2*(g:ℝ)^2)).sub
    (hmass.const_mul (4*(g:ℝ)^2))
  have hzero : 2*(g:ℝ)^2+2*(g:ℝ)^2-4*(g:ℝ)^2*1=0 := by ring
  rw [hzero] at h
  exact squeeze_zero (fun k => empiricalLatticeVariance_nonneg _ _)
    (fun k => empiricalLatticeVariance_le (hN k) (q k) g) h

lemma incoming_lattice_variance_le {n : ℕ} (u : Fin n → ℝ) (q : Fin n → ℕ)
    (a K : ℝ) (g : ℕ) (hres : (∑ i,(|u i|-a*(q i:ℝ))^2) ≤ K) :
    (n:ℝ)⁻¹*(∑ i,(|u i|-a*g)^2) ≤ 2*K/(n:ℝ)+2*a^2*empiricalLatticeVariance q g := by
  have hpoint (i : Fin n) : (|u i|-a*g)^2 ≤
      2*(|u i|-a*(q i:ℝ))^2+2*a^2*((q i:ℝ)-g)^2 := by
    nlinarith [sq_nonneg ((|u i|-a*(q i:ℝ))-a*((q i:ℝ)-g))]
  have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ => hpoint i)
  rw [Finset.sum_add_distrib,←Finset.mul_sum,←Finset.mul_sum] at hs
  have hh := mul_le_mul_of_nonneg_left hs (show 0 ≤ (n:ℝ)⁻¹ by positivity)
  have hK := mul_le_mul_of_nonneg_left hres (show 0 ≤ 2*(n:ℝ)⁻¹ by positivity)
  unfold empiricalLatticeVariance
  rw [div_eq_mul_inv]
  nlinarith only [hh,hK]

lemma incoming_lattice_variance_tendsto
    (N : ℕ → ℕ) (hpos : ∀ k,0 < N k) (hN : Tendsto N atTop atTop)
    (u : ∀ k,Fin (N k) → ℝ) (q : ∀ k,Fin (N k) → ℕ)
    (a : ℕ → ℝ) (a₀ K : ℝ) (g : ℕ)
    (ha : Tendsto a atTop (𝓝 a₀))
    (hres : ∀ k,(∑ i,(|u k i|-a k*(q k i:ℝ))^2) ≤ K)
    (hmoment : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 ((g:ℝ)^2)))
    (hmass : Tendsto (fun k => empiricalMass (q k) g) atTop (𝓝 1)) :
    Tendsto (fun k => (N k:ℝ)⁻¹*(∑ i,(|u k i|-a k*g)^2)) atTop (𝓝 0) := by
  have hv := empiricalLatticeVariance_tendsto N hpos q g hmoment hmass
  have hfirst : Tendsto (fun k => 2*K/(N k:ℝ)) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop (tendsto_natCast_atTop_atTop.comp hN)
  have hsecond := ((ha.pow 2).const_mul 2).mul hv
  simp only [mul_zero] at hsecond
  exact squeeze_zero (fun k => by positivity)
    (fun k => incoming_lattice_variance_le (u k) (q k) (a k) K g (hres k))
    (by simpa only [zero_add] using hfirst.add hsecond)

lemma incoming_common_variance_tendsto
    (N : ℕ → ℕ) (hpos : ∀ k,0 < N k) (hN : Tendsto N atTop atTop)
    (u : ∀ k,Fin (N k) → ℝ) (q : ∀ k,Fin (N k) → ℕ)
    (a : ℕ → ℝ) (a₀ K : ℝ) (g : ℕ)
    (ha : Tendsto a atTop (𝓝 a₀))
    (hres : ∀ k,(∑ i,(|u k i|-a k*(q k i:ℝ))^2) ≤ K)
    (hmoment : Tendsto (fun k => empiricalSecondMoment (q k)) atTop (𝓝 ((g:ℝ)^2)))
    (hmass : Tendsto (fun k => empiricalMass (q k) g) atTop (𝓝 1)) :
    Tendsto (fun k => (N k:ℝ)⁻¹*(∑ i,(|u k i|-a₀*g)^2)) atTop (𝓝 0) := by
  have hv := incoming_lattice_variance_tendsto N hpos hN u q a a₀ K g ha hres hmoment hmass
  have haDiff := ((ha.sub_const a₀).mul_const (g:ℝ)).pow 2
  simp only [sub_self,zero_mul,zero_pow (by norm_num : 2≠0)] at haDiff
  have hup := (hv.const_mul 2).add (haDiff.const_mul 2)
  simp only [mul_zero,zero_add] at hup
  apply squeeze_zero (fun k => by positivity) _ hup
  intro k
  have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
    (show (|u k i|-a₀*g)^2 ≤ 2*(|u k i|-a k*g)^2+2*((a k-a₀)*g)^2 by
      nlinarith [sq_nonneg ((|u k i|-a k*g)-(a k-a₀)*g)]))
  simp only [Finset.sum_add_distrib,←Finset.mul_sum,Finset.sum_const,Finset.card_univ,
    Fintype.card_fin,nsmul_eq_mul] at hs
  have hh := mul_le_mul_of_nonneg_left hs (show 0 ≤ (N k:ℝ)⁻¹ by positivity)
  have hnR : (N k:ℝ)≠0 := by exact_mod_cast (hpos k).ne'
  exact hh.trans_eq (by field_simp [hnR])

end NeuralGeneralization.OnlineLowerTanh
