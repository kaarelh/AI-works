"""Measure the length in pages of a section in a PDF: from the y-position of a start heading to an end heading.
usage: secpages.py file.pdf "start regex" "end regex" """
import sys, re, subprocess, html
pdf, start, end = sys.argv[1], sys.argv[2], sys.argv[3]
minpage = int(sys.argv[4]) if len(sys.argv)>4 else 0
out = subprocess.run(['pdftotext', '-bbox-layout', pdf, '-'], capture_output=True, text=True).stdout
pages = re.split(r'<page ', out)[1:]
def find(rx):
    for i, pg in enumerate(pages):
        if i < minpage: continue
        h = float(re.search(r'height="([\d.]+)"', pg).group(1))
        for ln in re.finditer(r'<line xMin="[\d.]+" yMin="([\d.]+)" xMax="[\d.]+" yMax="[\d.]+">(.*?)</line>', pg, re.S):
            words = re.findall(r'>([^<]*)</word>', ln.group(2))
            txt = html.unescape(' '.join(words))
            if re.search(rx, txt):
                return i, float(ln.group(1)), h, txt
    return None
a = find(start); b = find(end)
print('start', a); print('end', b)
# text area approx: top margin and bottom margin; use fraction of page height between 0.12 and 0.88
def pos(x):
    i, y, h, _ = x
    top, bot = 75.6, h-75.6
    return i + max(0, min(1, (y - top)/(bot - top)))
print('pages ~ %.2f' % (pos(b) - pos(a)))
