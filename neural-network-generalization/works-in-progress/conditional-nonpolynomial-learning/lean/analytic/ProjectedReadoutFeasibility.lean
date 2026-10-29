import NetworkReadoutCost

noncomputable section
open MeasureTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.TowerNetwork
open NeuralGeneralization.RobustGaussianGeometry

lemma activeProjection_preserves_values {m N : ℕ}
    (f : Fin m→EuclideanSpace ℝ (Fin N)) (g : Fin N→ℝ) (i : Fin m) :
    (∑j,activeProjection f (WithLp.toLp 2 g) j*f i j) = ∑j,g j*f i j := by
  have hi := (Submodule.span ℝ (Set.range f)).starProjection_inner_eq_zero
    (WithLp.toLp 2 g) (f i) (Submodule.subset_span (Set.mem_range_self i))
  rw [inner_sub_left,sub_eq_zero] at hi
  rw [activeProjection_eq_starProjection]
  simpa [PiLp.inner_apply, mul_comm] using hi.symm

/-- The minimal active-span readout as an actual vector of physical weights. -/
def projectedReadout {d N r : ℕ} (σ : ℝ) (w : Weights d N r) (i : Fin N) : ℝ :=
  (σ/Real.sqrt N)*activeProjection (cubeHiddenFamily w)
    (WithLp.toLp 2 (readoutStandardize σ (fun j=>w (.inr (.inr j))))) i

/-- Projection preserves every network output on the full Boolean cube. -/
theorem projectedReadout_preserves_output {d N r : ℕ} (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (w : Weights d N r) (x : Cube d) :
    networkOutput Real.tanh (withReadout w (projectedReadout σ w)) x=
      networkOutput Real.tanh w x := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hr : Real.sqrt N≠0 := (Real.sqrt_pos.mpr hn).ne'
  have hproj := activeProjection_preserves_values (cubeHiddenFamily w)
    (readoutStandardize σ (fun j=>w (.inr (.inr j)))) (Fintype.equivFin (Cube d) x)
  simp only [cubeHiddenFamily,Equiv.symm_apply_apply,WithLp.ofLp_toLp] at hproj
  simp only [networkOutput,withReadout,finalHidden_withReadout,projectedReadout]
  rw [show (∑ i,(σ/Real.sqrt N)*activeProjection (cubeHiddenFamily w)
      (WithLp.toLp 2 (readoutStandardize σ (fun j=>w (.inr (.inr j))))) i*
        finalHidden Real.tanh w x i) =
      (σ/Real.sqrt N)*(∑ i,activeProjection (cubeHiddenFamily w)
      (WithLp.toLp 2 (readoutStandardize σ (fun j=>w (.inr (.inr j))))) i*
        finalHidden Real.tanh w x i) by rw [Finset.mul_sum]; apply Finset.sum_congr rfl; intros; ring]
  rw [hproj,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  unfold readoutStandardize
  field_simp [hr,hσ.ne']

/-- The projected norm in the MGF is the physical energy of this feasible
readout, after exactly the Gaussian whitening factor. -/
theorem projectedReadout_norm {d N r : ℕ} (hN : 0<N) (σ : ℝ) (w : Weights d N r) :
    (∑i,projectedReadout σ w i^2)=σ^2/N*projectedReadoutSquared σ w := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  simp only [projectedReadout,mul_pow,←Finset.mul_sum,div_pow,Real.sq_sqrt hn.le]
  congr 1
  unfold projectedReadoutSquared
  rw [PiLp.norm_sq_eq_of_L2]
  simp only [Real.norm_eq_abs,sq_abs]

#print axioms projectedReadout_preserves_output
#print axioms projectedReadout_norm
end ConditionalNonpolynomial.Analytic
