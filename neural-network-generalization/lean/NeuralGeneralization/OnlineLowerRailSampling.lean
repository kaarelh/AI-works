import NeuralGeneralization.OnlineLowerRailSystem
import Mathlib.Data.Fintype.Pi

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerRelu

abbrev RailBits {p : ℕ} (size : Fin p → Bool → ℕ) :=
  (i : Fin p) → (b : Bool) → Fin (size i b) → Bool

/-- A physical input is exactly an independent assignment to every coordinate
of every physical rail. This is an equivalence, rather than a distributional
independence hypothesis. -/
def railCubeEquiv {p : ℕ} (size : Fin p → Bool → ℕ) :
    ClippingCube (railDimension size) ≃ RailBits size where
  toFun x i b k := x (railIndex size ⟨i,b,k⟩)
  invFun y j := y (((railIndex size).symm j).1)
    (((railIndex size).symm j).2.1) (((railIndex size).symm j).2.2)
  left_inv x := by
    funext j
    change x ((railIndex size) ((railIndex size).symm j)) = x j
    rw [Equiv.apply_symm_apply]
  right_inv y := by
    funext i b k
    change y (((railIndex size).symm ((railIndex size) ⟨i,b,k⟩)).1)
      (((railIndex size).symm ((railIndex size) ⟨i,b,k⟩)).2.1)
      (((railIndex size).symm ((railIndex size) ⟨i,b,k⟩)).2.2) = y i b k
    rw [Equiv.symm_apply_apply]

theorem railCube_inverse_apply {p : ℕ} (size : Fin p → Bool → ℕ)
    (y : RailBits size) (a : RailCoord size) :
    (railCubeEquiv size).symm y (railIndex size a) = y a.1 a.2.1 a.2.2 := by
  change y (((railIndex size).symm ((railIndex size) a)).1)
    (((railIndex size).symm ((railIndex size) a)).2.1)
    (((railIndex size).symm ((railIndex size) a)).2.2) = _
  rw [Equiv.symm_apply_apply]

/-- Exact transport of the physical uniform average under rail coordinates. -/
theorem rail_uniform_average {p : ℕ} (size : Fin p → Bool → ℕ)
    (f : ClippingCube (railDimension size) → ℝ) :
    (∑ x,f x)/(2:ℝ)^railDimension size =
      (∑ y:RailBits size,f ((railCubeEquiv size).symm y))/(2:ℝ)^railDimension size := by
  congr 1
  exact ((railCubeEquiv size).symm.sum_comp f).symm

/-- Separate an arbitrary selected orientation from its opposite rails. -/
def orientedRailBitsEquiv {p : ℕ} (size : Fin p → Bool → ℕ) (side : Fin p → Bool) :
    RailBits size ≃
      (((i:Fin p) → Fin (size i (side i)) → Bool) ×
       ((i:Fin p) → Fin (size i (!(side i))) → Bool)) where
  toFun y := (fun i => y i (side i), fun i => y i (!(side i)))
  invFun z i b k := if h:b=side i then z.1 i (h ▸ k) else
    z.2 i (by
      have hb : b= !(side i) := by
        cases b <;> cases hs:side i <;> simp_all
      exact hb ▸ k)
  left_inv y := by
    funext i b k
    dsimp only
    split
    · rename_i h
      cases h
      rfl
    · have heval : ∀ (c:Bool) (h:b=c), y i c (h ▸ k) = y i b k := by
        intro c h
        cases h
        rfl
      exact heval _ _
  right_inv z := by
    apply Prod.ext
    · funext i k
      simp
    · funext i k
      cases hs:side i <;> simp [hs]

/-- Split off the first and last coordinates of a rail, leaving exactly `r`
free bits. These are the literal independent variables in the parity sampler. -/
def endBitsEquiv (r : ℕ) : (Fin (r+2) → Bool) ≃ Bool × (Fin r → Bool) × Bool where
  toFun x := (x 0, (fun i => x ⟨i+1,by omega⟩),x (Fin.last (r+1)))
  invFun z i := if h0:i.val=0 then z.1 else
    if hl:i.val=r+1 then z.2.2 else z.2.1 ⟨i.val-1,by omega⟩
  left_inv x := by
    funext i
    dsimp only
    split
    · congr 1; apply Fin.ext; simp; omega
    · split
      · congr 1; apply Fin.ext; simp; omega
      · congr 1; apply Fin.ext; simp; omega
  right_inv z := by
    apply Prod.ext
    · simp
    · apply Prod.ext
      · funext i
        have hi := i.isLt
        simp [show (i:ℕ)≠r by omega]
      · simp

end NeuralGeneralization.OnlineLowerRelu
