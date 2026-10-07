# u14: every DTRC run in u5 (parts A and B), u6, u8, u9, u10 reaches the audit fixpoint on the first pass (u3, u5b print it themselves)
import sys, io, contextlib
sys.path.insert(0, '/home/user/AI-works/axiom-schemas/research/tracks/untagged/code')
import dtrc
rounds = []
orig = dtrc.DTRC.run_fixpoint
def wrapped(self, D, max_rounds=10):
    r = orig(self, D, max_rounds)
    rounds.append(self.rounds)
    return r
dtrc.DTRC.run_fixpoint = wrapped
for script in ('u6_forall_nontrans.py', 'u8_noise.py', 'u9_clean_fragmentation.py', 'u5_dtrc_zf.py', 'u10_zfc_choice.py'):
    rounds.clear()
    with contextlib.redirect_stdout(io.StringIO()):
        exec(compile(open(script).read(), script, 'exec'), {'__name__': '__main__'})
    print(script, 'DTRC runs:', len(rounds), 'passes per run:', sorted(set(rounds)))
