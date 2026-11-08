import NeuralGeneralization.OnlineLowerRailSampling
import NeuralGeneralization.OnlineLowerReluProjectorExpansion
import NeuralGeneralization.OnlineLowerReluUniformMarginal

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

/-- Positive selected bits are recorded by their actual finite subset. -/
def boolFinsetEquiv (α : Type*) [Fintype α] [DecidableEq α] : (α→Bool) ≃ Finset α where
  toFun x := Finset.univ.filter (fun a => x a)
  invFun S a := decide (a∈S)
  left_inv x := by funext a; simp
  right_inv S := by ext a; simp

abbrev SelectedCoord {p : ℕ} (P : Fin p → ℕ) := (i:Fin p) × Fin (P i)

def selectedBitsEquiv {p : ℕ} (P : Fin p → ℕ) :
    ((i:Fin p) → Fin (P i) → Bool) ≃ Finset (SelectedCoord P) where
  toFun x := (boolFinsetEquiv (SelectedCoord P)) (fun a => x a.1 a.2)
  invFun S i k := decide (⟨i,k⟩∈S)
  left_inv x := by funext i k; simp [boolFinsetEquiv]
  right_inv S := by ext a; simp [boolFinsetEquiv]

def piEndBitsEquiv {p : ℕ} (r : Fin p → ℕ) :
    ((i:Fin p) → Fin (r i+2) → Bool) ≃
    (Fin p→Bool) × ((i:Fin p)→Fin (r i)→Bool) × (Fin p→Bool) where
  toFun x := (fun i => (endBitsEquiv (r i) (x i)).1,
    (fun i => (endBitsEquiv (r i) (x i)).2.1),
    fun i => (endBitsEquiv (r i) (x i)).2.2)
  invFun z i := (endBitsEquiv (r i)).symm (z.1 i,z.2.1 i,z.2.2 i)
  left_inv x := by funext i; exact (endBitsEquiv (r i)).symm_apply_apply (x i)
  right_inv z := by
    apply Prod.ext
    · funext i; exact congrArg Prod.fst ((endBitsEquiv (r i)).apply_symm_apply (z.1 i,z.2.1 i,z.2.2 i))
    · apply Prod.ext
      · funext i; exact congrArg (fun a => a.2.1) ((endBitsEquiv (r i)).apply_symm_apply (z.1 i,z.2.1 i,z.2.2 i))
      · funext i; exact congrArg (fun a => a.2.2) ((endBitsEquiv (r i)).apply_symm_apply (z.1 i,z.2.1 i,z.2.2 i))

def samplerSize {p : ℕ} (P r : Fin p → ℕ) (i : Fin p) : Bool → ℕ
  | false => P i
  | true => r i+2

def splitSamplerBits {p : ℕ} (P r : Fin p → ℕ) :
    RailBits (samplerSize P r) ≃
      (((i:Fin p)→Fin (P i)→Bool) × ((i:Fin p)→Fin (r i+2)→Bool)) where
  toFun x := (fun i => x i false, fun i => x i true)
  invFun z i b := Bool.rec (z.1 i) (z.2 i) b
  left_inv x := by funext i b k; cases b <;> rfl
  right_inv z := by rfl

abbrev RailSamplerState {p : ℕ} (P r : Fin p → ℕ) :=
  Finset (SelectedCoord P) × (Fin p→Bool) × ((i:Fin p)→Fin (r i)→Bool) × (Fin p→Bool)

/-- A bijection from the literal Boolean cube to every displayed independent
variable of the conditional-parity calculation. -/
def railSamplerEquiv {p : ℕ} (P r : Fin p → ℕ) :
    ClippingCube (railDimension (samplerSize P r)) ≃ RailSamplerState P r :=
  (railCubeEquiv _).trans ((splitSamplerBits P r).trans
    ((selectedBitsEquiv P).prodCongr (piEndBitsEquiv r)))


theorem finiteAverage_prod {α β : Type*} [Fintype α] [Fintype β]
    (f : α → β → ℝ) :
    finiteAverage (fun z:α×β => f z.1 z.2) =
      finiteAverage (fun a => finiteAverage (f a)) := by
  unfold finiteAverage
  rw [Fintype.sum_prod_type,Fintype.card_prod,Nat.cast_mul]
  simp_rw [Finset.sum_div]
  apply Finset.sum_congr rfl
  intro a _
  apply Finset.sum_congr rfl
  intro b _
  ring

theorem finiteAverage_finset {α : Type*} [Fintype α] [DecidableEq α]
    (f : Finset α → ℝ) :
    finiteAverage f = selectedAverage (Finset.univ:Finset α) f := by
  simp [finiteAverage,selectedAverage]

