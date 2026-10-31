import NeuralGeneralization.AboveMeanFieldMain
import NeuralGeneralization.NormComplexityComparison

/-! Width-independent inverse mass/complexity comparison for gamma > 1.
The argument uses the actual spectral tail at large widths and the actual
whitened Gaussian norm tail at the remaining widths. -/
noncomputable section
open MeasureTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.ConcreteModel
open CompressionSampling

def massSmallEnergy (r T d B : ℕ) : ℕ := 8*(T*(d+2)+r*T^2)+4*(B+1)

theorem complexity_of_mass_below_width {d C N r T B : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hNT : N ≤ T) (γ : ℝ) (hγ : 1 ≤ γ)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (hC : isComplexity (r:=r) φ f C)
    (hmass : Real.exp (-(B:ℝ)*(N:ℝ)^γ) ≤ functionMass φ (1/2) (powerPrior d N r γ) f) :
    C ≤ compressionWidth d r (massSmallEnergy r T d B) := by
  let H := massSmallEnergy r T d B
  have hH : 1 ≤ H := by dsimp [H, massSmallEnergy]; omega
  have hv : (N:ℝ)^(-γ) ≤ 1 := by
    rw [Real.rpow_neg (Nat.cast_nonneg N)]
    exact inv_le_one_of_one_le₀ (one_le_width_power hN hγ)
  have hdim : Fintype.card (WeightIndex d N r) ≤ T*(d+2)+r*T^2 := by
    rw [weightIndex_card]
    have hsq := Nat.mul_self_le_mul_self hNT
    nlinarith
  have hbound : 8*(Fintype.card (WeightIndex d N r):ℝ)*(N:ℝ)^(-γ) ≤ (H:ℝ) := by
    have hh : 8*(Fintype.card (WeightIndex d N r):ℝ) ≤ (H:ℝ) := by
      exact_mod_cast (show 8*Fintype.card (WeightIndex d N r) ≤ H by dsimp [H,massSmallEnergy]; omega)
    exact (mul_le_of_le_one_right (by positivity) hv).trans hh
  have htail := powerPrior_whiten_subfamily_tail (by omega : 0<d) hN γ
    (fun i : WeightIndex d N r => i) Function.injective_id (H:ℝ) hbound
  have he (w : Weights d N r) : weightedSquaredNorm w = ∑ i, (whiten w i)^2 := by
    rw [←weightedSquaredNorm_unwhiten (by omega : 0<d) hN, unwhiten_whiten (by omega : 0<d) hN]
  simp only [←he] at htail
  have hstrict : Real.exp (-(H:ℝ)/(4*(N:ℝ)^(-γ))) <
      Real.exp (-(B:ℝ)*(N:ℝ)^γ) := by
    apply Real.exp_lt_exp.mpr
    rw [Real.rpow_neg (Nat.cast_nonneg N)]
    have hp : 0 < (N:ℝ)^γ := Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _
    have hHB : 4*(B:ℝ) < (H:ℝ) := by exact_mod_cast (show 4*B < H by dsimp [H,massSmallEnergy]; omega)
    have hid : -(H:ℝ)/(4*((N:ℝ)^γ)⁻¹) = -((H:ℝ)/4)*(N:ℝ)^γ := by field_simp
    rw [hid]
    exact mul_lt_mul_of_pos_right (by linarith) hp
  have hex : ∃ w : Weights d N r, w ∈ marginEvent φ (1/2) f ∧ weightedSquaredNorm w < H := by
    by_contra hh
    push Not at hh
    have hs : marginEvent (N:=N) (r:=r) φ (1/2) f ⊆ {w | (H:ℝ) ≤ weightedSquaredNorm w} := hh
    have hm := measureReal_mono hs (measure_ne_top (powerPrior d N r γ) _)
    exact not_lt_of_ge hmass (hm.trans htail |>.trans_lt hstrict)
  obtain ⟨w, hw, hnorm⟩ := hex
  obtain ⟨v, hv, hb, _⟩ := norm_compression hd hN hH φ hφ f w hnorm.le hw
  exact hC.2 _ ⟨compressionWidth_pos d r H hH, v, hv, hb⟩

def massComplexityBudget (r N₀ m d B : ℕ) : ℕ :=
  spectralCompressionWidth d r (aboveEnergyBudget r d B) +
    compressionWidth d r (massSmallEnergy r (aboveWidthThreshold r N₀ m d B) d B)

theorem massComplexityBudget_polynomialGrowth (r N₀ m : ℕ) :
    PolynomialGrowth2 (fun d B => massComplexityBudget r N₀ m d B) := by
  have hK := aboveEnergyBudget_polynomialGrowth r
  have hT := aboveWidthThreshold_polynomialGrowth r N₀ m
  have hH : PolynomialGrowth2 (fun d B => massSmallEnergy r (aboveWidthThreshold r N₀ m d B) d B) := by
    unfold massSmallEnergy
    exact ((PolynomialGrowth2.const 8).mul
      ((hT.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 2))).add
        ((PolynomialGrowth2.const r).mul (hT.pow 2)))).add
      ((PolynomialGrowth2.const 4).mul (PolynomialGrowth2.right.add (PolynomialGrowth2.const 1)))
  unfold massComplexityBudget spectralCompressionWidth
  exact ((compressionWidth_polynomialGrowth r).compositionRight
    ((PolynomialGrowth2.const (9*(r+2))).mul hK)).add
    ((compressionWidth_polynomialGrowth r).compositionRight hH)

