import math,json
out=[]
for H in [2,3,4,6,10,20,50]:
 for B in [1,2,8,64]:
  for multiplier in [1,2,5]:
   r=math.ceil(multiplier*max(8,math.sqrt(32*H))/B)
   G=r*B
   delta=4/(B*G**H)
   def chains(x):
    u=math.tanh(B*x);v=math.tanh(B*x/2)
    for _ in range(2,H+1):u=math.tanh(G*u);v=math.tanh(G*v)
    return u,v
   u,v=chains(delta); gap=u-v;c=1/(r*gap)
   u1,v1=chains(1); anchor=r*c*(u1-v1)
   assert (1-1e-12)/G<=gap<=(2+1e-12)/G,(H,B,r,gap)
   assert B/2*(1-1e-12)<=c<=B*(1+1e-12)
   assert -1e-12<=anchor<=min(1,2*G*math.exp(-2*math.tanh(.5)*G))+1e-12
   out.append({'H':H,'B':B,'group_width':r,'readout_over_B':c/B,'scaled_gap':G*gap,'anchor':anchor})
print(json.dumps({'cases':len(out),'min_scaled_gap':min(x['scaled_gap'] for x in out),'max_readout_over_B':max(x['readout_over_B'] for x in out),'max_anchor':max(x['anchor'] for x in out),'status':'all assertions passed'},indent=2))
