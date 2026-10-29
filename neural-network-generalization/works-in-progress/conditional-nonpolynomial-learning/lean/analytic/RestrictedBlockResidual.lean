import PolarBlockProduct
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
variable {E : ℕ→Type*} [∀n,NormedAddCommGroup (E n)]
  [∀n,InnerProductSpace ℝ (E n)] [∀n,FiniteDimensional ℝ (E n)]
variable {X : Type*}

/-- Lipschitz propagation along the actual query states only. -/
theorem actual_state_product_gain (u : ∀n,X→E n) (g : ℕ→ℝ)
    (H : ℕ) (hg : ∀j<H,0≤g j)
    (hstep : ∀j<H,∀x y,‖u (j+1) x-u (j+1) y‖≤g j*‖u j x-u j y‖)
    (x y : X) :
    ‖u H x-u H y‖≤(∏j∈Finset.range H,g j)*‖u 0 x-u 0 y‖ := by
  induction H with
  | zero=>simp
  | succ H ih=>
    have hh := ih (fun j hj=>hg j (by omega)) (fun j hj=>hstep j (by omega))
    have hn := (hstep H (by omega) x y).trans (mul_le_mul_of_nonneg_left hh (hg H (by omega)))
    rw [Finset.prod_range_succ]
    simpa only [mul_assoc,mul_comm,mul_left_comm] using hn

/-- The block residual estimate is restricted to genuine query trajectories.
No assertion about trajectories starting elsewhere in an ambient ball is used. -/
theorem actual_block_residual (u : ∀n,X→E n)
    (A : ∀n,E n→ₗ[ℝ] E (n+1)) (g b : ℕ→ℝ) (H : ℕ)
    (hg : ∀j<H,0≤g j) (hb : ∀j<H,0≤b j)
    (hlinear : ∀j<H,∀z,‖A j z‖≤g j*‖z‖)
    (hstep : ∀j<H,∀x y,‖u (j+1) x-u (j+1) y‖≤g j*‖u j x-u j y‖)
    (hres : ∀j<H,∀x y,
      ‖(u (j+1) x-A j (u j x))-(u (j+1) y-A j (u j y))‖≤
        g j*b j*‖u j x-u j y‖)
    (x y : X) :
    ‖(u H x-hsLinearChain A H (u 0 x))-(u H y-hsLinearChain A H (u 0 y))‖≤
      (∏j∈Finset.range H,g j)*(∑j∈Finset.range H,b j)*‖u 0 x-u 0 y‖ := by
  induction H with
  | zero=>simp [hsLinearChain]
  | succ H ih=>
    have ih' := ih (fun j hj=>hg j (by omega)) (fun j hj=>hb j (by omega))
      (fun j hj=>hlinear j (by omega)) (fun j hj=>hstep j (by omega)) (fun j hj=>hres j (by omega))
    have hu := actual_state_product_gain u g H (fun j hj=>hg j (by omega))
      (fun j hj=>hstep j (by omega)) x y
    let e := (u H x-hsLinearChain A H (u 0 x))-(u H y-hsLinearChain A H (u 0 y))
    let n := (u (H+1) x-A H (u H x))-(u (H+1) y-A H (u H y))
    have hid : (u (H+1) x-hsLinearChain A (H+1) (u 0 x))-
        (u (H+1) y-hsLinearChain A (H+1) (u 0 y))=A H e+n := by
      dsimp [e,n,hsLinearChain]
      simp only [map_sub]
      abel
    rw [hid]
    have hnorm := norm_add_le (A H e) n
    have hlin := (hlinear H (by omega) e).trans
      (mul_le_mul_of_nonneg_left ih' (hg H (by omega)))
    have hnr := (hres H (by omega) x y).trans
      (mul_le_mul_of_nonneg_left hu (mul_nonneg (hg H (by omega)) (hb H (by omega))))
    change ‖n‖≤_ at hnr
    rw [Finset.prod_range_succ,Finset.sum_range_succ]
    nlinarith

#print axioms actual_block_residual
end ConditionalNonpolynomial.Analytic