/-- A mass lower bound alone gives a polynomial implementation bound. The
constants are chosen before the dimension, function, mass budget and width. -/
theorem complexity_of_powerPrior_mass (r : ℕ) (γ : ℝ) (hγ : 1 < γ) :
    ∃ A : ℝ, 0 < A ∧ ∃ k : ℕ, ∀ d C N B : ℕ, 1 ≤ d → 0 < N →
      ∀ φ : ℝ → ℝ, admissibleActivation φ → ∀ f : BooleanFunction d,
      isComplexity (r:=r) φ f C →
      Real.exp (-(B:ℝ)*(N:ℝ)^γ) ≤ functionMass φ (1/2) (powerPrior d N r γ) f →
      (C:ℝ) ≤ A*(1+(d:ℝ)+B)^k := by
  obtain ⟨N₀, ht⟩ := eventually_atTop.mp (eventually_spectralFunctions_complement_mass_tail γ hγ)
  obtain ⟨m, hm⟩ := exists_truncation_polynomial_degree γ hγ
  obtain ⟨A,hA,k,hpoly⟩ := (massComplexityBudget_polynomialGrowth r N₀ m).real_envelope
  refine ⟨A,hA,k,?_⟩
  intro d C N B hd hN φ hφ f hC hmass
  apply le_trans (b:= (massComplexityBudget r N₀ m d B:ℝ)) _ (hpoly d B)
  apply Nat.cast_le.mpr
  let T := aboveWidthThreshold r N₀ m d B
  let K := aboveEnergyBudget r d B
  by_cases hTN : T ≤ N
  · have hKN : (K:ℝ) ≤ (N:ℝ)^2 :=
      (aboveWidthThreshold_energy_sq r N₀ m d B).trans
        (pow_le_pow_left₀ (Nat.cast_nonneg T) (by exact_mod_cast hTN) 2)
    have htail := ht N ((aboveWidthThreshold_ge_start r N₀ m d B).trans hTN) d r K hd
      (aboveEnergyBudget_ge_first r d B) hKN
      (matrixTruncationScale_le_radius hN γ hγ r K m hm
        ((aboveWidthThreshold_ge_truncation r N₀ m d B).trans hTN)) φ hφ
    have hgap : (B:ℝ)+Real.log (4*((r:ℝ)+1)) ≤ (K:ℝ)/64 := by
      have hl := Real.log_le_sub_one_of_pos (by positivity : 0 < 4*((r:ℝ)+1))
      dsimp [K,aboveEnergyBudget]
      push_cast
      linarith [Nat.cast_nonneg (aboveTargetBudget r d B) (α:=ℝ), Nat.cast_nonneg d (α:=ℝ)]
    have hratio : (∑ g ∈ Finset.univ \ spectralFunctions d r K φ,
        functionMass φ (1/2) (powerPrior d N r γ) g) /
        functionMass φ (1/2) (powerPrior d N r γ) f ≤ 1/2 := by
      apply exponential_tail_ratio_prefactor_le _ _ (2*((r:ℝ)+1)) (B:ℝ)
        ((K:ℝ)/64) ((N:ℝ)^γ) (1/2)
        (by convert htail using 1 <;> congr 2 <;> ring) hmass
        (by nlinarith [Nat.cast_nonneg r (α:=ℝ)]) (one_le_width_power hN hγ.le) (by norm_num) (by norm_num)
      convert hgap using 1 <;> congr 2 <;> ring
    have hfmem : f ∈ spectralFunctions d r K φ := by
      classical
      by_contra hh
      have hle : functionMass φ (1/2) (powerPrior d N r γ) f ≤
          ∑ g ∈ Finset.univ \ spectralFunctions d r K φ,
            functionMass φ (1/2) (powerPrior d N r γ) g :=
        Finset.single_le_sum (fun g _ => functionMass_nonneg φ (1/2) (powerPrior d N r γ) g)
          (Finset.mem_sdiff.mpr ⟨Finset.mem_univ _,hh⟩)
      have hpos : 0 < functionMass φ (1/2) (powerPrior d N r γ) f := (Real.exp_pos _).trans_le hmass
      have hh' := (le_div_iff₀ hpos).mpr (by simpa only [one_mul] using hle : 1 * functionMass φ (1/2) (powerPrior d N r γ) f ≤ _)
      linarith
    obtain ⟨v,hv,hb⟩ := (mem_spectralFunctions φ f).mp hfmem
    have hK : 1 ≤ 9*(r+2)*K := by
      have := aboveEnergyBudget_pos r d B
      dsimp [K] at *
      nlinarith
    have hc := hC.2 _ ⟨compressionWidth_pos d r _ hK,v,hv,hb⟩
    exact hc.trans (Nat.le_add_right _ _)
  · have hc := complexity_of_mass_below_width hd hN (le_of_not_ge hTN) γ hγ.le φ hφ f hC hmass
    exact hc.trans (Nat.le_add_left _ _)

