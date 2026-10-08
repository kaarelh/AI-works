"""GPT-6 (Codex), 2026-09-12.
Independent price/quality/date regressions; does not run downloaded source code.
"""
from pathlib import Path
import re, json, hashlib, math, csv
import numpy as np
import pandas as pd
from scipy.optimize import least_squares

BASE=Path(__file__).resolve().parent
SRC=BASE/"source"
rng=np.random.default_rng(20260912)
METHODS=[
 ("all_ols",False,False,"logit","ols"),
 ("open_ols",True,False,"logit","ols"),
 ("pareto_all_ols",False,True,"logit","ols"),
 ("pareto_open_ols",True,True,"logit","ols"),
 ("pareto_open_robust",True,True,"logit","soft_l1"),
 ("pareto_open_linear_score",True,True,"linear","ols"),
]
BENCHMARKS=[("gpqa","GPQA-Diamond","epoch_gpqa"),
            ("aime","AIME","oneshot_AIME"),
            ("swe","SWE-bench Verified","epoch_swe")]
N=1e120
K0=10**-27.5

DATE_AUDIT_SOURCES={
    'qwen3':{'earliest_release_month':'2025-04-01','release_date':'2025-04-29',
              'url':'https://qwenlm.github.io/blog/qwen3/'},
    'claude_4_1_opus':{'earliest_release_month':'2025-08-01','release_date':'2025-08-05',
                      'url':'https://www.anthropic.com/news/claude-opus-4-1'}
}

def base_model_cluster(label):
    """Remove observed serving/evaluation metadata, retaining model revisions.

    Dates inside IDs, named release months, parameter sizes, and revisions like
    0528/2507 are not removed. No speculative alias matching across model names.
    """
    label=re.sub(r"\s+\d{2}/\d{2}/\d{4}\s*$","",label.strip()).casefold()
    label=re.sub(r"\(\s*option\s*\d+\s*\)|\boption\s*\d+\b"," ",label)
    label=re.sub(r"\(\s*(?:aime|swe(?:-bench)?(?:\s+verified)?)\s*\d*\s*\)"," ",label)
    label=re.sub(r"\+a\d+\b"," ",label)  # observed evaluation label '(AIME 2)+A48'
    label=re.sub(r"\(\s*(?:xhigh|high|medium|low|\d+k)(?:\s+(?:tokens?|budget))?\s*\)"," ",label)
    label=re.sub(r"_(?:xhigh|high|medium|low|\d+k)\b"," ",label)
    label=re.sub(r"\(\s*(?:(?:non[- ]?)?reasoning|extended thinking|thinking)\s*\)"," ",label)
    label=re.sub(r"\s+thinking\b"," ",label)  # Claude 3.7 Sonnet Thinking
    return re.sub(r"\s+"," ",label).strip()

def flag_date(row):
    model=row.model.casefold()
    if model.startswith('qwen3 ') and row.date<pd.Timestamp('2025-04-01'):
        return 'qwen3'
    if model.startswith('claude 4.1 opus') and row.date<pd.Timestamp('2025-08-01'):
        return 'claude_4_1_opus'
    return ''

def load_data(stem, scorecol, exclude_flagged=True):
    d=pd.read_csv(SRC/(stem+".csv"))
    out=pd.DataFrame({
       "model":d["Model"].astype(str).str.strip(),
       "license":d["License"].fillna(""),
       "date":pd.to_datetime(d["Release Date"],format="%m/%d/%Y"),
       "score":pd.to_numeric(d[scorecol].astype(str).str.replace("%","",regex=False),errors="coerce")/100,
       "price":pd.to_numeric(d["Benchmark Cost USD"],errors="coerce")
    })
    out=out[(out.price>0)&(out.score>0)&(out.score<1)].copy()
    # Exact duplicate points add no information; retain model variants.
    out=out.drop_duplicates(["model","date","score","price"])
    out["cluster"]=out.model.map(base_model_cluster)
    out['date_audit_flag']=out.apply(flag_date,axis=1)
    if exclude_flagged:out=out[out.date_audit_flag==''].copy()
    out["t"]=(out.date-pd.Timestamp("2024-01-01")).dt.total_seconds()/(365.25*24*3600)
    return out.sort_values(["date","score","price"]).reset_index(drop=True)

def pareto(d):
    # A point is retained if not dominated by any offering available by its date.
    # Include same-date competitors; row ordering cannot change membership.
    keep=[]
    for idx,row in d.iterrows():
        earlier=d[d.date<=row.date]
        dom=(earlier.score>=row.score)&(earlier.price<=row.price)&(
              (earlier.score>row.score)|(earlier.price<row.price))
        if not dom.any(): keep.append(idx)
    return d.loc[keep].copy()

def design(d, control):
    score=np.clip(d.score.to_numpy(float),.005,.995)
    q=np.log(score/(1-score)) if control=="logit" else score
    return np.column_stack([np.ones(len(d)),q,d.t.to_numpy(float)])

