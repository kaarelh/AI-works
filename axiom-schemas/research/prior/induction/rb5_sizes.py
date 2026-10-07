# Referee: independent recount of the refutation sizes in B5 (same convention: symbols of distinct judgments,
# context formulas included, no symbol for the turnstile), from the judgment list written out by hand.
from rb_core import *
def Istar(n):
    return IMP(AND(EQ(gn(n, ZERO), ZERO), ALL(X, IMP(EQ(gn(n, ZERO), X), EQ(gn(n, S(ZERO)), S(X))))), ALL(X, EQ(gn(n, ZERO), X)))
def judgments(n):
    a, b = gn(n, ZERO), gn(n, S(ZERO)); h = EQ(a, X)
    J = [((), Istar(n)), ((), EQ(a, ZERO)), ((), EQ(b, S(a))), ((h,), h), ((h,), EQ(S(a), S(X))), ((h,), EQ(b, S(X))),
         ((), IMP(h, EQ(b, S(X)))), ((), ALL(X, IMP(h, EQ(b, S(X))))), ((), AND(EQ(a, ZERO), ALL(X, IMP(h, EQ(b, S(X)))))),
         ((), ALL(X, h)), ((), EQ(a, S(ZERO)))]
    if n == 0: J = [j for j in J if j[1] != EQ(b, S(a)) or j[0]] ; J = [j for j in J if not (j[0] and j[1] == EQ(b, S(X)) and b == S(a) and j != ((h,), EQ(S(a), S(X))))]
    J = list(dict.fromkeys(J))
    return J
for n in range(6):
    J = judgments(n)
    print(n, len(J), sum(sum(tsize(g) for g in G) + tsize(f) for G, f in J))
bot = EQ(ZERO, S(ZERO)); inst = IMP(AND(EQ(ZERO, ZERO), ALL(X, IMP(bot, bot))), ALL(X, bot))
J = [((), inst), ((), EQ(ZERO, ZERO)), ((bot,), bot), ((), IMP(bot, bot)), ((), ALL(X, IMP(bot, bot))), ((), AND(EQ(ZERO, ZERO), ALL(X, IMP(bot, bot)))), ((), ALL(X, bot)), ((), bot)]
print('Linf', len(J), sum(sum(tsize(g) for g in G) + tsize(f) for G, f in J))
