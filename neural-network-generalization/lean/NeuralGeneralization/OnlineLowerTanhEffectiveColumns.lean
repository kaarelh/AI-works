import NeuralGeneralization.OnlineLowerTanhPathFamily
import NeuralGeneralization.OnlineLowerTanhWalshColumns

/-! The actual split family as a compact independent increment cube. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh.Family
open OnlineLower OnlineLowerRelu OnlineLowerGeometry

abbrev effectiveDim (k:ℕ):ℕ:=OnlineLowerRelu.Family.pairDim k+2

def effectiveIndex (k:ℕ) :
    (Fin (OnlineLowerRelu.Family.pairDim k) ⊕ Fin 2) ≃ Fin (effectiveDim k):=finSumFinEquiv

def effectiveColumn (k:ℕ) (i:Fin (effectiveDim k)) : Finset (Fin (logicalDim k)):=
  match (effectiveIndex k).symm i with
  | .inl j => (OnlineLowerRelu.Family.column k j).map (oldLogical k)
  | .inr j => {logicalIndex k (.inr j)}

def effectiveIncrement (H k:ℕ) (i:Fin (effectiveDim k)) : ℝ:=
  match (effectiveIndex k).symm i with
  | .inl j => (OnlineLowerRelu.Family.increment k j:ℝ)
  | .inr _ => (H:ℝ)

def firstDistinguished (k:ℕ):Fin (effectiveDim k):=effectiveIndex k (.inr 0)
def secondDistinguished (k:ℕ):Fin (effectiveDim k):=effectiveIndex k (.inr 1)

lemma distinguished_ne (k:ℕ):firstDistinguished k≠secondDistinguished k:=by
  intro hh
  have h:=Sum.inr.inj ((effectiveIndex k).injective hh)
  norm_num at h

@[simp] lemma effectiveColumn_old (k:ℕ) (i:Fin (OnlineLowerRelu.Family.pairDim k)):
    effectiveColumn k (effectiveIndex k (.inl i))=(OnlineLowerRelu.Family.column k i).map (oldLogical k):=by
  simp [effectiveColumn]
@[simp] lemma effectiveColumn_distinguished (k:ℕ) (i:Fin 2):
    effectiveColumn k (effectiveIndex k (.inr i))={logicalIndex k (.inr i)}:=by
  simp [effectiveColumn]
@[simp] lemma effectiveIncrement_old (H k:ℕ) (i:Fin (OnlineLowerRelu.Family.pairDim k)):
    effectiveIncrement H k (effectiveIndex k (.inl i))=OnlineLowerRelu.Family.increment k i:=by
  simp [effectiveIncrement]
@[simp] lemma effectiveIncrement_distinguished (H k:ℕ) (i:Fin 2):
    effectiveIncrement H k (effectiveIndex k (.inr i))=H:=by simp [effectiveIncrement]

lemma effectiveIncrement_pos (H k:ℕ) (hH:0<H) (i:Fin (effectiveDim k)):
    0<effectiveIncrement H k i:=by
  obtain ⟨z,rfl⟩:=(effectiveIndex k).surjective i
  cases z with
  | inl j => simpa using (Nat.cast_pos.mpr (by have hh:=(OnlineLowerRelu.Family.increment_bounds k j).1;omega) : (0:ℝ)<OnlineLowerRelu.Family.increment k j)
  | inr j => simpa using (Nat.cast_pos.mpr hH : (0:ℝ)<H)

lemma effectiveIncrement_sum (H k:ℕ):
    (∑i,effectiveIncrement H k i)=4*OnlineLowerRelu.Family.pairDim k+2*H:=by
  rw [←(effectiveIndex k).sum_comp]
  simp only [Fintype.sum_sum_type,effectiveIncrement_old,effectiveIncrement_distinguished]
  rw [←Nat.cast_sum,OnlineLowerRelu.Family.increment_sum]
  simp

