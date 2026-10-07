# Thm 6.6(e) "what the floor buys": stated bound t >= ln((1-d')/d)/ln(1/(1-pi)).
# Counter-learner L: accept |-Con(T_{k-1}) at time t iff a sample tagged Con(T_{k-1}) has been seen.
# Under T_{k-1} that tag never occurs -> L never accepts (soundness error 0 <= delta).
# Under T_k: Pr(accept at t) = 1-(1-pi)^t.
import math
for (pi,delta,dp) in [(0.1,0.01,0.5),(0.1,0.001,0.1),(0.01,0.01,0.5),(0.2,0.05,0.2)]:
    stated=math.log((1-dp)/delta)/math.log(1/(1-pi))
    t=1
    while 1-(1-pi)**t < 1-dp: t+=1
    correct=math.log((1-delta)/dp)/math.log(1/(1-pi))
    print('pi=%.3f delta=%.3f delta\'=%.2f : stated bound %.1f ; L reaches 1-delta\' at t=%d ; corrected bound ln((1-delta)/delta\')/ln(1/(1-pi)) = %.1f'%(pi,delta,dp,stated,t,correct))
