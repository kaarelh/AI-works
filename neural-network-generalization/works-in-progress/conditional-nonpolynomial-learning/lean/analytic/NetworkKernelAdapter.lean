import NetworkControlledPath
import NetworkReadoutTransport
import ControlledPathRepair

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators InnerProductSpace ENNReal Matrix
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoActivation
open NeuralGeneralization.NetworkLayerSplit NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.GaussianDualLayer
open NeuralGeneralization.CovarianceDualLift NeuralGeneralization.DualCertificate

lemma normalizedHiddenFeature_inner {d N r : ℕ} (hN : 0<N)
    (w : Weights d N r) (x y : Cube d) :
    inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y)=
      (∑ i, finalHidden Real.tanh w x i*finalHidden Real.tanh w y i)/(N:ℝ) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  simp only [normalizedHiddenFeature,PiLp.inner_apply,Real.inner_apply]
  simp_rw [div_mul_div_comm,← pow_two,Real.sq_sqrt hn.le]
  exact (Finset.sum_div _ _ _).symm

lemma input_empirical_gram {d N : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (w : Weights d N 0) (x y : Cube d) :
    empirical (features Real.tanh) (rows (activationInputSource d N σ)
      (activationInputRows σ w)) (x,y)=
        inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y) := by
  rw [normalizedHiddenFeature_inner hN]
  simp only [empirical,features,rows]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  rw [activationInputRows_output hd hN hσ Real.tanh w x i,
    activationInputRows_output hd hN hσ Real.tanh w y i]

lemma last_empirical_gram {d N r : ℕ} (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (w : Weights d N (r+1)) (x y : Cube d) :
    empirical (features Real.tanh) (rows (activationLastSource Real.tanh σ (previousWeights w))
      (activationLastRows σ w)) (x,y)=
        inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y) := by
  rw [normalizedHiddenFeature_inner hN]
  simp only [empirical,features,rows]
  congr 1
  apply Finset.sum_congr rfl
  intro i hi
  rw [activationLastRows_output hσ Real.tanh w x i,
    activationLastRows_output hσ Real.tanh w y i]

lemma hiddenMoments_last {d N : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) : ∀ r (w : Weights d N r) (x y : Cube d),
    hiddenMoments d N σ r w (Fin.last r) (x,y)=
      inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y) := by
  intro r
  cases r with
  | zero => exact fun w x y => input_empirical_gram hd hN hσ w x y
  | succ r =>
    intro w x y
    simp only [hiddenMoments,Fin.snoc_last]
    exact last_empirical_gram hN hσ w x y

lemma hiddenMoments_psd {d N : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) : ∀ r (w : Weights d N r) (j : Fin (r+1)),
    (Matrix.of fun x y => hiddenMoments d N σ r w j (x,y)).PosSemidef := by
  intro r
  induction r with
  | zero =>
    intro w j
    have hmat : (Matrix.of fun x y => hiddenMoments d N σ 0 w j (x,y))=
        Matrix.gram ℝ (normalizedHiddenFeature w) := by
      ext x y
      exact input_empirical_gram hd hN hσ w x y
    rw [hmat]
    exact Matrix.posSemidef_gram ℝ _
  | succ r ih =>
    intro w j
    refine Fin.lastCases ?_ (fun i => ?_) j
    · have hmat : (Matrix.of fun x y => hiddenMoments d N σ (r+1) w (Fin.last (r+1)) (x,y))=
          Matrix.gram ℝ (normalizedHiddenFeature w) := by
        ext x y
        exact hiddenMoments_last hd hN hσ _ w x y
      rw [hmat]
      exact Matrix.posSemidef_gram ℝ _
    · simpa only [hiddenMoments,Fin.snoc_castSucc] using ih (previousWeights w) i

lemma activationLastSource_gram {d N r : ℕ} (hN : 0<N)
    (σ : ℝ) (w : Weights d N r) (x y : Cube d) :
    NeuralGeneralization.GaussianAngularPrice.gram (activationLastSource Real.tanh σ w) x y=
      ((N:ℝ)*σ^2)*inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  rw [normalizedHiddenFeature_inner hN]
  simp only [NeuralGeneralization.GaussianAngularPrice.gram,activationLastSource]
  have hsum : (∑ i, σ*finalHidden Real.tanh w x i*(σ*finalHidden Real.tanh w y i))=
      σ^2*(∑ i,finalHidden Real.tanh w x i*finalHidden Real.tanh w y i) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  rw [hsum]
  field_simp

