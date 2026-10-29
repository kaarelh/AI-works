import PhysicalGainPrefixEndpoint
import RepresentativeGridClassifier
import IndexedCoverIteration

noncomputable section
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open NeuralGeneralization.ConcreteModel ConditionalNonpolynomial.AnalyticLookup PhysicalShort
variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d} {P : ControlledMarginPath d H t f}
variable {S : Finset (Cube d)} {states : ℕ→CanonicalProgramState d}

def normalizedCanonicalFeature (P : ControlledMarginPath d H t f)
    (states : ℕ→CanonicalProgramState d) (j : ℕ) (x : Cube d) :=
  (physicalGainProduct P j)⁻¹ • (states j).feature x

lemma normalizedCanonicalFeature_step (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (j : ℕ) (hj : j<H) (x : Cube d) :
    normalizedCanonicalFeature P states (j+1) x=
      (M.layer ⟨j,hj⟩).gainValue (t*physicalGainProduct P j)
        (normalizedCanonicalFeature P states j x) := by
  classical
  have hg : physicalGainProduct P (j+1)=
      (t*physicalGainProduct P j)*Real.sqrt (gaussianEntropyGain (physicalLayerCost P j)) := by
    rw [physicalGainProduct_succ,physicalLayerGain_eq]
    ring
  rw [normalizedCanonicalFeature,CanonicalLayerModel.gainValue,←hg,M.evaluate ⟨j,hj⟩ x]
  congr 2
  rw [normalizedCanonicalFeature,smul_smul]
  have hs : (t*physicalGainProduct P j)*(physicalGainProduct P j)⁻¹=t := by
    field_simp [(physicalGainProduct_pos P j).ne']
  rw [hs]

lemma normalizedCanonicalFeature_pair_step (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (j : ℕ) (hj : j<H) (x y : Cube d) :
    ‖normalizedCanonicalFeature P states (j+1) x-normalizedCanonicalFeature P states (j+1) y‖≤
      ‖normalizedCanonicalFeature P states j x-normalizedCanonicalFeature P states j y‖ := by
  classical
  rw [normalizedCanonicalFeature_step M j hj x,normalizedCanonicalFeature_step M j hj y]
  exact (M.layer ⟨j,hj⟩).gainValue_lipschitz
    (mul_pos P.scale_positive (physicalGainProduct_pos P j)) _ _

lemma normalizedCanonicalFeature_suffix (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (s n : ℕ) (hsn : s≤n) (hnH : n≤H) (x y : Cube d) :
    ‖normalizedCanonicalFeature P states n x-normalizedCanonicalFeature P states n y‖≤
      ‖normalizedCanonicalFeature P states s x-normalizedCanonicalFeature P states s y‖ := by
  apply Nat.le_induction (P:=fun n _=>n≤H→
    ‖normalizedCanonicalFeature P states n x-normalizedCanonicalFeature P states n y‖≤
      ‖normalizedCanonicalFeature P states s x-normalizedCanonicalFeature P states s y‖)
    (fun _=>le_rfl) ?_ n hsn hnH
  intro j hsj ih hjH
  exact (normalizedCanonicalFeature_pair_step M j (by omega) x y).trans (ih (by omega))

lemma normalizedCanonicalFeature_readout_gap (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (j : ℕ) (hj : j≤H) (c : EuclideanSpace ℝ (states H).Index)
    (x y : Cube d) :
    |inner ℝ c ((states H).feature x)-inner ℝ c ((states H).feature y)|≤
      (‖c‖*physicalGainProduct P H)*
        ‖normalizedCanonicalFeature P states j x-normalizedCanonicalFeature P states j y‖ := by
  have hh:=normalizedCanonicalFeature_suffix M j H hj le_rfl x y
  have he : inner ℝ c ((states H).feature x)-inner ℝ c ((states H).feature y)=
      physicalGainProduct P H*inner ℝ c
        (normalizedCanonicalFeature P states H x-normalizedCanonicalFeature P states H y) := by
    simp only [normalizedCanonicalFeature,←smul_sub,real_inner_smul_right]
    rw [←inner_sub_right]
    field_simp [(physicalGainProduct_pos P H).ne']
  rw [he,abs_mul,abs_of_pos (physicalGainProduct_pos P H)]
  have hi:=abs_real_inner_le_norm c
    (normalizedCanonicalFeature P states H x-normalizedCanonicalFeature P states H y)
  calc
    _≤physicalGainProduct P H*(‖c‖*‖normalizedCanonicalFeature P states H x-
        normalizedCanonicalFeature P states H y‖) :=
      mul_le_mul_of_nonneg_left hi (physicalGainProduct_pos P H).le
    _≤(‖c‖*physicalGainProduct P H)*‖normalizedCanonicalFeature P states j x-
        normalizedCanonicalFeature P states j y‖ := by
      have hm:=mul_le_mul_of_nonneg_left hh (mul_nonneg (norm_nonneg c) (physicalGainProduct_pos P H).le)
      nlinarith only [hm]

lemma normalizedCanonicalFeature_opposite (M : PhysicalShort.FiniteCanonicalDynamics P S states)
    (j : ℕ) (hj : j≤H) (c : EuclideanSpace ℝ (states H).Index)
    (hc : ‖c‖≤‖P.readout‖)
    (herr : ∀x,|inner ℝ P.readout (P.feature H x)-inner ℝ c ((states H).feature x)|≤(1:ℝ)/8)
    (x y : Cube d) (hx : f x=false) (hy : f y=true) :
    3/(4*(1+‖P.readout‖*physicalGainProduct P H))≤
      ‖normalizedCanonicalFeature P states j x-normalizedCanonicalFeature P states j y‖ := by
  have hmx:=P.margin x
  have hmy:=P.margin y
  simp [hx,hy,labelReal] at hmx hmy
  have hex:=abs_le.mp (herr x)
  have hey:=abs_le.mp (herr y)
  have hdiff : (3:ℝ)/4≤|inner ℝ c ((states H).feature x)-inner ℝ c ((states H).feature y)| := by
    have ha:=neg_le_abs (inner ℝ c ((states H).feature x)-inner ℝ c ((states H).feature y))
    linarith
  have hbound:=hdiff.trans (normalizedCanonicalFeature_readout_gap M j hj c x y)
  have hcoef : ‖c‖*physicalGainProduct P H≤1+‖P.readout‖*physicalGainProduct P H := by
    have hh:=mul_le_mul_of_nonneg_right hc (physicalGainProduct_pos P H).le
    linarith
  have hm:=mul_le_mul_of_nonneg_right hcoef
    (norm_nonneg (normalizedCanonicalFeature P states j x-normalizedCanonicalFeature P states j y))
  apply (div_le_iff₀ (by positivity [physicalGainProduct_pos P H] :
    0<4*(1+‖P.readout‖*physicalGainProduct P H))).mpr
  nlinarith only [hbound,hm]

#print axioms normalizedCanonicalFeature_opposite
end ConditionalNonpolynomial.Analytic.PhysicalLong
