import math
g=9.81; rho=1.2; Cd=0.47
def sim(m,r,v0,th,dt=1e-5):
    A=math.pi*r*r; k=0.5*rho*Cd*A/m
    x=0;y=0;vx=v0*math.cos(th);vy=v0*math.sin(th);t=0
    while True:
        v=math.hypot(vx,vy)
        ax=-k*v*vx; ay=-g-k*v*vy
        x+=vx*dt;y+=vy*dt;vx+=ax*dt;vy+=ay*dt;t+=dt
        if y<0 and t>0.01: return x,t
for name,m,r in [("steel r=1cm",7800*4/3*math.pi*0.01**3,0.01),("pingpong",0.0027,0.02)]:
    v0=10;th=math.pi/4
    A=math.pi*r*r; adrag=0.5*rho*Cd*A*v0**2/m
    R0=v0**2*math.sin(2*th)/g; T0=2*v0*math.sin(th)/g
    bound=0.5*adrag*T0**2  # crude (uses ideal flight time)
    Rd,Td=sim(m,r,v0,th)
    print(name,"m=%.4f"%m,"a_drag/g=%.3f"%(adrag/g),"R0=%.3f"%R0,"Rdrag=%.3f"%Rd,"rel err=%.3f"%((R0-Rd)/R0),"crude bound rel=%.3f"%(bound/R0),"buoyancy ratio=%.2e"%(rho/(m/(4/3*math.pi*r**3))))
