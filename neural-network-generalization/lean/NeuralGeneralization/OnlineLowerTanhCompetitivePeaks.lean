import NeuralGeneralization.OnlineLowerTanhMomentPeriodic
import NeuralGeneralization.OnlineLowerTanhPeakLocalization
import NeuralGeneralization.OnlineLowerTanhBiasCandidates

/-! # Competitive actual coefficients lie near finitely many periodic peaks -/
noncomputable section
open scoped BigOperators Topology Classical
open Filter
namespace NeuralGeneralization.OnlineLowerTanh

/-- The lattice point is an actual odd integer, and its bias displacement
has an explicit `1/n` squared bound. All assumptions concern actual tanh
coefficients; the periodic localization is proved from the concrete series. -/
theorem equalBulk_competitive_peak_distance :
    ∃ R C : ℝ, 0 < R ∧ 0 < C ∧ ∃ N₀ : ℕ, 0 < N₀ ∧
      ∀ n : ℕ, N₀ ≤ n → ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ,
      |parityCorrelation (fun _ : Fin n => a) (bulkCentralBias n a)| ≤
        |parityCorrelation (fun _ : Fin n => a) B| →
      ∃ q : ℤ, Odd q ∧ |(q : ℝ)| ≤ R ∧
        (B-a*((q : ℝ)-(n%2 : ℕ)))^2 ≤ C/(n : ℝ) := by
  obtain ⟨R, hR, N₁, hN₁, hcompact⟩ := equalBulk_competitive_bias_compact
  obtain ⟨N₂, hN₂, hglobal⟩ := balanced_global_error_uniform
  obtain ⟨N₃, hN₃, hmom⟩ := balancedMoment_compact_error R hR.le
  let K := balancedGlobalConstant
  let E := 3*K+1+balancedMomentCompactConstant R
  let C := (800/periodicPeakFloor)*(E/Real.sqrt (2/Real.pi))
  have hK : 0 < K := balancedGlobalConstant_pos
  have hE : 0 < E := by dsimp [E]; positivity [balancedMomentCompactConstant_pos hR.le]
  have hC : 0 < C := by dsimp [C]; positivity [periodicPeakFloor_pos, gaussianLeadingScale_pos]
  refine ⟨R+3, C, by linarith, hC, max N₁ (max N₂ N₃), by omega, ?_⟩
  intro n hn a ha ha2 B hcomp
  have hn1 : N₁ ≤ n := (le_max_left _ _).trans hn
  have hn2 : N₂ ≤ n := (le_max_left _ _).trans ((le_max_right _ _).trans hn)
  have hn3 : N₃ ≤ n := (le_max_right _ _).trans ((le_max_right _ _).trans hn)
  have hn0 : 0 < n := lt_of_lt_of_le hN₁ hn1
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  have ha0 : 0 < a := by linarith
  have hB := hcompact n hn1 a ha ha2 B hcomp
  have hcentral := balanced_central_lower hn0 ha ha2 hK.le (hglobal n hn2 a ha ha2)
  have hcompS := mul_le_mul_of_nonneg_left hcomp (Real.sqrt_nonneg (n : ℝ))
  have herr := hmom n hn3 0 (by decide) a ha ha2 B ((n : ℝ)*Real.pi/2) hB
  rw [← residualRawKernel_parity, balancedMomentLeading_zero n ha0 B] at herr
  let b := B+(n%2 : ℕ)*a
  let F := periodicFourierResponse a b
  let v := Real.sqrt (n : ℝ)*parityCorrelation (fun _ : Fin n => a) B
  let M := (-1 : ℝ)^(n/2)*Real.sqrt (2/Real.pi)*F
  have htri : |v| ≤ |v-M|+|M| := by
    calc
      _ = |(v-M)+M| := by congr 1; ring
      _ ≤ _ := abs_add_le _ _
  have hv : |v| = Real.sqrt (n : ℝ)*|parityCorrelation (fun _ : Fin n => a) B| := by
    dsimp [v]
    rw [abs_mul, abs_of_nonneg (Real.sqrt_nonneg _)]
  have hM : |M| = Real.sqrt (2/Real.pi)*|F| := by
    dsimp [M]
    simp only [abs_mul, abs_pow, abs_neg, abs_one, one_pow, one_mul,
      abs_of_nonneg (Real.sqrt_nonneg _)]
  change |v-M| ≤ balancedMomentCompactConstant R/(n : ℝ) at herr
  rw [hv, hM] at htri
  have hfloor : Real.sqrt (2/Real.pi)*(periodicFourierMaximum a-|F|) ≤ E/(n : ℝ) := by
    rw [periodicFourierMaximum_eq_scalarF0 a ha0]
    dsimp [E, K, bulkAmplitude] at *
    rw [add_div]
    linarith
  have hdef : periodicFourierMaximum a-|F| ≤ (E/Real.sqrt (2/Real.pi))/(n : ℝ) := by
    rw [show (E/Real.sqrt (2/Real.pi))/(n : ℝ) = (E/(n : ℝ))/Real.sqrt (2/Real.pi) by ring]
    apply (le_div_iff₀ gaussianLeadingScale_pos).mpr
    simpa only [mul_comm] using hfloor
  let q := phaseInteger true (b/a)
  have hp := periodic_nearest_peak_distance ha ha2 b
  have he : B-a*((q : ℝ)-(n%2 : ℕ)) = b-a*(q : ℝ) := by dsimp [b]; ring
  refine ⟨q, hp.1, ?_, ?_⟩
  · have hmod : (0 : ℝ) ≤ (n%2 : ℕ) ∧ ((n%2 : ℕ) : ℝ) ≤ 1 := by
      constructor
      · exact_mod_cast (Nat.zero_le (n%2))
      · exact_mod_cast (show n%2 ≤ 1 by omega)
    have hshift : |((n%2 : ℕ) : ℝ)*a| ≤ 2 := by
      rw [abs_of_nonneg (mul_nonneg hmod.1 ha0.le)]
      nlinarith
    have hb : |b| ≤ R+2 := (abs_add_le _ _).trans (add_le_add hB hshift)
    have hi := periodic_nearest_peak_index_bound ha hb
    change |(q : ℝ)| ≤ R+2+1 at hi
    linarith
  · rw [he]
    have hh := mul_le_mul_of_nonneg_left hdef (show 0 ≤ 800/periodicPeakFloor by positivity [periodicPeakFloor_pos])
    exact hp.2.trans (by dsimp [C]; convert hh using 1 <;> ring)

