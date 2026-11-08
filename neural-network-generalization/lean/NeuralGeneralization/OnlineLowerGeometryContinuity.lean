import NeuralGeneralization.OnlineLowerGeometryReluFourier
import NeuralGeneralization.OnlineLowerGeometryCompact
import Mathlib.Topology.Algebra.Order.Field

/-! # Continuity of the actual finite Fourier score constraints -/

noncomputable section
open scoped BigOperators Classical

namespace NeuralGeneralization.OnlineLowerGeometry

variable {X : Type*} [TopologicalSpace X]

theorem continuous_cube_mean {d : ℕ} (F : X → ClippingCube d → ℝ)
    (hF : ∀ x, Continuous (fun q => F q x)) :
    Continuous (fun q => uniformCubeMean (F q)) := by
  unfold uniformCubeMean
  exact (continuous_finsetSum _ (fun x _ => hF x)).div_const _

theorem continuous_walsh_coefficient {d : ℕ} (F : X → ClippingCube d → ℝ)
    (hF : ∀ x, Continuous (fun q => F q x)) (s : Finset (Fin d)) :
    Continuous (fun q => walshCoefficients (F q) s) := by
  unfold walshCoefficients
  exact continuous_cube_mean _ (fun x => (hF x).mul continuous_const)

theorem continuous_walsh_expansion {d : ℕ} (a : X → Finset (Fin d) → ℝ)
    (ha : ∀ s, Continuous (fun q => a q s)) (x : ClippingCube d) :
    Continuous (fun q => walshExpansion (a q) x) := by
  unfold walshExpansion
  exact continuous_finsetSum _ (fun s _ => (ha s).mul continuous_const)

theorem continuous_weighted_walsh_cost {d : ℕ} (w : Finset (Fin d) → ℝ)
    (F : X → ClippingCube d → ℝ) (hF : ∀ x, Continuous (fun q => F q x)) :
    Continuous (fun q => weightedWalshCost w (F q)) := by
  unfold weightedWalshCost weightedL1
  exact continuous_finsetSum _ (fun s _ => continuous_const.mul
    (continuous_walsh_coefficient F hF s).abs)

namespace WalshCodeMap

variable {d m : ℕ} (C : WalshCodeMap d m)

theorem continuous_logical_projection (F : X → ClippingCube d → ℝ)
    (hF : ∀ x, Continuous (fun q => F q x)) (z : ClippingCube m) :
    Continuous (fun q => C.logicalProjection (F q) z) := by
  unfold logicalProjection
  exact continuous_walsh_expansion _ (fun s => continuous_walsh_coefficient F hF (C.support s)) z

theorem continuous_project (F : X → ClippingCube d → ℝ)
    (hF : ∀ x, Continuous (fun q => F q x)) (x : ClippingCube d) :
    Continuous (fun q => C.project (F q) x) := by
  unfold project
  exact continuous_const.mul (C.continuous_logical_projection F hF _)

end WalshCodeMap

theorem continuous_relu_slack {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : X → ClippingCube m → ℝ)
    (hg : ∀ z, Continuous (fun q => g q z)) :
    Continuous (fun q => reluCalibrationSlack w H v (g q)) := by
  unfold reluCalibrationSlack
  apply continuous_cube_mean
  intro z
  by_cases hz : cubeTranslation v z ∈ H.carrier
  · simp only [if_pos hz]
    exact continuous_const
  · simp only [if_neg hz]
    exact continuous_const.mul ((hg z).sub continuous_const)

theorem continuous_relu_deficit {m : ℕ} (w : Finset (Fin m) → ℝ)
    (H : CubeSubgroup m) (v : ClippingCube m) (g : X → ClippingCube m → ℝ)
    (hg : ∀ z, Continuous (fun q => g q z)) (B : X → ℝ) (hB : Continuous B) :
    Continuous (fun q => reluDualDeficit w H v (g q) (B q)) := by
  unfold reluDualDeficit
  exact hB.sub (continuous_cube_mean _ (fun z => continuous_const.mul (hg z)))

theorem continuous_relu_live_mass {m : ℕ} (H : CubeSubgroup m) (v : ClippingCube m)
    (g : X → ClippingCube m → ℝ) (hg : ∀ z, Continuous (fun q => g q z)) (z : ClippingCube m) :
    Continuous (fun q => reluLiveMass H v (g q) z) := by
  unfold reluLiveMass
  by_cases hz : cubeTranslation v z ∈ H.carrier
  · simp only [if_pos hz]
    exact (hg z).add continuous_const
  · simp only [if_neg hz]
    exact continuous_const

end NeuralGeneralization.OnlineLowerGeometry
