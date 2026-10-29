import ArithmeticResourceBounds

noncomputable section
set_option maxHeartbeats 2500000
namespace ConditionalNonpolynomial.AnalyticLookup
open ConditionalNonpolynomial.Analytic
namespace ArithmeticProgram

def maxDimension : {d o : ℕ}→ArithmeticProgram d o→ℕ
  | d,_,.nil _=>d
  | d,_,.cons _ T=>max d T.maxDimension

theorem input_le_maxDimension {d o : ℕ} (P : ArithmeticProgram d o) : d≤P.maxDimension := by
  cases P with
  | nil _=>exact le_rfl
  | cons _ _=>exact le_max_left _ _

def resourceExponent (n : ℕ) : ℕ := 1000^(n+1)

lemma resourceExponent_pos (n : ℕ) : 1≤resourceExponent n := by
  unfold resourceExponent
  exact one_le_pow₀ (by norm_num)

lemma resourceExponent_succ (n : ℕ) : resourceExponent (n+1)=1000*resourceExponent n := by
  unfold resourceExponent
  rw [pow_succ]
  ring

/-- Fixed-depth arithmetic programs have polynomial range, reciprocal
precision, and compiler size. The exponent depends only on the program length;
coefficients and all dimensions enter only through the common resource scale. -/
theorem resources {d o : ℕ} (P : ArithmeticProgram d o) {R : ℝ} (hR : 2≤R)
    (B N Q : ℕ) {ε : ℝ} (hε : 0<ε)
    (hDim : (P.maxDimension:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R)
    (hQ : (Q:ℝ)≤R) (hεinv : 1/ε≤R) :
    (P.outputRange B N:ℝ)≤R^(resourceExponent P.length) ∧
    1/P.tolerance B N ε≤R^(resourceExponent P.length) ∧
    (P.sizeBudget Q B N:ℝ)≤R^(resourceExponent P.length) := by
  induction P generalizing R N with
  | nil d=>
    have hpow : R≤R^(resourceExponent 0) := by
      simpa only [pow_one] using resource_pow_mono hR (a:=1) (resourceExponent_pos 0)
    exact ⟨hN.trans hpow,hεinv.trans hpow,by simp only [sizeBudget,Nat.cast_zero]; positivity⟩
  | @cons di mi oi A T ih=>
    have hdi : (di:ℝ)≤R := (show (di:ℝ)≤(max di T.maxDimension:ℕ) by exact_mod_cast le_max_left di T.maxDimension).trans hDim
    have hDimT : (T.maxDimension:ℝ)≤R := (show (T.maxDimension:ℝ)≤(max di T.maxDimension:ℕ) by exact_mod_cast le_max_right di T.maxDimension).trans hDim
    have hmi0 : (mi:ℝ)≤T.maxDimension := by exact_mod_cast T.input_le_maxDimension
    have hmi : (mi:ℝ)≤R := hmi0.trans hDimT
    have hRp : R≤R^16 := by simpa only [pow_one] using resource_pow_mono hR (show 1≤16 by norm_num)
    have hR16 : 2≤R^16 := hR.trans hRp
    have hn := layerNextRange_resource hR hdi hB hN
    have hamp := layerAmplification_resource hR hdi hB hN
    have ht := ih hR16 (layerNextRange di B N) (hDimT.trans hRp) (hB.trans hRp) hn
      (hQ.trans hRp) (hεinv.trans hRp)
    rw [←pow_mul] at ht
    let E := resourceExponent T.length
    have hE : 1≤E := resourceExponent_pos _
    have hOut : (T.outputRange B (layerNextRange di B N):ℝ)≤R^(16*E) := ht.1
    have hInv : 1/T.tolerance B (layerNextRange di B N) ε≤R^(16*E) := ht.2.1
    have hSize : (T.sizeBudget Q B (layerNextRange di B N):ℝ)≤R^(16*E) := ht.2.2
    have hsizeLayer := arithmeticLayerSize_resource hR16 (hdi.trans hRp) (hmi.trans hRp)
      (hQ.trans hRp) (hB.trans hRp) (hN.trans hRp) hn
    rw [←pow_mul] at hsizeLayer
    have hOut' : (T.outputRange B (layerNextRange di B N):ℝ)≤R^(1000*E) :=
      hOut.trans (resource_pow_mono hR (by omega))
    have hInv' : 1/(T.tolerance B (layerNextRange di B N) ε/(layerAmplification di B N:ℝ))^2≤R^(1000*E) := by
      have htail0 : 0≤1/T.tolerance B (layerNextRange di B N) ε :=
        div_nonneg (by norm_num) (T.tolerance_pos B _ hε).le
      have hm := resource_mul hR hamp hInv htail0
      have hp := resource_pow hR hm (by positivity) 2
      have he : 1/(T.tolerance B (layerNextRange di B N) ε/(layerAmplification di B N:ℝ))^2=
          ((layerAmplification di B N:ℝ)*(1/T.tolerance B (layerNextRange di B N) ε))^2 := by
        have htailne : T.tolerance B (layerNextRange di B N) ε≠0 := (T.tolerance_pos B _ hε).ne'
        have hampne : (layerAmplification di B N:ℝ)≠0 := by
          have hh : (1:ℝ)≤layerAmplification di B N := by exact_mod_cast layerAmplification_one_le di B N
          linarith
        field_simp
      rw [he]
      exact hp.trans (resource_pow_mono hR (by omega))
    have hSize' : (arithmeticLayerSize di mi Q B N (layerNextRange di B N):ℝ)+
        (T.sizeBudget Q B (layerNextRange di B N):ℝ)≤R^(1000*E) := by
      have hL : (arithmeticLayerSize di mi Q B N (layerNextRange di B N):ℝ)≤R^(800*E) :=
        hsizeLayer.trans (resource_pow_mono hR (by omega))
      have hT : (T.sizeBudget Q B (layerNextRange di B N):ℝ)≤R^(800*E) :=
        hSize.trans (resource_pow_mono hR (by omega))
      exact (resource_add_same hR hL hT).trans (resource_pow_mono hR (by omega))
    simpa only [outputRange,tolerance,sizeBudget,length,resourceExponent_succ,Nat.cast_add] using
      And.intro hOut' (And.intro hInv' hSize')

theorem resourceExponent_mono {n m : ℕ} (hnm : n≤m) : resourceExponent n≤resourceExponent m := by
  unfold resourceExponent
  exact pow_le_pow_right₀ (by norm_num) (by omega)

theorem resources_fixed_length {d o : ℕ} (P : ArithmeticProgram d o) {R : ℝ} (hR : 2≤R)
    (B N Q h : ℕ) {ε : ℝ} (hε : 0<ε) (hlen : P.length≤h)
    (hDim : (P.maxDimension:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R)
    (hQ : (Q:ℝ)≤R) (hεinv : 1/ε≤R) :
    (P.outputRange B N:ℝ)≤R^(resourceExponent h) ∧
    1/P.tolerance B N ε≤R^(resourceExponent h) ∧
    (P.sizeBudget Q B N:ℝ)≤R^(resourceExponent h) := by
  have hh := P.resources hR B N Q hε hDim hB hN hQ hεinv
  have hp := resource_pow_mono hR (resourceExponent_mono hlen)
  exact ⟨hh.1.trans hp,hh.2.1.trans hp,hh.2.2.trans hp⟩

theorem compiled_resources {d o : ℕ} (P : ArithmeticProgram d o) {R : ℝ} (hR : 2≤R)
    (B N h : ℕ) {ε : ℝ} (hε : 0<ε) (hlen : P.length≤h)
    (hDim : (P.maxDimension:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R)
    (hεinv : 1/ε≤R) :
    (P.outputRange B N:ℝ)≤R^(resourceExponent h) ∧
    (P.mesh B N ε:ℝ)≤R^(resourceExponent h+1) ∧
    (P.sizeBudget (P.mesh B N ε) B N:ℝ)≤R^((resourceExponent h+1)*resourceExponent h) := by
  have hh := P.resources_fixed_length hR B N 0 h hε hlen hDim hB hN
    (by norm_num; linarith) hεinv
  have hE := resourceExponent_pos h
  have hRp : R≤R^(resourceExponent h) := by
    simpa only [pow_one] using resource_pow_mono hR hE
  have hmesh : (P.mesh B N ε:ℝ)≤R^(resourceExponent h+1) := by
    have hm := P.mesh_upper B N hε
    have ht : (2:ℝ)≤R^(resourceExponent h) := hR.trans hRp
    exact hm.le.trans (resource_add_same hR hh.2.1 ht)
  have hRp' : R≤R^(resourceExponent h+1) := by
    simpa only [pow_one] using resource_pow_mono hR (show 1≤resourceExponent h+1 by omega)
  have hY : 2≤R^(resourceExponent h+1) := hR.trans hRp'
  have hsize := (P.resources_fixed_length hY B N (P.mesh B N ε) h hε hlen
    (hDim.trans hRp') (hB.trans hRp') (hN.trans hRp') hmesh (hεinv.trans hRp')).2.2
  rw [←pow_mul] at hsize
  exact ⟨hh.1,hmesh,hsize⟩

/-- The compiled threshold DAG has constant depth for a fixed number of
arithmetic stages and polynomial size in every numerical and dimensional
resource, including reciprocal desired accuracy. -/
theorem compiled_circuit_resources {d o : ℕ} (P : ArithmeticProgram d o) {R : ℝ} (hR : 2≤R)
    (B N h : ℕ) {ε : ℝ} (hε : 0<ε) (hlen : P.length≤h) (hP : P.bounded B)
    (hDim : (P.maxDimension:ℝ)≤R) (hB : (B:ℝ)≤R) (hN : (N:ℝ)≤R)
    (hεinv : 1/ε≤R) :
    (P.compile (P.mesh B N ε) B N).depth≤5*h ∧
    ((P.compile (P.mesh B N ε) B N).size:ℝ)≤R^((resourceExponent h+1)*resourceExponent h) := by
  have hh := P.compiled_resources hR B N h hε hlen hDim hB hN hεinv
  refine ⟨(P.compile_depth _ B N).trans (Nat.mul_le_mul_left 5 hlen),?_⟩
  have hsize : ((P.compile (P.mesh B N ε) B N).size:ℝ)≤P.sizeBudget (P.mesh B N ε) B N := by
    exact_mod_cast P.compile_size (P.mesh B N ε) B N hP
  exact hsize.trans hh.2.2

#print axioms compiled_circuit_resources
#print axioms resources
end ArithmeticProgram
end ConditionalNonpolynomial.AnalyticLookup
