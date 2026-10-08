"""Render the research report with linked citations, equations and appendices."""
from pathlib import Path
import re,json
from html import escape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.lib import colors
from reportlab.lib.styles import ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image, PageBreak, KeepTogether, HRFlowable
from reportlab.lib.pagesizes import A4
ROOT=Path(__file__).resolve().parents[1]
SRC=ROOT/'report.md';OUT=ROOT/'output/pdf/computational-cosmology.pdf'
OUT.parent.mkdir(parents=True,exist_ok=True)
from importlib.util import find_spec
import argparse
parser=argparse.ArgumentParser()
parser.add_argument('--font-directory',type=Path)
args=parser.parse_args()
FONT=args.font_directory or Path(find_spec('matplotlib').origin).parent/'mpl-data/fonts/ttf'
for name,f in [('Sans','DejaVuSans.ttf'),('Sans-Bold','DejaVuSans-Bold.ttf'),('Sans-Italic','DejaVuSans-Oblique.ttf'),('Sans-BoldItalic','DejaVuSans-BoldOblique.ttf'),('Serif','DejaVuSerif.ttf'),('Serif-Bold','DejaVuSerif-Bold.ttf'),('Serif-Italic','DejaVuSerif-Italic.ttf'),('Serif-BoldItalic','DejaVuSerif-BoldItalic.ttf')]:
    pdfmetrics.registerFont(TTFont(name,str(FONT/f)))
for name in ['Sans','Serif']:pdfmetrics.registerFontFamily(name,normal=name,bold=name+'-Bold',italic=name+'-Italic',boldItalic=name+'-BoldItalic')
INK=colors.HexColor('#172835');MUTED=colors.HexColor('#566575');ACCENT=colors.HexColor('#126879')
styles={
'body':ParagraphStyle('body',fontName='Serif',fontSize=9.8,leading=13.8,textColor=INK,spaceAfter=6.8,allowWidows=0,allowOrphans=0),
'meta':ParagraphStyle('meta',fontName='Sans',fontSize=7.7,leading=11,textColor=MUTED,spaceAfter=11),
'title':ParagraphStyle('title',fontName='Sans-Bold',fontSize=23,leading=28,textColor=INK,spaceAfter=10),
'heading':ParagraphStyle('heading',fontName='Sans-Bold',fontSize=12.2,leading=16,textColor=ACCENT,spaceBefore=10,spaceAfter=10,keepWithNext=True),
'cell':ParagraphStyle('cell',fontName='Sans',fontSize=8.1,leading=11.2,textColor=INK),
'head':ParagraphStyle('head',fontName='Sans-Bold',fontSize=8.1,leading=11.2,textColor=colors.white),
'caption':ParagraphStyle('caption',fontName='Sans',fontSize=8,leading=11,textColor=MUTED,spaceAfter=8)}
MATH=json.loads((ROOT/'tmp/pdfs/standalone/math/manifest.json').read_text())
FOOTNOTES={key:n for n,key in enumerate(re.findall(r'^\[\^([^\]]+)\]:',SRC.read_text(),re.M),1)}
def inline(s,small=False,white=False):
    holds=[]
    def save(v):holds.append(v);return f'ZZPLACE{len(holds)-1}ZZ'
    def math(m):
        v=MATH['inline:'+m.group(1)+m.group(2)];fac=.83 if small else .95
        path=v['white_path'] if white else v['path']
        return save(f'<img src="{path}" width="{v["width"]*fac:.3f}" height="{v["height"]*fac:.3f}" valign="{-v["depth"]*fac:.3f}"/>')
    s=re.sub(r'\$([^$\n]+)\$([.,;:!?]?)',math,s)
    s=re.sub(r'\[\^([^\]]+)\]',lambda m:save(f'<super><link href="#fn-{m.group(1)}" color="#126879">{FOOTNOTES[m.group(1)]}</link></super>'),s)
    def link(m):
        label,target=m.groups()
        if not target.startswith(('https://','http://')):return save(escape(label))
        return save(f'<link href="{escape(target,quote=True)}" color="#126879"><u>{escape(label)}</u></link>')
    s=re.sub(r'\[([^\]]+)\]\(((?:[^()]|\([^()]*\))+)\)',link,s)
    s=escape(s);s=re.sub(r'\*\*(.+?)\*\*',r'<b>\1</b>',s)
    for i,v in enumerate(holds):s=s.replace(f'ZZPLACE{i}ZZ',v)
    return s

def footer(c,doc):
    w,h=A4;c.saveState();c.setStrokeColor(colors.HexColor('#D9E2E6'));c.line(49,40,w-49,40)
    c.setFont('Sans',7.2);c.setFillColor(MUTED)
    c.drawString(49,27,'COMPUTATIONAL COSMOLOGY     |     OCTOBER 2026')
    c.drawRightString(w-49,27,str(doc.page));c.restoreState()

