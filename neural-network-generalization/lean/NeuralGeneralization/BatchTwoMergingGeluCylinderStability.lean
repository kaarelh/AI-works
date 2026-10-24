import NeuralGeneralization.BatchTwoMergingGeluRescaling

/-! Gaussian cylinder stability for actual GELU networks. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Matrix
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

def geluCylinderOutputFactor (d r : ℕ) (K G B : ℝ) : ℝ :=
  4*unboundedCylinderOutputFactor d r (4*K) G (2*B)

theorem gelu_cylinder_output_sq {d N r : ℕ} (hN : 0<N)
    (w v : Weights d N r) (R E : Fin r→Fin N→Fin N→ℝ) {K G B ρ : ℝ}
    (hK : 0≤K) (hG : 0≤G) (hρ : 0≤ρ) (hρ1 : ρ≤1/2)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hv : weightedSquaredNorm v≤K)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*G)
    (hE : ∀s,matrixActionBound (E s) B)
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ)
    (hread : ∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N)
    (hbounded : ∀(x : Cube d) (ss : List (Fin r)) i,
      |ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) i|≤1)
    (hkill : ∀(x : Cube d) (ss : List (Fin r)) (s : Fin r) (i : Fin N),
      (∑j,E s i j*ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) j)=0)
    (x : Cube d) :
    (networkOutput gelu w x-networkOutput gelu v x)^2≤
      ρ^2*geluCylinderOutputFactor d r K G B := by
  have hd : ∀s i j,doubledOutgoing w (Sum.inr (Sum.inl (s,i,j)))=
      doubledOutgoing v (Sum.inr (Sum.inl (s,i,j)))+2*R s i j+2*E s i j := by
    intro s i j
    simp only [doubledOutgoing,hdecomp]
    ring
  have hc : weightedSquaredNorm (doubledOutgoing v)≤4*K :=
    (doubledOutgoing_energy v).trans (mul_le_mul_of_nonneg_left hv (by norm_num))
  have hR' (s : Fin r) : (∑i,∑j,(2*R s i j)^2)≤(2*ρ)^2*G := by
    have hh := mul_le_mul_of_nonneg_left (hR s) (by norm_num : (0:ℝ)≤4)
    have he (z:ℝ) : (2*z)^2=4*z^2 := by ring
    simp only [he,←Finset.mul_sum]
    nlinarith
  have hE' (s : Fin r) : matrixActionBound (fun i j=>2*E s i j) (2*B) := by
    intro z
    have hh := mul_le_mul_of_nonneg_left (hE s z) (by norm_num : (0:ℝ)≤4)
    simp_rw [mul_assoc,←Finset.mul_sum]
    have he (z:ℝ) : (2*z)^2=4*z^2 := by ring
    simp only [he,←Finset.mul_sum]
    nlinarith
  have hf : ∀i j,|doubledOutgoing w (Sum.inl (i,j))-
      doubledOutgoing v (Sum.inl (i,j))|≤2*ρ := by
    intro i j
    exact (hfirst i j).trans (by linarith)
  have hr : ∀i,|doubledOutgoing w (Sum.inr (Sum.inr i))-
      doubledOutgoing v (Sum.inr (Sum.inr i))|≤(2*ρ)/N := by
    intro i
    simp only [doubledOutgoing,←mul_sub,abs_mul,abs_of_nonneg (by norm_num : (0:ℝ)≤2)]
    have hh := mul_le_mul_of_nonneg_left (hread i) (by norm_num : (0:ℝ)≤2)
    convert hh using 1
    all_goals first | rfl | ring
  have hb : ∀(x:Cube d) (ss:List (Fin r)) i,
      |ss.foldl (hiddenStep halfGelu (doubledOutgoing v))
        (firstHidden halfGelu (doubledOutgoing v) x) i|≤1 := by
    intro x ss i
    rw [halfGelu_hiddenFold]
    simp only [abs_div,abs_of_nonneg (by norm_num : (0:ℝ)≤2)]
    linarith [hbounded x ss i]
  have hk : ∀(x:Cube d) (ss:List (Fin r)) s i,
      (∑j,(2*E s i j)*ss.foldl (hiddenStep halfGelu (doubledOutgoing v))
        (firstHidden halfGelu (doubledOutgoing v) x) j)=0 := by
    intro x ss s i
    rw [halfGelu_hiddenFold]
    have he (j:Fin N) : (2*E s i j)*
        (ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) j/2)=
        E s i j*ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) j := by ring
    simp only [he]
    exact hkill x ss s i
  have hh := unbounded_cylinder_output_sq hN halfGelu_lipschitzZero
    (doubledOutgoing w) (doubledOutgoing v) (fun s i j=>2*R s i j) (fun s i j=>2*E s i j)
    (show 0≤4*K by positivity) hG (show 0≤2*ρ by positivity) (show 2*ρ≤1 by linarith)
    hd hc hR' hE' hf hr hb hk x
  rw [halfGelu_networkOutput,halfGelu_networkOutput] at hh
  unfold geluCylinderOutputFactor
  convert hh using 1
  all_goals first | rfl | ring

theorem gelu_merged_cylinder_output_sq {d N r : ℕ} (hN : 0<N)
    (p : PopulationPartition N) (w v : Weights d N r)
    (R E : Fin r→Fin N→Fin N→ℝ) {K G B ρ : ℝ}
    (hK : 0≤K) (hG : 0≤G) (hρ : 0≤ρ) (hρ1 : ρ≤1/2)
    (hfixed : mergedWeights (fun _=>p) v=v)
    (hdecomp : ∀s i j,w (Sum.inr (Sum.inl (s,i,j)))=
      v (Sum.inr (Sum.inl (s,i,j)))+R s i j+E s i j)
    (hkill : ∀s,Matrix.of (E s)*Matrix.of (populationProjection p)=0)
    (hv : weightedSquaredNorm v≤K)
    (hR : ∀s,(∑i,∑j,R s i j^2)≤ρ^2*G)
    (hfirst : ∀i j,|w (Sum.inl (i,j))-v (Sum.inl (i,j))|≤ρ)
    (hread : ∀i,|w (Sum.inr (Sum.inr i))-v (Sum.inr (Sum.inr i))|≤ρ/N)
    (hbounded : ∀(x:Cube d) (ss:List (Fin r)) i,
      |ss.foldl (hiddenStep gelu v) (firstHidden gelu v x) i|≤1)
    (x:Cube d) :
    (networkOutput gelu (mergedWeights (fun _=>p) w) x-networkOutput gelu v x)^2≤
      ρ^2*geluCylinderOutputFactor d r K G B := by
  apply gelu_cylinder_output_sq hN (mergedWeights (fun _=>p) w) v
    (fun s i j=>mergedPerturbation p R s i j) (fun _ _ _=>0)
    hK hG hρ hρ1 (merged_internal_decomposition p w v R E hfixed hdecomp hkill) hv
  · intro s
    exact (mergedPerturbation_squaredSum_le p R s).trans (hR s)
  · intro s z
    simp only [zero_mul,Finset.sum_const_zero,zero_pow (by omega : 2≠0)]
    positivity
  · intro i j
    rw [merged_first_difference w v hfixed]
    exact populationAverage_abs_le p _ ρ (fun k=>hfirst k j) i
  · intro i
    rw [merged_readout_difference w v hfixed]
    exact populationAverage_abs_le p _ (ρ/N) hread i
  · exact hbounded
  · intro x ss s i
    simp

end NeuralGeneralization.BatchTwoMerging
