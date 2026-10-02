# Numerical check of the sharpened many-row remainder bound (Lemma 4.4 of paulsen-streamlined.pdf).
# Prints |R3|/t^3, |R4|/t^4 (operator norms), the crude termwise budget of the original manuscript divided by t^3,
# |Gamma Z|_F^2 and the moment quantity A, for Z = Pi_F g / sqrt(n) computed by explicit projection.
import numpy as np
rng=np.random.default_rng(0)
def run(n,d,eta,t,trials=3):
    a=d/n
    # equal-norm nearly Parseval X: random gaussian rows normalized, then measure eta
    G=rng.standard_normal((n,d)); X=np.sqrt(a)*G/np.linalg.norm(G,axis=1,keepdims=True)
    S=X.T@X; e=X/np.sqrt(a)
    # basis of E-orthocomplement-of-F: Pi_E(X M_k) for symmetric M_k
    cols=[]
    for i in range(d):
        for j in range(i,d):
            M=np.zeros((d,d)); M[i,j]=1; M[j,i]=1
            Y=X@M
            Y=Y-np.sum(Y*e,axis=1,keepdims=True)*e
            cols.append(Y.ravel())
    Q,_=np.linalg.qr(np.array(cols).T)
    m=np.linalg.matrix_rank(np.array(cols).T)
    Q=Q[:,:m]
    out=[]
    for _ in range(trials):
        g=rng.standard_normal((n,d))
        Z0=g-np.sum(g*e,axis=1,keepdims=True)*e
        z=Z0.ravel(); z=z-Q@(Q.T@z); Z=z.reshape(n,d)/np.sqrt(n); Z0=Z0/np.sqrt(n)
        assert np.abs(X.T@Z+Z.T@X).max()<1e-10
        r=np.sum(Z*Z,axis=1)/a; c=r/(1+t*t*r)
        R3=-t**3*(X.T@(c[:,None]*Z)+(c[:,None]*Z).T@X)
        R4=-t**4*((c[:,None]*Z).T@Z - X.T@((c*r)[:,None]*X))
        crude=2*a*t**3*np.sum(r**1.5)+2*a*t**4*np.sum(r**2)
        cbar=1/(1+t*t)
        GZ=np.linalg.norm((c-cbar)[:,None]*Z); A=a*np.sum((r-1)**2*(1+r)**2)
        V=(X+t*Z)/np.sqrt(1+t*t*r)[:,None]
        delta=np.linalg.norm(V.T@V-np.eye(d),2)
        out.append((np.linalg.norm(R3,2)/t**3, np.linalg.norm(R4,2)/t**4, crude/t**3, GZ**2, A, delta/t**2, np.linalg.norm(S-np.eye(d),2)/t**2, np.linalg.norm(Z,2)))
    return m,np.array(out).mean(0)
for (n,d) in [(2000,10),(2000,20),(4000,20)]:
    for t in [0.3,0.1]:
        m,o=run(n,d,None,t)
        print(f"n={n} d={d} t={t} m={m}: |R3|/t^3={o[0]:.3f} |R4|/t^4={o[1]:.3f} crude/t^3={o[2]:.1f} |GZ|^2={o[3]:.3f} A={o[4]:.3f} delta/t^2={o[5]:.3f} eta/t^2={o[6]:.3f} |Z|op={o[7]:.2f}")
