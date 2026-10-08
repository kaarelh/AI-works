"""GPT-6 (Codex), 2026-09-13. Public-capacity calibration, not measured world R&D FLOPs."""
import csv, json, math, hashlib
from pathlib import Path
from collections import defaultdict
base=Path(__file__).resolve().parent
raw=base/'sources/ai_chip_users_year_end_by_lab.csv'
labs=defaultdict(dict)
for row in csv.DictReader(raw.open()):
    labs[row['Lab']][int(row['Year'])]=float(row['h100e_med'])
seconds_year=365.25*24*3600
peak_per_h100e=1.979e15
utilization_precision=.25
rd_share=.5
outside_top_five=1.3
annual_growth_proxy=3.4
elapsed_2026_years=256/365.25
software_log_growth_reference=1.2
rows=[]
for lab,vals in labs.items():
    start,end=vals[2024],vals[2025]
    average=(end-start)/math.log(end/start)
    rows.append(dict(lab=lab,end2024_h100e=start,end2025_h100e=end,mean2025_h100e_loglinear_interpolation=average,
        estimated2025_rd_flops=average*peak_per_h100e*seconds_year*utilization_precision*rd_share,
        end2025_annualized_rd_flops=end*peak_per_h100e*seconds_year*utilization_precision*rd_share))
def projection(label,h100e):
    flops=h100e*peak_per_h100e*seconds_year*utilization_precision*rd_share*outside_top_five
    return dict(label=label,h100e=h100e,estimated_rd_flops_per_year_or_year_total=flops,k0_at_reference_software_rate=software_log_growth_reference/flops,
        reciprocal_k0=flops/software_log_growth_reference)
end=sum(r['end2025_h100e'] for r in rows)
res=dict(author='GPT-6 (Codex)',date='2026-09-13',
    assumptions=dict(seconds_year=seconds_year,peak_dense8bit_operations_per_h100e_second=peak_per_h100e,
       achieved_arithmetic_operations_relative_to_peak8bit=utilization_precision,rd_share_of_frontier_capacity=rd_share,
       multiplier_for_research_outside_top5=outside_top_five,annual_capacity_growth_for2026_extrapolation=annual_growth_proxy,
       elapsed_years_since_end2025=elapsed_2026_years,software_log_growth_reference_per_year=software_log_growth_reference),
    labs=rows,calibrations=[projection('2025 full-year total, loglinear within-year fleet interpolation',sum(r['mean2025_h100e_loglinear_interpolation'] for r in rows)),
       projection('2025-12-31 annualized rate',end),projection('2026-09-13 annualized rate, extrapolated',end*annual_growth_proxy**elapsed_2026_years)],
    crosschecks=dict(llama405b_useful6ND_flops_relative_to_H100peak8bit=6*405e9*15e12/(30.84e6*3600*peak_per_h100e),
       latest_2025_OpenAI_rd_dollars=8.3e9,old_2025_projection_rd_dollars=9e9,
       latest_2025_OpenAI_flops_at_old_dollar_conversion=1.2701048404871383e28*8.3/9),
    provenance=dict(chip_csv='https://epoch.ai/data/ai_chip_users_year_end_by_lab.csv',chip_csv_sha256=hashlib.sha256(raw.read_bytes()).hexdigest(),
       current_spend_csv='https://epoch.ai/data/ai_companies_compute_spend.csv'))
(base/'compute_calibration.json').write_text(json.dumps(res,indent=2)+'\n')
print(json.dumps(res['calibrations'],indent=2))
