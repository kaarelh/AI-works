import NeuralGeneralization.RowDependentSquaredProcess
import NeuralGeneralization.MatrixOperatorGeometry

/-! The full squared Lipschitz process on the Euclidean unit ball, with
row-dependent responses and the literal sqrt(log(2(m+D))) dependence. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Filter
namespace NeuralGeneralization.SquaredSampling
variable {m D : ℕ}

abbrev ProcessVector (D : ℕ) := EuclideanSpace ℝ (Fin D)

def rowSquaredProcess (a : Fin m → Fin D → ℝ) (ψ : Fin m → ℝ → ℝ)
    (ε : Fin m → Bool) (u : ProcessVector D) : ℝ :=
  ∑ i,cubeCoordinateSign (ε i)*ψ i (linearEvaluation (a i) u)^2

def unitSquaredSup (a : Fin m → Fin D → ℝ) (ψ : Fin m → ℝ → ℝ)
    (ε : Fin m → Bool) : ℝ :=
  sSup ((fun u : ProcessVector D => |rowSquaredProcess a ψ ε u|) '' Metric.closedBall 0 1)

theorem continuous_rowSquaredProcess (a : Fin m → Fin D → ℝ) (ψ : Fin m → ℝ → ℝ)
    (hψ : ∀ i x y,|ψ i x-ψ i y| ≤ |x-y|) (ε : Fin m → Bool) :
    Continuous (rowSquaredProcess a ψ ε) := by
  have hp (i) : Continuous (ψ i) :=
    (LipschitzWith.of_dist_le_mul (K := 1) (by simpa [Real.dist_eq] using hψ i)).continuous
  unfold rowSquaredProcess linearEvaluation
  fun_prop

/-- Finite signs allow one maximizer per sign vector. The finite chaining
estimate therefore controls the full uncountable Euclidean unit ball. -/
theorem squared_lipschitz_process_pos (a : Fin m → Fin D → ℝ)
    (ψ : Fin m → ℝ → ℝ) (hψ0 : ∀ i,ψ i 0=0)
    (hψ : ∀ i x y,|ψ i x-ψ i y| ≤ |x-y|)
    (hm : 0 < m) (hD : 0 < D) {R V : ℝ} (hR : 0 < R) (hV : 0 < V)
    (ha : ∀ i,∑ j,a i j^2 ≤ R^2)
    (hrow : ∀ u : ProcessVector D,‖u‖ ≤ 1 → ∑ i,linearEvaluation (a i) u^2 ≤ V^2) :
    finiteMean (unitSquaredSup a ψ) ≤
      1073741824*R*Real.sqrt (Real.log (2*((m:ℝ)+D)))*V := by
  classical
  have hmax (ε : Fin m → Bool) : ∃ u : ProcessVector D,u ∈ Metric.closedBall 0 1 ∧
      ∀ v ∈ Metric.closedBall 0 1,|rowSquaredProcess a ψ ε v| ≤ |rowSquaredProcess a ψ ε u| :=
    (isCompact_closedBall (0 : ProcessVector D) 1).exists_isMaxOn
      ⟨0,by simp⟩ (continuous_rowSquaredProcess a ψ hψ ε).abs.continuousOn
  choose u hu hmax using hmax
  let p : Option (Fin m → Bool) → Fin D → ℝ := fun z => match z with
    | none => 0
    | some ε => u ε
  have hp (z : Option (Fin m → Bool)) : ∑ j,p z j^2 ≤ 1 := by
    cases z with
    | none => simp [p]
    | some ε =>
      have hn : ‖u ε‖ ≤ 1 := by simpa only [Metric.mem_closedBall, dist_zero_right] using hu ε
      have hs := (sq_le_sq₀ (norm_nonneg _) (by norm_num : (0:ℝ) ≤ 1)).mpr hn
      simpa only [p, EuclideanSpace.real_norm_sq_eq, one_pow] using hs
  have hprow (z : Option (Fin m → Bool)) : ∑ i,linearEvaluation (a i) (p z)^2 ≤ V^2 := by
    cases z with
    | none => simp only [p, linearEvaluation, Pi.zero_apply, mul_zero, Finset.sum_const_zero, zero_pow (by decide : 2 ≠ 0)]
              exact sq_nonneg V
    | some ε => exact hrow (u ε) (by simpa only [Metric.mem_closedBall,dist_zero_right] using hu ε)
  have hs := finite_row_squared_rademacher a p none rfl hm hR hV ha hp hprow ψ hψ0 hψ
  have he (ε : Fin m → Bool) : unitSquaredSup a ψ ε = envelope (fun z =>
      ∑ i,cubeCoordinateSign (ε i)*ψ i (linearEvaluation (a i) (p z))^2) := by
    have hzero : (0 : ProcessVector D) ∈ Metric.closedBall 0 1 := by simp
    have hps (z : Option (Fin m → Bool)) :
        |∑ i,cubeCoordinateSign (ε i)*ψ i (linearEvaluation (a i) (p z))^2| ≤
          |rowSquaredProcess a ψ ε (u ε)| := by
      cases z with
      | none => exact hmax ε 0 hzero
      | some z => exact hmax ε (u z) (hu z)
    rw [envelope_eq_of_max _ (some ε) (fun z => hps z)]
    unfold unitSquaredSup
    apply le_antisymm
    · refine csSup_le ?_ ?_
      · exact ⟨|rowSquaredProcess a ψ ε 0|,0,hzero,rfl⟩
      · rintro _ ⟨v,hv,rfl⟩
        exact hmax ε v hv
    · apply le_csSup
      · exact ((isCompact_closedBall (0 : ProcessVector D) 1).image
          (continuous_rowSquaredProcess a ψ hψ ε).abs).bddAbove
      · exact ⟨u ε,hu ε,rfl⟩
  simp_rw [← he] at hs
  have hlog := squared_process_log_budget hm hD
  have hsqrt := Real.sqrt_le_sqrt hlog
  have hlog0 : 0 ≤ Real.log (2*((m:ℝ)+D)) := Real.log_nonneg (by
    have hmn : (1:ℝ) ≤ m := by exact_mod_cast hm
    have hdn : (0:ℝ) ≤ D := Nat.cast_nonneg _
    nlinarith)
  rw [Real.sqrt_mul (by norm_num : (0:ℝ) ≤ 16)] at hsqrt
  have h16 : Real.sqrt (16:ℝ) = 4 := by
    rw [show (16:ℝ) = 4^2 by norm_num, Real.sqrt_sq (by norm_num)]
  rw [h16] at hsqrt
  have hh := mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left hsqrt (by positivity : 0 ≤ 268435456*R)) hV.le
  exact hs.trans (by nlinarith only [hh])

