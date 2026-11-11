import NeuralGeneralization.BatchTwoImprovedNoisyPolynomial

/-! The general-activation finite pre-stability compression theorem, with the
paper's real radius, entropy, and failure parameters. The paper is unchanged. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 700000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoImprovedInduction
open ConcreteModel BatchTwoImprovedResources

def paperCompressionInput (d L : ℕ) (K radius failure : ℝ) : RobustCompressionInput :=
  ⟨d, L, ⌈K⌉₊, ⌈2/radius⌉₊, ⌈1/failure⌉₊⟩

abbrev PaperCompressionCode (d L : ℕ) (K radius failure : ℝ) :=
  let p := paperCompressionInput d L K radius failure
  RobustOutputCode d (widthBound p) (L-2) (weightBound p) (8*(p.inverseRadius+1))

def paperCompressionOutput (d L : ℕ) (K radius failure : ℝ) (φ : ℝ → ℝ)
    (q : PaperCompressionCode d L K radius failure) : Cube d → ℝ :=
  let p := paperCompressionInput d L K radius failure
  robustGridOutput d (widthBound p) (L-2) (weightBound p) (8*(p.inverseRadius+1)) φ q

/-- Every code is an actual bounded-weight network of the prescribed depth. -/
theorem paper_compression_output_realization (d L : ℕ) (K ρ α : ℝ) (φ : ℝ → ℝ)
    (q : PaperCompressionCode d L K ρ α) :
    ∃ w : Weights d (widthBound (paperCompressionInput d L K ρ α)) (L-2),
      boundedWeights (weightBound (paperCompressionInput d L K ρ α)) w ∧
      networkOutput φ w = paperCompressionOutput d L K ρ α φ q := by
  exact ⟨robustGridWeights q, robustGridWeights_bounded (weightBound_pos _)
    (by omega : 0 < 8*((paperCompressionInput d L K ρ α).inverseRadius+1)) q, rfl⟩

theorem paper_compression_radius {ρ : ℝ} (hρ : 0 < ρ) :
    1/((⌈2/ρ⌉₊:ℝ)+1) ≤ ρ/2 := by
  have hd : 0 < (⌈2/ρ⌉₊:ℝ)+1 := by positivity
  apply (div_le_iff₀ hd).mpr
  have hc := Nat.le_ceil (2/ρ)
  have hh := (div_le_iff₀ hρ).mp hc
  nlinarith

theorem paper_compression_failure {α : ℝ} (hα : 0 < α) :
    1/((⌈1/α⌉₊:ℝ)+1) ≤ α := by
  apply (div_le_iff₀ (by positivity : 0 < (⌈1/α⌉₊:ℝ)+1)).mpr
  have hh := (div_le_iff₀ hα).mp (Nat.le_ceil (1/α))
  nlinarith

theorem paper_compression_size (d L : ℕ) {K ρ α : ℝ}
    (hK : 0 ≤ K) (hρ : 0 < ρ) (hα : 0 < α) :
    ((paperCompressionInput d L K ρ α).size:ℝ)+1 ≤
      3*(2+(d:ℝ)+L+K+ρ⁻¹+α⁻¹) := by
  have hk := Nat.ceil_lt_add_one hK
  have hr := Nat.ceil_lt_add_one (by positivity : 0 ≤ 2/ρ)
  have ha := Nat.ceil_lt_add_one (by positivity : 0 ≤ 1/α)
  simp only [paperCompressionInput, RobustCompressionInput.size,
    Nat.cast_add, Nat.cast_one]
  simp only [div_eq_mul_inv, one_mul] at hr ha ⊢
  linarith [Nat.cast_nonneg d (α := ℝ), Nat.cast_nonneg L (α := ℝ),
    inv_pos.mpr hρ, inv_pos.mpr hα]

/-- Universal polynomial entropy, in the real-valued parameters of the paper. -/
theorem paper_compression_entropy_polynomial :
    ∃ A : ℝ, 0 < A ∧ ∀ d L : ℕ, ∀ K ρ α : ℝ, 0 ≤ K → 0 < ρ → 0 < α →
      Real.log (Fintype.card (PaperCompressionCode d L K ρ α):ℝ) ≤
        A*(2+(d:ℝ)+L+K+ρ⁻¹+α⁻¹)^45 := by
  obtain ⟨A, hA, hbound⟩ := noisy_grid_entropy_polynomial
  refine ⟨A*3^45, by positivity, ?_⟩
  intro d L K ρ α hK hρ hα
  apply (hbound (paperCompressionInput d L K ρ α)).trans
  calc
    _ ≤ A*(3*(2+(d:ℝ)+L+K+ρ⁻¹+α⁻¹))^45 :=
      mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity)
        (paper_compression_size d L hK hρ hα) 45) hA.le
    _ = _ := by rw [mul_pow, mul_assoc]

