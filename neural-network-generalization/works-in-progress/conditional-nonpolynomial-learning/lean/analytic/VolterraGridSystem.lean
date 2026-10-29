import CanonicalInitializerNumerics
import FiniteVolterraCoordinates

noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic

structure VolterraGridSystem (ζ ι : Type) [Fintype ζ] [Fintype ι] (H : ℕ) where
  base : Fin (H+1)→EuclideanSpace ℝ ζ→L[ℝ]EuclideanSpace ℝ ι
  transfer : Fin (H+1)→Fin (H+1)→EuclideanSpace ℝ ι→L[ℝ]EuclideanSpace ℝ ι
  residual : Fin (H+1)→EuclideanSpace ℝ ι→EuclideanSpace ℝ ι
  bound : Fin (H+1)→ℝ
  base_norm : ∀j,‖base j‖≤1
  transfer_norm : ∀j i,‖transfer j i‖≤1
  bound_nonneg : ∀j,0≤bound j
  residual_range : ∀j x,‖residual j x‖≤bound j

namespace VolterraGridSystem
variable {ζ ι : Type} [Fintype ζ] [Fintype ι] {H : ℕ}
abbrev StateIndex (_M : VolterraGridSystem ζ ι H) := Fin (H+1)×ι
abbrev InputIndex (M : VolterraGridSystem ζ ι H) := ζ⊕M.StateIndex

def coefficients (M : VolterraGridSystem ζ ι H) := volterraCoefficients M.base M.transfer

def update (M : VolterraGridSystem ζ ι H) : EuclideanSpace ℝ M.InputIndex→EuclideanSpace ℝ M.StateIndex :=
  affineRealMap M.coefficients (fun _=>0) ∘ residualCarryMap M.residual

def totalBound (M : VolterraGridSystem ζ ι H) : ℝ := ∑j,M.bound j

def stateRange (M : VolterraGridSystem ζ ι H) : ℕ :=
  ⌈((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound)⌉₊+2

def tolerance (M : VolterraGridSystem ζ ι H) (η : ℝ) :=
  picardInnerTolerance (Fintype.card M.InputIndex) (Fintype.card M.StateIndex) (Fintype.card ι) η

def mesh (M : VolterraGridSystem ζ ι H) (η : ℝ) :=
  picardOuterMesh (Fintype.card M.InputIndex) (Fintype.card M.StateIndex) (Fintype.card ι) M.stateRange η

def affineRange (M : VolterraGridSystem ζ ι H) :=1+Fintype.card M.InputIndex*2*(M.stateRange+1)

theorem coefficients_bound (M : VolterraGridSystem ζ ι H) : ∀j i,|M.coefficients j i|≤1 :=
  volterraCoefficients_bound M.base M.transfer (B:=1) (by norm_num) M.base_norm M.transfer_norm

theorem totalBound_nonneg (M : VolterraGridSystem ζ ι H) : 0≤M.totalBound :=
  Finset.sum_nonneg fun j _=>M.bound_nonneg j

theorem stateRange_two (M : VolterraGridSystem ζ ι H) : 2≤M.stateRange := by unfold stateRange;omega

theorem stateRange_lower (M : VolterraGridSystem ζ ι H) :
    ((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound)+2≤(M.stateRange:ℝ) := by
  have hh:=Nat.le_ceil (((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound))
  unfold stateRange
  push_cast
  linarith

theorem stateRange_upper (M : VolterraGridSystem ζ ι H) :
    (M.stateRange:ℝ)<((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound)+3 := by
  have hr:=M.totalBound_nonneg
  have hh:=Nat.ceil_lt_add_one (show 0≤((Fintype.card M.StateIndex:ℝ)+1)*(3+M.totalBound) by positivity)
  unfold stateRange
  push_cast
  linarith

theorem tolerance_pos (M : VolterraGridSystem ζ ι H) {η : ℝ} (hη : 0<η) : 0<M.tolerance η :=
  picardInnerTolerance_pos _ _ _ hη

theorem tolerance_one (M : VolterraGridSystem ζ ι H) {η : ℝ} (hη : 0<η) (hη1 : η≤1) : M.tolerance η≤1 :=
  (picardInnerTolerance_le _ _ _ hη.le).trans hη1

theorem mesh_pos (M : VolterraGridSystem ζ ι H) (η : ℝ) : 0<M.mesh η :=picardOuterMesh_pos _ _ _ _ _

theorem selected_residual_range (M : VolterraGridSystem ζ ι H) {η : ℝ}
    (hη : 0<η) (hη1 : η≤1) (j : Fin (H+1)) :
    M.bound j+(M.tolerance η+((Fintype.card ι:ℝ)+1)*M.tolerance η)≤M.stateRange := by
  have ht:=(picardInnerTotal_le (Fintype.card M.InputIndex) (Fintype.card M.StateIndex)
    (Fintype.card ι) hη.le).trans hη1
  have hj:M.bound j≤M.totalBound:=Finset.single_le_sum (fun i _=>M.bound_nonneg i) (Finset.mem_univ j)
  have hlow:=M.stateRange_lower
  have hr:=M.totalBound_nonneg
  have hk:0≤(Fintype.card M.StateIndex:ℝ):=Nat.cast_nonneg _
  have hmul:=mul_nonneg hk (show 0≤3+M.totalBound by linarith)
  change M.tolerance η+((Fintype.card ι:ℝ)+1)*M.tolerance η≤1 at ht
  nlinarith

theorem update_range (M : VolterraGridSystem ζ ι H)
    (x : EuclideanSpace ℝ ζ) (u : Fin (H+1)→EuclideanSpace ℝ ι) {R : ℝ} (hx : ‖x‖≤R) :
    ‖M.update (WithLp.toLp 2 (Sum.elim (fun i=>x i) (fun z=>u z.1 z.2)))‖≤
      ((Fintype.card M.StateIndex:ℝ)+1)*(R+M.totalBound) := by
  have hR:0≤R:=(norm_nonneg x).trans hx
  have htot:=M.totalBound_nonneg
  apply euclidean_norm_of_coordinate_bounds _ (by positivity)
  intro z
  have he:=volterraCoefficients_eval M.base M.transfer M.residual x u z
  change |affineRealMap _ _ _ z|≤_
  change |affineRealMap (volterraCoefficients M.base M.transfer) _ _ z|≤_
  rw [he]
  exact (PiLp.norm_apply_le _ z.2).trans ((finiteVolterraValue_norm M.base M.transfer M.residual
    M.base_norm M.transfer_norm M.bound M.bound_nonneg M.residual_range x u z.1).trans
      (by change ‖x‖+M.totalBound≤R+M.totalBound; linarith))

#print axioms update_range
end VolterraGridSystem
end ConditionalNonpolynomial.AnalyticLookup
