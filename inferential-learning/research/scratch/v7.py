import numpy as np
exec(open('prop62.py').read().split('# check bound validity')[0])
rs = np.linspace(20, 34, 57); sg = np.linspace(0.5, 1, 101); al = np.radians(np.linspace(30, 60, 61))
R = np.array([[exact_ratio(r, s)[0] for s in sg] for r in rs])   # E_true/thin (point sun)
for name, f in [('V6', lambda a: 2*np.cos(a)**(1/1000)), ('V7', lambda a: 1.15*np.cos(a)**(1/50)), ('V8', lambda a: 1.5*np.exp(a/1000))]:
    A = np.array([f(a) for a in al])
    e1 = np.max(np.abs(R[..., None]/A[None, None, :] - 1)); e2 = np.max(np.abs(A[None, None, :]/R[..., None] - 1))
    e1min = np.min(np.abs(R[..., None]/A[None, None, :] - 1))
    print(name, 'max|E/ans-1|', round(e1, 4), 'max|ans/E-1|', round(e2, 4), 'min|E/ans-1|', round(e1min,4))
