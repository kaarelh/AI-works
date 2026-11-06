import NeuralGeneralization.DepthNormBallBudget
import NeuralGeneralization.Cloning
import NeuralGeneralization.NormBallPacking

/-! Growing-depth norm-ball lower bound, with actual witnesses and the literal counting consequence. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.DepthNormBall
open Classical ConcreteModel

/-- The universal constant is explicit; all larger widths preserve exact labels. -/
theorem exists_exact_network {q d m N : ℕ} (hq : 0 < q) (hm : 0 < m)
    (e : Fin q ↪ Fin d) (hN : 2^(q+1) ≤ N) (f : BooleanFunction q) :
    ∃ w : Weights d N (m+1),
      (∀ x, networkOutput Real.tanh w x=labelReal (f (x ∘ e))) ∧
      ConcreteModel.weightedSquaredNorm w ≤
        200*((d:ℝ)*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2+
          ((m:ℝ)+1)*(2:ℝ)^(2*(q:ℝ)/(m+1))) := by
  obtain ⟨v,hv,hinterp⟩ := exists_cube_coefficients hq f
  let w := liftInput e (weights m v (population q m) (amplitude q m))
  have hC : width q ≤ N := by simpa only [width_eq] using hN
  obtain ⟨W,hW,hcost⟩ := exists_clone_at_every_width (width_pos q) hC Real.tanh w
  refine ⟨W,?_,?_⟩
  · intro x
    rw [hW,liftInput_networkOutput]
    apply networkOutput_eq m v _ _ f hinterp (population_zero q m)
      (fun j hj => ⟨population_pos q m j,population_le q hm hj⟩)
    intro j hj
    exact ⟨amplitude_pos q m j,lt_of_le_of_lt (amplitude_le q hm hj) (by norm_num)⟩
  · have h := constructed_energy_bound hq hm e v hv
    change ConcreteModel.weightedSquaredNorm w ≤ _ at h
    linarith

/-- The proposition's literal depth `L`, input coordinates, width range and norm budget. -/
theorem paper_network {q d L N : ℕ} (hq : 0 < q) (hL : 4 ≤ L)
    (e : Fin q ↪ Fin d) (hN : 2^(q+1) ≤ N) (f : BooleanFunction q) :
    ∃ w : Weights d N (L-2),
      (∀ x, networkOutput Real.tanh w x=labelReal (f (x ∘ e))) ∧
      ConcreteModel.weightedSquaredNorm w ≤
        200*((d:ℝ)*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2+
          ((L:ℝ)-2)*(2:ℝ)^(2*(q:ℝ)/(L-2))) := by
  obtain ⟨m, rfl⟩ : ∃ m : ℕ, L=m+3 := ⟨L-3,by omega⟩
  have hm : 0 < m := by omega
  have hh := exists_exact_network hq hm e hN f
  have he : ((m:ℝ)+3)-2=(m:ℝ)+1 := by ring
  change ∃ w : Weights d N (m+1), _
  simpa only [Nat.cast_add,Nat.cast_ofNat,he] using hh

lemma restrict_injective {q d : ℕ} (e : Fin q ↪ Fin d) :
    Function.Injective (fun f : BooleanFunction q => (fun x : Cube d => f (x ∘ e))) := by
  intro f g h
  funext a
  let x : Cube d := Function.extend e a (fun _ => false)
  have hx : x ∘ e=a := Function.extend_comp e.injective a _
  simpa only [hx] using congrFun h x

lemma exact_network_mem_normBall {d N r : ℕ} (w : Weights d N r)
    (f : BooleanFunction d) (hw : ∀ x, networkOutput Real.tanh w x=labelReal (f x))
    {K : ℝ} (hK : weightedSquaredNorm w ≤ K) :
    f ∈ ParameterSensitivity.normBallFunctions d N r Real.tanh (Real.sqrt K) := by
  have hK0 : 0 ≤ K := (weightedSquaredNorm_nonneg w).trans hK
  have hm : w ∈ marginEvent Real.tanh (1/2) f := by
    intro x
    rw [hw]
    cases f x <;> norm_num [labelReal]
  apply Finset.mem_filter.mpr
  refine ⟨Finset.mem_univ _,⟨w,hm⟩,?_⟩
  rw [Real.sq_sqrt hK0]
  have h := networkEnergy_le_of_mem Real.tanh (1/2) f w hm
  linarith