/-- The manuscript lemma, also covering zero row norm or zero operator norm.
R and V may be any valid upper bounds; choosing their literal maxima gives
exactly the paper's statement. The universal numerical constant is explicit. -/
theorem squared_lipschitz_process (a : Fin m → Fin D → ℝ)
    (ψ : Fin m → ℝ → ℝ) (hψ0 : ∀ i,ψ i 0=0)
    (hψ : ∀ i x y,|ψ i x-ψ i y| ≤ |x-y|)
    (hm : 0 < m) (hD : 0 < D) {R V : ℝ} (hR : 0 ≤ R) (hV : 0 ≤ V)
    (ha : ∀ i,∑ j,a i j^2 ≤ R^2)
    (hrow : ∀ u : ProcessVector D,‖u‖ ≤ 1 → ∑ i,linearEvaluation (a i) u^2 ≤ V^2) :
    finiteMean (unitSquaredSup a ψ) ≤
      1073741824*R*Real.sqrt (Real.log (2*((m:ℝ)+D)))*V := by
  let e : ℕ → ℝ := fun n => 1/((n:ℝ)+1)
  have he : Tendsto e atTop (𝓝 0) := tendsto_one_div_add_atTop_nhds_zero_nat
  have hepos (n : ℕ) : 0 < e n := by dsimp [e]; positivity
  have hh (n : ℕ) := squared_lipschitz_process_pos a ψ hψ0 hψ hm hD
    (show 0 < R+e n by linarith [hepos n]) (show 0 < V+e n by linarith [hepos n])
    (fun i => (ha i).trans (by nlinarith [hepos n]))
    (fun u hu => (hrow u hu).trans (by nlinarith [hepos n]))
  have ht : Tendsto (fun n => 1073741824*(R+e n)*
      Real.sqrt (Real.log (2*((m:ℝ)+D)))*(V+e n)) atTop
      (𝓝 (1073741824*R*Real.sqrt (Real.log (2*((m:ℝ)+D)))*V)) := by
    convert ((tendsto_const_nhds.mul (tendsto_const_nhds.add he)).mul
      tendsto_const_nhds).mul (tendsto_const_nhds.add he) using 1 <;> simp
  exact le_of_tendsto_of_tendsto tendsto_const_nhds ht (Filter.Eventually.of_forall hh)

/-- The literal maximum Euclidean row norm (used below with m>0). -/
def maxRowNorm (a : Fin m → Fin D → ℝ) : ℝ :=
  sSup (Set.range (fun i => ‖(WithLp.toLp 2 (a i) : ProcessVector D)‖))

/-- The manuscript's exact R and V, with V the Euclidean operator norm.
There are no row-energy or response-homogeneity premises. -/
theorem squared_lipschitz_process_exact (a : Fin m → Fin D → ℝ)
    (ψ : Fin m → ℝ → ℝ) (hψ0 : ∀ i,ψ i 0=0)
    (hψ : ∀ i x y,|ψ i x-ψ i y| ≤ |x-y|) (hm : 0<m) (hD : 0<D) :
    finiteMean (unitSquaredSup a ψ) ≤ 1073741824*maxRowNorm a*
      Real.sqrt (Real.log (2*((m:ℝ)+D)))*RandomRestriction.operatorNorm a := by
  haveI : Nonempty (Fin m) := ⟨⟨0,hm⟩⟩
  have hrow (i : Fin m) : ‖(WithLp.toLp 2 (a i) : ProcessVector D)‖ ≤ maxRowNorm a :=
    le_csSup (Set.finite_range _).bddAbove (Set.mem_range_self i)
  have hR : 0 ≤ maxRowNorm a := (norm_nonneg _).trans (hrow ⟨0,hm⟩)
  apply squared_lipschitz_process a ψ hψ0 hψ hm hD hR (show 0 ≤ RandomRestriction.operatorNorm a by
    rw [← RandomRestriction.matrixCLM_norm]; exact norm_nonneg (RandomRestriction.matrixCLM a))
  · intro i
    simpa only [EuclideanSpace.real_norm_sq_eq] using
      (sq_le_sq₀ (norm_nonneg _) hR).mpr (hrow i)
  · intro u hu
    apply RandomRestriction.unit_quadratic_le
    simpa only [EuclideanSpace.real_norm_sq_eq,one_pow] using
      (sq_le_sq₀ (norm_nonneg _) (by norm_num : (0:ℝ) ≤ 1)).mpr hu

end NeuralGeneralization.SquaredSampling
