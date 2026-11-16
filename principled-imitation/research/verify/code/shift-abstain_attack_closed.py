"""Attack on 'in a closed system abstention saves at most the factor (1-a)^2 in questions'
(file: Section 4.4 title, summary item (3), Theorem 7.3 'In words', Section 10 items 3 and 6).
Class: zero function f0 and the indicators f_c of cells c in {0, 1..N1}; scaffold: L i.i.d. calls,
cell 0 with mass pi0 = 1 - N1*pi, each rare cell with mass pi; outcome = OR of the answers.
WITHOUT abstention (a = 0): for any protocol and deployed system with max_f sigma(f) <= sigma,
  Pr[c not asked under f0] <= 2 sigma / p_c,  p_c = 1-(1-pi_c)^L,
  (proof as in Theorem 4.5: sigma(f_c) >= Pr[c unasked]p_c - sigma(f0)), hence
  n >= sum_c (1 - 2 sigma/p_c)^+.
WITH abstention: ask cell 0 only (n = 1), deploy: answer cell 0 from the data and
  abstain on every rare cell; outcome = OR over answered calls. Silent failure 0 for every member,
  abort probability under f0 = 1-(1-N1*pi)^L =: a."""
L = 10
for a_target in (0.2, 0.5):
    for sigma in (1e-3, 1e-4, 1e-5):
        pc_target = 4*sigma                      # each rare cell: p_c = 4 sigma
        pi = 1-(1-pc_target)**(1/L)
        mass_rare = 1-(1-a_target)**(1/L)        # total rare mass giving abort prob a_target
        N1 = int(mass_rare/pi)
        a = 1-(1-N1*pi)**L
        pc = 1-(1-pi)**L
        n_without = N1*max(0.0, 1-2*sigma/pc)    # lower bound (cell 0 not even counted)
        print(f"L={L} sigma={sigma:g}: rare cells N1={N1}, abort a={a:.3f}; "
              f"no abstention needs n >= {n_without:.0f}; with abstention n = 1, silent failure 0; "
              f"saving factor >= {n_without:.0f}, versus 1/(1-a)^2 = {1/(1-a)**2:.2f}")
