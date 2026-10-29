import PhysicalPrefixRepresentativeCover

noncomputable section
set_option maxHeartbeats 2200000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

lemma IndexedActualBallCover.normalized {X E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]
    {u : X→E} {N : ℕ} {r g : ℝ} (hc : IndexedActualBallCover u N r) (hg : 0<g) :
    IndexedActualBallCover (fun x=>g⁻¹ • u x) N (r/g) := by
  obtain ⟨C,hC,hcover⟩ := hc
  refine ⟨C,hC,?_⟩
  intro x
  obtain ⟨y,hy,hxy⟩ := hcover x
  refine ⟨y,hy,?_⟩
  simp only [dist_eq_norm,←smul_sub,norm_smul,Real.norm_eq_abs,abs_inv,abs_of_pos hg]
  simpa only [div_eq_mul_inv,mul_comm,dist_eq_norm] using mul_le_mul_of_nonneg_left hxy (inv_nonneg.mpr hg.le)

lemma IndexedActualBallCover.radius_mono {X E : Type*} [PseudoMetricSpace E]
    {u:X→E} {N:ℕ} {r R:ℝ} (hc:IndexedActualBallCover u N r) (hr:r≤R) :
    IndexedActualBallCover u N R := by
  obtain ⟨C,hC,hcover⟩ := hc
  exact ⟨C,hC,fun x=>by obtain ⟨y,hy,hxy⟩:=hcover x; exact ⟨y,hy,hxy.trans hr⟩⟩

variable {d H : ℕ} {t : ℝ} {f : BooleanFunction d}

 theorem physical_representativeRadius_normalized
    (P : ControlledMarginPath d H t f) (b n : ℕ) (hfit : n*b≤H)
    (ha : 0<(physicalVariance P:ℝ)⁻¹-1)
    (good : ℕ→Prop) [DecidablePred good] {E : ℝ}
    (hE : (∑j∈Finset.range (n*b),physicalAdjustedCost P j)≤E) :
    representativeRadius
      (fun i=>(disjointBlockCost (physicalLayerCost P) 0 b i-
        (b:ℝ)*subcriticalCostBaseline (physicalVariance P))/((physicalVariance P:ℝ)⁻¹-1))
      good (2*Real.sqrt 2) n / physicalGainProduct P (n*b)≤
      2*Real.sqrt 2*Real.exp (E/((physicalVariance P:ℝ)⁻¹-1)-
        (((Finset.range n).filter good).card:ℝ)) := by
  let a := (physicalVariance P:ℝ)⁻¹-1
  let D := disjointBlockCost (physicalLayerCost P) 0 b
  let c := fun _ : ℕ=>(b:ℝ)*subcriticalCostBaseline (physicalVariance P)
  let g := disjointBlockCost (physicalPathLogGain P) 0 b
  let r := representativeRadius (fun i=>(D i-c i)/a) good (2*Real.sqrt 2)
  have hh := normalized_block_gain r D c g good n a ha.ne'
    (fun i hi=>le_rfl)
  have hsumg : (∑i∈Finset.range n,g i)=∑j∈Finset.range (n*b),physicalPathLogGain P j := by
    simpa only [g,Nat.zero_add] using disjoint_block_sum (physicalPathLogGain P) 0 b n
  have hid (i:ℕ) : D i-c i-a*g i=disjointBlockCost (physicalGaussianRemainder P) 0 b i := by
    simp only [D,c,g,disjointBlockCost,physicalGaussianRemainder,Finset.sum_sub_distrib,
      ←Finset.mul_sum,Finset.sum_const,Finset.card_range,nsmul_eq_mul]
    rfl
  have hsum : (∑i∈Finset.range n,(D i-c i-a*g i))≤E := by
    simp_rw [hid]
    rw [disjoint_block_sum]
    simp only [Nat.zero_add]
    apply le_trans (Finset.sum_le_sum ?_) hE
    intro j hj
    exact (physicalGaussianRemainder_bounds P j (by have:=Finset.mem_range.mp hj;omega)).2
  rw [hsumg,←physicalGainProduct_exp] at hh
  have hm := Real.exp_le_exp.mpr (sub_le_sub_right (div_le_div_of_nonneg_right hsum ha.le) (((Finset.range n).filter good).card:ℝ))
  have hf := hh.trans (mul_le_mul_of_nonneg_left hm (by positivity : 0≤2*Real.sqrt 2))
  exact hf

#print axioms physical_representativeRadius_normalized
end ConditionalNonpolynomial.Analytic
