import NeuralGeneralization.OnlineLowerReluRailCode
import NeuralGeneralization.OnlineLowerGeometryCode

/-! # Actual coordinate-column codes as physical Walsh code maps -/

noncomputable section

namespace NeuralGeneralization.OnlineLowerRelu

/-- A concrete code built from physical coordinate columns. Singleton
columns provide injectivity; the syndrome and character law are derived. -/
def coordinateWalshCode {d m : ℕ} (base : Finset (Fin d))
    (column : Fin d → Finset (Fin m)) (privateCoord : Fin m → Fin d)
    (hprivate : ∀ i, column (privateCoord i) = {i}) :
    OnlineLowerGeometry.WalshCodeMap d m where
  support := generatedSupport base (coordinateGenerator column)
  syndrome := generatedSyndrome (coordinateGenerator column)
  support_injective := generatedSupport_injective base (coordinateGenerator column)
    privateCoord (coordinateGenerator_private column privateCoord hprivate)
  character := by
    intro s x
    simpa only [generatedSupport_empty] using
      generatedSupport_character base (coordinateGenerator column) s x

end NeuralGeneralization.OnlineLowerRelu
