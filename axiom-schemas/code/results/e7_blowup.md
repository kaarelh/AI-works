# E7: size of Min(D) for pairs, DT° vs DT°_F

Command: `python3 experiments/e7_blowup.py`.

| mix | class | pairs | |Min|=1 | 2-4 | 5-16 | >16 | timeouts (>2s) | max |Min| | total time (s) |
|---|---|---|---|---|---|---|---|---|---|
| PA | DT° | 1176 | 1159 | 13 | 1 | 3 | 0 | 64 | 0.5 |
| PA | DT°_F | 1176 | 1143 | 33 | 0 | 0 | 0 | 4 | 0.2 |
| ZF | DT° | 666 | 660 | 0 | 0 | 3 | 3 | 32 | 6.2 |
| ZF | DT°_F | 666 | 661 | 2 | 3 | 0 | 0 | 8 | 0.1 |

Largest computed Min per (mix, class):

* PA DT°: |Min| = 64 for
    * `(0=S(0+0) & (Ax.0=S(x+x) -> 0=S(Sx+Sx))) -> (Ax.0=S(x+x))`
    * `(0=S(0+0) & (Ax.0=S(0+0) -> 0=S(0+0))) -> (Ax.0=S(0+0))`
* PA DT°_F: |Min| = 4 for
    * `((Ex.x<1 & (x=S(0+x) -> 1=0)) & (Ax.(Ey.y<Sx & (y=S(x+y) -> Sx=x)) -> (Ey.y<SSx & (y=S(Sx+y) -> SSx=Sx)))) -> (Ax.Ey.y<Sx & (y=S(x+y) -> Sx=x))`
    * `((Ex.x<0 & ((Ey.1=S(0*0)) -> 1=Sw0)) & (Ax.(Ey.y<x & ((Ez.1=S(x*0)) -> Sx=Sw0)) -> (Ey.y<Sx & ((Ez.1=S(Sx*0)) -> SSx=Sw0)))) -> (Ax.Ey.y<x & ((Ez.1=S(x*0)) -> Sx=Sw0))`
* ZF DT°: |Min| = 32 for
    * `Ax.Ey.Az.z in y <-> (z in x & (Eu.u in z & z=u))`
    * `Ax.Ey.Az.z in y <-> (z in x & (Eu.u in x & (Ev.x=z)))`
* ZF DT°_F: |Min| = 8 for
    * `Ax.(Ay.y in x -> (Ez.((Eu.x in x) & (Au.u in y -> x=z)) & (Au.((Ev.x in x) & (Av.v in y -> x=u)) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ((Ev.x in x) & (Av.v in u -> x=z))))`
    * `Ax.(Ay.y in x -> (Ez.((Eu.u in y & z in u) & (Au.u in x -> x in x)) & (Au.((Ev.v in y & u in v) & (Av.v in x -> x in x)) -> u=z))) -> (Ey.Az.z in y <-> (Eu.u in x & ((Ev.v in u & z in v) & (Av.v in x -> x in x))))`

Wall time: 7.0s