/-- The normalization is exact: nested selected-subset and opposite-bit
averages are the ordinary uniform average on the physical Boolean cube. -/
theorem actual_uniform_sampler {p : ℕ} (P r : Fin p → ℕ)
    (f : RailSamplerState P r → ℝ) :
    (∑ x:ClippingCube (railDimension (samplerSize P r)),f (railSamplerEquiv P r x)) /
        (2:ℝ)^railDimension (samplerSize P r) =
    physicalRailExpectation (Finset.univ:Finset (SelectedCoord P)) r
      (fun S y z last => f (S,y,z,last)) := by
  have he := finiteAverage_equiv (railSamplerEquiv P r) f
  have hl : finiteAverage (fun x:ClippingCube (railDimension (samplerSize P r)) =>
      f (railSamplerEquiv P r x)) =
      (∑ x,f (railSamplerEquiv P r x))/(2:ℝ)^railDimension (samplerSize P r) := by
    simp [finiteAverage,ClippingCube,Fintype.card_fun]
  rw [hl] at he
  rw [he]
  have hinner (S : Finset (SelectedCoord P)) :
      finiteAverage (fun yz:(Fin p→Bool)×(((i:Fin p)→Fin (r i)→Bool)×(Fin p→Bool)) => f (S,yz)) =
      finiteAverage (fun y => finiteAverage (fun z => finiteAverage (fun last => f (S,y,z,last)))) := by
    calc
      _ = finiteAverage (fun y => finiteAverage (fun zl => f (S,y,zl))) :=
        finiteAverage_prod (fun y zl => f (S,y,zl))
      _ = _ := by
        congr 1
        funext y
        exact finiteAverage_prod (fun z last => f (S,y,z,last))
  calc
    finiteAverage f = finiteAverage (fun S => finiteAverage (fun yz => f (S,yz))) :=
      finiteAverage_prod (fun S yz => f (S,yz))
    _ = finiteAverage (fun S => finiteAverage (fun y => finiteAverage (fun z =>
        finiteAverage (fun last => f (S,y,z,last))))) := by simp_rw [hinner]
    _ = _ := finiteAverage_finset _

@[simp] theorem sampler_inverse_selected {p : ℕ} (P r : Fin p → ℕ)
    (state : RailSamplerState P r) (i : Fin p) (k : Fin (P i)) :
    (railSamplerEquiv P r).symm state (railIndex (samplerSize P r) ⟨i,false,k⟩) =
      decide (⟨i,k⟩∈state.1) := by
  change (railCubeEquiv (samplerSize P r)).symm
    ((splitSamplerBits P r).symm (((selectedBitsEquiv P).prodCongr (piEndBitsEquiv r)).symm state))
    (railIndex (samplerSize P r) ⟨i,false,k⟩) = _
  rw [railCube_inverse_apply]
  rfl

@[simp] theorem sampler_inverse_opposite {p : ℕ} (P r : Fin p → ℕ)
    (state : RailSamplerState P r) (i : Fin p) (k : Fin (r i+2)) :
    (railSamplerEquiv P r).symm state (railIndex (samplerSize P r) ⟨i,true,k⟩) =
      (endBitsEquiv (r i)).symm (state.2.1 i,state.2.2.1 i,state.2.2.2 i) k := by
  change (railCubeEquiv (samplerSize P r)).symm
    ((splitSamplerBits P r).symm (((selectedBitsEquiv P).prodCongr (piEndBitsEquiv r)).symm state))
    (railIndex (samplerSize P r) ⟨i,true,k⟩) = _
  rw [railCube_inverse_apply]
  rfl

theorem endBits_sum (r : ℕ) (x : Fin (r+2)→Bool) (f : Bool→ℝ) :
    (∑ k,f (x k)) =
      f (endBitsEquiv r x).1 + (∑ k,f ((endBitsEquiv r x).2.1 k)) +
        f (endBitsEquiv r x).2.2 := by
  change (∑ k,f (x k)) = f (x 0) + (∑ k:Fin r,f (x ⟨k+1,by omega⟩)) +
    f (x (Fin.last (r+1)))
  rw [Fin.sum_univ_succ,Fin.sum_univ_castSucc]
  exact (add_assoc _ _ _).symm

theorem endBits_prod (r : ℕ) (x : Fin (r+2)→Bool) (f : Bool→ℝ) :
    (∏ k,f (x k)) =
      f (endBitsEquiv r x).1 * (∏ k,f ((endBitsEquiv r x).2.1 k)) *
        f (endBitsEquiv r x).2.2 := by
  change (∏ k,f (x k)) = f (x 0) * (∏ k:Fin r,f (x ⟨k+1,by omega⟩)) *
    f (x (Fin.last (r+1)))
  rw [Fin.prod_univ_succ,Fin.prod_univ_castSucc]
  exact (mul_assoc _ _ _).symm

end NeuralGeneralization.OnlineLowerRelu
