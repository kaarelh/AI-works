import NeuralGeneralization.MonotoneCoefficientDensity
import NeuralGeneralization.ArcsineExponentialCusp
import NeuralGeneralization.IteratedArcsineSpectrum
import NeuralGeneralization.GammaRatioBounds

/-! Sharp coefficients of every actual finite arcsine iterate, proved by
positive Hankel matrices and an elementary real two-scale density argument. -/
noncomputable section
namespace NeuralGeneralization
open IteratedArcsineSeries

lemma arcsineDepthExponent_bounds (k : ℕ) :
    0 < (1/(2 : ℝ)^(k+1)) ∧ (1/(2 : ℝ)^(k+1)) < 1 := by
  constructor
  · positivity
  · apply (div_lt_one (by positivity : (0 : ℝ) < 2^(k+1))).mpr
    exact one_lt_pow₀ (by norm_num : (1 : ℝ) < 2) (by omega)

/-- Sharp odd-power coefficients at every positive depth, uniformly in
power. This proves the paper's scalar coefficient comparison directly. -/
theorem iteratedArcsine_coefficient_power_bounds (k : ℕ) :
    ∃ l U : ℝ,0 < l ∧ 0 < U ∧ ∀ n : ℕ,
      l ≤ ((2*n+1 : ℕ) : ℝ)^(1+1/(2 : ℝ)^(k+1))*coefficient (k+1) (2*n+1) ∧
      ((2*n+1 : ℕ) : ℝ)^(1+1/(2 : ℝ)^(k+1))*coefficient (k+1) (2*n+1) ≤ U := by
  let β : ℝ := 1/(2 : ℝ)^(k+1)
  let b : ℕ → ℝ := fun n => coefficient (k+1) (2*n+1)
  have hβ := arcsineDepthExponent_bounds k
  have hb : ∀ n,0 ≤ b n := fun n => coefficient_nonneg _ _
  have hs : Summable b := (IteratedArcsineSpectrum.hasSum_odd_coefficient (k+1)).summable
  obtain ⟨c,C,hc,hC,hcusp⟩ := exists_iteratedArcsine_exp_cusp (k+1)
  have hcusp' : ∀ t : ℝ,0 < t → t ≤ 1 →
      c*t^β ≤ oddSeriesDeficit b t ∧ oddSeriesDeficit b t ≤ C*t^β := by
    intro t ht ht1
    rw [show oddSeriesDeficit b t=1-iteratedArcsine (k+1) (Real.exp (-t)) from
      IteratedArcsineSpectrum.oddSeriesDeficit_eq (k+1) ht.le]
    exact hcusp t ht ht1
  obtain ⟨c',C',hc',hC',htail⟩ := oddSeries_cusp_tail_bounds hb hs hβ.1 hβ.2 hc hC hcusp'
  obtain ⟨l,U,hl,hU,hbounds⟩ := monotone_coefficient_power_bounds hb hs
    (IteratedArcsineHankel.odd_antitone k) hβ.1 hc' hC' htail
  have hb0 : 0 < b 0 := coefficient_odd_pos k 0
  let lo := min l (b 0)
  let up := max (U*(3 : ℝ)^(1+β)) (b 0)
  have hlo : 0 < lo := lt_min hl hb0
  have hup : 0 < up := lt_max_of_lt_left (by positivity)
  refine ⟨lo,up,hlo,hup,?_⟩
  intro n
  change lo ≤ ((2*n+1 : ℕ) : ℝ)^(1+β)*b n ∧
    ((2*n+1 : ℕ) : ℝ)^(1+β)*b n ≤ up
  by_cases hn : n=0
  · subst n
    norm_num only [mul_zero,zero_add,Nat.cast_one,Real.one_rpow,one_mul]
    exact ⟨min_le_right _ _,le_max_right _ _⟩
  · have hn0 : 0 < n := Nat.pos_of_ne_zero hn
    have hnR : 0 < (n : ℝ) := by exact_mod_cast hn0
    have hpow : 0 ≤ 1+β := by linarith [hβ.1]
    have hlowpow : (n : ℝ)^(1+β) ≤ ((2*n+1 : ℕ) : ℝ)^(1+β) := by
      apply Real.rpow_le_rpow hnR.le _ hpow
      exact_mod_cast (show n ≤ 2*n+1 by omega)
    have huppow : ((2*n+1 : ℕ) : ℝ)^(1+β) ≤ (3*(n : ℝ))^(1+β) := by
      apply Real.rpow_le_rpow (by positivity) _ hpow
      exact_mod_cast (show 2*n+1 ≤ 3*n by omega)
    constructor
    · exact (min_le_left _ _).trans ((hbounds n hn0).1.trans
        (mul_le_mul_of_nonneg_right hlowpow (hb n)))
    · apply le_trans _ (le_max_left _ _)
      calc
        _ ≤ (3*(n : ℝ))^(1+β)*b n := mul_le_mul_of_nonneg_right huppow (hb n)
        _ = (3 : ℝ)^(1+β)*((n : ℝ)^(1+β)*b n) := by
          rw [Real.mul_rpow (by norm_num : (0 : ℝ) ≤ 3) hnR.le]
          ring
        _ ≤ (3 : ℝ)^(1+β)*U :=
          mul_le_mul_of_nonneg_left (hbounds n hn0).2 (by positivity)
        _ = _ := by ring

