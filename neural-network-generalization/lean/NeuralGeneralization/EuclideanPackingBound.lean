import Mathlib.MeasureTheory.Covering.BesicovitchVectorSpace

/-! The exact volumetric packing constant (1+2 R Lambda)^P. -/
noncomputable section
open MeasureTheory Metric Module
open scoped BigOperators NNReal ENNReal
namespace NeuralGeneralization

 theorem euclidean_packing_bound {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    [FiniteDimensional ℝ E] (s : Finset E) {R Λ : ℝ} (hR : 0≤R) (hΛ : 0<Λ)
    (hs : ∀ c∈s,‖c‖≤R) (hsep : ∀ c∈s,∀ d∈s,c≠d → 1/Λ≤‖c-d‖) :
    (s.card:ℝ)≤(1+2*R*Λ)^finrank ℝ E := by
  borelize E
  let μ : Measure E := Measure.addHaar
  let δ : ℝ := 1/(2*Λ)
  let ρ : ℝ := R+δ
  have hδ : 0<δ := by dsimp [δ]; positivity
  have hρ : 0<ρ := by dsimp [ρ]; positivity
  let A := ⋃ c∈s,ball c δ
  have hdis : Set.Pairwise (s:Set E) (fun c d => Disjoint (ball c δ) (ball d δ)) := by
    intro c hc d hd hcd
    apply ball_disjoint_ball
    rw [dist_eq_norm]
    have he : δ+δ=1/Λ := by dsimp [δ]; ring
    rw [he]
    exact hsep c hc d hd hcd
  have hsub : A⊆ball (0:E) ρ := by
    refine Set.iUnion₂_subset fun x hx => ?_
    apply ball_subset_ball'
    dsimp [ρ]
    rw [dist_zero_right]
    linarith [hs x hx]
  have hvol : (s.card:ℝ≥0∞)*ENNReal.ofReal (δ^finrank ℝ E)*μ (ball 0 1)≤
      ENNReal.ofReal (ρ^finrank ℝ E)*μ (ball 0 1) := by
    calc
      _ = μ A := by
        rw [show A=⋃ c∈s,ball c δ from rfl,measure_biUnion_finset hdis (fun c _ => measurableSet_ball)]
        simp only [μ.addHaar_ball_of_pos _ hδ,Finset.sum_const,nsmul_eq_mul,mul_assoc]
      _ ≤ μ (ball (0:E) ρ) := measure_mono hsub
      _ = _ := μ.addHaar_ball_of_pos _ hρ
  have hv := (ENNReal.mul_le_mul_iff_left (measure_ball_pos μ (0:E) zero_lt_one).ne'
    measure_ball_lt_top.ne).mp hvol
  have hr : (s.card:ℝ)*δ^finrank ℝ E≤ρ^finrank ℝ E := by
    simpa only [ENNReal.toReal_mul,ENNReal.toReal_natCast,ENNReal.toReal_ofReal (pow_nonneg hδ.le _)]
      using ENNReal.toReal_le_of_le_ofReal (pow_nonneg hρ.le _) hv
  calc
    _ ≤ ρ^finrank ℝ E/δ^finrank ℝ E := (le_div_iff₀ (pow_pos hδ _)).mpr hr
    _ = (ρ/δ)^finrank ℝ E := (div_pow _ _ _).symm
    _ = _ := by
      congr 1
      dsimp [ρ,δ]
      field_simp
      <;> ring

end NeuralGeneralization
