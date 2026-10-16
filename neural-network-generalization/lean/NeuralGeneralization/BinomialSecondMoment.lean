import NeuralGeneralization.BinomialGeometricBounds

/-! A sharp finite binomial second-moment estimate.  The high-degree part is
controlled by spectral monotonicity and trace, while the first part uses
geometric growth of binomial multiplicities. -/
noncomputable section
namespace NeuralGeneralization.BinomialGeometry
open scoped BigOperators

theorem second_moment_low {D k B : ℕ} (S : Finset ℕ) (a : ℕ→ℝ) (T : ℝ)
    (hkB : k≤B) (hB : 3*(B+1)≤D) (hT : 0≤T)
    (hS : ∀j∈S,k≤j ∧ j≤B) (ha : ∀j∈S,0≤a j)
    (hmass : ∀j∈S,(D.choose j:ℝ)*a j≤T) :
    (∑j∈S,(D.choose j:ℝ)*(a j)^2)≤2*T^2/(D.choose k:ℝ) := by
  have hterm (j : ℕ) (hj : j∈S) :
      (D.choose j:ℝ)*(a j)^2 ≤ T^2*(1/(D.choose j:ℝ)) := by
    have hp : (0:ℝ)<D.choose j := by
      exact_mod_cast Nat.choose_pos (by have := hS j hj; omega : j≤D)
    have hn : 0≤(D.choose j:ℝ)*a j := mul_nonneg hp.le (ha j hj)
    have hs : ((D.choose j:ℝ)*a j)^2≤T^2 := sq_le_sq₀ hn hT |>.mpr (hmass j hj)
    rw [mul_one_div]
    apply (le_div_iff₀ hp).mpr
    nlinarith only [hs]
  have hsub : S⊆Finset.Ico k (B+1) := by
    intro j hj
    exact Finset.mem_Ico.mpr ⟨(hS j hj).1,by have := (hS j hj).2; omega⟩
  have hs := Finset.sum_le_sum hterm
  have hi := Finset.sum_le_sum_of_subset_of_nonneg hsub
    (fun j _ _ => by positivity : ∀j∈Finset.Ico k (B+1),j∉S → 0≤(1/(D.choose j:ℝ)))
  have hh := mul_le_mul_of_nonneg_left (hi.trans (reciprocal_choose_Ico hkB hB))
    (sq_nonneg T)
  rw [← Finset.mul_sum] at hs
  calc
    _ ≤ T^2*(∑j∈S,1/(D.choose j:ℝ)) := hs
    _ ≤ T^2*(2/(D.choose k:ℝ)) := hh
    _ = _ := by ring

theorem second_moment_high {D B : ℕ} (S : Finset ℕ) (a : ℕ→ℝ) (T R : ℝ)
    (hBD : B≤D) (haB : 0≤a B) (hR : 0≤R)
    (ha : ∀j∈S,0≤a j) (hmono : ∀j∈S,a j≤a B)
    (hmass : (D.choose B:ℝ)*a B≤T)
    (htrace : (∑j∈S,(D.choose j:ℝ)*a j)≤R) :
    (∑j∈S,(D.choose j:ℝ)*(a j)^2)≤T*R/(D.choose B:ℝ) := by
  have hs : (∑j∈S,(D.choose j:ℝ)*(a j)^2) ≤
      a B*(∑j∈S,(D.choose j:ℝ)*a j) := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro j hj
    have hh := mul_le_mul_of_nonneg_right (hmono j hj)
      (mul_nonneg (Nat.cast_nonneg (D.choose j)) (ha j hj))
    nlinarith only [hh]
  have hp : (0:ℝ)<D.choose B := by exact_mod_cast Nat.choose_pos hBD
  have hb : a B≤T/(D.choose B:ℝ) := (le_div_iff₀ hp).mpr (by simpa [mul_comm] using hmass)
  calc
    _ ≤ a B*(∑j∈S,(D.choose j:ℝ)*a j) := hs
    _ ≤ a B*R := mul_le_mul_of_nonneg_left htrace haB
    _ ≤ (T/(D.choose B:ℝ))*R := mul_le_mul_of_nonneg_right hb hR
    _ = _ := by ring

