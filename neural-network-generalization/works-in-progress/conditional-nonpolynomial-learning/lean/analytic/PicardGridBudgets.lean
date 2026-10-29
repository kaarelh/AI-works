import ActualCanonicalPicardGrid

/-! Explicit polynomial finite-grid precision for one actual Picard update. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

 def picardAmplifier (A K : ℕ) : ℕ := (K+1)*A*(A+1)*(K+1)
 def picardRoundingWeight (A K D N : ℕ) : ℕ :=
  picardAmplifier A K*(D+1)+(K+1)*(A*(N+1)+2)+1
 def picardInnerTolerance (A K D : ℕ) (η : ℝ) : ℝ :=
  η/(4*((picardAmplifier A K:ℝ)+1)*((D:ℝ)+2))
 def picardOuterMesh (A K D N : ℕ) (η : ℝ) : ℕ :=
  ⌈2*(picardRoundingWeight A K D N:ℝ)/η⌉₊+1

 theorem picardInnerTolerance_pos (A K D : ℕ) {η : ℝ} (hη : 0<η) :
    0<picardInnerTolerance A K D η := by unfold picardInnerTolerance;positivity

 theorem picardInnerTolerance_le (A K D : ℕ) {η : ℝ} (hη : 0≤η) :
    picardInnerTolerance A K D η≤η := by
  have hL:0≤(picardAmplifier A K:ℝ):=Nat.cast_nonneg _
  have hD:0≤(D:ℝ):=Nat.cast_nonneg _
  unfold picardInnerTolerance
  apply (div_le_iff₀ (by positivity : 0<4*((picardAmplifier A K:ℝ)+1)*((D:ℝ)+2))).mpr
  have hd : (1:ℝ)≤4*((picardAmplifier A K:ℝ)+1)*((D:ℝ)+2) := by
    nlinarith [mul_nonneg hL hD]
  simpa only [mul_one] using mul_le_mul_of_nonneg_left hd hη

 theorem picardInnerTolerance_inverse (A K D : ℕ) {η : ℝ} (hη : 0<η) :
    1/picardInnerTolerance A K D η=4*((picardAmplifier A K:ℝ)+1)*((D:ℝ)+2)/η := by
  unfold picardInnerTolerance
  field_simp

 theorem picardOuterMesh_pos (A K D N : ℕ) (η : ℝ) : 0<picardOuterMesh A K D N η := by
  unfold picardOuterMesh
  omega

 theorem picardOuterMesh_upper (A K D N : ℕ) {η : ℝ} (hη : 0<η) :
    (picardOuterMesh A K D N η:ℝ)<2*(picardRoundingWeight A K D N:ℝ)/η+2 := by
  have hh:=Nat.ceil_lt_add_one (show 0≤2*(picardRoundingWeight A K D N:ℝ)/η by positivity)
  unfold picardOuterMesh
  push_cast
  linarith

 theorem picardOuterMesh_product (A K D N : ℕ) {η : ℝ} (hη : 0<η) :
    2*(picardRoundingWeight A K D N:ℝ)≤(picardOuterMesh A K D N η:ℝ)*η := by
  apply (div_le_iff₀ hη).mp
  have hh:=Nat.le_ceil (2*(picardRoundingWeight A K D N:ℝ)/η)
  unfold picardOuterMesh
  push_cast
  linarith

 def abstractPicardGridError (A K D N Q : ℕ) (τ ε : ℝ) : ℝ :=
  (((K:ℝ)+1)*(A:ℝ))*(((A:ℝ)+1)*(((K:ℝ)+1)*
    (τ+((D:ℝ)+1)*ε+((D:ℝ)+1)/(2*(Q:ℝ)))))+
  (((K:ℝ)+1)*(((A:ℝ)*((N:ℝ)+1)+1)/(2*(Q:ℝ))))+((K:ℝ)+1)/(2*(Q:ℝ))

 theorem picard_selected_error (A K D N : ℕ) {η : ℝ} (hη : 0<η) :
    abstractPicardGridError A K D N (picardOuterMesh A K D N η)
      (picardInnerTolerance A K D η) (picardInnerTolerance A K D η)≤η/2 := by
  let L:ℝ:=picardAmplifier A K
  let W:ℝ:=picardRoundingWeight A K D N
  let Q:ℕ:=picardOuterMesh A K D N η
  have hL:0≤L:=Nat.cast_nonneg _
  have hD:0≤(D:ℝ):=Nat.cast_nonneg _
  have hLp:0<L+1:=by linarith
  have hDp:0<(D:ℝ)+2:=by positivity
  have hQp:(0:ℝ)<Q:=Nat.cast_pos.mpr (picardOuterMesh_pos _ _ _ _ _)
  have ht : L*((D:ℝ)+2)*picardInnerTolerance A K D η≤η/4 := by
    calc
      _ = (η/4)*(L/(L+1)) := by
        dsimp [picardInnerTolerance]
        change L*((D:ℝ)+2)*(η/(4*(L+1)*((D:ℝ)+2)))=_
        field_simp
      _ ≤ η/4 := mul_le_of_le_one_right (by positivity)
        ((div_le_iff₀ hLp).mpr (by linarith))
  have hprod : 2*W≤(Q:ℝ)*η := picardOuterMesh_product A K D N hη
  have hr : (W-1)/(2*(Q:ℝ))≤η/4 := by
    apply (div_le_iff₀ (by positivity : 0<2*(Q:ℝ))).mpr
    linarith
  have he : abstractPicardGridError A K D N Q
      (picardInnerTolerance A K D η) (picardInnerTolerance A K D η)=
      L*((D:ℝ)+2)*picardInnerTolerance A K D η+(W-1)/(2*(Q:ℝ)) := by
    dsimp [abstractPicardGridError,L,W,picardAmplifier,picardRoundingWeight]
    push_cast
    ring
  rw [he]
  linarith

 theorem picardInnerTotal_le (A K D : ℕ) {η : ℝ} (hη : 0≤η) :
    picardInnerTolerance A K D η+((D:ℝ)+1)*picardInnerTolerance A K D η≤η := by
  let L:ℝ:=picardAmplifier A K
  have hL:0≤L:=Nat.cast_nonneg _
  have hLp:0<L+1:=by linarith
  have hDp:0<(D:ℝ)+2:=by positivity
  calc
    _ = η/(4*(L+1)) := by
      dsimp [picardInnerTolerance]
      change η/(4*(L+1)*((D:ℝ)+2))+((D:ℝ)+1)*(η/(4*(L+1)*((D:ℝ)+2)))=_
      field_simp
      ring
    _ ≤ η := by
      apply (div_le_iff₀ (by positivity : 0<4*(L+1))).mpr
      have hh:=mul_le_mul_of_nonneg_left (show (1:ℝ)≤4*(L+1) by linarith) hη
      simpa only [mul_one] using hh


#print axioms picard_selected_error
end ConditionalNonpolynomial.AnalyticLookup
