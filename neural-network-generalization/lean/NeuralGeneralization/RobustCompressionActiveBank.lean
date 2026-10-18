import NeuralGeneralization.RobustCompressionLayerBound
import NeuralGeneralization.RobustCompressionLayerParameters
import NeuralGeneralization.RobustGaussianGeometrySourceBank

/-! # Instantiation by the actual selected active family

Zero-safe Gram--Schmidt supplies the source rows and physical active
coordinates. Hence covariance contraction and the rank-sized trace bound
are conclusions of the construction, not compression hypotheses.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
open scoped BigOperators RealInnerProductSpace ENNReal
namespace NeuralGeneralization.RobustCompressionActiveBank
open RobustGaussianGeometry RobustCompressionLayerParameters RobustCompressionSourceBank
open RobustCompressionLayerComparison RobustCompressionLayerGaussian RobustCoupling

variable {A X : Type*} [MeasurableSpace A] {N m q : ℕ}

/-- The data used by the finite reconstruction, from actual selected vectors
and actual current Gaussian rows. -/
def activeBankData (b : A → Fin q → EuclideanSpace ℝ (Fin N))
    (rows : A → Fin N → EuclideanSpace ℝ (Fin N))
    (I : A → Fin m → Fin N) (h : A → X → Fin N → ℝ) (t : ℝ)
    (hb : Measurable b) (hrows : Measurable rows) (hI : Measurable I) (hh : Measurable h) :
    BankLayerData A X N m q where
  source := fun θ => sourceRows (b θ)
  active := fun θ i => t • toLp 2 (evaluations (gramSchmidtNormed ℝ (b θ)) (rows θ i))
  indices := I
  feature := h
  source_measurable := measurable_sourceRows.comp hb
  active_measurable := by
    apply measurable_pi_lambda
    intro i
    exact (((WithLp.measurable_toLp 2 (Fin q → ℝ)).comp
      (measurable_active_coordinates.comp (hb.prodMk ((measurable_pi_apply i).comp hrows)))).const_smul t)
  indices_measurable := hI
  feature_measurable := hh

theorem activeBankData_source_quadratic (b : A → Fin q → EuclideanSpace ℝ (Fin N))
    (rows : A → Fin N → EuclideanSpace ℝ (Fin N))
    (I : A → Fin m → Fin N) (h : A → X → Fin N → ℝ) (t : ℝ)
    (hb : Measurable b) (hrows : Measurable rows) (hI : Measurable I) (hh : Measurable h)
    (hN : 0 < N) (θ : A) (v : EuclideanSpace ℝ (Fin q)) :
    (∑ i, ⟪(activeBankData b rows I h t hb hrows hI hh).source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2 :=
  sourceRows_quadratic_le (b θ) hN v

theorem activeBankData_source_trace (b : A → Fin q → EuclideanSpace ℝ (Fin N))
    (rows : A → Fin N → EuclideanSpace ℝ (Fin N))
    (I : A → Fin m → Fin N) (h : A → X → Fin N → ℝ) (t : ℝ)
    (hb : Measurable b) (hrows : Measurable rows) (hI : Measurable I) (hh : Measurable h)
    (hN : 0 < N) (θ : A) :
    (∑ i, ‖(activeBankData b rows I h t hb hrows hI hh).source θ i‖^2)/(N : ℝ) ≤ q :=
  sourceRows_trace_le (b θ) hN

/-- For an actual active family, every term in the full layer bound is
specified explicitly by the source cutoff and empirical-bank tolerance. -/
theorem activeBankData_total_cost [NeZero N] [NeZero m]
    (b : A → Fin q → EuclideanSpace ℝ (Fin N))
    (rows : A → Fin N → EuclideanSpace ℝ (Fin N))
    (I : A → Fin m → Fin N) (h : A → X → Fin N → ℝ)
    (hb : Measurable b) (hrows : Measurable rows) (hI : Measurable I) (hh : Measurable h)
    {a t T BH BG : ℝ} (ha : 0 ≤ a) (ht : |t| ≤ 1) (hT : 0 < T)
    (hBH : 0 < BH) (hBG : 0 < BG)
    (hbounded : ∀ θ x i, |h θ x i| ≤ 1)
    (hgood : ∀ θ, sourceBankGood (sourceRows (b θ)) (h θ) a T (I θ))
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (x : X) (θ : A) :
    let data := activeBankData b rows I h t hb hrows hI hh
    let p := data.parameters a t T BH x
    (∫⁻ z : LayerDraw N m, ENNReal.ofReal (∑ i,
      (φ (⟪data.active θ i,data.idealFeature x θ⟫ +
          Real.sqrt (p.idealVariance θ i : ℝ)*z.1.1 i) -
        φ (p.clippedFiniteObservable BG (θ,z.2) i))^2) ∂layerJointKernel P p θ) ≤
      4 * (ENNReal.ofReal ((4/BH^2)*∑ i, ‖data.active θ i‖^2) +
        (∫⁻ z, ENNReal.ofReal (∑ i,
          (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
          ∂finiteCouplingKernel (gaussianReal 0 1) N P θ) +
        ENNReal.ofReal ((N : ℝ)*(BH^2*((q : ℝ)/T+2*a)^2 +
          t^2*(a+2*((q : ℝ)/T+2*a)))) +
        ENNReal.ofReal (64*(N : ℝ)*m/BG^2)) := by
  dsimp only
  let data := activeBankData b rows I h t hb hrows hI hh
  have hquad : ∀ θ v, (∑ i, ⟪data.source θ i,v⟫^2)/(N : ℝ) ≤ ‖v‖^2 :=
    fun θ v => sourceRows_quadratic_le (b θ) (NeZero.pos N) v
  have htrace : ∀ θ, (∑ i, ‖data.source θ i‖^2)/(N : ℝ) ≤ q :=
    fun θ => sourceRows_trace_le (b θ) (NeZero.pos N)
  have hp := data.parameters_contractive (t := t) (BH := BH) ha x hquad hgood
  have he := data.parameters_error_bounds (t := t) ha hT hBH.le x θ (hbounded θ)
    (hquad θ) (htrace θ) (hgood θ)
  exact layerJointKernel_total_cost P (data.parameters a t T BH x) hp θ φ hφ hφbound
    (data.active θ) (data.idealFeature x θ) hBH hBG (fun _ => rfl)
    (fun j => hbounded θ x (I θ j)) ht (NeZero.pos m) he.1 he.2

end NeuralGeneralization.RobustCompressionActiveBank