lines=SRC.read_text().splitlines();meta=lines[0];i=2;story=[];width=A4[0]-98
while i<len(lines):
    line=lines[i].strip()
    if not line:i+=1;continue
    if line=='<!-- pagebreak -->':story.append(PageBreak());i+=1
    elif re.match(r'^\[\^([^\]]+)\]:',line):
        key,note=re.fullmatch(r'\[\^([^\]]+)\]:\s*(.*)',line).groups()
        previous=next((s.strip() for s in reversed(lines[:i]) if s.strip()),'')
        if not re.match(r'^\[\^([^\]]+)\]:',previous):
            story.extend([Spacer(1,5),HRFlowable(width=90,thickness=.5,color=colors.HexColor('#D9E2E6'),hAlign='LEFT'),Spacer(1,5)])
        story.append(Paragraph(f'<a name="fn-{key}"/><super>{FOOTNOTES[key]}</super> '+inline(note,small=True),styles['caption']));i+=1
    elif line.startswith('# '):
        story.extend([Paragraph(inline(line[2:]),styles['title']),Paragraph(escape(meta),styles['meta'])]);i+=1
    elif line.startswith('## '):
        heading=Paragraph(inline(line[3:]),styles['heading'])
        heading._outline_title=line[3:]
        story.append(heading);i+=1
    elif line.startswith('$$'):
        v=MATH['display:'+line[2:-2]];fac=min(1,width/v['width'])
        im=Image(v['path'],width=v['width']*fac,height=v['height']*fac,hAlign='CENTER')
        group=[Spacer(1,2),im,Spacer(1,11)]
        if story and isinstance(story[-1],Paragraph) and story[-1].style.name=='body':
            group.insert(0,story.pop())
        if story and isinstance(story[-1],Paragraph) and story[-1].style.name=='heading':
            group.insert(0,story.pop())
        story.append(KeepTogether(group));i+=1
    elif line.startswith('!['):
        m=re.fullmatch(r'!\[([^\]]*)\]\(([^)]+)\)',line);label,target=m.groups()
        from PIL import Image as PILImage
        path=(SRC.parent/target).resolve();w,h=PILImage.open(path).size
        fig=[Image(str(path),width=width,height=width*h/w),Spacer(1,6)];i+=1
        j=i
        while j<len(lines) and not lines[j].strip():j+=1
        if j<len(lines) and lines[j].strip().startswith('**Figure '):
            fig.extend([Paragraph(inline(lines[j].strip(),small=True),styles['caption']),Spacer(1,4)])
            i=j+1
        story.append(KeepTogether(fig))
    elif line.startswith('|'):
        rows=[]
        while i<len(lines) and lines[i].strip().startswith('|'):
            cells=[c.strip() for c in lines[i].strip().strip('|').split('|')]
            if not all(re.fullmatch('[-:]+',c) for c in cells):rows.append(cells)
            i+=1
        nc=len(rows[0]); fractions={2:[.24,.76],3:[.32,.34,.34],4:[.25,.25,.25,.25],5:[.14,.17,.16,.25,.28]}[nc]
        if rows[0][0]=='Future scenario':fractions=[.31,.69]
        if nc==3 and 'Conditional parameters' in rows[0]:fractions=[.29,.10,.61]
        if nc==3 and 'Series analyzed' in rows[0]:fractions=[.30,.33,.37]
        if nc==4 and 'Conditional specification' in rows[0]:fractions=[.24,.12,.12,.52]
        if nc==4 and 'Taste' in ' '.join(rows[0]):fractions=[.32,.22,.23,.23]
        if nc==4 and 'Mass in kg' in rows[0]:fractions=[.22,.22,.28,.28]
        if nc==5 and 'Central configuration' in rows[0]:fractions=[.28,.19,.19,.18,.16]
        data=[[Paragraph(inline(c,True,r==0),styles['head'] if r==0 else styles['cell']) for c in row] for r,row in enumerate(rows)]
        t=Table(data,colWidths=[width*v for v in fractions],hAlign='LEFT',repeatRows=1)
        t.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),ACCENT),('VALIGN',(0,0),(-1,-1),'MIDDLE'),('LEFTPADDING',(0,0),(-1,-1),7),('RIGHTPADDING',(0,0),(-1,-1),7),('TOPPADDING',(0,0),(-1,-1),5.5),('BOTTOMPADDING',(0,0),(-1,-1),5.5),('ROWBACKGROUNDS',(0,1),(-1,-1),[colors.HexColor('#F1F5F6'),colors.white]),('LINEBELOW',(0,-1),(-1,-1),.5,colors.HexColor('#D9E2E6'))]))
        group=[t,Spacer(1,10)]
        if story and isinstance(story[-1],Paragraph) and story[-1].style.name=='body':
            group.insert(0,story.pop())
        if story and isinstance(story[-1],Paragraph) and story[-1].style.name=='heading':
            group.insert(0,story.pop())
        story.append(KeepTogether(group))
    else:
        para=[line];i+=1
        while i<len(lines) and lines[i].strip() and not lines[i].strip().startswith(('#','$$','|','<!--','![','[^')):
            para.append(lines[i].strip());i+=1
        story.append(Paragraph(inline(' '.join(para)),styles['body']))
class ReportDoc(SimpleDocTemplate):
    def afterFlowable(self,flowable):
        if hasattr(flowable,'_outline_title'):
            title=flowable._outline_title
            key='section-'+str(self.seq.nextf('outline'))
            self.canv.bookmarkPage(key)
            self.canv.addOutlineEntry(title,key,level=0,closed=False)
doc=ReportDoc(str(OUT),pagesize=A4,rightMargin=49,leftMargin=49,topMargin=40,bottomMargin=53,title='Computational cosmology',author='Codex (OpenAI AI assistant)',subject='Physical limits and possible futures of computation: causality, thermodynamics, memory, specification, and reliability')
doc.build(story,onFirstPage=footer,onLaterPages=footer)
print(OUT)