def fit(d,control,estimator):
    X=design(d,control); y=np.log(d.price.to_numpy(float))
    if len(d)<8 or np.linalg.matrix_rank(X)<3:
        return None
    b=np.linalg.lstsq(X,y,rcond=None)[0]
    if estimator!="ols":
        b=least_squares(lambda bb:X@bb-y,b,loss="soft_l1",f_scale=.5,max_nfev=2000).x
    residual=y-X@b
    return {"coef":b,"r2":1-float(residual@residual)/float(((y-y.mean())**2).sum()),
            "rmse":float(np.sqrt(np.mean(residual**2)))}

def predict_stop(s,G):
    if s<=0:
        return {"status":"Non-positive hardware-adjusted improvement; incompatible with positive k0 calibration",
                "p":s/math.log(G),"x_stop":None,"x_exact":None}
    p=s/math.log(G)
    return {"status":"finite_power_law_stop","p":p,"delta":1/p,
            "x_stop":p/(1+p)*(N-1/K0),
            "x_exact":p*(N-1/K0),
            "gain_coefficient_times_1e_minus_120_at_stop":1+p}

results=[]; projections=[]; clean_summary=[];date_sensitivity=[];excluded_rows=[]
for stem,benchmark,scorecol in BENCHMARKS:
    source_clean=load_data(stem,scorecol,exclude_flagged=False)
    for _,row in source_clean[source_clean.date_audit_flag!=''].iterrows():
        excluded_rows.append({'benchmark':benchmark,'model':row.model,'recorded_date':str(row.date.date()),
            'score':row.score,'price':row.price,'cluster':row.cluster,
            'reason':'Recorded availability month predates officially documented model release month',
            **DATE_AUDIT_SOURCES[row.date_audit_flag]})
    data=load_data(stem,scorecol)
    data.to_csv(BASE/(stem+"_cleaned.csv"),index=False)
    clean_summary.append({"benchmark":benchmark,"n":len(data),
                          "models":int(data.cluster.nunique()),
                          "start":str(data.date.min().date()),"end":str(data.date.max().date())})
    for mid,onlyopen,onlypareto,control,estimator in METHODS:
        d=data[data.license.str.contains("open",case=False)].copy() if onlyopen else data.copy()
        if onlypareto:d=pareto(d)
        f=fit(d,control,estimator)
        rec={"id":stem+"_"+mid,"benchmark":benchmark,"method":mid,
             "only_open":onlyopen,"pareto":onlypareto,"quality_control":control,"estimator":estimator,
             "n":len(d),"n_model_clusters":int(d.cluster.nunique()),
             "date_start":str(d.date.min().date()) if len(d) else None,
             "date_end":str(d.date.max().date()) if len(d) else None}
        if f is None:
            rec["status"]="Insufficient sample: require >=8 usable points and full-rank design"
            results.append(rec);continue
        b=f["coef"]
        rec.update(status="fit",coefficients=b.tolist(),
                   raw_price_efficiency_log_growth_per_year=float(-b[2]),
                   raw_annual_price_efficiency_factor=float(math.exp(-b[2])),
                   r2=f["r2"],rmse_log_price=f["rmse"])
        if len(source_clean)!=len(data):
            old=source_clean[source_clean.license.str.contains('open',case=False)].copy() if onlyopen else source_clean.copy()
            if onlypareto:old=pareto(old)
            oldfit=fit(old,control,estimator)
            if oldfit is not None:
                old_s=float(-oldfit['coef'][2])-math.log(1.49)
                new_s=float(-b[2])-math.log(1.49)
                date_sensitivity.append({'fit_id':rec['id'],'n_with_flagged_rows':len(old),'n_primary':len(d),
                    'hardware_H':1.49,'research_G':3.4,
                    'with_flagged_rows_s':old_s,'primary_s':new_s,
                    'with_flagged_rows_projection':predict_stop(old_s,3.4),
                    'primary_projection':predict_stop(new_s,3.4)})
        clusters=d.cluster.unique()
        boot=[]
        for _ in range(400):
            ids=rng.choice(clusters,size=len(clusters),replace=True)
            sample=pd.concat([d[d.cluster==cid] for cid in ids],ignore_index=True)
            bf=fit(sample,control,estimator)
            if bf is not None:boot.append(float(-bf["coef"][2]))
        rec["bootstrap_successful"]=len(boot)
        rec["bootstrap_raw_log_growth_90pct"]=np.quantile(boot,[.05,.5,.95]).tolist() if boot else None
        rec["bootstrap_note"]="Resamples same-base-model clusters across price dates, reasoning budgets, modes, options and evaluation labels; preserves release revisions and sizes. Conditional on cleaning/Pareto sample; selection is not rerun."
        train=d[d.date<pd.Timestamp("2026-01-01")]
        test=d[d.date>=pd.Timestamp("2026-01-01")]
        tf=fit(train,control,estimator)
        if tf is not None and len(test)>=3:
            errors=design(test,control)@tf["coef"]-np.log(test.price.to_numpy(float))
            rec["chronological_holdout"]={"train_n":len(train),"test_n":len(test),
                "train_through":"2025-12-31",
                "test_rmse_log_price":float(np.sqrt(np.mean(errors**2))),
                "training_log_growth":float(-tf["coef"][2])}
        for H in (1.49,1/0.7):
            s=float(-b[2])-math.log(H)
            for G in (3.4,5.0):
                pr={"fit_id":rec["id"],"benchmark":benchmark,"method":mid,
                    "n":len(d),"hardware_efficiency_growth":H,"research_compute_growth_proxy":G,
                    "adjusted_software_log_growth_per_year":s,
                    "adjusted_annual_software_factor":math.exp(s),
                    **predict_stop(s,G)}
                if boot:
                    adjusted=np.asarray(boot)-math.log(H)
                    valid=adjusted>0
                    pp=adjusted[valid]/math.log(G)
                    pr["bootstrap_positive_fraction"]=float(valid.mean())
                    pr["conditional_bootstrap_stop_90pct"]=(np.quantile(pp/(1+pp)*N,[.05,.5,.95]).tolist() if len(pp) else None)
                projections.append(pr)
        results.append(rec)
        print(f"Completed {rec['id']}: n={len(d)}, base-model clusters={len(clusters)}",flush=True)
        d.to_csv(BASE/(rec["id"]+"_selected.csv"),index=False)

