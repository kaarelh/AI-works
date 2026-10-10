"""c4: the two maps of the soft sandwich (notes §5, Theorem 5.2), checked on random data.

(b) certificate -> axiom.  Z := all (#0 = #0) (size 4).  C_c := nu_{c_1}(... nu_{c_k}(Z)) with nu_0 = not, nu_1 = all
    (vacuous).  theta_c := Z -> (C_c -> Z), an instance of A1 of size |c| + 14.  The axiom for (phi, c) is
    theta_c -> phi^b, and the derivation is  theta_c (A1),  theta_c -> phi^b (axiom),  phi^b (MP).
    Checked: c is read off theta_c uniquely (decode(theta_c) = c; formulas not of this shape are rejected);
    theta_c is an A1 instance for the independent recogniser; the derivation is valid; its symbol size is exactly
    2|c| + 2|phi^b| + 29; its bit length in the prefix code of kcore.code_length is exactly
    2 b_s |c| + 2 |phi^b|_bit + 29 b_s + 24 (b_s bits per token).
(a) derivation -> certificate.  A real encoder/decoder for the prefix code (tokens of b_s bits, Elias-gamma for
    indices, parameters and line numbers, 2-bit line tags).  The certificate for phi^b is the code of a derivation
    with the last line's formula and the end tag removed; the verifier re-inserts the code of phi (then of not phi)
    and decodes.  Checked on random derivations (generator of c1): round trip encode/decode; the verifier recovers
    exactly the derivation; certificate length = code length - |phi^b|_bit - 2.
"""
import random
import sys

import kcore as K
import c1_subformula as C1

sys.setrecursionlimit(20000)
SEED = 99
rng = random.Random(SEED)
C1.rng.seed(SEED + 1)
out = []

Z = ('all', ('eq', ('idx', 0), ('idx', 0)))


def C_of(c):
    x = Z
    for b in reversed(c):
        x = ('not', x) if b == 0 else ('all', x)
    return x


def theta(c):
    return K.imp(Z, K.imp(C_of(c), Z))


def decode_theta(th):
    if not (th[0] == 'imp' and th[1] == Z and th[2][0] == 'imp' and th[2][2] == Z):
        return None
    x, bits = th[2][1], []
    while x != Z:
        if x[0] == 'not':
            bits.append(0)
        elif x[0] == 'all':
            bits.append(1)
        else:
            return None
        x = x[1]
    return bits


# ---------------------------------------------------------------- the prefix code (tokens)

TOKENS = ['not', 'imp', 'all', 'eq', 'IDX', 'PAR', ('fn', '0'), ('fn', 'S'), ('fn', '+'), ('rel', 'P'), ('rel', 'Q')]
ARITY = {('fn', '0'): 0, ('fn', 'S'): 1, ('fn', '+'): 2, ('rel', 'P'): 1, ('rel', 'Q'): 2}
BS = (len(TOKENS) - 1).bit_length()  # bits per token


def gamma(n):
    b = bin(n)[2:]
    return '0' * (len(b) - 1) + b


def read_gamma(s, i):
    z = 0
    while s[i] == '0':
        z += 1
        i += 1
    v = int(s[i:i + z + 1], 2)
    return v, i + z + 1


def tok(t):
    return format(TOKENS.index(t), f'0{BS}b')


def enc_f(x):
    k = x[0]
    if k == 'idx':
        return tok('IDX') + gamma(x[1] + 1)
    if k == 'par':
        return tok('PAR') + gamma(x[1] + 1)
    if k in ('fn', 'rel'):
        return tok((k, x[1])) + ''.join(enc_f(a) for a in x[2])
    if k == 'eq':
        return tok('eq') + enc_f(x[1]) + enc_f(x[2])
    if k in ('not', 'all'):
        return tok(k) + enc_f(x[1])
    if k == 'imp':
        return tok('imp') + enc_f(x[1]) + enc_f(x[2])
    raise ValueError(x)


def dec_f(s, i):
    t = TOKENS[int(s[i:i + BS], 2)]
    i += BS
    if t in ('IDX', 'PAR'):
        v, i = read_gamma(s, i)
        return (('idx' if t == 'IDX' else 'par'), v - 1), i
    if t in ('not', 'all'):
        a, i = dec_f(s, i)
        return (t, a), i
    if t in ('imp', 'eq'):
        a, i = dec_f(s, i)
        b, i = dec_f(s, i)
        return (t, a, b), i
    args = []
    for _ in range(ARITY[t]):
        a, i = dec_f(s, i)
        args.append(a)
    return (t[0], t[1], tuple(args)), i


TAG = {'ax': '00', 'mp': '01', 'gen': '10', 'end': '11'}


def enc_derivation(lines):
    s = ''
    for f, j in lines:
        s += TAG[j[0]]
        if j[0] == 'mp':
            s += gamma(j[1] + 1) + gamma(j[2] + 1)
        elif j[0] == 'gen':
            s += gamma(j[1] + 1) + gamma(j[2] + 1)  # premise line and parameter
        s += enc_f(f)
    return s + TAG['end']


