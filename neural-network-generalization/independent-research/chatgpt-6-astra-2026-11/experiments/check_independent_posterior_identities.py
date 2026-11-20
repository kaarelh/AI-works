"""Exact rational checks of finite-dimensional sampler identities.

These checks do not certify the asymptotic posterior theorems. They test
Gaussian conditioning, determinant normalizations, coarea-related matrix
identities, and the exact local ReLU output formula without floats.
"""
import itertools,json,random,time
from fractions import Fraction
from pathlib import Path
import sympy as s
ROOT=Path(__file__).resolve().parents[1];rng=random.Random(20261120);start=time.monotonic();checks=[]
for M in (2,4,6,8):
 K=M//2;n=M+3
 for replicate in range(3):
  Q=s.eye(M)
  for step in range(2*M):
   i,j=rng.sample(range(M),2);R=s.eye(M);R[i,i]=R[j,j]=s.Rational(3,5);R[i,j]=s.Rational(4,5);R[j,i]=-s.Rational(4,5);Q=Q*R
  assert Q.T*Q==s.eye(M)
  A=Q[:,:K]*s.diag(*range(1,K+1));B=Q[:,K:];plus=(A.T*A).inv()*A.T
  H=s.Matrix(M,n,lambda i,j:rng.randrange(-3,4));H[:,:M]=s.eye(M)
  T=B.T*H;C=T*T.T;projection=s.eye(n)-T.T*C.inv()*T
  assert projection.T==projection and projection*projection==projection and T*projection==s.zeros(K,n)
  mean=s.Matrix([rng.randrange(-2,3) for _ in range(n)]);xi=s.Matrix([rng.randrange(-2,3) for _ in range(n)]);target=s.Matrix([rng.randrange(-2,3) for _ in range(M)])
  d=B.T*target;readout=mean+xi+T.T*C.inv()*(d-T*(mean+xi));c=plus*(target-H*readout)
  assert T*readout==d and H*readout+A*c==target
  Sigma=H*H.T+s.diag(*range(1,M+1));gamma=s.Rational(2,3)
  assert s.factor(Sigma.det()*(A.T*Sigma.inv()*A).det()-(A.T*A).det()*(B.T*Sigma*B).det())==0
  W=s.eye(M)+gamma*Sigma
  assert s.factor(W.det()*(A.T*W.inv()*A).det()-(A.T*A).det()*(s.eye(K)+gamma*B.T*Sigma*B).det())==0
  residual=H*mean+A*c-target;P=s.eye(M)-A*plus
  centered=c-plus*target+plus*H*mean
  assert (residual.T*residual)[0]==((P*H*mean-P*target).T*(P*H*mean-P*target))[0]+(centered.T*A.T*A*centered)[0]
  checks.append(dict(output_dimension=M,replicate=replicate,status='PASS'))
corner_checks=0
for r in (4,6,8):
 for replicate in range(4):
  z=[rng.choice((-1,1)) for _ in range(r)];u=[Fraction(rng.randrange(-3,4),100) for _ in range(r+1)]
  # Orthogonalize the weights exactly; the incoming core is 16*z.
  dot=sum(Fraction(z[j])*u[j+1] for j in range(r))
  for j in range(r):u[j+1]-=Fraction(z[j],r)*dot
  sigma=(-1)**(r//2-1)
  for v in z:sigma*=v
  for x in itertools.product((-1,1),repeat=r):
   sx=sum(a*b for a,b in zip(z,x));tx=u[0]+sum(a*b for a,b in zip(u[1:],x))
   actual=sigma*9*max(Fraction(16*sx)+tx,0)
   psi=sigma*(tx if sx>0 else max(tx,0) if sx==0 else 0)
   # Both sides are divided by sqrt(r): A=9sqrt(r), R=16sqrt(r).
   expected=144*sigma*max(sx,0)+9*psi
   assert actual==expected
   corner_checks+=1
result=dict(status='PASS',rational_matrix_cases=len(checks),exact_corner_input_cases=corner_checks,seconds=time.monotonic()-start,checks=checks,scope='Finite algebra identities only; the probability limits and computational-cost theorem are conventional proofs, not formalized by this script.')
(ROOT/'results/independent_posterior_identity_checks.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps({k:v for k,v in result.items() if k!='checks'}))
