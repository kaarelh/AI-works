#!/usr/bin/env python3
"""Compose two exact sufficient certificates without hiding unresolved rows."""
from pathlib import Path
from fractions import Fraction
import hashlib,json
ROOT=Path(__file__).resolve().parent
def rat(a):return Fraction(int(a['numerator']),int(a['denominator']))
def rr(a):return dict(numerator=str(a.numerator),denominator=str(a.denominator))
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 partition=ROOT/'full-cube-partition-verified-505-c1_1000/certificate.json'
 point=ROOT/'point-covariance-state-verified-505-v325-c1_1000/certificate.json'
 a=json.loads(partition.read_text());b=json.loads(point.read_text())
 for key in ['model','model_sha256','c_exact','readout_energy_exact','noise_radius_squared_exact']:
  assert a[key]==b[key],key
 assert a['input_count']==512 and len(a['rows'])==512 and not a['remaining_groups']
 assert [r['input_index'] for r in a['rows']]==list(range(512))
 failed=[r['input_index'] for r in a['rows'] if not r['certified']]
 assert failed==[325],failed
 assert b['vertex']==325 and b['certified'] and rat(b['clipped_change_upper'])==0
 r=a['rows'][325]
 assert rat(r['output_lower'])<=rat(b['clean_output_upper'])
 assert rat(b['clean_output_lower'])<=rat(r['output_upper'])
 assert rat(b['perturbed_output_upper'])<-Fraction(1,2)
 assert a['all_training_margins_interval_verified']
 minimum=min(min(abs(rat(r['output_lower'])),abs(rat(r['output_upper'])))
             if rat(r['output_lower'])*rat(r['output_upper'])>0 else Fraction(0) for r in a['rows'])
 result=dict(model=a['model'],model_sha256=a['model_sha256'],dimension=9,width=64,hidden_depth=64,
  c_exact=a['c_exact'],input_count=512,certified=512,all_boolean_inputs_certified=True,
  all_training_margins_interval_verified=True,all_input_clean_absolute_margin_verified=minimum>Fraction(1,2),
  minimum_absolute_clean_output_lower=rr(minimum),minimum_absolute_clean_output_lower_approx=float(minimum),
  interval_verified_correct_vertices=a['interval_verified_correct_vertices'],
  partition_certified_count=a['certified'],partition_unresolved_vertices_retained=failed,
  supplemental_point_vertices=[325],
  component_certificates=[dict(path=str(p.relative_to(ROOT)),sha256=digest(p)) for p in [partition,point]],
  covered_vertices=[dict(input_index=i,component='point covariance' if i==325 else 'shared tube') for i in range(512)],
  composition_source_sha256=digest(Path(__file__)),
  scope='All512 declared Boolean vertices, every simultaneous hidden/output disturbance at c=1/1000; primary cap1/2 and tolerance1/16.',
  qualification='Composition of exact rational/outward-interval sufficient certificates, not Lean. Original partition retains its one unresolved vertex; the independent state-covariance proof covers that same vertex without changing the domain.')
 (ROOT/'full-cube-composite-505-c1_1000.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps({k:v for k,v in result.items() if k not in ['covered_vertices']}))
if __name__=='__main__':main()
