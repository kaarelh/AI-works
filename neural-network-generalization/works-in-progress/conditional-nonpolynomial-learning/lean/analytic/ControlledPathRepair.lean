import ControlledLayerRepair
import PathRepairRecurrence

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators InnerProductSpace ENNReal Matrix
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

abbrev PairFeature (X : Type*) [Fintype X] := X → EuclideanSpace ℝ (X ⊕ X)

def featureCoefficients (u : X → EuclideanSpace ℝ I) : X → I → ℝ :=
  fun x => (u x).ofLp

omit [Fintype X] [DecidableEq X] in
lemma featureCoefficients_gram (u : X → EuclideanSpace ℝ I) (x y : X) :
    GaussianAngularPrice.gram (featureCoefficients u) x y = inner ℝ (u x) (u y) := by
  simp only [GaussianAngularPrice.gram,featureCoefficients,PiLp.inner_apply,Real.inner_apply]

omit [Fintype X] [DecidableEq X] in
lemma featureCoefficients_distance (u v : X → EuclideanSpace ℝ I) (x : X) :
    (∑ i, (featureCoefficients u x i-featureCoefficients v x i)^2)=‖u x-v x‖^2 := by
  rw [EuclideanSpace.norm_sq_eq]
  simp only [featureCoefficients,WithLp.ofLp_sub,Pi.sub_apply,Real.norm_eq_abs,sq_abs]

def propagatedFeatureError (gain : ℕ → ℝ) (δ : ℝ) : ℕ → ℝ
  | 0 => 0
  | n+1 => gain n*propagatedFeatureError gain δ n+δ

lemma propagatedFeatureError_nonneg (gain : ℕ → ℝ) (δ : ℝ)
    (hg : ∀ n, 0 ≤ gain n) (hδ : 0 ≤ δ) (n : ℕ) :
    0 ≤ propagatedFeatureError gain δ n := by
  induction n with
  | zero => simp [propagatedFeatureError]
  | succ n ih => exact add_nonneg (mul_nonneg (hg n) ih) hδ

/-- Entire exact controlled path from approximate bounded-tilt certificates.
Each repaired Gaussian row law is constructed, its entropy is no larger than
its own certificate entropy, and only the additive Gram defect incurs a
square-root cost. The control coordinate dimension stays 2|X| at every layer.

