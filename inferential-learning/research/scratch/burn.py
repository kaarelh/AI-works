import time, sys
from multiprocessing import Pool
def f(_):
    t=time.time(); s=0
    for i in range(6_000_000): s += i*i % 7
    return time.time()-t
if __name__ == '__main__':
    for n in (1, 2, 4):
        with Pool(n) as p:
            t=time.time(); r = p.map(f, range(n)); print(n, 'workers: per-task %.2fs, wall %.2fs' % (sum(r)/n, time.time()-t))
