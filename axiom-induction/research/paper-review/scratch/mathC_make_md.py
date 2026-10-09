# Builds research/paper-review/review-math-C.md from the narrative and issues-math-C.json.
import json
base = '/home/user/AI-works/axiom-induction/research/paper-review/'
nar = open(base + 'scratch/mathC_narrative.md').read()
I = json.load(open(base + 'issues-math-C.json'))
out = [nar.rstrip('\n'), '']
for k, it in enumerate(I, 1):
    out.append('%d. **%s [%s]** `%s`, %s.' % (k, it['id'], it['severity'], it['file'], it['label_or_line']))
    out.append('   * *Problem.* ' + it['problem'])
    out.append('   * *Evidence.* ' + it['evidence'])
    out.append('   * *Fix.* ' + it['fix'])
    out.append('')
open(base + 'review-math-C.md', 'w').write('\n'.join(out))
print('written', len(I), 'issues')
