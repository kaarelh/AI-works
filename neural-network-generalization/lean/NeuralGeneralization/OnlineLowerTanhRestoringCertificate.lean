import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle0
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle1
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle2
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle3
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle4
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle5
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle6
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle7
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle8
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle9
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangle10
import NeuralGeneralization.OnlineLowerTanhRestoringCertificateRectangles

/-! Exact rational positivity certificate for the finite restoring polynomial.

The eleven rectangle modules contain the integer-scaled Bernstein coefficients.
All coefficient signs and polynomial identities are checked by the Lean kernel;
the external calculation that discovered the coefficients is not a premise.
-/
noncomputable section
namespace NeuralGeneralization.OnlineLowerTanh

theorem restoringPolynomial_gt_margin {q x : ℝ}
    (hqlo : 1 / 256 ≤ q) (hqhi : q ≤ 17 / 200)
    (hxlo : -1 ≤ x) (hxhi : x ≤ 1) :
    1 / 10000 < restoringPolynomial q x := by
  have hp : 0 < restoringPolynomialExpanded q x :=
    restoringCertificate_rectangles_elim
      (fun q x => 0 < restoringPolynomialExpanded q x)
      (fun _ _ => restoringRectangle0_pos)
      (fun _ _ => restoringRectangle1_pos)
      (fun _ _ => restoringRectangle2_pos)
      (fun _ _ => restoringRectangle3_pos)
      (fun _ _ => restoringRectangle4_pos)
      (fun _ _ => restoringRectangle5_pos)
      (fun _ _ => restoringRectangle6_pos)
      (fun _ _ => restoringRectangle7_pos)
      (fun _ _ => restoringRectangle8_pos)
      (fun _ _ => restoringRectangle9_pos)
      (fun _ _ => restoringRectangle10_pos)
      hqlo hqhi hxlo hxhi
  rw [← restoringPolynomial_eq_expanded] at hp
  linarith

end NeuralGeneralization.OnlineLowerTanh
