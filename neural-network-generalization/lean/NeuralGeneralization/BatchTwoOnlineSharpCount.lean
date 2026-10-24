import NeuralGeneralization.BatchTwoOnlineSharpCompression
import NeuralGeneralization.CapacityBound

/-! Exact logarithmic rounding count used in the online appendix. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel

def sharpParameterMesh (d u r : ℕ) : ℕ := (d+1)*(u*(u+1))^(r+1)

theorem sharp_sensitivity (d u r : ℕ) (hu : 1≤u) :
    nextSensitivity u u (hiddenSensitivity d u u r)≤(sharpParameterMesh d u r:ℝ) := by
  have hbase : (1:ℝ)≤(u:ℝ)*(u+1):=by
    have hur:(1:ℝ)≤u:=by exact_mod_cast hu
    nlinarith
  have hrec : ∀s : ℕ,hiddenSensitivity d u u s≤((d:ℝ)+1)*((u:ℝ)*(u+1))^s := by
    intro s
    induction s with
    | zero=>simp [hiddenSensitivity]
    | succ s ih=>
      let X:=((d:ℝ)+1)*((u:ℝ)*(u+1))^s
      have hX:1≤X:=one_le_mul_of_one_le_of_one_le (by linarith [Nat.cast_nonneg d (α:=ℝ)]) (one_le_pow₀ hbase)
      change (u:ℝ)*(1+(u:ℝ)*hiddenSensitivity d u u s)≤_
      calc
        _ ≤ (u:ℝ)*(1+(u:ℝ)*X):=by gcongr
        _ ≤ (u:ℝ)*(X+(u:ℝ)*X):=by gcongr
        _ = _:=by dsimp [X];rw [pow_succ];ring
  have hh:=hrec (r+1)
  simpa only [hiddenSensitivity,sharpParameterMesh,Nat.cast_mul,Nat.cast_add,Nat.cast_one,Nat.cast_pow] using hh

def normLogCount (d u r : ℕ) : ℝ := ((u:ℝ)*(d+2)+r*(u:ℝ)^2)*
  Real.log (3+16*((r:ℝ)+2)*u*max (u:ℝ) ((d:ℝ)+1)*((u:ℝ)*(u+1))^(r+1))

theorem bounded_functions_card_paper (d u r : ℕ) (hu : 1≤u) (φ : ℝ→ℝ) (hφ : admissibleActivation φ) :
    (Fintype.card (BoundedNetworkFunctions d u r u φ):ℝ)≤Real.exp (normLogCount d u r) := by
  let T:=sharpParameterMesh d u r
  have hT:0<T:=by dsimp [T,sharpParameterMesh];positivity
  have hc:=boundedNetworkFunctions_card_le d u r u T φ hφ hT (sharp_sensitivity d u r hu)
  let A:ℝ:=3+16*((r:ℝ)+2)*u*max (u:ℝ) ((d:ℝ)+1)*((u:ℝ)*(u+1))^(r+1)
  have hA:0<A:=by dsimp [A];positivity
  have hu0:(0:ℝ)≤u:=Nat.cast_nonneg _
  have hr0:(0:ℝ)≤r:=Nat.cast_nonneg _
  have hd0:(0:ℝ)≤d:=Nat.cast_nonneg _
  have hbase:(0:ℝ)≤((u:ℝ)*(u+1))^(r+1):=by positivity
  have hmesh:(2*(u*T)+1:ℕ)≤A:=by
    dsimp [A,T,sharpParameterMesh]
    push_cast
    have hh:=mul_le_mul_of_nonneg_left (le_max_right (u:ℝ) ((d:ℝ)+1))
      (show 0≤(u:ℝ)*((u:ℝ)*(u+1))^(r+1) by positivity)
    have hh0:0≤(u:ℝ)*max (u:ℝ) ((d:ℝ)+1)*((u:ℝ)*(u+1))^(r+1):=by positivity
    nlinarith
  have hp:(Fintype.card (BoundedNetworkFunctions d u r u φ):ℝ)≤A^(Fintype.card (WeightIndex d u r)):=by
    apply (show (Fintype.card (BoundedNetworkFunctions d u r u φ):ℝ)≤
      ((2*(u*T)+1:ℕ):ℝ)^(Fintype.card (WeightIndex d u r)) by exact_mod_cast hc).trans
    exact pow_le_pow_left₀ (Nat.cast_nonneg _) hmesh _
  apply hp.trans_eq
  rw [←Real.exp_log hA,←Real.exp_nat_mul]
  congr 1
  dsimp [normLogCount,A]
  rw [weightIndex_card]
  push_cast
  ring

theorem represented_class_card_paper {d u r : ℕ} (A : Finset (BooleanFunction d)) (hu : 1≤u)
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (hrep : ∀f∈A,∃w : Weights d u r,w∈marginEvent φ (1/2) f ∧ boundedWeights u w) :
    (A.card:ℝ)≤Real.exp (normLogCount d u r) := by
  classical
  let embed : ↥A→BoundedNetworkFunctions d u r u φ:=fun f=>⟨f.val,hrep f.val f.property⟩
  have hinj:Function.Injective embed:=by
    intro f g h
    apply Subtype.ext
    exact congrArg (fun z : BoundedNetworkFunctions d u r u φ=>z.val) h
  have hc:=Fintype.card_le_of_injective embed hinj
  rw [Fintype.card_coe] at hc
  exact (show (A.card:ℝ)≤Fintype.card (BoundedNetworkFunctions d u r u φ) by exact_mod_cast hc).trans
    (bounded_functions_card_paper d u r hu φ hφ)

end NeuralGeneralization.BatchTwoOnlineSharp
