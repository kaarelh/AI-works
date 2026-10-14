"""Check the label manifest of PLAN.md against the base Paper 2 (dcb3a3a3).
Usage: python3 -I plan_check.py  (run from anywhere; reads the base with git show)."""
import re, subprocess, sys
ROOT = '/home/user/AI-works'
PLAN = ROOT + '/solomonoff-function-induction/research/paper-review/restructure/PLAN.md'
files = subprocess.run(['git', '-C', ROOT, 'ls-tree', '-r', '--name-only', 'dcb3a3a3',
                        'solomonoff-function-induction/paper-steeper/sections'],
                       capture_output=True, text=True, check=True).stdout.split()
base = {}
for f in files:
    if 'app-verification' in f or not f.endswith('.tex'):
        continue
    t = subprocess.run(['git', '-C', ROOT, 'show', 'dcb3a3a3:' + f], capture_output=True, text=True, check=True).stdout
    for l in re.findall(r'\\label\{([^}]*)\}', t):
        base[l] = f.rsplit('/', 1)[1]
plan = open(PLAN).read()
sec31 = plan.split('### 3.1')[1].split('### 3.2')[0]
sec32 = plan.split('### 3.2')[1].split('### 3.3')[0]
sec33 = plan.split('### 3.3')[1].split('### 3.4')[0]
def first_col_labels(block):
    out = []
    for line in block.splitlines():
        if line.startswith('| `'):
            cell = line.split('|')[1]
            out += re.findall(r'`([a-z]+:[A-Za-z0-9:]+)`', cell)
    return out
thm = [l for l in base if not re.match(r'(sec|app):', l)]
struct = [l for l in base if re.match(r'(sec|app):', l)]
m31 = first_col_labels(sec31); m32 = first_col_labels(sec32); m33 = first_col_labels(sec33)
ok = True
missing_thm = sorted(set(thm) - set(m31)); missing_struct = sorted(set(struct) - set(m32))
dup31 = sorted({l for l in m31 if m31.count(l) > 1}); dup32 = sorted({l for l in m32 if m32.count(l) > 1})
extra31 = sorted(set(m31) - set(thm))
new_clash = sorted(set(m33) & set(base)); dup33 = sorted({l for l in m33 if m33.count(l) > 1})
print('base theorem-like labels:', len(thm), '| in 3.1:', len(set(m31)))
print('base structural labels:', len(struct), '| in 3.2:', len(set(m32)))
print('new labels in 3.3:', len(set(m33)), sorted(set(m33)))
for name, val in [('missing theorem-like', missing_thm), ('missing structural', missing_struct),
                  ('duplicated in 3.1', dup31), ('duplicated in 3.2', dup32), ('3.1 labels not in base', extra31),
                  ('new labels clashing with base', new_clash), ('duplicated new labels', dup33)]:
    print(name + ':', val if val else 'none'); ok &= not val
print('ALL OK' if ok else 'PROBLEMS')
sys.exit(0 if ok else 1)
