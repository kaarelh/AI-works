"""Run the C helper nearest.c on an enumeration file and save, for every function f and every
Hamming distance r, the least K(g) over functions g != f at distance exactly r.

Usage: python3 nearest.py IN.npz OUT.npy        (compiles nearest.c with gcc if needed)
"""
import os
import struct
import subprocess
import sys

import numpy as np

here = os.path.dirname(os.path.abspath(__file__))
exe = os.path.join(here, "nearest")
if not os.path.exists(exe):
    subprocess.check_call(["gcc", "-O3", "-march=native", "-fopenmp", "-o", exe,
                           os.path.join(here, "nearest.c")])
d = np.load(sys.argv[1])
F, K = np.ascontiguousarray(d["F"], dtype=np.uint8), d["K"].astype(np.int16)
n, nxy = F.shape
buf = struct.pack("ii", n, nxy) + F.tobytes() + K.tobytes()
res = subprocess.run([exe], input=buf, stdout=subprocess.PIPE, check=True).stdout
prof = np.frombuffer(res, dtype=np.int16).reshape(n, nxy + 1)
np.save(sys.argv[2], prof)
print("saved", sys.argv[2], prof.shape)
