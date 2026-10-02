import Paulsen.Linear.ManyRowParameters
import Paulsen.Linear.Assembly

/-!
# The many-row seed (`thm:manyrow`)

For `n ≥ B d²` and spectral error `0 < η ≤ c_*` (an absolute constant, no
`1/d²` factor), every equal-norm frame is within `C_* η d` of an equal-norm
Parseval frame. The construction: the constrained Gaussian `Z = Π_F g/√n`,
the coupled row-independent `Z₀ = Π_E g/√n`, row normalisation at amplitude
`t = √(K η)`, the centred remainder estimate, Markov and net events, the
dense reference core of the `Z₀`-seed, whitening, and static balancing
(through the barrier-form endpoint `correction_of_dense_reference_gram_barrier`).
-/

namespace Paulsen.Linear

open Paulsen

noncomputable section

/-- The many-row theorem at fixed `n, d, η`. -/
theorem manyRow_equalRowBound {n d : ℕ} (hd : 0 < d) (hdn : d ≤ n)
    (hsize : manyRowB * (d : ℝ) ^ 2 ≤ n)
    {η : ℝ} (hη : 0 < η) (hηcap : η ≤ manyRowC) :
    EqualRowBound n d η manyRowCost := by
  intro X hXn hXp
  set t := Real.sqrt (manyRowK * η)
  have hb : ManyRowScalarBounds n d η t := manyRowScalarBounds hd hη hηcap hsize
  have hh : 0 < manyRowH := by norm_num [manyRowH]
  obtain ⟨g, hdense, hZop, hZ₀op, hH, hC, hfl, hM⟩ :=
    exists_manyRow_sample X hb.n_ge hd hdn hXn hb.t_pos hb.t_le hh hb.small_ball
  have hfl' : ‖conditionedFluctuation X g‖ ≤ manyRowFluctuation n d := by
    apply Real.le_sqrt_of_sq_le
    have heq : 100 * (8 * (d : ℝ) ^ 2 / n) = 800 * (d : ℝ) ^ 2 / n := by ring
    rw [heq] at hfl
    exact hfl.le
  have hQ : (0 : ℝ) ≤ manyRowQ := by norm_num [manyRowQ]
  have hM0 : (0 : ℝ) ≤ manyRowMoment n d := by unfold manyRowMoment; positivity
  have hc := manyRow_conditioned_correction_of_sample hd hdn X η t (manyRowDelta t)
    (manyRowGamma n d t) (manyRowRho n d t) (100 * d) (100 * ((d : ℝ) ^ 2 / n))
    (manyRowFluctuation n d) manyRowQ (manyRowMoment n d) g
    hXn hXp hη.le hQ hM0 hH.le hC.le hfl'
    (frameEnergy_le_of_operator_norm_le _ 128 hZop)
    (frameEnergy_le_of_operator_norm_le _ 128 hZ₀op)
    hM.le hb.covariance hb.delta_pos.le hb.delta_half hb.gamma_pos hb.gamma_le hb.rho_pos
    hdense hb.row hb.count hb.leverage hb.small
  exact hc.mono hb.cost

/-- **Many-row seed theorem** (`thm:manyrow`), in the interface of the
partition-free assembly. -/
theorem manyRowBound : ManyRowBound manyRowB manyRowC manyRowCost := by
  intro n d hd hdn hsize η hη hηcap
  exact manyRow_equalRowBound hd hdn hsize hη hηcap

end

end Paulsen.Linear