def dec_derivation2(s):
    i, lines = 0, []
    while i < len(s):
        tag = s[i:i + 2]
        i += 2
        if tag == '11':
            return lines, i
        if tag == '00':
            j = ('ax',)
        elif tag == '01':
            a, i = read_gamma(s, i)
            b, i = read_gamma(s, i)
            j = ('mp', a - 1, b - 1)
        else:
            a, i = read_gamma(s, i)
            p, i = read_gamma(s, i)
            j = ('gen', a - 1, p - 1)
        f, i = dec_f(s, i)
        lines.append((f, j))
    raise ValueError("no end tag")


def certificate(lines):
    """The code of the derivation with the last line's formula and the end tag removed."""
    full = enc_derivation(lines)
    return full[:len(full) - 2 - len(enc_f(lines[-1][0]))]


def verifier(phi, cert, NLpred):
    """acc if cert + code(phi) + end decodes to a valid derivation of phi; rej likewise for not phi; else None."""
    for target, verdict in ((phi, 'acc'), (K.neg(phi), 'rej')):
        s = cert + enc_f(target) + TAG['end']
        try:
            lines, i = dec_derivation2(s)
        except (ValueError, IndexError, KeyError):
            continue
        if i != len(s) or not lines or lines[-1][0] != target:
            continue
        ok, _ = K.check_derivation(lines, NLpred)
        if ok:
            return verdict, lines
    return None, None


def main():
    out.append(f"c4_cert_embedding  (seed {SEED}); token bits b_s = {BS}")
    # (b) certificate -> axiom
    nb, bad_dec, bad_A1, bad_valid, bad_size, bad_bits, bad_reject = 0, 0, 0, 0, 0, 0, 0
    for _ in range(3000):
        c = [rng.randrange(2) for _ in range(rng.randrange(0, 40))]
        phi = C1.rform(3)
        if not K.closed(phi):
            continue
        b = rng.randrange(2)
        phib = phi if b else K.neg(phi)
        th = theta(c)
        nb += 1
        bad_dec += decode_theta(th) != c
        bad_A1 += not K.is_A1(th)
        chi = K.imp(th, phib)
        lines = [(th, ('ax',)), (chi, ('ax',)), (phib, ('mp', 0, 1))]
        ok, _ = K.check_derivation(lines, lambda f: f == chi)
        bad_valid += not ok
        bad_size += K.derivation_size(lines) != 2 * len(c) + 2 * K.size(phib) + 29
        bad_bits += K.code_length(lines, BS) != 2 * BS * len(c) + 2 * K.formula_bits(phib, BS) + 29 * BS + 24
        # formulas of a similar outer shape that are not theta_c must be rejected by the decoder
        junk = K.imp(Z, K.imp(K.imp(C_of(c), Z), Z))
        bad_reject += decode_theta(junk) is not None
    out.append(f"(b) certificate -> axiom: {nb} random (phi, c, polarity), |c| < 40")
    out.append(f"    decode(theta_c) != c: {bad_dec}; theta_c not an A1 instance: {bad_A1}; invalid derivation: "
               f"{bad_valid}")
    out.append(f"    symbol size != 2|c| + 2|phi^b| + 29: {bad_size}; bit length != 2 b_s|c| + 2|phi^b|_bit + 29 b_s + "
               f"24: {bad_bits}; mis-shaped formula accepted by the decoder: {bad_reject}")
    okb = bad_dec == bad_A1 == bad_valid == bad_size == bad_bits == bad_reject == 0
    # (a) derivation -> certificate
    na, bad_rt, bad_ver, bad_len, bad_codelen = 0, 0, 0, 0, 0
    for _ in range(120):
        NL = [C1.closed_sentence(2) for _ in range(4)]
        NLset = set(NL)
        raw = C1.generate(100, NL)
        for t in rng.sample(range(len(raw)), 4):
            pi = K.normalise(raw[:t + 1])
            na += 1
            s = enc_derivation(pi)
            back, i = dec_derivation2(s)
            bad_rt += (back != pi or i != len(s))
            bad_codelen += len(s) != K.code_length(pi, BS)
            cert = certificate(pi)
            phi = pi[-1][0]
            verdict, rec = verifier(phi, cert, lambda f: f in NLset)
            bad_ver += not (verdict == 'acc' and rec == pi)
            bad_len += len(cert) != len(s) - len(enc_f(phi)) - 2
    out.append(f"(a) derivation -> certificate: {na} normal derivations (generator of c1)")
    out.append(f"    encode/decode round trip fails: {bad_rt}; code length != computed length: {bad_codelen}")
    out.append(f"    verifier does not recover the derivation from (phi, certificate): {bad_ver}; "
               f"certificate length != code length - |phi|_bit - 2: {bad_len}")
    oka = bad_rt == bad_ver == bad_len == bad_codelen == 0
    out.append("")
    out.append(f"verdict: {'all checks pass' if oka and okb else 'FAILURE'}")


if __name__ == '__main__':
    main()
    text = "\n".join(out)
    print(text)
    with open(__file__.replace('.py', '.out'), 'w') as fh:
        fh.write(text + "\n")
