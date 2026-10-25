def parse(spec):
    kw = {}
    for a in spec.split(';'):
        k, v = a.split('=')
        if v == 'None': kw[k] = None
        else:
            try: kw[k] = float(v)
            except ValueError: kw[k] = v
    return kw