/-- The manuscript's unconditioned mass complexity. Positivity is stated
separately because Lean's total logarithm is also defined at zero. -/
def powerMassComplexity {d N r : ℕ} (φ : ℝ → ℝ) (γ : ℝ) (f : BooleanFunction d) : ℝ :=
  -2*Real.log (functionMass φ (1/2) (powerPrior d N r γ) f)/(N:ℝ)^γ

theorem powerMassComplexity_nonneg {d N r : ℕ} (hN : 0 < N)
    (φ : ℝ → ℝ) (γ : ℝ) (f : BooleanFunction d)
    (hp : 0 < functionMass φ (1/2) (powerPrior d N r γ) f) :
    0 ≤ powerMassComplexity (N:=N) (r:=r) φ γ f := by
  have hp1 : functionMass φ (1/2) (powerPrior d N r γ) f ≤ 1 := measureReal_le_one
  have hl := Real.log_nonpos hp.le hp1
  unfold powerMassComplexity
  exact div_nonneg (by linarith) (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _).le

/-- The literal inverse mass-complexity corollary, with a width-independent
real polynomial and no teacher-width restriction on the learner. -/
theorem complexity_le_polynomial_powerMassComplexity (r : ℕ) (γ : ℝ) (hγ : 1 < γ) :
    ∃ A : ℝ, 0 < A ∧ ∃ k : ℕ, ∀ d C N : ℕ, 1 ≤ d → 0 < N →
      ∀ φ : ℝ → ℝ, admissibleActivation φ → ∀ f : BooleanFunction d,
      isComplexity (r:=r) φ f C →
      0 < functionMass φ (1/2) (powerPrior d N r γ) f →
      (C:ℝ) ≤ A*(1+(d:ℝ)+powerMassComplexity (N:=N) (r:=r) φ γ f)^k := by
  obtain ⟨A,hA,k,h⟩ := complexity_of_powerPrior_mass r γ hγ
  refine ⟨A*2^k, by positivity, k, ?_⟩
  intro d C N hd hN φ hφ f hC hp
  let b := powerMassComplexity (N:=N) (r:=r) φ γ f
  have hb : 0 ≤ b := powerMassComplexity_nonneg hN φ γ f hp
  have hs : 0 < (N:ℝ)^γ := Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _
  have hlog : b*(N:ℝ)^γ = -2*Real.log (functionMass φ (1/2) (powerPrior d N r γ) f) := by
    dsimp [b,powerMassComplexity]
    field_simp
  have hc := Nat.le_ceil b
  have hmass : Real.exp (-(⌈b⌉₊:ℝ)*(N:ℝ)^γ) ≤ functionMass φ (1/2) (powerPrior d N r γ) f := by
    rw [←Real.exp_log hp]
    apply Real.exp_le_exp.mpr
    have hh := mul_le_mul_of_nonneg_right hc hs.le
    have hh' := mul_nonneg hb hs.le
    nlinarith
  have hbound := h d C N ⌈b⌉₊ hd hN φ hφ f hC hmass
  have hbase : 1+(d:ℝ)+(⌈b⌉₊:ℝ) ≤ 2*(1+(d:ℝ)+b) := by
    have hh := Nat.ceil_lt_add_one hb
    linarith [Nat.cast_nonneg d (α:=ℝ)]
  calc
    (C:ℝ) ≤ A*(1+(d:ℝ)+(⌈b⌉₊:ℝ))^k := hbound
    _ ≤ A*(2*(1+(d:ℝ)+b))^k :=
      mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hbase k) hA.le
    _ = _ := by rw [mul_pow]; ring

/-- The converse uses the original cylinder polynomial, uniformly for all
gamma >= 1 and every learner width at least the teacher complexity. -/
theorem powerMassComplexity_le_polynomial_complexity {d C N r : ℕ}
    (hd : 0 < d) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C)
    (hCN : C ≤ N) {γ : ℝ} (hγ : 1 ≤ γ) :
    powerMassComplexity (N:=N) (r:=r) φ γ f ≤
      2*cylinderPolynomialCoefficient r*(1+(d:ℝ)+C)^cylinderPolynomialDegree r := by
  have hN : 0 < N := lt_of_lt_of_le (Nat.succ_le_iff.mp hf.1) hCN
  have hs : 0 < (N:ℝ)^γ := Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _
  have hm := powerPrior_target_mass_polynomial hd φ hφ f hf hCN hγ
  have hl := Real.log_le_log (Real.exp_pos _) hm
  rw [Real.log_exp] at hl
  unfold powerMassComplexity
  apply (div_le_iff₀ hs).mpr
  nlinarith

end NeuralGeneralization.ConcreteModel