/-- There are at least `2^(2^q)` functions in the actual network norm ball. -/
theorem paper_norm_ball_card {q d L N : ℕ} (hq : 0 < q) (hL : 4 ≤ L)
    (e : Fin q ↪ Fin d) (hN : 2^(q+1) ≤ N) {K : ℝ}
    (hK : 200*((d:ℝ)*(q:ℝ)^2*(Real.log (2*(q:ℝ)))^2+
      ((L:ℝ)-2)*(2:ℝ)^(2*(q:ℝ)/(L-2))) ≤ K) :
    2^(2^q) ≤ (ParameterSensitivity.normBallFunctions d N (L-2) Real.tanh (Real.sqrt K)).card := by
  let E : BooleanFunction q → BooleanFunction d := fun f x => f (x ∘ e)
  have hmem (f : BooleanFunction q) :
      E f ∈ ParameterSensitivity.normBallFunctions d N (L-2) Real.tanh (Real.sqrt K) := by
    obtain ⟨w,hw,hcost⟩ := paper_network hq hL e hN f
    exact exact_network_mem_normBall w (E f) hw (hcost.trans hK)
  have hsub : Finset.univ.image E ⊆ ParameterSensitivity.normBallFunctions d N (L-2) Real.tanh (Real.sqrt K) := by
    intro g hg
    obtain ⟨f,_,rfl⟩ := Finset.mem_image.mp hg
    exact hmem f
  have hcard := Finset.card_le_card hsub
  rw [Finset.card_image_of_injective _ (restrict_injective e)] at hcard
  simpa [BooleanFunction,Cube] using hcard

/-- The paper's `q=d`, `L=d+2` example, with an explicit universal constant. -/
theorem all_functions_linear_depth {d N : ℕ} (hd : 2 ≤ d) (hN : 2^(d+1) ≤ N)
    (f : BooleanFunction d) :
    ∃ w : Weights d N d, (∀ x, networkOutput Real.tanh w x=labelReal (f x)) ∧
      weightedSquaredNorm w ≤ 200*((d:ℝ)^3*(Real.log (2*(d:ℝ)))^2+4*d) := by
  obtain ⟨m, rfl⟩ : ∃ m : ℕ, d=m+1 := ⟨d-1,by omega⟩
  have hm : 0 < m := by omega
  have hdR : ((m+1:ℕ):ℝ)≠0 := by positivity
  have he : 2*((m+1:ℕ):ℝ)/((m:ℝ)+1)=(2:ℝ) := by push_cast; field_simp
  obtain ⟨w,hw,hcost⟩ := exists_exact_network (q := m+1) (d := m+1) (m := m)
    (by omega) hm (Function.Embedding.refl _) hN f
  refine ⟨w,?_,?_⟩
  · intro x
    simpa only [Function.Embedding.refl_apply,Function.comp_def] using hw x
  · rw [he,Real.rpow_two] at hcost
    convert hcost using 1 <;> push_cast <;> ring

/-- At linear depth the bounded-norm class contains every Boolean function. -/
theorem all_functions_card {d N : ℕ} (hd : 2 ≤ d) (hN : 2^(d+1) ≤ N) :
    (ParameterSensitivity.normBallFunctions d N d Real.tanh
      (Real.sqrt (200*((d:ℝ)^3*(Real.log (2*(d:ℝ)))^2+4*d)))).card=2^(2^d) := by
  have he : ParameterSensitivity.normBallFunctions d N d Real.tanh
      (Real.sqrt (200*((d:ℝ)^3*(Real.log (2*(d:ℝ)))^2+4*d)))=Finset.univ := by
    apply Finset.eq_univ_of_forall
    intro f
    obtain ⟨w,hw,hcost⟩ := all_functions_linear_depth hd hN f
    exact exact_network_mem_normBall w f hw hcost
  rw [he]
  simp [BooleanFunction,Cube]

end NeuralGeneralization.DepthNormBall
