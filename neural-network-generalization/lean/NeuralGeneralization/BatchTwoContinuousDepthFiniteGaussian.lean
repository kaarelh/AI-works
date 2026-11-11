import NeuralGeneralization.GaussianMatrixTail
import NeuralGeneralization.GaussianApproximationTail

/-! Literal Gaussian-block constants in the finite-scale approximation lemma. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false

def firstNoiseSquared (d : ℕ) : ℝ := 2*((d : ℝ)+1)*Real.log 2+4*Real.log 8

def internalNoiseSquared (L : ℕ) : ℝ := 16*Real.log 9+8*Real.log (8*(L : ℝ))

def noiseSquared (d L : ℕ) : ℝ := max (firstNoiseSquared d) (internalNoiseSquared L)

def noiseRadius (d L : ℕ) : ℝ := Real.sqrt (noiseSquared d L)

theorem firstNoiseSquared_pos (d : ℕ) : 0 < firstNoiseSquared d := by
  have h2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h8 : 0 < Real.log 8 := Real.log_pos (by norm_num)
  unfold firstNoiseSquared
  positivity

theorem internalNoiseSquared_pos {L : ℕ} (hL : 1 ≤ L) : 0 < internalNoiseSquared L := by
  have hLR : (1 : ℝ) ≤ L := by exact_mod_cast hL
  have h9 : 0 < Real.log 9 := Real.log_pos (by norm_num)
  have h8 : 0 < Real.log (8*(L : ℝ)) := Real.log_pos (by linarith)
  unfold internalNoiseSquared
  positivity

theorem noiseRadius_pos (d L : ℕ) : 0 < noiseRadius d L := by
  apply Real.sqrt_pos.2
  exact lt_of_lt_of_le (firstNoiseSquared_pos d) (le_max_left _ _)

theorem inverse_sqrt_half : (Real.sqrt (1/2 : ℝ))⁻¹=Real.exp (Real.log 2/2) := by
  have hp : 0 < Real.sqrt (1/2 : ℝ) := Real.sqrt_pos.2 (by norm_num)
  have hs := Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 1/2)
  have he : (Real.exp (Real.log 2/2))^2=2 := by
    rw [← Real.exp_nat_mul]
    norm_num only [Nat.cast_ofNat]
    rw [show (2 : ℝ)*(Real.log 2/2)=Real.log 2 by ring,Real.exp_log (by norm_num)]
  have hi : ((Real.sqrt (1/2 : ℝ))⁻¹)^2=2 := by
    rw [inv_pow, hs]
    norm_num
  nlinarith [Real.exp_pos (Real.log 2/2), inv_pos.mpr hp]

/-- One eighth tail for either boundary block, with the paper's exact a_d. -/
theorem gaussian_boundary_paper_tail {ι : Type*} [Fintype ι] {N d : ℕ}
    (hN : 1 ≤ N) (hcard : Fintype.card ι ≤ N*(d+1))
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (Measure.pi fun _ : ι => gaussianReal 0 v).real
      {x | (N : ℝ)*v*firstNoiseSquared d ≤ ∑ i,x i^2} ≤ 1/8 := by
  have h := GaussianTail.gaussian_squaredNorm_rate_upper (ι:=ι) v hv
    ((N : ℝ)*v*firstNoiseSquared d) (1/2) (by norm_num) (by norm_num)
  rw [inverse_sqrt_half, ← Real.exp_nat_mul, ← Real.exp_add] at h
  have hNR : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hcardR : (Fintype.card ι : ℝ) ≤ (N : ℝ)*((d : ℝ)+1) := by exact_mod_cast hcard
  have hl2 : 0 ≤ Real.log 2 := Real.log_nonneg (by norm_num)
  have hl8 : 0 ≤ Real.log 8 := Real.log_nonneg (by norm_num)
  have he : -((1-(1/2 : ℝ))*((N : ℝ)*v*firstNoiseSquared d))/(2*(v : ℝ))+
      (Fintype.card ι : ℝ)*(Real.log 2/2) ≤ -Real.log 8 := by
    have hcancel : -((1-(1/2 : ℝ))*((N : ℝ)*v*firstNoiseSquared d))/(2*(v : ℝ))=
        -(N : ℝ)*firstNoiseSquared d/4 := by field_simp; ring
    rw [hcancel]
    have hc := mul_le_mul_of_nonneg_right hcardR hl2
    have hn := mul_le_mul_of_nonneg_right hNR hl8
    unfold firstNoiseSquared
    nlinarith
  apply h.trans
  calc
    _ ≤ Real.exp (-Real.log 8) := Real.exp_le_exp.mpr he
    _ = 1/8 := by rw [Real.exp_neg,Real.exp_log (by norm_num)]; norm_num