/-- Uniform Gamma comparison of the actual coefficients, with no
asymptotic or complex-analytic transfer theorem as a premise. -/
theorem iteratedArcsine_coefficient_gamma_bounds (k : ℕ) :
    ∃ c C : ℝ,0 < c ∧ 0 < C ∧ ∀ n : ℕ,
      c*(Real.Gamma (((2*n+1 : ℕ) : ℝ)-1/(2 : ℝ)^(k+1))/((2*n+1).factorial : ℝ)) ≤
        coefficient (k+1) (2*n+1) ∧
      coefficient (k+1) (2*n+1) ≤
        C*(Real.Gamma (((2*n+1 : ℕ) : ℝ)-1/(2 : ℝ)^(k+1))/((2*n+1).factorial : ℝ)) := by
  let β : ℝ := 1/(2 : ℝ)^(k+1)
  have hβ := arcsineDepthExponent_bounds k
  obtain ⟨l,U,hl,hU,hbounds⟩ := iteratedArcsine_coefficient_power_bounds k
  refine ⟨l*(1-β),U,mul_pos hl (by linarith [hβ.2]),hU,?_⟩
  intro n
  let m : ℕ := 2*n+1
  have hm : 1 ≤ m := by dsimp [m]; omega
  have hp : 0 < (m : ℝ)^(1+β) := Real.rpow_pos_of_pos (by positivity : 0 < (m : ℝ)) _
  have hg := gamma_coefficient_power_bounds hm hβ.1 hβ.2
  have hb := hbounds n
  change l ≤ (m : ℝ)^(1+β)*coefficient (k+1) m ∧
    (m : ℝ)^(1+β)*coefficient (k+1) m ≤ U at hb
  constructor
  · apply (mul_le_mul_iff_right₀ hp).mp
    have hh := mul_le_mul_of_nonneg_left hg.2 (mul_nonneg hl.le (show 0 ≤ 1-β by dsimp [β]; linarith [hβ.2]))
    have he : (l*(1-β))*(1/(1-β))=l := by
      field_simp [ne_of_gt (show 0 < 1-β by dsimp [β]; linarith [hβ.2])]
    rw [he] at hh
    calc
      _ = (l*(1-β))*((m : ℝ)^(1+β)*(Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ))) := by ring
      _ ≤ l := hh
      _ ≤ _ := hb.1
  · apply (mul_le_mul_iff_right₀ hp).mp
    have hh := mul_le_mul_of_nonneg_left hg.1 hU.le
    calc
      _ ≤ U := hb.2
      _ ≤ U*((m : ℝ)^(1+β)*(Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ))) := by simpa only [mul_one] using hh
      _ = _ := by ring

end NeuralGeneralization
