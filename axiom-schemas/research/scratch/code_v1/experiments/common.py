"""Shared experiment helpers."""
import os
import sys
import json
import random
import time
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..'))
RESULTS = os.path.abspath(os.path.join(HERE, '..', 'results'))
os.makedirs(RESULTS, exist_ok=True)

from dtrc.syntax import canon_params, pp                      # noqa: E402
from dtrc.templates import match, geq, equiv                    # noqa: E402
from dtrc.refute import TemplateRefuter, Oracle                 # noqa: E402
from dtrc.dtrc import DTRC, tagged_learner                      # noqa: E402
from dtrc.metrics import (adjusted_rand, purity, exact_for, complete_for, targets_of,  # noqa: E402
                          sample_instances)
from dtrc.baselines import FOLgg, pattern_lgg                   # noqa: E402


def save(name, text, data=None):
    with open(os.path.join(RESULTS, name + '.md'), 'w') as f:
        f.write(text)
    if data is not None:
        with open(os.path.join(RESULTS, name + '.json'), 'w') as f:
            json.dump(data, f, indent=1, default=str)


def md_table(header, rows):
    out = '| ' + ' | '.join(header) + ' |\n'
    out += '|' + '|'.join(['---'] * len(header)) + '|\n'
    for r in rows:
        out += '| ' + ' | '.join(str(x) for x in r) + ' |\n'
    return out


def clustering_scores(model, data, targets):
    lab = {}
    for s, l in data:
        lab.setdefault(canon_params(s), l)
    sents = [s for s in lab if not lab[s].startswith('MISTAKE') and len(targets_of(s, targets)) == 1]
    pred = model.labels_for(sents)
    keep = [i for i, p in enumerate(pred) if p >= 0]
    yt = [lab[sents[i]] for i in keep]
    yp = [pred[i] for i in keep]
    amb = sum(1 for s in lab if len(targets_of(s, targets)) > 1)
    return {'ARI': round(adjusted_rand(yt, yp), 4), 'purity': round(purity(yt, yp), 4), 'n_scored': len(yt),
            'n_ambiguous': amb}


def per_target(model, targets, heldout):
    out = {}
    for name, T in targets.items():
        ex = any(c.acc and exact_for(c.acc, T) for c in model.clusters)
        ho = heldout.get(name, [])
        acc = sum(1 for q in ho if model.accepts(q))
        out[name] = {'exact': ex, 'heldout_accepted': acc, 'heldout_total': len(ho)}
    return out


def probe_dtrc(model, targets, lang, rng, n_per_cluster=30, oracle=None):
    """sample instances of each cluster's acceptance set; count non-target and oracle-refuted ones"""
    oracle = oracle or Oracle(lang)
    tot = nontarget = refuted = 0
    examples = []
    for c in model.clusters:
        if not c.acc:
            continue
        cand = sample_instances(c.acc[0], lang, rng, n_per_cluster * 2, data=c.data)
        cand = [q for q in dict.fromkeys(cand) if model.cluster_accepts(c, q)][:n_per_cluster]
        for q in cand:
            tot += 1
            if not targets_of(q, targets):
                nontarget += 1
                if oracle.refutes(q):
                    refuted += 1
                    if len(examples) < 3:
                        examples.append(pp(q))
    return {'probes': tot, 'nontarget': nontarget, 'refuted': refuted, 'examples': examples}


def probe_hyp(sampler, targets, lang, oracle):
    """sampler() -> list of accepted sentences"""
    qs = list(dict.fromkeys(sampler()))
    nontarget = refuted = 0
    ex = []
    for q in qs:
        if not targets_of(q, targets):
            nontarget += 1
            if oracle.refutes(q):
                refuted += 1
                if len(ex) < 2:
                    ex.append(pp(q))
    return {'probes': len(qs), 'nontarget': nontarget, 'refuted': refuted, 'examples': ex}


def by_label(data):
    out = {}
    for s, l in data:
        out.setdefault(l, []).append(canon_params(s))
    return out
