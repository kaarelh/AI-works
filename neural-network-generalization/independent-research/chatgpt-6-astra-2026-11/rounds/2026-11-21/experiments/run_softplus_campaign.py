"""Bounded sequential validation campaign; preserves per-proposal output."""
from pathlib import Path
import argparse,datetime,json,subprocess,sys,time
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'results/softplus_campaign';OUT.mkdir(exist_ok=True)
parser=argparse.ArgumentParser();parser.add_argument('--hours',type=float,default=8.);parser.add_argument('--stop-utc');args=parser.parse_args()
stop=datetime.datetime.fromisoformat(args.stop_utc) if args.stop_utc else datetime.datetime.now(datetime.timezone.utc)+datetime.timedelta(hours=args.hours)
if stop.tzinfo is None:raise SystemExit('--stop-utc must include a timezone')
jobs=[(65536,2000),(262144,2000),(1048576,1500),(4194304,1200),(16777216,1000)]
records=[]
for j,(width,proposals) in enumerate(jobs):
    remaining=(stop-datetime.datetime.now(datetime.timezone.utc)).total_seconds()
    if remaining<60:break
    name=f'square_N{width}';command=[sys.executable,str(ROOT/'experiments/softplus_corrected_proposal.py'),'--width',str(width),
        '--proposals',str(proposals),'--seed',str(2026112231+j),'--output',str(OUT/(name+'.json'))]
    start=time.monotonic()
    with (OUT/(name+'.log')).open('w') as stream:
        try:result=subprocess.run(command,stdout=stream,stderr=subprocess.STDOUT,timeout=remaining);status='complete' if result.returncode==0 else 'failed'
        except subprocess.TimeoutExpired:status='time_cap_reached'
    row=dict(name=name,width=width,proposals=proposals,status=status,seconds=time.monotonic()-start,command=command)
    records.append(row);(OUT/'campaign.json').write_text(json.dumps(records,indent=2)+'\n');print(json.dumps(row),flush=True)
    if status!='complete':break