/-- The literal pre-stability compression conclusion. There is one finite
network-output class before N, t, Q, or x is chosen. The law on that class is
common to all inputs. The coupling, including its actual disturbance, may
depend on x. No robustness premise and no tanh restriction is present. -/
theorem paper_finite_compression_before_stability (d L : ℕ)
    (hd : 1 ≤ d) (_hL : 2 ≤ L) (K ρ α : ℝ)
    (hK : 1 ≤ K) (hρ : 0 < ρ) (hα : 0 < α)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (N : ℕ) (hN : 0 < N) (t : ℝ) (ht : 0 < t) (ht1 : t ≤ 1)
    (Q : Measure (Weights d N (L-2))) [IsProbabilityMeasure Q]
    (hQ : klDiv Q (smallPrior d N (L-2) (t/Real.sqrt (N:ℝ))) ≤
      ENNReal.ofReal (N*K/t^2)) :
    ∃ Γ : Measure (PaperCompressionCode d L K ρ α), IsProbabilityMeasure Γ ∧
      ∀ x : Cube d, ∃ π : NoisyGridCoupling Q Γ,
        1-α ≤ π.joint.real {z | Real.sqrt (noiseBudgetSq z.2.2) < ρ/2 ∧
          |paperCompressionOutput d L K ρ α φ z.2.1 x -
            noisyNetworkOutput φ z.1 x z.2.2| ≤ ρ/8} := by
  let p := paperCompressionInput d L K ρ α
  have hpK : 1 ≤ p.energy := Nat.ceil_pos.mpr (by linarith : 0 < K)
  have hKN : K ≤ (p.energy:ℝ) := Nat.le_ceil K
  have hKL : klDiv Q (smallPrior d N (L-2) (t/Real.sqrt (N:ℝ))) ≤
      ENNReal.ofReal ((p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2) := by
    apply hQ.trans (ENNReal.ofReal_le_ofReal ?_)
    have he : (p.energy:ℝ)/(t/Real.sqrt (N:ℝ))^2 = N*p.energy/t^2 := by
      rw [div_pow, Real.sq_sqrt (Nat.cast_nonneg N)]
      field_simp
    rw [he]
    gcongr
  obtain ⟨Γ, hΓ, hcouple⟩ := all_width_noisy_compression p hd hpK hN φ hφ ht ht1 Q hKL
  refine ⟨Γ, hΓ, ?_⟩
  intro x
  obtain ⟨π, hπ⟩ := hcouple x
  refine ⟨π, ?_⟩
  let radius := 1/((p.inverseRadius:ℝ)+1)
  let err := 1/(8*((p.inverseRadius:ℝ)+1))
  have hr0 : 0 < radius := by dsimp [radius]; positivity
  have hr : radius ≤ ρ/2 := paper_compression_radius hρ
  have he : err ≤ ρ/8 := by
    have heq : err = radius/8 := by dsimp [err, radius]; field_simp
    rw [heq]
    linarith
  have hb : π.joint.real (noisyGridFailure φ (paperCompressionOutput d L K ρ α φ)
      x (ρ/2) (ρ/8)) ≤ α := by
    apply le_trans (b := π.joint.real (noisyGridFailure φ
      (paperCompressionOutput d L K ρ α φ) x radius err)) _
      (hπ.trans (paper_compression_failure hα))
    apply measureReal_mono _ (measure_ne_top _ _)
    intro z hz
    rcases hz with hn | ho
    · exact Or.inl ((sq_le_sq₀ hr0.le (by positivity)).mpr hr |>.trans hn)
    · exact Or.inr (he.trans_lt ho)
  have hs := measurable_noisyGridFailure (N := N) (r := L-2) φ
    (admissibleActivation_continuous hφ) (paperCompressionOutput d L K ρ α φ)
    (fun _ => measurable_of_countable _) x (ρ/2) (ρ/8)
  have hc := measureReal_compl (μ := π.joint) hs
  have hset : (noisyGridFailure φ (paperCompressionOutput d L K ρ α φ) x (ρ/2) (ρ/8))ᶜ =
      {z : NoisyGridState d N (L-2) (PaperCompressionCode d L K ρ α) |
        Real.sqrt (noiseBudgetSq z.2.2) < ρ/2 ∧
        |paperCompressionOutput d L K ρ α φ z.2.1 x - noisyNetworkOutput φ z.1 x z.2.2| ≤ ρ/8} := by
    ext z
    simp only [noisyGridFailure, Set.mem_compl_iff, Set.mem_setOf_eq, not_or, not_le, not_lt]
    rw [Real.sqrt_lt (noiseBudgetSq_nonneg _) (by positivity : 0 ≤ ρ/2)]
  rw [hset, probReal_univ] at hc
  linarith

end NeuralGeneralization.BatchTwoImprovedInduction