theorem second_moment_low_fibers {ι : Type*} [DecidableEq ι] {D k B : ℕ}
    (S : Finset ι) (degree : ι→ℕ) (a : ι→ℝ) (T : ℝ)
    (hkB : k≤B) (hB : 3*(B+1)≤D) (hT : 0≤T)
    (hdegree : ∀x∈S,k≤degree x ∧ degree x≤B)
    (hfiber : ∀j∈Finset.Ico k (B+1),(S.filter (fun x=>degree x=j)).card≤D.choose j)
    (ha : ∀x∈S,0≤a x)
    (hmass : ∀x∈S,(D.choose (degree x):ℝ)*a x≤T) :
    (∑x∈S,(a x)^2)≤2*T^2/(D.choose k:ℝ) := by
  classical
  have hmaps : ∀x∈S,degree x∈Finset.Ico k (B+1) := by
    intro x hx
    exact Finset.mem_Ico.mpr ⟨(hdegree x hx).1,by have := (hdegree x hx).2; omega⟩
  rw [← Finset.sum_fiberwise_of_maps_to hmaps (fun x=>(a x)^2)]
  have hf (j : ℕ) (hj : j∈Finset.Ico k (B+1)) :
      (∑x∈S.filter (fun x=>degree x=j),(a x)^2) ≤ T^2*(1/(D.choose j:ℝ)) := by
    have hp : (0:ℝ)<D.choose j := by
      exact_mod_cast Nat.choose_pos (by have := Finset.mem_Ico.mp hj; omega : j≤D)
    have hs : (∑x∈S.filter (fun x=>degree x=j),(a x)^2) ≤
        ((S.filter (fun x=>degree x=j)).card:ℝ)*(T/(D.choose j:ℝ))^2 := by
      rw [← nsmul_eq_mul, ← Finset.sum_const]
      apply Finset.sum_le_sum
      intro x hx
      obtain ⟨hxS,he⟩ := Finset.mem_filter.mp hx
      have hm := hmass x hxS
      rw [he] at hm
      apply (sq_le_sq₀ (ha x hxS) (div_nonneg hT hp.le)).mpr
      exact (le_div_iff₀ hp).mpr (by simpa [mul_comm] using hm)
    have hc : ((S.filter (fun x=>degree x=j)).card:ℝ)≤D.choose j := by
      exact_mod_cast hfiber j hj
    calc
      _ ≤ ((S.filter (fun x=>degree x=j)).card:ℝ)*(T/(D.choose j:ℝ))^2 := hs
      _ ≤ (D.choose j:ℝ)*(T/(D.choose j:ℝ))^2 :=
        mul_le_mul_of_nonneg_right hc (sq_nonneg _)
      _ = _ := by field_simp
  calc
    _ ≤ ∑j∈Finset.Ico k (B+1),T^2*(1/(D.choose j:ℝ)) := Finset.sum_le_sum hf
    _ = T^2*(∑j∈Finset.Ico k (B+1),1/(D.choose j:ℝ)) := by rw [Finset.mul_sum]
    _ ≤ T^2*(2/(D.choose k:ℝ)) :=
      mul_le_mul_of_nonneg_left (reciprocal_choose_Ico hkB hB) (sq_nonneg _)
    _ = _ := by ring

theorem second_moment_of_fibers {ι : Type*} [DecidableEq ι] {D k B : ℕ}
    (S : Finset ι) (degree : ι→ℕ) (a : ι→ℝ) (T q : ℝ)
    (hkB : 2*k≤B) (hB : 3*(B+1)≤D) (hT : 0≤T) (hq : 0≤q)
    (hdegree : ∀x∈S,k≤degree x)
    (hfiber : ∀j∈Finset.Ico k (B+1),(S.filter (fun x=>degree x=j)).card≤D.choose j)
    (ha : ∀x∈S,0≤a x)
    (hlow : ∀x∈S,degree x≤B → (D.choose (degree x):ℝ)*a x≤T)
    (hhigh : ∀x∈S,B<degree x → a x≤q)
    (hboundary : (D.choose B:ℝ)*q≤T)
    (htrace : (∑x∈S.filter (fun x=>B<degree x),a x)≤(k:ℝ)*T) :
    (∑x∈S,(a x)^2)≤3*T^2/(D.choose k:ℝ) := by
  classical
  let L := S.filter (fun x=>degree x≤B)
  let H := S.filter (fun x=>B<degree x)
  have hL : (∑x∈L,(a x)^2)≤2*T^2/(D.choose k:ℝ) := by
    apply second_moment_low_fibers L degree a T (by omega) hB hT
    · intro x hx
      obtain ⟨hxS,hxB⟩ := Finset.mem_filter.mp hx
      exact ⟨hdegree x hxS,hxB⟩
    · intro j hj
      apply (Finset.card_le_card ?_).trans (hfiber j hj)
      intro x hx
      obtain ⟨hxL,hxj⟩ := Finset.mem_filter.mp hx
      exact Finset.mem_filter.mpr ⟨(Finset.mem_filter.mp hxL).1,hxj⟩
    · intro x hx
      exact ha x (Finset.mem_filter.mp hx).1
    · intro x hx
      exact hlow x (Finset.mem_filter.mp hx).1 (Finset.mem_filter.mp hx).2
  have hp : (0:ℝ)<D.choose k := by exact_mod_cast Nat.choose_pos (by omega : k≤D)
  have hgrowth : (k:ℝ)*(D.choose k:ℝ)≤D.choose B := by
    exact_mod_cast choose_growth_multiple hkB (by omega : 3*B≤D)
  have hqk : q*(k:ℝ)≤T/(D.choose k:ℝ) := by
    apply (le_div_iff₀ hp).mpr
    have hh := mul_le_mul_of_nonneg_left hgrowth hq
    nlinarith only [hh,hboundary]
  have hH : (∑x∈H,(a x)^2)≤T^2/(D.choose k:ℝ) := by
    calc
      _ ≤ ∑x∈H,q*a x := by
        apply Finset.sum_le_sum
        intro x hx
        obtain ⟨hxS,hxB⟩ := Finset.mem_filter.mp hx
        have hh := mul_le_mul_of_nonneg_right (hhigh x hxS hxB) (ha x hxS)
        nlinarith only [hh]
      _ = q*(∑x∈H,a x) := by rw [Finset.mul_sum]
      _ ≤ q*((k:ℝ)*T) := mul_le_mul_of_nonneg_left htrace hq
      _ = (q*(k:ℝ))*T := by ring
      _ ≤ (T/(D.choose k:ℝ))*T := mul_le_mul_of_nonneg_right hqk hT
      _ = _ := by ring
  have hsplit : (∑x∈L,(a x)^2)+(∑x∈H,(a x)^2)=∑x∈S,(a x)^2 := by
    simpa only [L,H,not_le] using
      Finset.sum_filter_add_sum_filter_not S (fun x=>degree x≤B) (fun x=>(a x)^2)
  rw [← hsplit]
  calc
    _ ≤ 2*T^2/(D.choose k:ℝ)+T^2/(D.choose k:ℝ) := add_le_add hL hH
    _ = _ := by ring

end NeuralGeneralization.BinomialGeometry
