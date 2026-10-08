from pathlib import Path
import os, re, json, hashlib
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'tmp/pdfs/standalone/math';OUT.mkdir(parents=True,exist_ok=True)
os.environ['MPLCONFIGDIR']=str(ROOT/'tmp/pdfs/mplconfig')
os.environ['XDG_CACHE_HOME']=str(ROOT/'tmp/pdfs/cache')
import matplotlib
matplotlib.use('Agg')
from matplotlib.mathtext import math_to_image
from matplotlib.font_manager import FontProperties
from PIL import Image
matplotlib.rcParams['mathtext.fontset']='dejavuserif'
matplotlib.rcParams['savefig.transparent']=True
text=(ROOT/'report.md').read_text()
data={}
for m in re.finditer(r'\$\$(.+?)\$\$|\$([^$\n]+)\$([.,;:!?]?)',text):
    display=bool(m.group(1));size=11.5 if display else 10
    expr=m.group(1) if display else m.group(2)+(m.group(3) or '')
    key=('display:' if display else 'inline:')+expr
    fn=OUT/(hashlib.sha256(key.encode()).hexdigest()[:16]+'.png')
    depth=math_to_image('$'+expr+'$',str(fn),prop=FontProperties(size=size),dpi=240,color='#172835')
    im=Image.open(fn);w,h=im.size
    white=fn.with_stem(fn.stem+'_white')
    if not display:math_to_image('$'+expr+'$',str(white),prop=FontProperties(size=size),dpi=240,color='white')
    data[key]={'path':str(fn),'white_path':str(white),'width':w*72/240,'height':h*72/240,'depth':depth}
(OUT/'manifest.json').write_text(json.dumps(data,indent=2))
print('Rendered',len(data),'unique formulas')
