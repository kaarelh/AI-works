# Per-seed re-read of E3(b) from code/results/e3_misspec.json
import json
d=json.load(open('/home/user/AI-works/axiom-induction/code/results/e3_misspec.json'))
for gen in ('dtrc-motive','root-skew','deep','atomic'):
    rs=[r for r in d['b'] if r['gen']==gen]
    print('==',gen, 'seeds', [r['seed'] for r in rs])
    for n in (16,64,256,1024,2048):
        line=[]
        for r in rs:
            row=[x for x in r['rows'] if x['n']==n]
            if not row: continue
            row=row[0]
            fa=row.get('post',{}).get('frag-atoms')
            line.append(f"s{r['seed']}: T*={row['T*']:.3g} eq={row['eq']['yes']:.3g} map={row['map']}({row['map_post']:.3g}) fa={fa}")
        print(n,'; '.join(line))
    # code lengths of frag-observed relative to T* at 2048
    for r in rs:
        row=[x for x in r['rows'] if x['n']==2048][0]
        b=row['bits']
        fo={k:round(v-b['T*'],1) for k,v in b.items() if k.startswith('frag-observed')}
        print('  seed',r['seed'],'frag-observed - T* at 2048:',fo)
