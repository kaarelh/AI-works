"""Check report/PDF consistency after building; visual inspection remains separate."""
from pathlib import Path
import ast
import hashlib
import json
import re
from pypdf import PdfReader

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / 'report.md').read_text()
pdf = ROOT / 'output/pdf/computational-cosmology.pdf'
reader = PdfReader(pdf)
assert reader.metadata.author == 'GPT-6 Astra (OpenAI)'
assert all(len(p.extract_text()) > 400 for p in reader.pages), 'Empty or nearly empty page'
assert all(abs(float(p.mediabox.width) - 595.2756) < 0.1 for p in reader.pages)
assert all(abs(float(p.mediabox.height) - 841.8898) < 0.1 for p in reader.pages)
links = re.findall(r'\[[^\]]+\]\(((?:[^()]|\([^()]*\))+)\)', source)
external = {s for s in links if s.startswith(('https://', 'http://'))}
pdf_links = set()
for page in reader.pages:
    for ref in page.get('/Annots', []):
        action = ref.get_object().get('/A', {})
        if action.get('/URI'):
            pdf_links.add(str(action['/URI']))
assert external == pdf_links, (external - pdf_links, pdf_links - external)
local = [s for s in links if not s.startswith(('https://', 'http://', '#'))]
for target in local:
    assert (ROOT / target.split('#')[0]).exists(), target
assert not any(ord(c) < 32 and c not in '\n\r\t' for c in source)
assert not re.search(r'TODO|FIXME|ZZPLACE|turn\d+(?:search|view)\d+', source)
assert len(reader.outline) == len(re.findall(r'^## ', source, re.M))
figures = re.findall(r'^\*\*Figure (\d+)\.', source, re.M)
assert figures == list(map(str, range(1, len(figures) + 1)))
for directory in ('analysis', 'research', 'scripts'):
    for path in (ROOT / directory).rglob('*.py'):
        if not any(part in {'.venv', 'venv', '__pycache__', 'tmp'} for part in path.relative_to(ROOT).parts):
            ast.parse(path.read_text(), filename=str(path))
# Match the builder's inline punctuation convention and display formulas.
formulas = set()
for line in source.splitlines():
    if line.startswith('$$'):
        formulas.add('display:' + line[2:-2])
    else:
        for math, punctuation in re.findall(r'\$([^$\n]+)\$([.,;:!?]?)', line):
            formulas.add('inline:' + math + punctuation)
manifest_path = ROOT / 'tmp/pdfs/standalone/math/manifest.json'
if manifest_path.exists():
    manifest = json.loads(manifest_path.read_text())
    assert set(manifest) == formulas
    for formula, item in manifest.items():
        for key in (('path',) if formula.startswith('display:') else ('path', 'white_path')):
            if key in item:
                assert Path(item[key]).stat().st_size > 0
result = {
    'pages': len(reader.pages),
    'outline_entries': len(reader.outline),
    'figures': len(figures),
    'appendices': len(re.findall(r'^## Appendix ', source, re.M)),
    'matching_unique_external_citation_links': len(external),
    'report_words': len(source.split()),
    'local_report_links_checked': len(local),
    'unique_formulas': len(formulas),
    'author': reader.metadata.author,
    'pdf_sha256': hashlib.sha256(pdf.read_bytes()).hexdigest(),
    'scope': 'Automated consistency checks; layout and scientific validity require separate review.'
}
(ROOT / 'analysis/document_validation.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
