# E1: universal axioms from instances (Q1)

Command: `python3 experiments/e1_universal.py`; 2000 runs per target, run r uses random.Random(1000*1000003 + 7919*r), N capped at 40 (a run that never becomes exact is counted as 41).

Instance distribution *mixed*: numeral (p=0.6, uniform 0..7), random closed term over 0,S,+,* of depth <= 2 (p=0.25), parameter (p=0.15). *numerals*: numerals only.

| data | target | DT°_F mean N | median | 95% | fo-lgg mean N | same N (runs) | predicted mean N |
|---|---|---|---|---|---|---|---|
| mixed | x+0=x | 3.27 | 2 | 7 | 3.27 | 2000/2000 | 3.25 |
| mixed | x*0=0 | 3.27 | 2 | 7 | 3.27 | 2000/2000 | 3.25 |
| mixed | 0+x=x | 3.27 | 2 | 7 | 3.27 | 2000/2000 | 3.25 |
| mixed | ~Sx=0 | 3.27 | 2 | 7 | 3.27 | 2000/2000 | 3.25 |
| mixed | x<Sx | 3.27 | 2 | 7 | 3.27 | 2000/2000 | 3.25 |
| mixed | x+y=y+x | 4.18 | 3 | 9 | 4.18 | 2000/2000 | - |
| numerals | x+0=x | 8.42 | 6 | 24 | 8.42 | 2000/2000 | 8.11 |
| numerals | x*0=0 | 8.42 | 6 | 24 | 8.42 | 2000/2000 | 8.11 |
| numerals | 0+x=x | 8.42 | 6 | 24 | 8.42 | 2000/2000 | 8.11 |
| numerals | ~Sx=0 | 8.42 | 6 | 24 | 8.42 | 2000/2000 | 8.11 |
| numerals | x<Sx | 8.42 | 6 | 24 | 8.42 | 2000/2000 | 8.11 |
| numerals | x+y=y+x | 11.85 | 10 | 28 | 11.85 | 2000/2000 | - |

Predicted: E[min(N,41)] from P(not exact after N) = sum_h p_h^N (anchor iff the substituted terms do not all share a head symbol); head distributions: mixed {'S': 0.65, '0': 0.1, '+': 0.05, '*': 0.05, 'param': 0.15}, numerals {'S': 0.875, '0': 0.125}.

## Closure-normal form: the learned schema accepts the Gen form

| target | data | Min(D) | query (closure = Ax...) | accepted |
|---|---|---|---|---|
| x+0=x | 0+0=0; 1+0=1 | ?f0+0=?f0 | w0+0=w0 | True |
| x*0=0 | 0*0=0; 1*0=0 | ?f0*0=0 | w0*0=0 | True |
| 0+x=x | 0+0=0; 0+1=1 | 0+?f0=?f0 | 0+w0=w0 | True |
| ~Sx=0 | ~1=0; ~2=0 | ~S?f0=0 | ~Sw0=0 | True |
| x<Sx | 0<1; 1<2 | ?f0<S?f0 | w0<Sw0 | True |
| x+y=y+x | 0+1=1+0; 1+(0+0)=0+0+1 | ?f0+?f1=?f1+?f0 | w0+w1=w1+w0 | True |

## A non-anchor: all substituted terms have head S

D = 1+0=1, 2+0=2, 3+0=3 ; Min(D) = S?f0+0=S?f0 ; accepts 0+0=0: False

Wall time: 48.3s
