# E6: cautious k-union verifier over DT°_F (no clustering), Q + induction

Command: `python3 experiments/e6_kunion.py`.

| induction motives in data | k | refutation negatives | held-out Ind accepted | false non-instances accepted | time (s) |
|---|---|---|---|---|---|
| x=x , ~x=0 | 8 | no | 0/8 | 0/2 | 0.0 |
| x=x , ~x=0 | 8 | yes | 8/8 | 0/2 | 0.6 |
| x=x , ~x=0 | 9 | no | 0/8 | 0/2 | 0.0 |
| x=x , ~x=0 | 9 | yes | 0/8 | 0/2 | 0.8 |
| x=x , ~x=0 , x+0=x | 8 | no | 0/8 | 0/2 | 0.0 |
| x=x , ~x=0 , x+0=x | 8 | yes | 8/8 | 0/2 | 4.4 |
| x=x , ~x=0 , x+0=x | 9 | no | 0/8 | 0/2 | 0.0 |
| x=x , ~x=0 , x+0=x | 9 | yes | 8/8 | 0/2 | 5.2 |
| x=x , ~x=0 , Ey.x<y | 9 | no | 0/8 | 0/2 | 0.0 |
| x=x , ~x=0 , Ey.x<y | 9 | yes | 8/8 | 0/2 | 4.7 |

Witness unions (a member of the version space that misses the query):

* motives ['x=x', '~x=0'], k=8, negatives=False; query `(0*0=0 & (Ax.x*0=0 -> Sx*0=0)) -> (Ax.x*0=0)`:
    * `Ax.?P0(x)`
    * `(0=0 & (Ax.x=x -> Sx=Sx)) -> (Ax.x=x)`
    * `(~0=0 & (Ax.~x=0 -> ~Sx=0)) -> (Ax.~x=0)`
* motives ['x=x', '~x=0'], k=9, negatives=False; query `(0*0=0 & (Ax.x*0=0 -> Sx*0=0)) -> (Ax.x*0=0)`:
    * `Ax.?P0(x)`
    * `(0=0 & (Ax.x=x -> Sx=Sx)) -> (Ax.x=x)`
    * `(~0=0 & (Ax.~x=0 -> ~Sx=0)) -> (Ax.~x=0)`
* motives ['x=x', '~x=0'], k=9, negatives=True; query `(0*0=0 & (Ax.x*0=0 -> Sx*0=0)) -> (Ax.x*0=0)`:
    * `Ax.~Sx=0`
    * `Ax.Ay.Sx=Sy -> x=y`
    * `Ax.~x=0 -> (Ey.x=Sy)`
    * `Ax.x+0=x`
    * `Ax.Ay.x+Sy=S(x+y)`
    * `Ax.x*0=0`
    * `Ax.Ay.x*Sy=x*y+x`
    * `(0=0 & (Ax.x=x -> Sx=Sx)) -> (Ax.x=x)`
    * `(~0=0 & (Ax.~x=0 -> ~Sx=0)) -> (Ax.~x=0)`
* motives ['x=x', '~x=0', 'x+0=x'], k=8, negatives=False; query `(0*0=0 & (Ax.x*0=0 -> Sx*0=0)) -> (Ax.x*0=0)`:
    * `Ax.?P0(x)`
    * `(0=0 & (Ax.x=x -> Sx=Sx)) -> (Ax.x=x)`
    * `(~0=0 & (Ax.~x=0 -> ~Sx=0)) -> (Ax.~x=0)`
    * `(0+0=0 & (Ax.x+0=x -> Sx+0=Sx)) -> (Ax.x+0=x)`
* motives ['x=x', '~x=0', 'x+0=x'], k=9, negatives=False; query `(0*0=0 & (Ax.x*0=0 -> Sx*0=0)) -> (Ax.x*0=0)`:
    * `Ax.?P0(x)`
    * `(0=0 & (Ax.x=x -> Sx=Sx)) -> (Ax.x=x)`
    * `(~0=0 & (Ax.~x=0 -> ~Sx=0)) -> (Ax.~x=0)`
    * `(0+0=0 & (Ax.x+0=x -> Sx+0=Sx)) -> (Ax.x+0=x)`
* motives ['x=x', '~x=0', 'Ey.x<y'], k=9, negatives=False; query `(0*0=0 & (Ax.x*0=0 -> Sx*0=0)) -> (Ax.x*0=0)`:
    * `Ax.?P0(x)`
    * `(0=0 & (Ax.x=x -> Sx=Sx)) -> (Ax.x=x)`
    * `(~0=0 & (Ax.~x=0 -> ~Sx=0)) -> (Ax.~x=0)`
    * `((Ex.0<x) & (Ax.(Ey.x<y) -> (Ey.Sx<y))) -> (Ax.Ey.x<y)`

Wall time: 15.9s
