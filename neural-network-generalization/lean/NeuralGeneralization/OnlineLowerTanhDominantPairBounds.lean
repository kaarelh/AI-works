import NeuralGeneralization.OnlineLowerTanhWalshPairMass

/-! Quantitative dominant-pair estimates for the actual optimized tanh cost. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel OnlineLowerGeometry

/-- The distinguished two-increment coefficient has a quantitative positive
lower bound, while all other positive high-order coefficients together are
bounded by old increment mass times total increment mass. -/
theorem optimized_increment_dominant_pair_bounds (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀d:ℕ,∀δ:Fin d→ℝ,(∀i,0<δ i) → ∀n:ℝ,
      S*(d+1:ℕ)≤n → ∀i j:Fin d,i≠j →
      optimizedCostCurvature*(δ i*δ j)/(4*(n+∑t,δ t)^3)≤
        walshCoefficients (incrementScore δ (optimizedRealCost b) n) {i,j} ∧
      (∑T:Finset (Fin d),if 2≤T.card ∧ T≠({i,j}:Finset (Fin d))
        then walshCoefficients (incrementScore δ (optimizedRealCost b) n) T else 0)≤
        (3*optimizedCostCurvature/(4*n^3))*
          ((∑t∈({i,j}:Finset (Fin d))ᶜ,δ t)*(∑t,δ t)) := by
  obtain ⟨S₁,hS₁,hcoeff⟩:=optimized_increment_walsh_bounds b
  obtain ⟨S₂,hS₂,hmixed⟩:=optimizedRealCost_mixed_differences b
  refine ⟨max S₁ S₂,lt_max_of_lt_left hS₁,?_⟩
  intro d δ hδ n hn i j hij
  have hn₁:S₁*(d+1:ℕ)≤n:=(mul_le_mul_of_nonneg_right (le_max_left S₁ S₂) (Nat.cast_nonneg _)).trans hn
  have hn₂:S₂*(d+1:ℕ)≤n:=(mul_le_mul_of_nonneg_right (le_max_right S₁ S₂) (Nat.cast_nonneg _)).trans hn
  have hn0:0<n:=lt_of_lt_of_le (mul_pos hS₁ (by positivity)) hn₁
  have hpair:({i,j}:Finset (Fin d)).card=2:=by simp [hij]
  have hd:2≤d:=by
    have hh:=Finset.card_le_univ ({i,j}:Finset (Fin d))
    simpa only [hpair,Fintype.card_fin] using hh
  have hc:=hcoeff d δ hδ n hn₁ {i,j} (by omega)
  constructor
  · have hh:=hc.1
    simp only [hpair,Finset.prod_pair hij,Nat.factorial_two,Nat.cast_ofNat,
      show (2:ℕ)+1=3 from rfl] at hh
    convert hh using 1 <;> field_simp <;> ring
  · have hpositive:∀T:Finset (Fin d),2≤T.card →
        0≤walshCoefficients (incrementScore δ (optimizedRealCost b) n) T:=by
      intro T hT
      have hh:=(hcoeff d δ hδ n hn₁ T hT).1
      have hprod:0≤∏i∈T,δ i:=Finset.prod_nonneg (fun t _=>(hδ t).le)
      have hsum:0≤∑i,δ i:=Finset.sum_nonneg (fun t _=>(hδ t).le)
      exact (by positivity [optimizedCostCurvature_pos] :
        0≤((∏i∈T,δ i)*((optimizedCostCurvature/2)*(T.card.factorial:ℝ)/
          (n+∑i,δ i)^(T.card+1)))/(2:ℝ)^T.card).trans hh
    apply noncentral_mass_le_weighted_pair_budget _ i j hpositive δ (fun t=>(hδ t).le)
      (3*optimizedCostCurvature/(4*n^3)) (by positivity [optimizedCostCurvature_pos])
    intro a ha c hca
    rw [increment_walsh_pair_tail_mixed δ (optimizedRealCost b) n a c hca.symm]
    have hsteps:∀h∈[δ a,δ c],0<h:=by simp only [List.mem_cons,List.not_mem_nil,or_false];intro h hh;rcases hh with rfl|rfl;exact hδ a;exact hδ c
    have hb:S₂*([δ a,δ c].length+1:ℕ)≤n:=by
      have hdR:(3:ℝ)≤(d+1:ℕ):=by exact_mod_cast (show 3≤d+1 by omega)
      have hh:=mul_le_mul_of_nonneg_left hdR hS₂.le
      norm_num only [List.length_cons,List.length_nil] at *
      linarith
    have hh:=((hmixed [δ a,δ c] hsteps (by simp)).1 n hb).2.2
    norm_num only [List.length_cons,List.length_nil,List.prod_cons,List.prod_nil,
      mul_one,Nat.factorial_two,Nat.cast_ofNat] at hh
    have hh':mixedBackwardDifference [δ a,δ c] (optimizedRealCost b) n≤
        3*optimizedCostCurvature*(δ a*δ c)/n^3:=by convert hh using 1 <;> field_simp <;> ring
    have hdv:=div_le_div_of_nonneg_right hh' (by norm_num : (0:ℝ)≤4)
    calc
      _ ≤ (3*optimizedCostCurvature*(δ a*δ c)/n^3)/4 := hdv
      _ = _ := by field_simp

end NeuralGeneralization.OnlineLowerTanh
