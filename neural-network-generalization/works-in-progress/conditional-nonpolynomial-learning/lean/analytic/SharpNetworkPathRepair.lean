import NetworkPathRepair
import SharpControlledPathRepair
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators InnerProductSpace ENNReal Matrix
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoActivation
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.CovarianceDualLift
open NeuralGeneralization.ActualBoundedDual NeuralGeneralization.BoundedDual
variable {d N r : ℕ}
def sharpNetworkRepairError (σ : ℝ) (w : Weights d N r)
    (star : Fin (r+1) → Cube d × Cube d → ℝ) (ε : ℝ) : ℕ → ℝ :=
  propagatedFeatureError (fun n => |Real.sqrt N*σ| *
    (1+Real.sqrt (2*networkCertificateCostAt σ w star n)))
    ((Fintype.card (Cube d):ℝ)^4*ε)

/-- Convert the actual finite-network covariance certificates to a genuine
controlled Gaussian path, preserving every full-cube empirical Gram and the
individual entropy budgets. The terminal pair is in 2·2^d coordinates,
independently of the original width. -/
theorem actual_network_path_repair_sharp (hd : 0<d) (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (w : Weights d N r) (star : Fin (r+1) → Cube d × Cube d → ℝ)
    (G ε : ℝ) (hε : 0≤ε) (hstar : ∀ j, entryL1 (star j)≤G)
    (hdefect : ∀ j, maxAbs (hiddenMoments d N σ r w j-
      mean (hiddenReferences d N σ r w j) (features Real.tanh) (star j)) ≤ ε^2) :
    ∃ C D : ℕ → PairFeature (Cube d), ∃ Q : ℕ → Measure (Cube d → ℝ),
      (∀ x, C 0 x=D 0 x) ∧
      (∀ n (hn : n≤r+1) x y, inner ℝ (C n x) (C n y)=
        networkKernel d N σ r w ⟨n,by omega⟩ x y) ∧
      (∀ n < r+1, IsProbabilityMeasure (Q n)) ∧
      (∀ n < r+1, klDiv (Q n)
        (fieldLaw (scaledFeatureCoefficients (Real.sqrt N*σ) (D n))) ≠ ∞) ∧
      (∀ n (hn : n<r+1), (klDiv (Q n)
        (fieldLaw (scaledFeatureCoefficients (Real.sqrt N*σ) (D n)))).toReal ≤
        networkCertificateCost σ w star ⟨n,hn⟩) ∧
      (∀ n < r+1, ∀ x y, inner ℝ (D (n+1) x) (D (n+1) y)=
        ∫ z, Real.tanh (z x)*Real.tanh (z y) ∂Q n) ∧
      (∀ n≤r+1, ∀ x, ‖C n x-D n x‖≤sharpNetworkRepairError σ w star ε n) ∧
      (∀ x y, inner ℝ (C (r+1) x) (C (r+1) y)=
        inner ℝ (normalizedHiddenFeature w x) (normalizedHiddenFeature w y)) := by
  classical
  let t := Real.sqrt N*σ
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have ht2 : t^2=(N:ℝ)*σ^2 := by dsimp [t]; rw [mul_pow,Real.sq_sqrt hn.le]
  let K : ℕ → Matrix (Cube d) (Cube d) ℝ := fun n =>
    if hn : n≤r+1 then networkKernel d N σ r w ⟨n,by omega⟩ else 0
  have hK : ∀ n≤r+1, (K n).PosSemidef := by
    intro n hn
    simp only [K,dif_pos hn]
    exact networkKernel_psd hd hN hσ _ w _
  let Z : (n : ℕ) → n≤r+1 → Cube d → EuclideanSpace ℝ (Cube d) :=
    fun n hn => matrixRowFeature (psdSpectrum (hK n hn)).root
  have hZ (n : ℕ) (hn : n≤r+1) (x y : Cube d) :
      inner ℝ (Z n hn x) (Z n hn y)=K n x y := by
    rw [matrixRowFeature_inner]
    exact congrFun (congrFun (psdSpectrum (hK n hn)).root_gram x) y
  let R : ℕ → Cube d → Cube d → ℝ := fun n =>
    if hn : n<r+1 then scaledFeatureCoefficients t (Z n (by omega)) else 0
  let V : ℕ → (Cube d → ℝ) → ℝ := fun n =>
    if hn : n<r+1 then potential (features Real.tanh) (star ⟨n,hn⟩) else 0
  have hV : ∀ n<r+1, Measurable (V n) := by
    intro n hn
    simp only [V,dif_pos hn]
    exact measurable_potential (features Real.tanh) (fun p => (NeuralGeneralization.TanhDifferential.continuous_tanhPairValue p.1 p.2).measurable) _
  have hbound : ∀ n<r+1, ∀ z, |V n z|≤G := by
    intro n hn z
    simp only [V,dif_pos hn]
    exact (potential_bound (features Real.tanh)
      (features_bound Real.tanh (fun x=>(Real.abs_tanh_lt_one x).le)) _ z).trans (hstar _)
  have hRgram : ∀ n<r+1, ∀ x y,
      NeuralGeneralization.GaussianAngularPrice.gram (R n) x y=t^2*K n x y := by
    intro n hn x y
    simp only [R,dif_pos hn,scaledFeatureCoefficients_gram,hZ]
  have hRlaw (n : ℕ) (hn : n<r+1) :
      fieldLaw (R n)=hiddenReferences d N σ r w ⟨n,hn⟩ := by
    symm
    apply hiddenReferences_of_gram hd hN hσ r w ⟨n,hn⟩
    intro x y
    rw [hRgram n hn,ht2]
    simp only [K,dif_pos (show n≤r+1 by omega)]
    rfl
  have hd' : ∀ n<r+1, ∀ x y,
      |(∫ z, Real.tanh (z x)*Real.tanh (z y) ∂(fieldLaw (R n)).tilted (V n))-
        K (n+1) x y|≤ε^2 := by
    intro n hn x y
    rw [hRlaw n hn]
    simp only [V,dif_pos hn,K,dif_pos (show n+1≤r+1 by omega)]
    have hh := (abs_le_maxAbs (hiddenMoments d N σ r w ⟨n,hn⟩-
      mean (hiddenReferences d N σ r w ⟨n,hn⟩) (features Real.tanh) (star ⟨n,hn⟩)) (x,y)).trans
        (hdefect ⟨n,hn⟩)
    change |(∫ z, Real.tanh (z x)*Real.tanh (z y)
      ∂(hiddenReferences d N σ r w ⟨n,hn⟩).tilted
        (potential (features Real.tanh) (star ⟨n,hn⟩)))-
        hiddenMoments d N σ r w ⟨n,hn⟩ (x,y)|≤ε^2
    rw [abs_sub_comm]
    exact hh
  obtain ⟨C,D,Q,hC,hzero,hprob,hKL,hcost,hrec,herror⟩ :=
    exists_repaired_controlled_path_scaled_sharp (r+1) (fun _ => t) R V hV (fun _ => G) hbound K hK
      hRgram ε hε hd'
  have hcostEq (n : ℕ) (hn : n<r+1) :
      (klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal=
        networkCertificateCost σ w star ⟨n,hn⟩ := by
    rw [hRlaw n hn]
    simp only [V,dif_pos hn,networkCertificateCost]
  have herrorEq : ∀ n≤r+1,
      propagatedFeatureError
        (fun n => |t| * (1+Real.sqrt (2*(klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal))) ((Fintype.card (Cube d):ℝ)^4*ε) n=
        sharpNetworkRepairError σ w star ε n := by
    intro n hnl
    induction n with
    | zero => rfl
    | succ n ih =>
      have hnh : n<r+1 := by omega
      unfold sharpNetworkRepairError
      simp only [propagatedFeatureError]
      change |t| * (1+Real.sqrt (2*(klDiv ((fieldLaw (R n)).tilted (V n)) (fieldLaw (R n))).toReal))*_+_=_
      rw [hcostEq n hnh]
      have hi := ih (by omega)
      change propagatedFeatureError _ _ n=propagatedFeatureError _ _ n at hi
      rw [hi]
      simp only [networkCertificateCostAt,dif_pos hnh]
      rfl
  refine ⟨C,D,Q,hzero,?_,hprob,hKL,?_,hrec,?_,?_⟩
  · intro n hn x y
    simpa only [K,dif_pos hn] using hC n hn x y
  · intro n hn
    exact (hcost n hn).trans_eq (hcostEq n hn)
  · intro n hn x
    have hh := herror n hn x
    rw [herrorEq n hn] at hh
    exact hh
  · intro x y
    have hh := hC (r+1) (by omega) x y
    simp only [K,dif_pos (show r+1≤r+1 by omega)] at hh
    exact hh.trans (networkKernel_terminal hd hN hσ r w x y)

#print axioms actual_network_path_repair_sharp
end ConditionalNonpolynomial.Analytic
