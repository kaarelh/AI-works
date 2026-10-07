# E0b: property-based checks of Min (both languages, rigid parameters)

Command: `python3 experiments/e0b_property.py 200`. Generator: the referee's (recheck/r5_mincover.py). (a) = minima cover D, are DT°_F, pairwise incomparable; (b) = Prop E1(c), some minimum <= T*; (c) = specialisation walks from T*: reached covering templates not >= any minimum (E1(b) failures) and strictly below a minimum (minimality failures).

| language | T* has a rigid parameter | Min | data sets | minima | (a) failures | (b) failures | walk templates | (c) not above a min | (c) below a min | Min^al differs from Min_lit |
|---|---|---|---|---|---|---|---|---|---|---|
| PA | no | Min_lit | 200 | 200 | 0 | 0 | 380 | 0 | 0 | - |
| PA | no | Min^al | 200 | 200 | 0 | 0 | 380 | 0 | 0 | 38 |
| PA | yes | Min_lit | 200 | 200 | 0 | 17 | 317 | 6 | 0 | - |
| PA | yes | Min^al | 200 | 203 | 0 | 0 | 320 | 0 | 0 | 199 |
| ZF | no | Min_lit | 200 | 200 | 0 | 0 | 408 | 0 | 0 | - |
| ZF | no | Min^al | 200 | 206 | 0 | 0 | 408 | 0 | 0 | 72 |
| ZF | yes | Min_lit | 200 | 204 | 0 | 36 | 381 | 27 | 0 | - |
| ZF | yes | Min^al | 200 | 220 | 0 | 0 | 419 | 0 | 0 | 199 |

Examples of (b) failures:

* PA, Min_lit: T* = `(?f0=a & ?P1) -> (Ex.?P2(x))`; D = `(w0=w1 & (2=1 & 0=0)) -> (Ex.~(Ey.y<x & 1=y)) ; (0=w0 & (2=1 & (Ax.S(1+x)=x))) -> (Ex.~0=S(x+x))`; computed Min = `(?f0=?f1 & (2=1 & ?P0)) -> (Ex.~?P1(x))`
* PA, Min_lit: T* = `?P0 | (Ax.(Ay.?f1<a+y) -> Sx<0)`; D = `~(Ax.Sx=S(0+w0)) | (Ax.(Ay.w0*1*1<w0+y) -> Sx<0) ; ~w0+1=1 | (Ax.(Ay.0+3<w0+y) -> Sx<0) ; ~0+1=0 | (Ax.(Ay.w0<w1+y) -> Sx<0)`; computed Min = `~?P0 | (Ax.(Ay.?f0<?f1+y) -> Sx<0)`
* ZF, Min_lit: T* = `~(?P0 | c=c)`; D = `~(w0 in w1 | w1=w1) ; ~((Ex.w0 in w0) | w0=w0)`; computed Min = `~(?P0 | ?f0=?f0)`
* ZF, Min_lit: T* = `(?P0 & c=c) | c in c`; D = `(~(Ax.x in w0 -> w0 in x) & w0=w0) | w0 in w0 ; (~(Ex.x in w0 & (Ay.y in x -> x in y)) & w1=w1) | w1 in w1`; computed Min = `(~?P0 & ?f0=?f0) | ?f0 in ?f0`

Wall time: 5.3s
