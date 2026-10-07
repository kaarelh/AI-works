import re
def words(f,a,b):
    L=open(f).read().split('\n')[a-1:b]
    L=[l for l in L if not l.lstrip().startswith('%')]
    t=' '.join(L)
    t=re.sub(r'\\(cref|Cref|citep|citet|citealt|label|src|ref|leanok|status)\{[^}]*\}',' X ',t)
    return len(t.split())
moves=[
('setting.tex',207,212,'R3 setting neg data about valuations (keep 1 sentence: -50)'),
('setting.tex',299,313,'R2 setting bag/descent/W3 para (keep 2 sentences)'),
('setting.tex',364,381,'ex alg2 numbers (cut last 5 lines)'),
('setting.tex',466,472,'setting reading KWIK'),
('setting.tex',475,495,'contexts preview -> 3 sentences'),
('search.tex',21,21,'recall step language'),
('search.tex',83,87,'remarks a,c'),
('search.tex',96,98,'def pure dup'),
('search.tex',196,223,'ensembles -> move to coherence (protocol dup ~300)'),
('search.tex',228,228,'search in practice'),
('caution.tex',35,37,'conventions+recall'),
('caution.tex',164,169,'untagged (iii)'),
('caution.tex',176,182,'computed + conjecture evidence'),
('caution.tex',261,271,'hyp needed + tight prop'),
('imitation.tex',36,54,'cautious lemma dup'),
('imitation.tex',128,128,'reading dup'),
('imitation.tex',272,281,'dimension remark'),
('imitation.tex',284,288,'imitation in practice'),
('coherence.tex',171,171,'reading Exp B tail'),
('coherence.tex',367,367,'tonk exp'),
('coherence.tex',421,421,'Exp B para'),
('coherence.tex',256,260,'costs prop + memo remark'),
('coherence.tex',451,469,'consensus+projection'),
('twotier.tex',46,46,'depth honestly (shorten)'),
('twotier.tex',121,123,'Bayesian remark'),
('twotier.tex',180,180,'two details'),
('twotier.tex',193,204,'cost + voting'),
('twotier.tex',236,236,'nonmono'),
('twotier.tex',299,302,'burnin LP + instance'),
('twotier.tex',319,319,'Hilbert'),
('twotier.tex',412,412,'why learn'),
('twotier.tex',414,431,'arith detail'),
('twotier.tex',457,457,'exp B dup'),
('twotier.tex',460,469,'reading user terms'),
('simplicity.tex',51,59,'empirical lemma'),
('simplicity.tex',63,65,'relation to lit'),
('simplicity.tex',91,103,'sequence pathology'),
('simplicity.tex',194,250,'idealized+shapes+example'),
('simplicity.tex',328,329,'further pathologies'),
('existence.tex',184,217,'threshold/scope/closed/firstorder/omega/inductors'),
('existence.tex',220,229,'vnm'),
('existence.tex',273,296,'tree/triangle/true-in-context'),
('existence.tex',336,375,'term models..Tennenbaum'),
('informal.tex',113,113,'no union bound dup'),
('informal.tex',125,129,'escalation costs'),
('informal.tex',188,191,'weaker example detail'),
('informal.tex',264,264,'minimax values'),
('informal.tex',469,469,'hardest open problem dup'),
('physics.tex',41,59,'T3 accounting'),
('physics.tex',383,394,'brute force paragraph'),
('physics.tex',425,434,'remark existence'),
('physics.tex',643,692,'gronwall projectile chains'),
('physics.tex',766,860,'certifiers'),
('physics.tex',1038,1066,'thin-leg finite-sun'),
('physics.tex',1102,1117,'residual defects'),
('experiments.tex',135,210,'D-G + reproduction'),
('philosophy.tex',156,178,'answers table'),
]
tot=0
for f,a,b,d in moves:
    w=words(f,a,b); tot+=w
    print(f"{w:6d} {f}:{a}-{b} {d}")
print('total',tot, 'of 79812 =', round(100*tot/79812,1),'%')
