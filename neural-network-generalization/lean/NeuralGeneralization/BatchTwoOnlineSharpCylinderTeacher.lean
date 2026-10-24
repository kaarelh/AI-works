import NeuralGeneralization.BatchTwoOnlineSharpTeacher
import NeuralGeneralization.CylinderGeometry

/-! The actual cloned cylinder center with separate sharp layer costs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel CompressionSampling

def cylinderBulkBound (r : ℕ) : ℝ := Real.sqrt (16*Real.log 9+8*Real.log (4*((r:ℝ)+2)))
def cylinderGrowth (C r : ℕ) : ℝ := 2+3*(C:ℝ)^2+cylinderBulkBound r
def cylinderRadius (d C r : ℕ) : ℝ := (2+9*(C:ℝ)^2*((d:ℝ)+r+3)*(cylinderGrowth C r)^r)⁻¹
def cylinderCenterBudget (d C r : ℕ) : ℝ := (d:ℝ)*(d+1)*C^2+2*(r:ℝ)*C^4+36*(C:ℝ)^4
def targetCost (d C r : ℕ) : ℝ := 2*cylinderCenterBudget d C r+
  4*((d:ℝ)+2+r*C)/cylinderRadius d C r+2

theorem cylinderBulkBound_nonneg (r : ℕ) : 0≤cylinderBulkBound r :=Real.sqrt_nonneg _
theorem cylinderGrowth_ge_two (C r : ℕ) : 2≤cylinderGrowth C r :=by
  unfold cylinderGrowth
  nlinarith [sq_nonneg (C:ℝ),cylinderBulkBound_nonneg r]
theorem cylinderRadius_pos (d C r : ℕ) : 0<cylinderRadius d C r :=by
  have hh:=cylinderGrowth_ge_two C r
  unfold cylinderRadius
  positivity
theorem cylinderRadius_le_half (d C r : ℕ) : cylinderRadius d C r≤1/2 :=by
  have hh:=cylinderGrowth_ge_two C r
  have hp:0≤9*(C:ℝ)^2*((d:ℝ)+r+3)*(cylinderGrowth C r)^r:=by positivity
  simpa only [cylinderRadius,one_div] using
    (one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2)
      (show (2:ℝ)≤2+9*(C:ℝ)^2*((d:ℝ)+r+3)*(cylinderGrowth C r)^r by linarith))
theorem targetCost_ge_one (d C r : ℕ) : 1≤targetCost d C r :=by
  have hh:=cylinderRadius_pos d C r
  have hb:0≤cylinderCenterBudget d C r:=by unfold cylinderCenterBudget;positivity
  have hq:0≤4*((d:ℝ)+2+r*C)/cylinderRadius d C r:=by positivity
  unfold targetCost
  linarith

