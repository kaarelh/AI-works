import NeuralGeneralization.SharpNeuralTailGramScalar
import NeuralGeneralization.ActualAdaptiveSpectrum

/-! Actual sharp neural tail-Gram probability in adaptive scalar normalization. -/
noncomputable section
namespace NeuralGeneralization.AdaptiveCutoff
open scoped BigOperators
open RandomRestriction SmallSampleCutoff Filter

/-- Every spectral, concentration, coherence, and collision estimate is
instantiated for the actual arcsine spectrum. The only sample threshold
hypothesis is the explicit failed-next-cutoff binomial bound. -/
theorem actual_adaptive_gram_probability (depth : ℕ) (A : ℝ) (hA : 0≤A) :
    ∃ C : ℝ,1≤C ∧ ∀ᶠ d : ℕ in atTop,∀ r n : ℕ,
      1≤r →Odd r →131072*(r+1)≤d →
      logDimension d^2/2≤(r:ℝ) →4≤n →(n:ℝ)≤Real.exp ((d:ℝ)/128) →
      (n:ℝ)≤2*A*Real.log (8*(n:ℝ))*((d+1).choose (r+2):ℝ) →
      15/16≤ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
        (fun s => ∀ u : Fin n → ℝ,
          finiteQuadratic (fun i j=>arcsineTailCovariance d (depth+1) (r+1) (s i) (s j)) u≤
            (C*(r:ℝ)^(-(1/(2:ℝ)^(depth+1)))*
              (1+Real.sqrt ((d:ℝ)*Real.log (8*(n:ℝ)))/(r:ℝ)+Real.log (8*(n:ℝ))/(r:ℝ)))*
              (∑ i,u i^2)) := by
  obtain ⟨U,hU,hspec⟩ := actual_spectral_budget depth
  let C := max 1 (adaptiveGramConstant A U)
  refine ⟨C,le_max_left _ _,?_⟩
  filter_upwards [eventually_arcsine_tail_gram_good (depth+1) (by omega)]
    with d hgram r n hr hodd hdim hlog hn hnmax hnext
  let β : ℝ := 1/(2:ℝ)^(depth+1)
  let T : ℝ := (r:ℝ)^(-β)
  let K : ℝ := ((d+1).choose (r+2):ℝ)
  let L : ℝ := Real.log (8*(n:ℝ))
  let ell : ℝ := U*T/((r:ℝ)*K)
  let tau := walshSpectralTail (arcsineProfile d (depth+1)) (r+1)
  let s2 := ∑ S∈Finset.univ.filter (fun S : Finset (Fin d)=>r+1≤S.card),
    walshCoefficients (arcsineProfile d (depth+1)) S^2
  let G := gramConstant*(tau+Real.sqrt ((n:ℝ)*(d:ℝ)*s2)+(n:ℝ)*ell)
  have hU0 : 0≤U := by linarith
  have hr0 : (0:ℝ)<r := by exact_mod_cast (show 0<r by omega)
  have hK : 0<K := Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hT : 0≤T := Real.rpow_nonneg hr0.le _
  have hL : 0≤L := by
    dsimp [L]
    exact (show (0:ℝ)≤1 by norm_num).trans (log_eight_sample_ge_one (by omega))
  have hell : 0≤ell := by dsimp [ell]; positivity
  obtain ⟨heigen,hsecond,htrace,_⟩ := hspec d r hr hodd (by omega)
  change (∀ S : Finset (Fin d),r<S.card →walshCoefficients (arcsineProfile d (depth+1)) S≤ell) at heigen
  change s2≤U*T^2/((r:ℝ)^2*K) at hsecond
  change tau≤U*T at htrace
  have hp := hgram (r+1) n (by omega) hdim
    (hlog.trans (by exact_mod_cast Nat.le_succ r)) hn hnmax ell hell
    (fun S hS=>heigen S (by omega))
  change 15/16≤ConcreteModel.sampleProbability (ConcreteModel.uniformLaw d) n
    (fun s=>∀ u : Fin n→ℝ,
      finiteQuadratic (fun i j=>arcsineTailCovariance d (depth+1) (r+1) (s i) (s j)) u≤G*(∑i,u i^2)) at hp
  have hG := gram_bound_of_adaptive_scalars (Nat.cast_nonneg d) hL hA hU0 hT hr0 hK
    (Nat.cast_nonneg n) hnext htrace (le_refl ell) hsecond (le_refl G)
  change G≤adaptiveGramConstant A U*T*(1+Real.sqrt ((d:ℝ)*L)/(r:ℝ)+L/(r:ℝ)) at hG
  have hfactor : 0≤T*(1+Real.sqrt ((d:ℝ)*L)/(r:ℝ)+L/(r:ℝ)) := by positivity
  have hGC : G≤C*T*(1+Real.sqrt ((d:ℝ)*L)/(r:ℝ)+L/(r:ℝ)) := by
    have hh := mul_le_mul_of_nonneg_right (le_max_right (1:ℝ) (adaptiveGramConstant A U)) hfactor
    dsimp only [C]
    nlinarith only [hG,hh]
  apply hp.trans
  apply ConcreteModel.sampleProbability_mono
  intro s hs u
  apply (hs u).trans
  have hh := mul_le_mul_of_nonneg_right hGC (Finset.sum_nonneg (fun i (_ : i∈Finset.univ)=>sq_nonneg (u i)))
  exact hh

end NeuralGeneralization.AdaptiveCutoff
