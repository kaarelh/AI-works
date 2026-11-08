import NeuralGeneralization.OnlineLowerTanhCostDifferences
import NeuralGeneralization.OnlineLowerTanhCodeSupport
import NeuralGeneralization.OnlineLowerCostFourier

/-! Actual independent increment-cube Walsh coefficients as mixed differences. -/
noncomputable section
open scoped BigOperators Topology Classical
namespace NeuralGeneralization.OnlineLowerTanh
open ConcreteModel

def incrementLinear {d:ℕ} (δ:Fin d→ℝ) (x:Cube d) : ℝ :=
  ∑i,δ i*(if x i then 0 else 1)
def incrementScore {d:ℕ} (δ:Fin d→ℝ) (f:ℝ→ℝ) (n:ℝ) (x:Cube d) : ℝ :=
  f (n+incrementLinear δ x)

lemma incrementLinear_cons {d:ℕ} (δ:Fin (d+1)→ℝ) (b:Bool) (x:Cube d) :
    incrementLinear δ (Fin.cons b x)=δ 0*(if b then 0 else 1)+
      incrementLinear (fun i=>δ i.succ) x := by
  unfold incrementLinear
  rw [Fin.sum_univ_succ]
  simp

lemma paritySign_cons {d:ℕ} (b:Bool) (x:Cube d) :
    paritySign (Fin.cons b x)=labelReal b*paritySign x := by
  unfold paritySign
  rw [Fin.prod_univ_succ]
  simp

/-- The unnormalized full-parity sum is exactly a backward mixed difference. -/
theorem increment_full_walsh (d:ℕ) (δ:Fin d→ℝ) (f:ℝ→ℝ) (n:ℝ) :
    (∑x:Cube d,paritySign x*incrementScore δ f n x)=
      mixedBackwardDifference (List.ofFn δ) f n := by
  induction d generalizing n with
  | zero => simp [paritySign,incrementScore,incrementLinear,mixedBackwardDifference,ConcreteModel.Cube]
  | succ d ih =>
    rw [OnlineLower.sum_bool_tuple_succ]
    simp only [incrementScore,incrementLinear_cons,paritySign_cons,labelReal,
      Bool.false_eq_true,↓reduceIte,neg_one_mul,one_mul,mul_one,mul_zero,zero_add]
    rw [List.ofFn_succ,mixedBackwardDifference]
    have hfalse:(∑x:Cube d,-paritySign x*f (n+(δ 0+incrementLinear (fun i=>δ i.succ) x)))=
        -(∑x:Cube d,paritySign x*incrementScore (fun i=>δ i.succ) f (n+δ 0) x):=by
      simp only [incrementScore,neg_mul,Finset.sum_neg_distrib,add_assoc]
    rw [hfalse,ih]
    have ht:=ih (fun i=>δ i.succ) n
    change (∑x:Cube d,paritySign x*f (n+incrementLinear (fun i=>δ i.succ) x))=_ at ht
    rw [ht]
    ring

lemma incrementLinear_partition {d:ℕ} (S:Finset (Fin d)) (δ:Fin d→ℝ) (x:Cube d) :
    incrementLinear δ x=incrementLinear (subsetWeights Sᶜ δ) (subsetInputs Sᶜ x)+
      incrementLinear (subsetWeights S δ) (subsetInputs S x) := by
  unfold incrementLinear subsetWeights subsetInputs
  rw [subset_sum_reindex Sᶜ (fun i=>δ i*(if x i then 0 else 1)),
    subset_sum_reindex S (fun i=>δ i*(if x i then 0 else 1))]
  exact (Finset.sum_add_sum_compl S (fun i=>δ i*(if x i then 0 else 1))).symm.trans (add_comm _ _)