theorem cloned_teacher_layer_costs {d C N r k p : ℕ} (hC : 0<C) (hk : 0<k)
    (hbelow : C*k≤N) (habove : N≤2*C*k)
    (e : ((Fin C×Fin k)⊕Fin p)≃Fin N) (w : Weights d C r) (hw : boundedWeights C w) :
    (d:ℝ)/N*(∑i,∑j,clonedWeights e w (Sum.inl (i,j))^2)≤(d:ℝ)*(d+1)*C^2 ∧
    (∀s : Fin r,(∑i,∑j,clonedWeights e w (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4) ∧
    (N:ℝ)*(∑i,clonedWeights e w (Sum.inr (Sum.inr i))^2)≤2*(C:ℝ)^4 :=by
  have hN:0<N:=lt_of_lt_of_le (Nat.mul_pos hC hk) hbelow
  have hCR:0<(C:ℝ):=by exact_mod_cast hC
  have hkR:0<(k:ℝ):=by exact_mod_cast hk
  have hn:0<(N:ℝ):=by exact_mod_cast hN
  have hlo:(C:ℝ)*k≤N:=by exact_mod_cast hbelow
  have hhi:(N:ℝ)≤2*C*k:=by exact_mod_cast habove
  obtain ⟨hf,_,ho⟩:=bounded_teacher_sums w hw
  refine ⟨?_,?_,?_⟩
  · rw [first_squaredSum_cloned]
    have he:(d:ℝ)/N*((k:ℝ)*(∑i,∑j,w (Sum.inl (i,j))^2))=
        ((d:ℝ)*k/N)*(∑i,∑j,w (Sum.inl (i,j))^2):=by ring
    rw [he]
    have hc:(d:ℝ)*k/N≤(d:ℝ)/C:=by
      apply (div_le_div_iff₀ hn hCR).mpr
      nlinarith [mul_le_mul_of_nonneg_left hlo (Nat.cast_nonneg d : (0:ℝ)≤d)]
    calc
      _ ≤ ((d:ℝ)/C)*((C:ℝ)*(d+1)*C^2):=
        mul_le_mul hc hf (by positivity) (by positivity)
      _ = _:=by field_simp <;> ring
  · intro s
    rw [internal_squaredSum_cloned hk]
    calc
      _ ≤ ∑_i : Fin C,∑_j : Fin C,(C:ℝ)^2:=by
        apply Finset.sum_le_sum
        intro i _
        apply Finset.sum_le_sum
        intro j _
        simpa only [sq_abs] using
          (sq_le_sq₀ (abs_nonneg _) (Nat.cast_nonneg C)).mpr (hw (Sum.inr (Sum.inl (s,i,j))))
      _ = _:=by simp;ring
  · rw [readout_squaredSum_cloned hk]
    have hc:(N:ℝ)/k≤2*C:=(div_le_iff₀ hkR).mpr hhi
    calc
      _ = ((N:ℝ)/k)*(∑i,w (Sum.inr (Sum.inr i))^2):=by ring
      _ ≤ (2*(C:ℝ))*C^3:=mul_le_mul hc ho (by positivity) (by positivity)
      _ = _:=by ring

theorem exists_sharp_supported_teacher {d C N r : ℕ} (φ : ℝ→ℝ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ∃(v : Weights d N r) (S : Submodule ℝ (Fin N→ℝ)),
      v∈marginEvent φ (3/2) f ∧
      (d:ℝ)/N*(∑i,∑j,v (Sum.inl (i,j))^2)≤(d:ℝ)*(d+1)*C^2 ∧
      (∀s : Fin r,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4) ∧
      (N:ℝ)*(∑i,v (Sum.inr (Sum.inr i))^2)≤18*(C:ℝ)^4 ∧
      Module.finrank ℝ S≤C+1 ∧
      (∀x (ss : List (Fin r)),ss.foldl (hiddenStep φ v) (firstHidden φ v x)∈S) ∧
      (∀s i,(fun j=>v (Sum.inr (Sum.inl (s,i,j))))∈S) :=by
  classical
  obtain ⟨hC,w,hwm,hwb⟩:=hf
  let k:=N/C
  have hC0:0<C:=by omega
  have hk:0<k:=Nat.div_pos hCN hC0
  have hmod:N%C<C:=Nat.mod_lt _ hC0
  have hsplit:N%C+C*k=N:=Nat.mod_add_div N C
  have hbelow:C*k≤N:=by omega
  have hCk:C≤C*k:=by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove:N≤2*C*k:=by nlinarith
  let e : ((Fin C×Fin k)⊕Fin (N-C*k))≃Fin N:=Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  let u:=clonedWeights e w
  let v:=rescaleReadout 3 u
  obtain ⟨hfirst,hinternal,hread⟩:=cloned_teacher_layer_costs hC0 hk hbelow habove e w hwb
  refine ⟨v,cloneSubspace e,?_,hfirst,hinternal,?_,cloneSubspace_finrank_le e,?_,?_⟩
  · intro x
    change 3/2<labelReal (f x)*networkOutput φ (rescaleReadout 3 u) x
    rw [rescaleReadout_output]
    have he:=networkOutput_cloned hk φ e w x
    change networkOutput φ u x=networkOutput φ w x at he
    rw [he]
    nlinarith [hwm x]
  · change (N:ℝ)*(∑i,(3*u (Sum.inr (Sum.inr i)))^2)≤18*(C:ℝ)^4
    simp only [mul_pow,←Finset.mul_sum]
    dsimp [u] at *
    nlinarith only [hread]
  · exact fun x ss=>hiddenFold_cloned_mem_cloneSubspace hk φ e w x ss
  · exact fun s i=>cloned_internalRow_mem_cloneSubspace e w s i

theorem exists_sharp_adapted_teacher {d C N r : ℕ} (φ : ℝ→ℝ) (f : BooleanFunction d)
    (hf : realizesAtComplexity (r:=r) φ f C) (hCN : C≤N) :
    ∃(v : Weights d N r) (b : OrthonormalBasis (Fin N) ℝ (EuclideanSpace ℝ (Fin N)))
      (J : Finset (Fin N)),v∈marginEvent φ (3/2) f ∧
      weightedSquaredNorm v≤cylinderCenterBudget d C r ∧
      (∀s : Fin r,(∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(C:ℝ)^4) ∧
      (N:ℝ)*(∑i,v (Sum.inr (Sum.inr i))^2)≤18*(C:ℝ)^4 ∧
      J.card≤C+1 ∧
      (∀s i j,j∉J→basisCoordinates b (fun a=>v (Sum.inr (Sum.inl (s,i,a)))) j=0) ∧
      (∀(x : Cube d) (ss : List (Fin r)) j,j∉J→
        basisCoordinates b (ss.foldl (hiddenStep φ v) (firstHidden φ v x)) j=0) :=by
  obtain ⟨v,S,hmargin,hfirst,hinternal,hread,hdim,hhidden,hrows⟩:=
    exists_sharp_supported_teacher φ f hf hCN
  let e : (Fin N→ℝ)≃ₗ[ℝ]EuclideanSpace ℝ (Fin N):=(WithLp.linearEquiv 2 ℝ (Fin N→ℝ)).symm
  let T : Submodule ℝ (EuclideanSpace ℝ (Fin N)):=S.map e.toLinearMap
  obtain ⟨b,J,hJ,hspan⟩:=NeuralGeneralization.AdaptedBasis.exists_adapted_orthonormalBasis N T
  have hcard:J.card≤C+1:=by
    rw [hJ]
    change Module.finrank ℝ (S.map e.toLinearMap)≤C+1
    rw [LinearEquiv.finrank_map_eq]
    exact hdim
  have hsupp (z : Fin N→ℝ) (hz : z∈S):∀j,j∉J→basisCoordinates b z j=0:=by
    apply basisCoordinates_zero_of_mem_span b J z
    rw [←hspan]
    exact Submodule.mem_map.mpr ⟨z,hz,rfl⟩
  refine ⟨v,b,J,hmargin,?_,hinternal,hread,hcard,fun s i=>hsupp _ (hrows s i),
    fun x ss=>hsupp _ (hhidden x ss)⟩
  have hi:(∑s,∑i,∑j,v (Sum.inr (Sum.inl (s,i,j)))^2)≤(r:ℝ)*(C:ℝ)^4:=by
    calc
      _ ≤ ∑_s : Fin r,(C:ℝ)^4:=Finset.sum_le_sum fun s _=>hinternal s
      _ = _:=by simp
  unfold weightedSquaredNorm cylinderCenterBudget
  have h0:0≤(r:ℝ)*(C:ℝ)^4:=by positivity
  have h1:0≤(C:ℝ)^4:=by positivity
  linarith

end NeuralGeneralization.BatchTwoOnlineSharp