manifest={"retrieved":"2026-09-12","files":[]}
for path in sorted(SRC.iterdir()):
    if path.is_file():
       manifest["files"].append({"name":path.name,"sha256":hashlib.sha256(path.read_bytes()).hexdigest(),"bytes":path.stat().st_size})
commit=json.loads((SRC/"source_commit.json").read_text())
manifest["upstream_commit"]=commit["sha"]
manifest["upstream_commit_date"]=commit["commit"]["committer"]["date"]
manifest["repository"]="https://github.com/hansgundlach/Algorithmic_Progress_Inference"
(BASE/"source_manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
out={"author":"GPT-6 (Codex)","date":"2026-09-12","normalization":{"N":N,"k0":K0},
     "cluster_definition":"Same explicit base-model label across budgets/modes/options/evaluation tags and price dates; model revision dates/names and parameter sizes retained; no speculative aliases.",
     "date_audit":{"exclusion_policy":"Only independently verified earlier-release-month contradictions; source data unmodified; no inferred replacement dates.",
                   "excluded_rows":excluded_rows,"primary_sources":DATE_AUDIT_SOURCES},
     "cleaned_data":clean_summary,
     "assumptions":[
       "Inference prices are converted to software efficiency using a multiplicative hardware adjustment.",
       "Open-weight samples reduce but do not eliminate competition, margin, subsidy and serving-utilization effects.",
       "All-license fits retain stronger economic confounding.",
       "Global AI capacity growth proxies cumulative raw research FLOPs, assuming fixed research share/utilization and exponential prehistory.",
       "5x frontier training-compute growth is a weaker alternative research-input proxy.",
       "A logarithmic price trend maps to a raw research power law; no second recursive multiplier is applied.",
       "These are independent regressions on the July2026 source snapshot, not exact reproductions of the March2026 paper."
     ],
     "fits":results,"projections":projections}
(BASE/"inference_results.json").write_text(json.dumps(out,indent=2)+"\n")
(BASE/"data_quality_sensitivity.json").write_text(json.dumps({'scope':'Point-estimate sensitivity to retaining independently flagged date rows; revised clustering does not affect point estimates.',
    'excluded_rows':excluded_rows,'fits':date_sensitivity},indent=2)+"\n")
flat=[]
for pr in projections:
    row={k:v for k,v in pr.items() if not isinstance(v,(dict,list))}
    if isinstance(pr.get("conditional_bootstrap_stop_90pct"),list):
        for label,val in zip(["q05","median","q95"],pr["conditional_bootstrap_stop_90pct"]):
            row["conditional_bootstrap_stop_"+label]=val
    flat.append(row)
keys=list(dict.fromkeys(k for r in flat for k in r))
with (BASE/"all_answers.csv").open("w") as f:
    w=csv.DictWriter(f,fieldnames=keys);w.writeheader();w.writerows(flat)
print(json.dumps({"cleaned_data":clean_summary,"fits":[
    {"id":r["id"],"n":r["n"],"status":r["status"],"price_factor":r.get("raw_annual_price_efficiency_factor"),"r2":r.get("r2")}
    for r in results],
    "baseline_projections":[p for p in projections if p["hardware_efficiency_growth"]==1.49 and p["research_compute_growth_proxy"]==3.4]},indent=2))