/-- Arbitrary selected Fourier coefficients are averages of actual selected
mixed differences, with the other increments left as ordinary positive shifts. -/
theorem increment_walsh_eq_difference_average {d:ℕ} (S:Finset (Fin d))
    (δ:Fin d→ℝ) (f:ℝ→ℝ) (n:ℝ) :
    walshCoefficients (incrementScore δ f n) S=
      (∑y:Cube Sᶜ.card,mixedBackwardDifference (List.ofFn (subsetWeights S δ)) f
        (n+incrementLinear (subsetWeights Sᶜ δ) y))/(Fintype.card (Cube d):ℝ) := by
  unfold walshCoefficients uniformCubeMean
  rw [←(subsetCubeEquiv S).symm.sum_comp]
  rw [Fintype.sum_prod_type]
  congr 1
  apply Finset.sum_congr rfl
  intro y _
  rw [←increment_full_walsh S.card]
  apply Finset.sum_congr rfl
  intro z _
  let x:Cube d:=(subsetCubeEquiv S).symm (y,z)
  have hsub:(subsetInputs Sᶜ x,subsetInputs S x)=(y,z):=
    (subsetCubeEquiv S).apply_symm_apply (y,z)
  have h1:=congrArg Prod.fst hsub
  have h2:=congrArg Prod.snd hsub
  dsimp only at h1 h2
  have hp:=paritySign_subsetInputs S x
  change incrementScore δ f n x*walshCharacter S x=
    paritySign z*incrementScore (subsetWeights S δ) f
      (n+incrementLinear (subsetWeights Sᶜ δ) y) z
  rw [←hp,h2]
  unfold incrementScore
  rw [incrementLinear_partition S δ x,h1,h2]
  rw [add_assoc,mul_comm]

lemma incrementLinear_nonneg {d:ℕ} (δ:Fin d→ℝ) (hδ:∀i,0≤δ i) (x:Cube d) :
    0 ≤ incrementLinear δ x := by
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hδ i) (by split_ifs <;> norm_num)

