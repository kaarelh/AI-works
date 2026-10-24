import NeuralGeneralization.BatchTwoOnlineSharpCompressionError
import NeuralGeneralization.CompressionSampling
import NeuralGeneralization.MarginRescaling

/-! Actual sharp norm compression, with the exact scalar tolerance appearing
in the online paper's appendix. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel Compression CompressionSampling

def normRho (r : ℕ) (K : ℝ) : ℝ :=
  (12*((r:ℝ)+1)*(2:ℝ)^(r+2)*(Real.sqrt K)^(r+1))⁻¹

def normWidth (d r : ℕ) (K : ℝ) : ℕ := max ⌈9*K⌉₊
  ⌈256*(normRho r K)⁻¹^4*((d:ℝ)+Real.log (((r:ℝ)+2)/normRho r K))⌉₊

theorem normRho_pos {r : ℕ} {K : ℝ} (hK : 1≤K) : 0<normRho r K := by
  unfold normRho
  positivity

theorem normRho_error_identity {r : ℕ} {K : ℝ} (hK : 1≤K) :
    2*((r:ℝ)+1)*normRho r K*(2*Real.sqrt K)^(r+1)=1/12 := by
  have hsq:Real.sqrt K≠0:=ne_of_gt (Real.sqrt_pos.mpr (by linarith))
  have hr:(r:ℝ)+1≠0:=by positivity
  unfold normRho
  rw [mul_pow,show r+2=(r+1)+1 by omega,pow_succ]
  field_simp
  <;> ring

theorem normRho_le_one_twentyfour {r : ℕ} {K : ℝ} (hK : 1≤K) : normRho r K≤1/24 := by
  have hs:1≤Real.sqrt K:=by exact (Real.one_le_sqrt).mpr hK
  have hp:1≤(Real.sqrt K)^(r+1):=one_le_pow₀ hs
  have htwo:(2:ℝ)≤(2:ℝ)^(r+2):=by
    simpa only [pow_one] using pow_le_pow_right₀ (by norm_num : (1:ℝ)≤2) (show 1≤r+2 by omega)
  have hbase:24≤12*((r:ℝ)+1)*(2:ℝ)^(r+2)*(Real.sqrt K)^(r+1):=by
    have hr:1≤(r:ℝ)+1:=by linarith [Nat.cast_nonneg r (α:=ℝ)]
    nlinarith [mul_le_mul htwo hp (by norm_num : (0:ℝ)≤1) (by positivity : (0:ℝ)≤(2:ℝ)^(r+2))]
  simpa only [normRho,one_div] using (one_div_le_one_div_of_le (by norm_num : (0:ℝ)<24) hbase)

/-- All hypotheses beyond the actual network are explicit scalar inequalities.
The retained-row probability and good-sample existence are proved internally. -/
theorem norm_compression_of_row_bound {d N r M : ℕ} (hd : 1≤d) (hN : 0<N)
    {K : ℝ} (hK : 1≤K) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (w : Weights d N r) (hw : weightedSquaredNorm w≤K)
    (hmargin : w∈marginEvent φ (1/2) f) (hM : 0<M) (hbudget : 9*K≤M)
    (hwidth : (((r:ℝ)*M+1)*2^d*(2*Real.exp (-(normRho r K)^4*(M:ℝ)/32)))≤1/4) :
    ∃v : Weights d M r,v∈marginEvent φ (1/2) f ∧ boundedWeights M v ∧ weightedSquaredNorm v≤9*K := by
  letI : NeZero N:=⟨hN.ne'⟩
  let ρ:=normRho r K
  let q:=Real.sqrt (N:ℝ)
  have hρ:0<ρ:=normRho_pos hK
  have hq:0<q:=Real.sqrt_pos.mpr (by exact_mod_cast hN)
  have hqsq:q^2=(N:ℝ):=Real.sq_sqrt (Nat.cast_nonneg N)
  let u:=prunedWeights ρ q w
  have hu:weightedSquaredNorm u≤K:=(prunedWeights_cost_le ρ q w).trans hw
  obtain ⟨I,hcost,hmass,hrows,hread⟩:=exists_good_sampling_lists (M:=M) hM φ hφ.1 hρ hq hqsq
    (by linarith : 0<K) w u hw hu (prunedWeights_internal_bound hρ.le hq.le w)
    (prunedWeights_output_bound hρ.le hq.le w) hwidth
  let v:=sampledWeights u I
  have herr (x : Cube d):|networkOutput φ v x-networkOutput φ w x|≤1/12 := by
    have hs:=sampled_output_sharp hM φ hφ hρ hq hqsq hK w u hw I hcost hmass x (hrows x) (hread x)
    have hp:=pruned_output_sharp hN φ hφ hρ hq hqsq hK w hw x
    have hp' : ((r:ℝ)+1)*ρ*(Real.sqrt K)^(r+1)≤((r:ℝ)+1)*ρ*(2*Real.sqrt K)^(r+1):=by gcongr;linarith [Real.sqrt_nonneg K]
    have hi:=normRho_error_identity (r:=r) hK
    have ht:=abs_sub_le (networkOutput φ v x) (networkOutput φ u x) (networkOutput φ w x)
    change |networkOutput φ v x-networkOutput φ u x|≤_ at hs
    change |networkOutput φ u x-networkOutput φ w x|≤_ at hp
    change 2*((r:ℝ)+1)*ρ*(2*Real.sqrt K)^(r+1)=1/12 at hi
    nlinarith
  have hscaled:weightedSquaredNorm (rescaleReadout (3/2) v)≤9*K:=by
    have hh:=rescaleReadout_cost_le (show (1:ℝ)≤3/2 by norm_num) v
    change weightedSquaredNorm v≤4*K at hcost
    nlinarith
  exact ⟨rescaleReadout (3/2) v,rescaleReadout_preserves_margin φ f w v hmargin herr,
    boundedWeights_of_cost hd hM _ (hscaled.trans hbudget),hscaled⟩

end NeuralGeneralization.BatchTwoOnlineSharp