lemma effectiveIncrement_old_sum (H k:ℕ):
    (∑i∈({firstDistinguished k,secondDistinguished k}:Finset (Fin (effectiveDim k)))ᶜ,
      effectiveIncrement H k i)=4*OnlineLowerRelu.Family.pairDim k:=by
  have hsum:=Finset.sum_add_sum_compl ({firstDistinguished k,secondDistinguished k}:Finset (Fin (effectiveDim k))) (effectiveIncrement H k)
  rw [Finset.sum_pair (distinguished_ne k),effectiveIncrement_sum] at hsum
  simp only [firstDistinguished,secondDistinguished,effectiveIncrement_distinguished] at hsum
  simp only [firstDistinguished,secondDistinguished]
  linarith

/-- The split physical columns have exactly the same degree function as the
old columns together with two unsplit H-increments. -/
theorem columnDegree_effective_compact (R H k:ℕ) (n:ℝ) (x:ClippingCube (logicalDim k)):
    columnDegree n (column R H k) (fun i=>(increment R H k i:ℝ)) x=
      columnDegree n (effectiveColumn k) (effectiveIncrement H k) x:=by
  rw [columnDegree_effective]
  unfold columnDegree
  rw [←(effectiveIndex k).sum_comp,Fintype.sum_sum_type]
  simp only [effectiveColumn_old,effectiveColumn_distinguished,effectiveIncrement_old,
    effectiveIncrement_distinguished]
  simp only [walsh_oldLogical,walshCharacter,Finset.prod_singleton,Finset.prod_map]
  simp only [oldLogical,oldInput]
  ring

/-- Literal transform coefficients of the actual scalar support costs are
pushforwards of the compact independent-increment cube. -/
theorem scalarSupportWeight_compact_pushforward (R H k:ℕ) (f:ℝ→ℝ)
    (T:Finset (Fin (logicalDim k))):
    rectangleWeightTransform (scalarSupportWeight R H k f) (negativeBitsCube T)=
      columnCoefficientPushforward (effectiveColumn k)
        (walshCoefficients (incrementScore (effectiveIncrement H k) f
          ((pairDim R H k:ℝ)*R+1))) T:=by
  rw [scalarSupportWeight_transform]
  simp_rw [columnDegree_effective_compact]
  exact columnDegree_walsh_pushforward _ _ _ _ _

def centralEffectiveSupport (k:ℕ):Finset (Fin (effectiveDim k)):=
  {firstDistinguished k,secondDistinguished k}

def centralLogicalSupport (k:ℕ):Finset (Fin (logicalDim k)):=
  {logicalIndex k (.inr 0),logicalIndex k (.inr 1)}

lemma centralEffectiveSupport_image (k:ℕ):
    generatedSupport ∅ (effectiveColumn k) (centralEffectiveSupport k)=centralLogicalSupport k:=by
  have hne:logicalIndex k (.inr 0)≠logicalIndex k (.inr 1):=by
    intro h;have hh:=Sum.inr.inj ((logicalIndex k).injective h);norm_num at hh
  unfold centralEffectiveSupport
  rw [generatedSupport_insert _ _ _ _ (by simp [distinguished_ne k]),generatedSupport_singleton]
  simp only [firstDistinguished,secondDistinguished,effectiveColumn_distinguished]
  ext j
  simp [centralLogicalSupport,Finset.mem_symmDiff]
  aesop

lemma centralLogicalSupport_point (k:ℕ):negativeBitsCube (centralLogicalSupport k)=shiftPoint k:=by
  ext i
  obtain ⟨i,rfl⟩:=(logicalIndex k).surjective i
  cases i with
  | inl j => simp [centralLogicalSupport,negativeBitsCube,shiftPoint,extendPoint,joinPoint,cubeOne]
  | inr j => fin_cases j <;> simp [centralLogicalSupport,negativeBitsCube,shiftPoint,extendPoint,joinPoint]

lemma centralEffectiveSupport_point (k:ℕ):
    negativeBitsCube (generatedSupport ∅ (effectiveColumn k) (centralEffectiveSupport k))=shiftPoint k:=by
  rw [centralEffectiveSupport_image,centralLogicalSupport_point]

end NeuralGeneralization.OnlineLowerTanh.Family
