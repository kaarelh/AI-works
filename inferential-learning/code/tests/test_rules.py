from cil.domains.algebra import TARGET_BY_NAME, entails
from cil.rules import (Guard, InferenceSchema, RewriteRule, TRUE_GUARD, diff_chain, explanations, guard_candidates,
                       induce_schema, licenses, minimal_core, rule_from_strings)
from cil.terms import parse, parse_pattern


def test_diff_chain_minimal_and_ancestors():
    b, a = parse("(x*1)*y"), parse("x*y")
    ch = diff_chain(b, a)
    assert ch[0] == ((0,), parse("x*1"), parse("x"))
    assert [p for p, _, _ in ch] == [(0,), ()]
    assert diff_chain(b, b) == []


def test_diff_chain_ambiguity_collapse():
    # (y+0)+0 -> y+0 : add_zero at the root, or at position (0,)
    b, a = parse("(y + 0) + 0"), parse("y + 0")
    ch = diff_chain(b, a)
    assert ch[0][0] == (0,) and ch[-1][0] == ()
    r = TARGET_BY_NAME["add_zero"]
    ex = explanations(r, b, a)
    assert {p for p, _ in ex} == {(0,), ()}


def test_licenses_with_guard():
    r = TARGET_BY_NAME["div_self"]
    b, a = parse("2 + x/x"), parse("2 + 1")
    assert licenses(r, b, a, frozenset(), entails) is None
    assert licenses(r, b, a, frozenset({("nonzero", parse("x"))}), entails) is not None
    assert licenses(r, b, a, frozenset({("pos", parse("x"))}), entails) is not None
    # wrong result is never licensed
    assert licenses(r, b, parse("2 + 2"), frozenset({("nonzero", parse("x"))}), entails) is None


def test_licenses_guard_through_ambiguity():
    # sqrt(sqrt(t^2)^2) -> sqrt(t^2): the root explanation's guard nonneg(sqrt(t^2)) holds,
    # the deeper explanation's guard nonneg(t) does not; licensing must find the root one.
    r = TARGET_BY_NAME["sqrt_sq"]
    b, a = parse("sqrt(sqrt(x^2)^2)"), parse("sqrt(x^2)")
    assert licenses(r, b, a, frozenset(), entails) is not None


def test_induce_schema_from_cores():
    cores = [(parse("x*(y + 1)"), parse("x*y + x*1")), (parse("2*(a + b)"), parse("2*a + 2*b"))]
    rule = induce_schema(cores)
    assert rule.variant_of(TARGET_BY_NAME["distrib_l"], check_guard=False)
    assert rule.is_range_restricted()


def test_rule_structure():
    r = rule_from_strings("a/a", "1", [("nonzero", "a")], name="t")
    assert r.vars() == ["a"]
    c = r.canonical()
    assert str(c.guard) == "nonzero(?v0)"
    assert r.variant_of(rule_from_strings("q/q", "1", [("nonzero", "q")]))
    assert not r.variant_of(rule_from_strings("q/q", "1"))
    assert r.variant_of(rule_from_strings("q/q", "1"), check_guard=False)
    gen = rule_from_strings("a*b", "b*a")
    spec = rule_from_strings("x*(x + 1)", "(x + 1)*x")
    assert gen.subsumes(spec) and not spec.subsumes(gen)
    assert not rule_from_strings("a + b", "c").is_range_restricted()


def test_rewrites_and_guard_implication():
    r = TARGET_BY_NAME["mul_one"]
    out = r.rewrites(parse("(x*1)*(y*1)"))
    assert len(out) == 2
    g1, g2 = Guard([("nonzero", "a")]), Guard([("defined", "a")])
    from cil.domains.algebra import pred_implies
    assert g1.implies(g2, pred_implies) and not g2.implies(g1, pred_implies)


def test_guard_candidates():
    r = rule_from_strings("a*b", "b*a")
    c = guard_candidates(r, ("defined", "nonzero", "nonneg"), 2)
    assert len(c) == 6 + 15


def test_inference_schema_generic():
    # modus-ponens-like schema learned from two instances
    inst = [((parse("imp(p, q)"), parse("p")), parse("q")), ((parse("imp(r, s(t))"), parse("r")), parse("s(t)"))]
    sch = InferenceSchema.induce(inst)
    assert sch.instance((parse("imp(u, v)"), parse("u")), parse("v")) is not None
    assert sch.instance((parse("imp(u, v)"), parse("v")), parse("u")) is None