/-- All selected orders at least two have strictly positive actual coefficients;
the degree threshold grows only linearly with the full increment count. -/
theorem optimized_increment_walsh_positive (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀d:ℕ,∀δ:Fin d→ℝ,(∀i,0<δ i) → ∀n:ℝ,
      S*(d+1:ℕ)≤n → ∀T:Finset (Fin d),2≤T.card →
      0<walshCoefficients (incrementScore δ (optimizedRealCost b) n) T := by
  obtain ⟨S,hS,hbound⟩:=optimizedRealCost_mixed_differences b
  refine ⟨S,hS,?_⟩
  intro d δ hδ n hn T hT
  rw [increment_walsh_eq_difference_average]
  apply div_pos _ (by exact_mod_cast Fintype.card_pos)
  apply Finset.sum_pos
  · intro y _
    have hsteps:∀h∈List.ofFn (subsetWeights T δ),0<h:=by
      intro h hh
      obtain ⟨i,rfl⟩:=List.mem_ofFn.mp hh
      exact hδ _
    have hlen:2≤(List.ofFn (subsetWeights T δ)).length:=by simpa using hT
    have hcard:T.card≤d:=(Finset.card_le_card (Finset.subset_univ _)).trans_eq (Finset.card_fin _)
    have hb:S*((List.ofFn (subsetWeights T δ)).length+1:ℕ)≤n+incrementLinear (subsetWeights Tᶜ δ) y:=by
      have hc:(T.card+1:ℕ)≤d+1:=by omega
      have hcR:((T.card+1:ℕ):ℝ)≤(d+1:ℕ):=by exact_mod_cast hc
      have hm:=mul_le_mul_of_nonneg_left hcR hS.le
      have hi:=incrementLinear_nonneg (subsetWeights Tᶜ δ) (fun i=>(hδ _).le) y
      simp only [List.length_ofFn]
      linarith
    exact ((hbound _ hsteps hlen).1 _ hb).1
  · exact Finset.univ_nonempty

lemma incrementLinear_le_total {d:ℕ} (δ:Fin d→ℝ) (hδ:∀i,0≤δ i) (x:Cube d) :
    incrementLinear δ x≤∑i,δ i := by
  apply Finset.sum_le_sum
  intro i _
  by_cases h:x i=true
  · simp [h,hδ i]
  · simp [h]

lemma increment_total_partition {d:ℕ} (T:Finset (Fin d)) (δ:Fin d→ℝ) :
    (∑i,subsetWeights Tᶜ δ i)+(∑i,subsetWeights T δ i)=∑i,δ i := by
  unfold subsetWeights
  rw [subset_sum_reindex,subset_sum_reindex]
  exact (add_comm _ _).trans (Finset.sum_add_sum_compl T δ)

lemma increment_walsh_eq_normalized_difference_average {d:ℕ} (T:Finset (Fin d))
    (δ:Fin d→ℝ) (f:ℝ→ℝ) (n:ℝ) :
    walshCoefficients (incrementScore δ f n) T=
      uniformCubeMean (fun y:Cube Tᶜ.card=>mixedBackwardDifference
        (List.ofFn (subsetWeights T δ)) f (n+incrementLinear (subsetWeights Tᶜ δ) y))/(2:ℝ)^T.card := by
  rw [increment_walsh_eq_difference_average]
  unfold uniformCubeMean
  simp only [ConcreteModel.Cube,ClippingCube,Fintype.card_fun,Fintype.card_fin,
    Fintype.card_bool,Nat.cast_pow,Nat.cast_ofNat]
  rw [div_div,←pow_add]
  congr 2
  rw [Finset.card_compl,Fintype.card_fin]
  have ht:T.card≤d:=(Finset.card_le_card (Finset.subset_univ T)).trans_eq (Finset.card_fin d)
  omega

lemma increment_walsh_bounds_of_differences {d:ℕ} (T:Finset (Fin d))
    (δ:Fin d→ℝ) (f:ℝ→ℝ) (n L U:ℝ)
    (h:∀y:Cube Tᶜ.card,L≤mixedBackwardDifference (List.ofFn (subsetWeights T δ)) f
      (n+incrementLinear (subsetWeights Tᶜ δ) y) ∧
      mixedBackwardDifference (List.ofFn (subsetWeights T δ)) f
        (n+incrementLinear (subsetWeights Tᶜ δ) y)≤U) :
    L/(2:ℝ)^T.card≤walshCoefficients (incrementScore δ f n) T ∧
      walshCoefficients (incrementScore δ f n) T≤U/(2:ℝ)^T.card := by
  rw [increment_walsh_eq_normalized_difference_average]
  have hc:0<(Fintype.card (Cube Tᶜ.card):ℝ):=by exact_mod_cast Fintype.card_pos
  have hlo:=Finset.sum_le_sum (s:=Finset.univ) (fun y _=>(h y).1)
  have hhi:=Finset.sum_le_sum (s:=Finset.univ) (fun y _=>(h y).2)
  simp only [Finset.sum_const,Finset.card_univ,nsmul_eq_mul] at hlo hhi
  have hl:L≤uniformCubeMean (fun y:Cube Tᶜ.card=>mixedBackwardDifference
      (List.ofFn (subsetWeights T δ)) f (n+incrementLinear (subsetWeights Tᶜ δ) y)):=by
    apply (le_div_iff₀ hc).mpr
    nlinarith
  have hu:uniformCubeMean (fun y:Cube Tᶜ.card=>mixedBackwardDifference
      (List.ofFn (subsetWeights T δ)) f (n+incrementLinear (subsetWeights Tᶜ δ) y))≤U:=by
    apply (div_le_iff₀ hc).mpr
    nlinarith
  exact ⟨div_le_div_of_nonneg_right hl (by positivity),div_le_div_of_nonneg_right hu (by positivity)⟩

/-- Actual quantitative high-order coefficients, without a Laplace-kernel
hypothesis or an exponentially small remainder. -/
theorem optimized_increment_walsh_bounds (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀d:ℕ,∀δ:Fin d→ℝ,(∀i,0<δ i) → ∀n:ℝ,
      S*(d+1:ℕ)≤n → ∀T:Finset (Fin d),2≤T.card →
      ((∏i∈T,δ i)*((optimizedCostCurvature/2)*(T.card.factorial:ℝ)/
        (n+∑i,δ i)^(T.card+1)))/(2:ℝ)^T.card≤
        walshCoefficients (incrementScore δ (optimizedRealCost b) n) T ∧
      walshCoefficients (incrementScore δ (optimizedRealCost b) n) T≤
        ((∏i∈T,δ i)*((3*optimizedCostCurvature/2)*(T.card.factorial:ℝ)/
          n^(T.card+1)))/(2:ℝ)^T.card := by
  obtain ⟨S,hS,hbound⟩:=optimizedRealCost_mixed_differences b
  refine ⟨S,hS,?_⟩
  intro d δ hδ n hn T hT
  have hn0:0<n:=lt_of_lt_of_le (mul_pos hS (by positivity)) hn
  have hcard:T.card≤d:=(Finset.card_le_card (Finset.subset_univ _)).trans_eq (Finset.card_fin _)
  have hsteps:∀h∈List.ofFn (subsetWeights T δ),0<h:=by
    intro h hh
    obtain ⟨i,rfl⟩:=List.mem_ofFn.mp hh
    exact hδ _
  have hlen:2≤(List.ofFn (subsetWeights T δ)).length:=by simpa using hT
  have hp:(List.ofFn (subsetWeights T δ)).prod=∏i∈T,δ i:=by
    rw [List.prod_ofFn]
    exact subset_prod_reindex T δ
  apply increment_walsh_bounds_of_differences
  intro y
  let x:=n+incrementLinear (subsetWeights Tᶜ δ) y
  have hnx:n≤x:=by
    dsimp [x]
    linarith [incrementLinear_nonneg (subsetWeights Tᶜ δ) (fun i=>(hδ _).le) y]
  have hx0:0<x:=hn0.trans_le hnx
  have hb:S*((List.ofFn (subsetWeights T δ)).length+1:ℕ)≤x:=by
    have hcR:((T.card+1:ℕ):ℝ)≤(d+1:ℕ):=by exact_mod_cast (show T.card+1≤d+1 by omega)
    have hm:=mul_le_mul_of_nonneg_left hcR hS.le
    simp only [List.length_ofFn]
    linarith
  have hsum:x+(List.ofFn (subsetWeights T δ)).sum≤n+∑i,δ i:=by
    rw [List.sum_ofFn]
    have hi:=incrementLinear_le_total (subsetWeights Tᶜ δ) (fun i=>(hδ _).le) y
    have he:=increment_total_partition T δ
    dsimp [x]
    linarith
  have hsum0:0<x+(List.ofFn (subsetWeights T δ)).sum:=by
    apply add_pos_of_pos_of_nonneg hx0
    exact List.sum_nonneg (fun h hh=>(hsteps h hh).le)
  obtain ⟨_,hlo,hhi⟩:=(hbound _ hsteps hlen).1 x hb
  simp only [List.length_ofFn,hp] at hlo hhi
  have hprod:0≤∏i∈T,δ i:=Finset.prod_nonneg (fun i _=>(hδ i).le)
  constructor
  · apply le_trans _ hlo
    apply mul_le_mul_of_nonneg_left _ hprod
    apply div_le_div_of_nonneg_left (by positivity [optimizedCostCurvature_pos])
      (pow_pos hsum0 _) (pow_le_pow_left₀ hsum0.le hsum _)
  · apply hhi.trans
    apply mul_le_mul_of_nonneg_left _ hprod
    apply div_le_div_of_nonneg_left (by positivity [optimizedCostCurvature_pos])
      (pow_pos hn0 _) (pow_le_pow_left₀ hn0.le hnx _)

/-- Increasing scalar costs have nonpositive singleton increment coefficients. -/
theorem increment_walsh_singleton_nonpos {d:ℕ} (δ:Fin d→ℝ) (hδ:∀i,0≤δ i)
    (f:ℝ→ℝ) (a n:ℝ) (hf:MonotoneOn f (Set.Ici a)) (hn:a≤n)
    (T:Finset (Fin d)) (hT:T.card=1) :
    walshCoefficients (incrementScore δ f n) T≤0 := by
  rw [increment_walsh_eq_difference_average]
  apply div_nonpos_of_nonpos_of_nonneg _ (Nat.cast_nonneg _)
  apply Finset.sum_nonpos
  intro y _
  have hlen:(List.ofFn (subsetWeights T δ)).length=1:=by simpa using hT
  obtain ⟨h,hh⟩:=List.length_eq_one_iff.mp hlen
  have hhmem:h∈List.ofFn (subsetWeights T δ):=by rw [hh];simp
  obtain ⟨i,hi⟩:=List.mem_ofFn.mp hhmem
  have hh0:0≤h:=by rw [←hi];exact hδ _
  rw [hh,mixedBackwardDifference,mixedBackwardDifference]
  have hx:a≤n+incrementLinear (subsetWeights Tᶜ δ) y:=by
    have hh:=incrementLinear_nonneg (subsetWeights Tᶜ δ) (fun i=>hδ _) y
    linarith
  change f (n+incrementLinear (subsetWeights Tᶜ δ) y)-f (n+incrementLinear (subsetWeights Tᶜ δ) y+h)≤0
  exact sub_nonpos.mpr (hf hx (show a≤n+incrementLinear (subsetWeights Tᶜ δ) y+h by linarith) (by linarith))

end NeuralGeneralization.OnlineLowerTanh