/-- Every competitive coefficient eventually belongs to any prescribed fixed
neighborhood of one of a uniformly bounded set of odd periodic peaks. -/
theorem equalBulk_competitive_peak_neighborhood :
    ∃ R : ℝ, 0 < R ∧ ∀ δ : ℝ, 0 < δ → ∃ N₀ : ℕ, 0 < N₀ ∧
      ∀ n : ℕ, N₀ ≤ n → ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ,
      |parityCorrelation (fun _ : Fin n => a) (bulkCentralBias n a)| ≤
        |parityCorrelation (fun _ : Fin n => a) B| →
      ∃ q : ℤ, Odd q ∧ |(q : ℝ)| ≤ R ∧
        |B-a*((q : ℝ)-(n%2 : ℕ))| ≤ δ := by
  obtain ⟨R, C, hR, hC, N₁, hN₁, hloc⟩ := equalBulk_competitive_peak_distance
  refine ⟨R, hR, ?_⟩
  intro δ hδ
  obtain ⟨N₂, hN₂⟩ := exists_nat_gt (C/δ^2)
  refine ⟨max N₁ N₂, lt_of_lt_of_le hN₁ (le_max_left _ _), ?_⟩
  intro n hn a ha ha2 B hcomp
  have hn1 := le_trans (le_max_left N₁ N₂) hn
  have hn2 := le_trans (le_max_right N₁ N₂) hn
  have hn0 : 0 < n := lt_of_lt_of_le hN₁ hn1
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn0
  obtain ⟨q, hq, hqR, hdist⟩ := hloc n hn1 a ha ha2 B hcomp
  refine ⟨q, hq, hqR, ?_⟩
  have hlarge : C/(n : ℝ) ≤ δ^2 := by
    apply (div_le_iff₀ hnR).mpr
    have hnn : (N₂ : ℝ) ≤ n := by exact_mod_cast hn2
    have ht := (div_lt_iff₀ (sq_pos_of_pos hδ)).mp (lt_of_lt_of_le hN₂ hnn)
    nlinarith
  have habs := sq_abs (B-a*((q : ℝ)-(n%2 : ℕ)))
  nlinarith [abs_nonneg (B-a*((q : ℝ)-(n%2 : ℕ)))]

end NeuralGeneralization.OnlineLowerTanh
