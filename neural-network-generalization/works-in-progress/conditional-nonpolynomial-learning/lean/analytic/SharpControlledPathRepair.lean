import ControlledPathRepair
import SharpControlledLayerRepair
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators InnerProductSpace ENNReal Matrix
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt
variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]
theorem exists_repaired_controlled_path_scaled_sharp (H : ℕ) (t : ℕ → ℝ)
    (R : ℕ → X → I → ℝ) (V : ℕ → (X → ℝ) → ℝ)
    (hV : ∀ n < H, Measurable (V n)) (G : ℕ → ℝ)
    (hbound : ∀ n < H, ∀ z, |V n z| ≤ G n)
    (K : ℕ → Matrix X X ℝ) (hK : ∀ n ≤ H, (K n).PosSemidef)
    (hR : ∀ n < H, ∀ x y, GaussianAngularPrice.gram (R n) x y=(t n)^2*K n x y)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hdefect : ∀ n < H, ∀ x y,
      |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw (R n)).tilted (V n))-
        K (n+1) x y| ≤ ε^2) :
    let cost := fun n => (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal
    let gain := fun n => |t n| *(1+Real.sqrt (2*cost n))
    ∃ C D : ℕ → PairFeature X, ∃ Q : ℕ → Measure (X → ℝ),
      (∀ n ≤ H, ∀ x y, inner ℝ (C n x) (C n y)=K n x y) ∧
      (∀ x, C 0 x=D 0 x) ∧
      (∀ n < H, IsProbabilityMeasure (Q n)) ∧
      (∀ n < H, klDiv (Q n) (fieldLaw (scaledFeatureCoefficients (t n) (D n))) ≠ ∞) ∧
      (∀ n < H, (klDiv (Q n) (fieldLaw (scaledFeatureCoefficients (t n) (D n)))).toReal ≤ cost n) ∧
      (∀ n < H, ∀ x y, inner ℝ (D (n+1) x) (D (n+1) y)=
        ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q n) ∧
      ∀ n ≤ H, ∀ x, ‖C n x-D n x‖ ≤ propagatedFeatureError gain ((Fintype.card X:ℝ)^4*ε) n := by
  classical
  dsimp only
  let cost := fun n => (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal
  let gain := fun n => |t n| *(1+Real.sqrt (2*cost n))
  let error := propagatedFeatureError gain ((Fintype.card X:ℝ)^4*ε)
  have hg : ∀ n, 0 ≤ gain n := by intro n; dsimp [gain,cost]; positivity
  have he : ∀ n, 0 ≤ error n :=
    propagatedFeatureError_nonneg gain _ hg (by positivity)
  let State := fun n => {p : PairFeature X × PairFeature X //
    n ≤ H → (∀ x y, inner ℝ (p.1 x) (p.1 y)=K n x y) ∧
      ∀ x, ‖p.1 x-p.2 x‖ ≤ error n}
  let StepOK := fun n (s : State n) (Q : Measure (X → ℝ)) (s' : State (n+1)) =>
    IsProbabilityMeasure Q ∧ klDiv Q (fieldLaw (scaledFeatureCoefficients (t n) s.val.2)) ≠ ∞ ∧
    (klDiv Q (fieldLaw (scaledFeatureCoefficients (t n) s.val.2))).toReal ≤ cost n ∧
    ∀ x y, inner ℝ (s'.val.2 x) (s'.val.2 y)=
      ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q
  have hstep : ∀ n, n < H → ∀ (s : State n), ∃ p : Measure (X → ℝ) × State (n+1),
      StepOK n s p.1 p.2 := by
    intro n hn s
    let A := scaledFeatureCoefficients (t n) s.val.1
    let B := scaledFeatureCoefficients (t n) s.val.2
    have hfield : fieldLaw A=fieldLaw (R n) := by
      apply GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
      intro x y
      rw [scaledFeatureCoefficients_gram,(s.property (by omega)).1 x y,hR n hn x y]
    have hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ (|t n| *error n)^2 := by
      intro x
      rw [scaledFeatureCoefficients_distance,mul_pow,sq_abs]
      exact mul_le_mul_of_nonneg_left
        ((sq_le_sq₀ (norm_nonneg _) (he n)).mpr ((s.property (by omega)).2 x)) (sq_nonneg _)
    have hd : ∀ x y,
        |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted (V n))-
          K (n+1) x y| ≤ ε^2 := by simpa only [hfield] using hdefect n hn
    obtain ⟨Q,C,D,hprob,hKL,hcost,hC,hD,herr⟩ :=
      repair_controlled_gaussian_layer_sharp A B (V n) (hV n hn) (hbound n hn)
        (K (n+1)) (hK (n+1) (by omega)) (|t n| *error n) ε
          (mul_nonneg (abs_nonneg _) (he n)) hε hclose hd
    have herr' : ∀ x, ‖C x-D x‖ ≤ error (n+1) := by
      intro x
      have hh := herr x
      simp only [hfield,Fintype.card_sum,Nat.cast_add] at hh
      change ‖C x-D x‖ ≤ gain n*error n+(Fintype.card X:ℝ)^4*ε
      dsimp [gain,cost]
      nlinarith
    refine ⟨(Q,⟨(C,D),fun _ => ⟨hC,herr'⟩⟩),hprob,hKL,?_,hD⟩
    simpa only [hfield] using hcost
  let step := fun n (s : State n) => if hn : n < H then Classical.choose (hstep n hn s)
    else (Measure.dirac 0, (⟨(0,0),by intro h; omega⟩ : State (n+1)))
  have step_spec (n) (hn : n < H) (s : State n) :
      StepOK n s (step n s).1 (step n s).2 := by
    simpa only [step,dif_pos hn] using Classical.choose_spec (hstep n hn s)
  let u := matrixRowFeature (psdSpectrum (hK 0 (Nat.zero_le H))).root
  obtain ⟨C0,D0,hC0,_,_,_⟩ := compress_feature_pair u u
  have hc0 : ∀ x y, inner ℝ (C0 x) (C0 y)=K 0 x y := by
    intro x y
    rw [hC0,matrixRowFeature_inner]
    exact congrFun (congrFun (psdSpectrum (hK 0 (Nat.zero_le H))).root_gram x) y
  let s0 : State 0 := ⟨(C0,C0),fun _ => ⟨hc0,by intro x; simp [error,propagatedFeatureError]⟩⟩
  let states : (n : ℕ) → State n := fun n => Nat.rec s0 (fun n s => (step n s).2) n
  refine ⟨fun n => (states n).val.1,fun n => (states n).val.2,
    fun n => (step n (states n)).1,?_,?_,?_,?_,?_,?_,?_⟩
  · intro n hn; exact ((states n).property hn).1
  · intro x; rfl
  · intro n hn; exact (step_spec n hn (states n)).1
  · intro n hn; exact (step_spec n hn (states n)).2.1
  · intro n hn; exact (step_spec n hn (states n)).2.2.1
  · intro n hn; exact (step_spec n hn (states n)).2.2.2
  · intro n hn; exact ((states n).property hn).2

#print axioms exists_repaired_controlled_path_scaled_sharp
end ConditionalNonpolynomial.Analytic
