import NeuralGeneralization.CylinderContainment
import NeuralGeneralization.NetworkCylinderProbability

/-!
# Actual all-width Gaussian target mass

A strengthened-margin cloned teacher, a basis adapted to its hidden states,
and one free-matrix norm event give an explicit lower bound for the actual
network prior. No cylinder probability, orthogonal independence, or margin
stability estimate is assumed here: each is instantiated from checked lemmas.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.ConcreteModel
variable {d N r : ℕ}

/-- Quantitative target mass from any supported teacher in the actual architecture.
This intermediate statement exposes its deterministic geometric data. -/
theorem smallPrior_supported_target_mass (hd : 0 < d) (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (v : Weights d N r)
    (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
    (J : Finset (Fin N)) (K G σ : ℝ)
    (hK : 0 ≤ K) (hG : 0 ≤ G) (hσ : 0 < σ)
    (hscale : (N:ℝ)*σ^2 ≤ 1) (hJ : (J.card:ℝ) ≤ G)
    (hmargin : v ∈ marginEvent φ (3/2) f) (hcost : weightedSquaredNorm v ≤ K)
    (hrows : ∀ s i j, j ∉ J →
      basisCoordinates b (fun a => v (Sum.inr (Sum.inl (s,i,a)))) j = 0)
    (hhidden : ∀ (x : Cube d) (ss : List (Fin r)) j, j ∉ J →
      basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j = 0) :
    let ρ := cylinderRadius d r K G (16*((r:ℝ)+1))
    Real.exp (-K/σ^2 - (N:ℝ)*((d:ℝ)+2+(r:ℝ)*G)*
      (ρ^2+Real.sqrt (2*Real.pi)/(2*ρ)) - 1) ≤
      functionMass φ (1/2) (smallPrior d N r σ) f := by
  classical
  let B : ℝ := 16*((r:ℝ)+1)
  let ρ := cylinderRadius d r K G B
  have hρ : 0 < ρ := cylinderRadius_pos d r hK hG
  let a : {q : WeightIndex d N r // constrainedIndex J q} → ℝ :=
    fun q => rotateInternalRows b.repr (whiten v) q.val
  let T : Set (Weights d N r) :=
    orthogonalWhiten (internalRowIsometry b.repr) ⁻¹'
      ((MeasurableEquiv.piEquivPiSubtypeProd
        (fun _ : WeightIndex d N r => ℝ) (constrainedIndex J)) ⁻¹'
        ((Set.pi Set.univ fun q => Set.Icc (a q-ρ*σ) (a q+ρ*σ)) ×ˢ
          freeCoordinateEvent J B))
  have hsub : T ⊆ marginEvent φ (1/2) f := by
    intro w hw
    apply margin_of_rotated_coordinate_cylinder hd hN φ hφ f w v b J K G B σ
      hK hG (by dsimp [B]; positivity) hσ.le hscale hJ hmargin hcost hrows hhidden
    · intro q hq
      have hq' := hw.1 (⟨q,hq⟩ : {q : WeightIndex d N r // constrainedIndex J q})
        (Set.mem_univ _)
      change a ⟨q,hq⟩-ρ*σ ≤ rotateInternalRows b.repr (whiten w) q ∧
        rotateInternalRows b.repr (whiten w) q ≤ a ⟨q,hq⟩+ρ*σ at hq'
      apply abs_le.mpr
      dsimp [a] at hq'
      constructor <;> linarith [hq'.1,hq'.2]
    · exact hw.2
  have hfree := freeCoordinateEvent_real_ge_half (d := d) (r := r) hN J hσ hscale
  have hmass := smallPrior_selected_cylinder_exp_lower hd hN hσ hρ
    (internalRowIsometry b.repr) (constrainedIndex J) a (freeCoordinateEvent J B) hfree
  have htarget : (smallPrior d N r σ).real T ≤
      functionMass φ (1/2) (smallPrior d N r σ) f :=
    measureReal_mono hsub (measure_ne_top _ _)
  have henergy : (∑ q, a q^2) ≤ K :=
    (selected_rotated_center_energy_le hd hN b.repr (constrainedIndex J) v).trans hcost
  have hdim : (Fintype.card {q : WeightIndex d N r // constrainedIndex J q}:ℝ) ≤
      (N:ℝ)*((d:ℝ)+2+(r:ℝ)*G) := by
    rw [card_constrainedIndex]
    push_cast
    apply mul_le_mul_of_nonneg_left _ (Nat.cast_nonneg N)
    linarith [mul_le_mul_of_nonneg_left hJ (Nat.cast_nonneg r)]
  let c := ρ^2+Real.sqrt (2*Real.pi)/(2*ρ)
  have hc : 0 ≤ c := by dsimp [c]; positivity
  have he : -K/σ^2 - (N:ℝ)*((d:ℝ)+2+(r:ℝ)*G)*c ≤
      -(∑ q, a q^2)/σ^2 -
        (Fintype.card {q : WeightIndex d N r // constrainedIndex J q}:ℝ)*c := by
    have h1 := div_le_div_of_nonneg_right henergy (sq_nonneg σ)
    have h2 := mul_le_mul_of_nonneg_right hdim hc
    simp only [neg_div]
    linarith
  have hehalf : Real.exp (-1) ≤ (1:ℝ)/2 := by
    have hh : (2:ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp 1]
    have hi := one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2) hh
    simpa only [one_div, ← Real.exp_neg] using hi
  change Real.exp (-K/σ^2 - (N:ℝ)*((d:ℝ)+2+(r:ℝ)*G)*c - 1) ≤ _
  calc
    _ = Real.exp (-1)*Real.exp (-K/σ^2-(N:ℝ)*((d:ℝ)+2+(r:ℝ)*G)*c) := by
      rw [← Real.exp_add]
      congr 1
      ring
    _ ≤ (1/2)*Real.exp (-(∑ q,a q^2)/σ^2-
        (Fintype.card {q : WeightIndex d N r // constrainedIndex J q}:ℝ)*c) :=
      mul_le_mul hehalf (Real.exp_le_exp.mpr he) (Real.exp_nonneg _) (by norm_num)
    _ ≤ (smallPrior d N r σ).real T := hmass
    _ ≤ _ := htarget

end NeuralGeneralization.ConcreteModel
