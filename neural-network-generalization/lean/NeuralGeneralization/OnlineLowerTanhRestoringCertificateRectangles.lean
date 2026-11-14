import NeuralGeneralization.OnlineLowerTanhRestoringCertificateBasis

/-! Exact coverage by the eleven rectangles of the restoring certificate. -/

namespace NeuralGeneralization.OnlineLowerTanh

theorem restoringCertificate_rectangles_elim (P : ℝ → ℝ → Prop)
    (h0 : ∀ q x : ℝ, 1 / 256 ≤ q → q ≤ 569 / 12800 → -1 ≤ x → x ≤ 0 → P q x)
    (h1 : ∀ q x : ℝ, 1 / 256 ≤ q → q ≤ 569 / 12800 → 0 ≤ x → x ≤ 1 → P q x)
    (h2 : ∀ q x : ℝ, 569 / 12800 ≤ q → q ≤ 1657 / 25600 → -1 ≤ x → x ≤ -1 / 2 → P q x)
    (h3 : ∀ q x : ℝ, 569 / 12800 ≤ q → q ≤ 1657 / 25600 → -1 / 2 ≤ x → x ≤ 0 → P q x)
    (h4 : ∀ q x : ℝ, 1657 / 25600 ≤ q → q ≤ 17 / 200 → -1 ≤ x → x ≤ -1 / 2 → P q x)
    (h5 : ∀ q x : ℝ, 1657 / 25600 ≤ q → q ≤ 3833 / 51200 → -1 / 2 ≤ x → x ≤ 0 → P q x)
    (h6 : ∀ q x : ℝ, 3833 / 51200 ≤ q → q ≤ 1637 / 20480 → -1 / 2 ≤ x → x ≤ -1 / 4 → P q x)
    (h7 : ∀ q x : ℝ, 1637 / 20480 ≤ q → q ≤ 17 / 200 → -1 / 2 ≤ x → x ≤ -3 / 8 → P q x)
    (h8 : ∀ q x : ℝ, 1637 / 20480 ≤ q → q ≤ 17 / 200 → -3 / 8 ≤ x → x ≤ -1 / 4 → P q x)
    (h9 : ∀ q x : ℝ, 3833 / 51200 ≤ q → q ≤ 17 / 200 → -1 / 4 ≤ x → x ≤ 0 → P q x)
    (h10 : ∀ q x : ℝ, 569 / 12800 ≤ q → q ≤ 17 / 200 → 0 ≤ x → x ≤ 1 → P q x)
    {q x : ℝ} (hq0 : 1 / 256 ≤ q) (hq1 : q ≤ 17 / 200)
    (hx0 : -1 ≤ x) (hx1 : x ≤ 1) : P q x := by
  by_cases hqa : q ≤ 569 / 12800
  · by_cases hxa : x ≤ 0
    · exact h0 q x hq0 hqa hx0 hxa
    · exact h1 q x hq0 hqa (by linarith) hx1
  · have hqa' : 569 / 12800 ≤ q := le_of_lt (lt_of_not_ge hqa)
    by_cases hxa : 0 ≤ x
    · exact h10 q x hqa' hq1 hxa hx1
    · have hxa' : x ≤ 0 := le_of_lt (lt_of_not_ge hxa)
      by_cases hqb : q ≤ 1657 / 25600
      · by_cases hxb : x ≤ -1 / 2
        · exact h2 q x hqa' hqb hx0 hxb
        · exact h3 q x hqa' hqb (by linarith) hxa'
      · have hqb' : 1657 / 25600 ≤ q := le_of_lt (lt_of_not_ge hqb)
        by_cases hxb : x ≤ -1 / 2
        · exact h4 q x hqb' hq1 hx0 hxb
        · have hxb' : -1 / 2 ≤ x := le_of_lt (lt_of_not_ge hxb)
          by_cases hqc : q ≤ 3833 / 51200
          · exact h5 q x hqb' hqc hxb' hxa'
          · have hqc' : 3833 / 51200 ≤ q := le_of_lt (lt_of_not_ge hqc)
            by_cases hxc : -1 / 4 ≤ x
            · exact h9 q x hqc' hq1 hxc hxa'
            · have hxc' : x ≤ -1 / 4 := le_of_lt (lt_of_not_ge hxc)
              by_cases hqd : q ≤ 1637 / 20480
              · exact h6 q x hqc' hqd hxb' hxc'
              · have hqd' : 1637 / 20480 ≤ q := le_of_lt (lt_of_not_ge hqd)
                by_cases hxd : x ≤ -3 / 8
                · exact h7 q x hqd' hq1 hxb' hxd
                · exact h8 q x hqd' hq1 (by linarith) hxc'

end NeuralGeneralization.OnlineLowerTanh