/-- Input features in the same normalization as the hidden empirical kernels. -/
def normalizedInputFeature (d : ℕ) (x : Cube d) : EuclideanSpace ℝ (Fin (d+1)) :=
  WithLp.toLp 2 (fun i => inputVector x i/Real.sqrt d)

def networkKernel (d N : ℕ) (σ : ℝ) (r : ℕ) (w : Weights d N r) :
    Fin (r+2) → Matrix (Cube d) (Cube d) ℝ :=
  Fin.cons (Matrix.gram ℝ (normalizedInputFeature d))
    (fun j => Matrix.of fun x y => hiddenMoments d N σ r w j (x,y))

lemma networkKernel_psd {d N : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (r : ℕ) (w : Weights d N r) (j : Fin (r+2)) :
    (networkKernel d N σ r w j).PosSemidef := by
  refine Fin.cases ?_ (fun i => ?_) j
  · exact Matrix.posSemidef_gram ℝ _
  · exact hiddenMoments_psd hd hN hσ r w i

lemma networkKernel_prefix {d N r : ℕ} (σ : ℝ) (w : Weights d N (r+1))
    (j : Fin (r+2)) :
    networkKernel d N σ (r+1) w j.castSucc =
      networkKernel d N σ r (previousWeights w) j := by
  refine Fin.cases ?_ (fun i => ?_) j
  · rfl
  · rw [← Fin.succ_castSucc]
    simp only [networkKernel,Fin.cons_succ,hiddenMoments,Fin.snoc_castSucc]

lemma networkKernel_terminal {d N : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (r : ℕ) (w : Weights d N r) (x y : Cube d) :
    networkKernel d N σ r w (Fin.last (r+1)) x y=
      inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y) := by
  change hiddenMoments d N σ r w (Fin.last r) (x,y)=_
  exact hiddenMoments_last hd hN hσ r w x y

lemma activationInputSource_gram {d N : ℕ} (hd : 0<d) (σ : ℝ) (x y : Cube d) :
    NeuralGeneralization.GaussianAngularPrice.gram (activationInputSource d N σ) x y=
      ((N:ℝ)*σ^2)*inner ℝ (normalizedInputFeature d x) (normalizedInputFeature d y) := by
  have hdreal : (0:ℝ)<d := by exact_mod_cast hd
  have hNreal : (0:ℝ)≤N := Nat.cast_nonneg N
  simp only [NeuralGeneralization.GaussianAngularPrice.gram,activationInputSource,
    normalizedInputFeature,PiLp.inner_apply,Real.inner_apply]
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  have hs := Real.sq_sqrt (div_nonneg hNreal hdreal.le)
  have hd2 := Real.sq_sqrt hdreal.le
  have hds : Real.sqrt d ≠ 0 := (Real.sqrt_pos.mpr hdreal).ne'
  field_simp
  rw [hs,hd2]
  field_simp

/-- The concrete conditional reference law is exactly the Gaussian field
of the preceding empirical kernel, including its Gaussian amplitude. -/
theorem hiddenReferences_of_gram {d N : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) {I : Type*} [Fintype I] :
    ∀ r (w : Weights d N r) (j : Fin (r+1)) (R : Cube d → I → ℝ),
    (∀ x y, NeuralGeneralization.GaussianAngularPrice.gram R x y=
      ((N:ℝ)*σ^2)*networkKernel d N σ r w j.castSucc x y) →
    hiddenReferences d N σ r w j=fieldLaw R := by
  intro r
  induction r with
  | zero =>
    intro w j R hR
    have hj : j=0 := Fin.eq_zero j
    subst j
    apply NeuralGeneralization.GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
    intro x y
    rw [hR]
    exact activationInputSource_gram hd σ x y
  | succ r ih =>
    intro w j R
    refine Fin.lastCases ?_ (fun i => ?_) j
    · intro hR
      simp only [hiddenReferences,Fin.snoc_last]
      apply NeuralGeneralization.GaussianFieldCovariance.fieldLaw_eq_of_gram_eq
      intro x y
      rw [hR,activationLastSource_gram hN]
      congr 1
      rw [networkKernel_prefix,networkKernel_terminal hd hN hσ]
    · intro hR
      simp only [hiddenReferences,Fin.snoc_castSucc]
      apply ih (previousWeights w) i R
      intro x y
      rw [hR,networkKernel_prefix]

end ConditionalNonpolynomial.Analytic