The data are indexed by natural numbers to make the recursion explicit; the
budget corollary below uses only an arbitrary finite prefix. -/
theorem exists_repaired_controlled_path
    (R : ℕ → X → I → ℝ) (V : ℕ → (X → ℝ) → ℝ)
    (hV : ∀ n, Measurable (V n)) (G : ℕ → ℝ) (hbound : ∀ n z, |V n z| ≤ G n)
    (K : ℕ → Matrix X X ℝ) (hK : ∀ n, (K n).PosSemidef)
    (hR : ∀ n x y, GaussianAngularPrice.gram (R n) x y=K n x y)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hdefect : ∀ n x y,
      |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw (R n)).tilted (V n))-
        K (n+1) x y| ≤ ε^2) :
    let cost := fun n => (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal
    let gain := fun n => 1+4*cost n+4*Fintype.card X
    ∃ C D : ℕ → PairFeature X, ∃ Q : ℕ → Measure (X → ℝ),
      (∀ n x y, inner ℝ (C n x) (C n y)=K n x y) ∧
      (∀ x, C 0 x=D 0 x) ∧
      (∀ n, IsProbabilityMeasure (Q n)) ∧
      (∀ n, klDiv (Q n) (fieldLaw (featureCoefficients (D n))) ≠ ∞) ∧
      (∀ n, (klDiv (Q n) (fieldLaw (featureCoefficients (D n)))).toReal ≤ cost n) ∧
      (∀ n x y, inner ℝ (D (n+1) x) (D (n+1) y)=
        ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q n) ∧
      ∀ n x, ‖C n x-D n x‖ ≤ propagatedFeatureError gain ((Fintype.card X:ℝ)^4*ε) n := by
  classical
  dsimp only
  let cost := fun n => (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal
  let gain := fun n => 1+4*cost n+4*Fintype.card X
  let error := propagatedFeatureError gain ((Fintype.card X:ℝ)^4*ε)
  have hg : ∀ n, 0 ≤ gain n := by intro n; dsimp [gain,cost]; positivity
  have he : ∀ n, 0 ≤ error n :=
    propagatedFeatureError_nonneg gain _ hg (by positivity)
  let State := fun n => {p : PairFeature X × PairFeature X //
    (∀ x y, inner ℝ (p.1 x) (p.1 y)=K n x y) ∧
      ∀ x, ‖p.1 x-p.2 x‖ ≤ error n}
  let StepOK := fun n (s : State n) (Q : Measure (X → ℝ)) (s' : State (n+1)) =>
    IsProbabilityMeasure Q ∧ klDiv Q (fieldLaw (featureCoefficients s.val.2)) ≠ ∞ ∧
    (klDiv Q (fieldLaw (featureCoefficients s.val.2))).toReal ≤ cost n ∧
    ∀ x y, inner ℝ (s'.val.2 x) (s'.val.2 y)=
      ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q
  have hstep : ∀ n (s : State n), ∃ p : Measure (X → ℝ) × State (n+1),
      StepOK n s p.1 p.2 := by
    intro n s
    let A := featureCoefficients s.val.1
    let B := featureCoefficients s.val.2
    have hfield : fieldLaw A=fieldLaw (R n) := by
      apply GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
      intro x y
      exact (featureCoefficients_gram s.val.1 x y).trans ((s.property.1 x y).trans (hR n x y).symm)
    have hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ (error n)^2 := by
      intro x
      rw [featureCoefficients_distance]
      exact (sq_le_sq₀ (norm_nonneg _) (he n)).mpr (s.property.2 x)
    have hd : ∀ x y,
        |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted (V n))-
          K (n+1) x y| ≤ ε^2 := by simpa only [hfield] using hdefect n
    obtain ⟨Q,C,D,hprob,hKL,hcost,hC,hD,herr⟩ :=
      repair_controlled_gaussian_layer A B (V n) (hV n) (hbound n)
        (K (n+1)) (hK (n+1)) (error n) ε (he n) hε hclose hd
    have herr' : ∀ x, ‖C x-D x‖ ≤ error (n+1) := by
      intro x
      have hh := herr x
      simp only [hfield,Fintype.card_sum,Nat.cast_add] at hh
      change ‖C x-D x‖ ≤ gain n*error n+(Fintype.card X:ℝ)^4*ε
      dsimp [gain,cost]
      nlinarith
    refine ⟨(Q,⟨(C,D),hC,herr'⟩),hprob,hKL,?_,hD⟩
    simpa only [hfield] using hcost
  let step := fun n s => Classical.choose (hstep n s)
  have step_spec (n) (s : State n) : StepOK n s (step n s).1 (step n s).2 :=
    Classical.choose_spec (hstep n s)
  let u := matrixRowFeature (psdSpectrum (hK 0)).root
  obtain ⟨C0,D0,hC0,_,_,_⟩ := compress_feature_pair u u
  have hc0 : ∀ x y, inner ℝ (C0 x) (C0 y)=K 0 x y := by
    intro x y
    rw [hC0,matrixRowFeature_inner]
    exact congrFun (congrFun (psdSpectrum (hK 0)).root_gram x) y
  let s0 : State 0 := ⟨(C0,C0),hc0,by intro x; simp [error,propagatedFeatureError]⟩
  let states : (n : ℕ) → State n := fun n => Nat.rec s0 (fun n s => (step n s).2) n
  refine ⟨fun n => (states n).val.1,fun n => (states n).val.2,
    fun n => (step n (states n)).1,?_,?_,?_,?_,?_,?_,?_⟩
  · intro n; exact (states n).property.1
  · intro x; rfl
  · intro n; exact (step_spec n (states n)).1
  · intro n; exact (step_spec n (states n)).2.1
  · intro n; exact (step_spec n (states n)).2.2.1
  · intro n; exact (step_spec n (states n)).2.2.2
  · intro n; exact (states n).property.2

/-- Finite-horizon version requiring certificates only for the supplied layers.
No infinite extension or additional analytic hypothesis is imposed. -/
theorem exists_repaired_controlled_path_finite (H : ℕ)
    (R : ℕ → X → I → ℝ) (V : ℕ → (X → ℝ) → ℝ)
    (hV : ∀ n < H, Measurable (V n)) (G : ℕ → ℝ)
    (hbound : ∀ n < H, ∀ z, |V n z| ≤ G n)
    (K : ℕ → Matrix X X ℝ) (hK : ∀ n ≤ H, (K n).PosSemidef)
    (hR : ∀ n < H, ∀ x y, GaussianAngularPrice.gram (R n) x y=K n x y)
    (ε : ℝ) (hε : 0 ≤ ε)
    (hdefect : ∀ n < H, ∀ x y,
      |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw (R n)).tilted (V n))-
        K (n+1) x y| ≤ ε^2) :
    let cost := fun n => (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal
    let gain := fun n => 1+4*cost n+4*Fintype.card X
    ∃ C D : ℕ → PairFeature X, ∃ Q : ℕ → Measure (X → ℝ),
      (∀ n ≤ H, ∀ x y, inner ℝ (C n x) (C n y)=K n x y) ∧
      (∀ x, C 0 x=D 0 x) ∧
      (∀ n < H, IsProbabilityMeasure (Q n)) ∧
      (∀ n < H, klDiv (Q n) (fieldLaw (featureCoefficients (D n))) ≠ ∞) ∧
      (∀ n < H, (klDiv (Q n) (fieldLaw (featureCoefficients (D n)))).toReal ≤ cost n) ∧
      (∀ n < H, ∀ x y, inner ℝ (D (n+1) x) (D (n+1) y)=
        ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q n) ∧
      ∀ n ≤ H, ∀ x, ‖C n x-D n x‖ ≤ propagatedFeatureError gain ((Fintype.card X:ℝ)^4*ε) n := by
  classical
  dsimp only
  let cost := fun n => (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal
  let gain := fun n => 1+4*cost n+4*Fintype.card X
  let error := propagatedFeatureError gain ((Fintype.card X:ℝ)^4*ε)
  have hg : ∀ n, 0 ≤ gain n := by intro n; dsimp [gain,cost]; positivity
  have he : ∀ n, 0 ≤ error n :=
    propagatedFeatureError_nonneg gain _ hg (by positivity)
  let State := fun n => {p : PairFeature X × PairFeature X //
    n ≤ H → (∀ x y, inner ℝ (p.1 x) (p.1 y)=K n x y) ∧
      ∀ x, ‖p.1 x-p.2 x‖ ≤ error n}
  let StepOK := fun n (s : State n) (Q : Measure (X → ℝ)) (s' : State (n+1)) =>
    IsProbabilityMeasure Q ∧ klDiv Q (fieldLaw (featureCoefficients s.val.2)) ≠ ∞ ∧
    (klDiv Q (fieldLaw (featureCoefficients s.val.2))).toReal ≤ cost n ∧
    ∀ x y, inner ℝ (s'.val.2 x) (s'.val.2 y)=
      ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q
  have hstep : ∀ n, n < H → ∀ (s : State n), ∃ p : Measure (X → ℝ) × State (n+1),
      StepOK n s p.1 p.2 := by
    intro n hn s
    let A := featureCoefficients s.val.1
    let B := featureCoefficients s.val.2
    have hfield : fieldLaw A=fieldLaw (R n) := by
      apply GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
      intro x y
      exact (featureCoefficients_gram s.val.1 x y).trans (((s.property (by omega)).1 x y).trans (hR n hn x y).symm)
    have hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ (error n)^2 := by
      intro x
      rw [featureCoefficients_distance]
      exact (sq_le_sq₀ (norm_nonneg _) (he n)).mpr ((s.property (by omega)).2 x)
    have hd : ∀ x y,
        |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw A).tilted (V n))-
          K (n+1) x y| ≤ ε^2 := by simpa only [hfield] using hdefect n hn
    obtain ⟨Q,C,D,hprob,hKL,hcost,hC,hD,herr⟩ :=
      repair_controlled_gaussian_layer A B (V n) (hV n hn) (hbound n hn)
        (K (n+1)) (hK (n+1) (by omega)) (error n) ε (he n) hε hclose hd
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

def scaledFeatureCoefficients (t : ℝ) (u : X → EuclideanSpace ℝ I) : X → I → ℝ :=
  fun x i => t*featureCoefficients u x i

omit [Fintype X] [DecidableEq X] in
lemma scaledFeatureCoefficients_gram (t : ℝ) (u : X → EuclideanSpace ℝ I) (x y : X) :
    GaussianAngularPrice.gram (scaledFeatureCoefficients t u) x y = t^2*inner ℝ (u x) (u y) := by
  rw [← featureCoefficients_gram]
  simp only [GaussianAngularPrice.gram,scaledFeatureCoefficients,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  ring

omit [Fintype X] [DecidableEq X] in
lemma scaledFeatureCoefficients_distance (t : ℝ) (u v : X → EuclideanSpace ℝ I) (x : X) :
    (∑ i, (scaledFeatureCoefficients t u x i-scaledFeatureCoefficients t v x i)^2)=
      t^2*‖u x-v x‖^2 := by
  rw [← featureCoefficients_distance]
  simp only [scaledFeatureCoefficients,← mul_sub,mul_pow,Finset.mul_sum]

/-- Finite controlled-path repair with arbitrary layerwise Gaussian amplitude.
Both the reference and repaired features are scaled before each transition;
no covariance normalization is silently identified with the empirical Gram. -/
theorem exists_repaired_controlled_path_scaled (H : ℕ) (t : ℕ → ℝ)
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
    let gain := fun n => |t n| *(1+4*cost n+4*Fintype.card X)
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
  let gain := fun n => |t n| *(1+4*cost n+4*Fintype.card X)
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
      repair_controlled_gaussian_layer A B (V n) (hV n hn) (hbound n hn)
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

omit [DecidableEq X] in
/-- The entropy of every finite repaired prefix is bounded by the sum of its
original certificate costs, without any layer-count loss. -/
theorem repaired_prefix_budget (Q : ℕ → Measure (X → ℝ)) (D : ℕ → PairFeature X)
    (cost : ℕ → ℝ) (H : ℕ) (B : ℝ)
    (hcost : ∀ n < H, (klDiv (Q n) (fieldLaw (featureCoefficients (D n)))).toReal ≤ cost n)
    (hbudget : ∑ n ∈ Finset.range H, cost n ≤ B) :
    (∑ n ∈ Finset.range H, (klDiv (Q n) (fieldLaw (featureCoefficients (D n)))).toReal) ≤ B :=
  (Finset.sum_le_sum (fun n hn => hcost n (Finset.mem_range.mp hn))).trans hbudget

end ConditionalNonpolynomial.Analytic
