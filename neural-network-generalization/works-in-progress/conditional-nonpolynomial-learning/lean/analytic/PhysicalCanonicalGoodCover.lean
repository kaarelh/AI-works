import PhysicalCanonicalBlockBounds
import IndexedBlockCover

/-! Actual good-block representative covers. The cardinality depends only on
the fixed Gaussian block budget and target contraction, not on width, depth,
physical scale, or the number of Boolean inputs. -/
noncomputable section
set_option maxHeartbeats 2200000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open BooleanDepthResearch
variable {I : ℕ→Type*} [∀j,Fintype (I j)] [∀j,DecidableEq (I j)]
variable {K X : Type*} [Fintype K] [Nonempty X]
variable {anchors : ∀j,K→EuclideanSpace ℝ (I j)} {D : ℕ→ℝ} {H : ℕ}

theorem actual_physical_good_block_cover
    {E B : ℝ} (hB : 0<B) (T k : ℕ) (hT : 0<T)
    (hgridSize : (canonicalBlockHSBound E)^2≤(B/64)^2*k)
    (hgridError : ∀Q:ℝ,0≤Q→Q≤(canonicalBlockHSBound E)^2→
      Real.sqrt (Q/(T:ℝ)^2+(B/64)^2)≤B/32)
    (M : ∀j,j<H→CanonicalLayerModel (J:=I (j+1)) (anchors j) (D j))
    {t : ℝ} (ht : 0<t) (ht1 : t≤1) (hH : 1≤H)
    (u : ∀j,X→EuclideanSpace ℝ (I j)) (radius : ℕ→ℝ)
    (hr : ∀j<H,0<radius j) (hu : ∀j<H,∀x,‖u j x‖≤radius j)
    (hrec : ∀j (hj:j<H),∀x,u (j+1) x=(M j hj).value (t • u j x))
    (hcost : (H:ℝ)*(∑j∈Finset.range H,finiteGaussianCost M j)≤E)
    (hfree : t^H≤B/32)
    (hnonlinear : (∑j∈Finset.range H,((radius j)^2+Real.sqrt (finiteNongaussianCost M j)))≤
      B/(16*canonicalBlockNonlinearBound E))
    (S : Set X) (z : EuclideanSpace ℝ (I 0)) {r : ℝ} (hrpos : 0<r)
    (hS : ∀x∈S,dist (u 0 x) z≤r) :
    ∃Y:Finset X,(↑Y:Set X)⊆S ∧Y.card≤(2*T+1)^k ∧
      ∀x∈S,∃y∈Y,dist (u H x) (u H y)≤B*r/2 := by
  obtain ⟨⟨U,hpolar⟩,hgain,hres⟩ := actual_physical_canonical_block M ht ht1 u radius hr hu hrec
  let L := hsLinearChain (finitePhysicalLinear M t) H
  let F := t^H • U.toLinearMap
  let A := L-F
  have hFA : F+A=L := by dsimp [A]; abel
  have hsqrt : Real.sqrt (2*H*(∑j∈Finset.range H,finiteGaussianCost M j))≤Real.sqrt (2*E) :=
    Real.sqrt_le_sqrt (by nlinarith only [hcost])
  have hnorm : frobeniusNorm A≤canonicalBlockHSBound E := by
    exact hpolar.trans (mul_le_mul (Real.exp_le_exp.mpr hsqrt) hsqrt
      (Real.sqrt_nonneg _) (Real.exp_pos _).le)
  have hsq : frobeniusSq A≤(canonicalBlockHSBound E)^2 := by
    have hh := pow_le_pow_left₀ (frobeniusNorm_nonneg A) hnorm 2
    rwa [frobeniusNorm_sq] at hh
  apply indexed_canonical_good_block_cover S (u 0) (u H) z r B (t^H) (B/64) T k F A
    hrpos hB.le (pow_nonneg ht.le _) (by positivity) hT hS
  · intro x
    simp only [F,LinearMap.smul_apply,norm_smul,Real.norm_eq_abs,abs_of_nonneg (pow_nonneg ht.le _),
      LinearIsometry.coe_toLinearMap,U.norm_map]
    exact le_rfl
  · exact hsq.trans hgridSize
  · have hh := hgridError (frobeniusSq A) (frobeniusSq_nonneg _) hsq
    linarith
  · intro x hx y hy
    rw [hFA]
    simp only [dist_eq_norm]
    have hb := finitePhysicalBlock_nonlinearity_le M ht.le ht1 hH radius hcost
    have hC := canonicalBlockNonlinearBound_pos E
    have htotal : (∏j∈Finset.range H,finitePhysicalGain M t j)*
        (∑j∈Finset.range H,finitePhysicalNonlinearity M t radius j)≤B/16 := by
      apply hb.trans
      calc
        _ ≤ canonicalBlockNonlinearBound E*(B/(16*canonicalBlockNonlinearBound E)) :=
          mul_le_mul_of_nonneg_left hnonlinear hC.le
        _ = B/16 := by field_simp
    exact (hres x y).trans (mul_le_mul_of_nonneg_right htotal (norm_nonneg _))

/-- The grid parameters can be chosen once for each fixed block budget and
contraction target. -/
theorem physical_good_block_grid_exists (E B : ℝ) (hB : 0<B) :
    ∃T k:ℕ,0<T ∧(canonicalBlockHSBound E)^2≤(B/64)^2*k ∧
      ∀Q:ℝ,0≤Q→Q≤(canonicalBlockHSBound E)^2→
        Real.sqrt (Q/(T:ℝ)^2+(B/64)^2)≤B/32 :=
  exists_block_cover_parameters (canonicalBlockHSBound E) B (by unfold canonicalBlockHSBound; positivity) hB

#print axioms actual_physical_good_block_cover
end ConditionalNonpolynomial.Analytic
