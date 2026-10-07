import random

import pytest

from cil.terms import (App, HOLE, Var, canonical, canonical_tuple, is_instance, is_variant, lgg, lgg_many,
                       lgg_tuples, lgg_tuples_subst, match, match_tuple, num, numeral_value, parse,
                       parse_pattern, plug, positions, pretty, rename_apart, replace, subst, subterm,
                       unify, variables)


def P(s):
    return parse_pattern(s)


def test_precedence_and_associativity():
    assert parse("-x^2") == App("neg", (App("^", (App("x"), App("2"))),))
    assert parse("a - b - c") == parse("(a - b) - c")
    assert parse("a^b^c") == parse("a^(b^c)")
    assert parse("2^-1") == App("^", (App("2"), App("neg", (App("1"),))))
    assert parse("-a*b") == parse("(-a)*b")
    assert parse("sqrt(x + 1)").head == "sqrt"
    assert parse("?x + y") == App("+", (Var("x"), App("y")))
    assert parse("x + y", var_names={"x"}) == App("+", (Var("x"), App("y")))


def test_pretty_roundtrip_examples():
    for s in ["a + b*c", "(a + b)*c", "a - (b - c)", "a - b - c", "(-x)^2", "-x^2", "a^(b + c)",
              "a/(b*c)", "a/b/c", "--x", "a*(-b)", "sqrt(x^2) + f(x, y)", "(a^b)^c", "2^(-1)",
              "?a + ?b", "-(a + b)", "-a + (-b)"]:
        t = parse(s)
        assert parse(pretty(t)) == t, s


def _rand_term(rng, d):
    if d == 0 or rng.random() < 0.25:
        return rng.choice([App("x"), App("y"), num(rng.randint(0, 3)), Var("v")])
    r = rng.random()
    if r < 0.15:
        return App("neg", (_rand_term(rng, d - 1),))
    if r < 0.22:
        return App("sqrt", (_rand_term(rng, d - 1),))
    op = rng.choice(["+", "-", "*", "/", "^"])
    return App(op, (_rand_term(rng, d - 1), _rand_term(rng, d - 1)))


def test_pretty_roundtrip_random():
    rng = random.Random(0)
    for _ in range(2000):
        t = _rand_term(rng, 5)
        assert parse(pretty(t)) == t, pretty(t)


def test_numerals():
    assert numeral_value(num(-3)) == -3
    assert numeral_value(num(5)) == 5
    assert numeral_value(parse("x")) is None


def test_substitution_and_matching():
    pat = P("a + a*b")
    t = parse("x + x*(y + 1)")
    s = match(pat, t)
    assert s == {"a": parse("x"), "b": parse("y + 1")}
    assert subst(pat, s) == t
    assert match(P("a + a"), parse("x + y")) is None
    assert match_tuple((P("a + b"), P("b + a")), (parse("x + y"), parse("y + x"))) is not None
    assert match_tuple((P("a + b"), P("b + a")), (parse("x + y"), parse("x + y"))) is None
    # variables in the matched term are rigid
    assert match(P("a"), Var("q")) == {"a": Var("q")}
    assert match(P("f(a)"), Var("q")) is None


def test_unification():
    s = unify(P("f(x, g(y))"), P("f(g(z), x)"))
    assert s is not None
    assert subst(subst(P("f(x, g(y))"), s), s) == subst(P("f(x, g(y))"), s)
    assert subst(P("f(x, g(y))"), s) == subst(P("f(g(z), x)"), s)
    assert unify(P("x"), P("f(x)")) is None  # occurs check
    assert unify(P("f(a)"), P("g(a)")) is None


def test_lgg_classic():
    g, s1, s2 = lgg(parse("f(a, a)"), parse("f(b, b)"))
    assert is_variant(g, P("f(X, X)"))
    g, s1, s2 = lgg(parse("f(a, b)"), parse("f(b, a)"))
    assert is_variant(g, P("f(X, Y)"))
    g, s1, s2 = lgg(parse("x + 0"), parse("(y*z) + 0"))
    assert is_variant(g, P("a + 0"))
    assert subst(g, s1) == parse("x + 0") and subst(g, s2) == parse("(y*z) + 0")


def test_lgg_tuples_consistent_map():
    l, r = lgg_tuples([(parse("x + 0"), parse("x")), (parse("y + 0"), parse("y"))])
    assert canonical_tuple((l, r)) == canonical_tuple((P("a + 0"), P("a")))
    g, subs = lgg_tuples_subst([(parse("x*y"), parse("y*x")), (parse("2*(z+1)"), parse("(z+1)*2"))])
    assert canonical_tuple(g) == canonical_tuple((P("a*b"), P("b*a")))
    for i, tp in enumerate([(parse("x*y"), parse("y*x")), (parse("2*(z+1)"), parse("(z+1)*2"))]):
        assert tuple(subst(c, subs[i]) for c in g) == tp


def _generalise_random(rng, t):
    """A random generalisation of t: replace some subterms by fresh variables."""
    ps = positions(t)
    out = t
    for k, p in enumerate(sorted(rng.sample(ps, min(2, len(ps))), key=len, reverse=True)):
        try:
            out = replace(out, p, Var(f"G{k}"))
        except (IndexError, AttributeError):
            pass
    return out


def test_lgg_is_least_general_random():
    rng = random.Random(1)
    for _ in range(300):
        s = _rand_term(rng, 3)
        if not s.ground:
            continue
        # build t sharing structure with s
        t = s
        for p in rng.sample(positions(s), 1):
            t = replace(t, p, _rand_term(rng, 1) if rng.random() < 0.5 else App("z"))
        if not t.ground:
            continue
        g, s1, s2 = lgg(s, t)
        assert subst(g, s1) == s and subst(g, s2) == t
        # every common generalisation h of s and t generalises g
        h, _, _ = lgg(g, s)  # a generalisation of g (hence of s, t)
        assert is_instance(g, h)
        # n-ary lgg agrees with the binary one
        assert is_variant(lgg_many([s, t]), g)


def test_lgg_many_associative():
    ts = [parse("(x + 1)*y"), parse("(z + 1)*2"), parse("(y*y + 1)*x")]
    g = lgg_many(ts)
    assert is_variant(g, P("(a + 1)*b"))
    g12, _, _ = lgg(ts[0], ts[1])
    g123, _, _ = lgg(g12, ts[2])
    assert is_variant(g123, g)


def test_positions_and_contexts():
    t = parse("(x + y)*z")
    assert positions(t) == [(), (0,), (0, 0), (0, 1), (1,)]
    assert subterm(t, (0, 1)) == parse("y")
    assert replace(t, (0, 1), parse("2")) == parse("(x + 2)*z")
    ctx = App("+", (HOLE, App("1")))
    assert plug(ctx, parse("x*y")) == parse("x*y + 1")


def test_canonical_and_rename():
    a = P("p + q*p")
    b = P("u + v*u")
    assert canonical(a) == canonical(b)
    assert variables(rename_apart(a, "'")) == ["p'", "q'"]
    assert not is_variant(P("a + b"), P("a + a"))


def test_size():
    assert parse("x + y*2").size == 5
    assert Var("a").size == 1
