"""bai: Bayesian axiom induction over DT° template theories.

The package reuses the syntax, DT° templates, unique matcher and minimal covering templates of
../axiom-schemas/code/dtrc (imported read-only through sys.path; that package is not modified).
"""
import os
import sys

_HERE = os.path.dirname(os.path.abspath(__file__))
DTRC_ROOT = os.path.abspath(os.path.join(_HERE, '..', '..', '..', 'axiom-schemas', 'code'))
if DTRC_ROOT not in sys.path:
    sys.path.insert(0, DTRC_ROOT)

sys.setrecursionlimit(max(sys.getrecursionlimit(), 20000))