/-- The two quarter-nets give the literal one/(4L) internal-block tail. -/
theorem gaussian_internal_paper_tail {N L : ℕ} (hN : 1 ≤ N) (hL : 1 ≤ L)
    (v : ℝ≥0) (hv : 0 < (v : ℝ)) :
    (Measure.pi fun _ : Fin N × Fin N => gaussianReal 0 v).real
      {z | Real.sqrt ((N : ℝ)*v)*Real.sqrt (internalNoiseSquared L) <
        ‖coordinateMatrixOperator z‖} ≤ 1/(4*(L : ℝ)) := by
  have hbp := internalNoiseSquared_pos hL
  have h := GaussianTail.gaussian_matrix_operator_tail (m:=Fin N) (n:=Fin N) v hv
    (Real.sqrt ((N : ℝ)*v)*Real.sqrt (internalNoiseSquared L)/2) (by positivity)
  have hs : 2*(Real.sqrt ((N : ℝ)*v)*Real.sqrt (internalNoiseSquared L)/2)=
      Real.sqrt ((N : ℝ)*v)*Real.sqrt (internalNoiseSquared L) := by ring
  have he : -(Real.sqrt ((N : ℝ)*v)*Real.sqrt (internalNoiseSquared L)/2)^2/(2*(v : ℝ))=
      -(N : ℝ)*internalNoiseSquared L/8 := by
    rw [div_pow,mul_pow,Real.sq_sqrt (by positivity),Real.sq_sqrt hbp.le]
    field_simp
    ring
  simp only [Fintype.card_fin,hs,he] at h
  have hpow : (9 : ℝ)^(N+N)=Real.exp (2*(N : ℝ)*Real.log 9) := by
    rw [show 2*(N : ℝ)*Real.log 9=(N+N : ℕ)*Real.log 9 by push_cast;ring,
      Real.exp_nat_mul,Real.exp_log (by norm_num)]
  rw [hpow,mul_assoc,← Real.exp_add] at h
  have hNR : (1 : ℝ) ≤ N := by exact_mod_cast hN
  have hLR : (1 : ℝ) ≤ L := by exact_mod_cast hL
  have hl : 0 ≤ Real.log (8*(L : ℝ)) := Real.log_nonneg (by linarith)
  have hex : 2*(N : ℝ)*Real.log 9-(N : ℝ)*internalNoiseSquared L/8 ≤
      -Real.log (8*(L : ℝ)) := by
    have hn := mul_le_mul_of_nonneg_right hNR hl
    unfold internalNoiseSquared
    nlinarith
  apply h.trans
  rw [show 2*(N : ℝ)*Real.log 9 + -(N : ℝ)*internalNoiseSquared L/8 =
    2*(N : ℝ)*Real.log 9-(N : ℝ)*internalNoiseSquared L/8 by ring]
  calc
    _ ≤ 2*Real.exp (-Real.log (8*(L : ℝ))) :=
      mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hex) (by norm_num)
    _ = 1/(4*(L : ℝ)) := by
      rw [Real.exp_neg,Real.exp_log (by positivity)]
      field_simp
      <;> ring

end NeuralGeneralization.BatchTwoContinuousDepthPaper
