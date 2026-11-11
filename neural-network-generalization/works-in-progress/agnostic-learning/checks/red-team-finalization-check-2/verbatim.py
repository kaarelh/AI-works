import re, sys
RN = "/workspace/ai-works/neural-network-generalization/works-in-progress/agnostic-learning/research-notes/"
final = open("final.md").read()
slw = open(RN+"small-learner-width.md").read()
d2 = open(RN+"depth-two.md").read()

def sec(text, start, end):
    i = text.index(start); j = text.index(end, i)
    return text[i:j]

slw73 = sec(slw, "### 7.3 Corrected wording", "### 7.4")
d26 = sec(d2, "## 6. Errata", "## 7. Numerical record")

checks = []
# small-learner-width 7.3 entries: extract the text after 'by: "' or 'by "' up to '"' closing
def quoted_after(s, marker):
    i = s.index(marker) + len(marker)
    # find matching closing quote: the replacement strings end with '."' or '"' followed by space/period
    j = s.index('"', i)
    return s[i:j]

ent = {}
e = slw73.split("- **")
for chunk in e[1:]:
    name = chunk.split("**")[0]
    ent[name] = chunk
for k in ent: print("SLW entry:", k[:80])

repl = {}
repl["slw §0 item 1"] = quoted_after(ent["§0 item 1"], 'by: "')
repl["slw §0 item 7"] = quoted_after(ent["§0 item 7"], 'by "')
a2 = ent["§2.3 A2"]
i = a2.index('Replace these three sentences by: "') + len('Replace these three sentences by: "')
j = a2.rindex('"')
repl["slw §2.3 A2"] = a2[i:j]
repl["slw §6.3 item 2"] = quoted_after(ent["§6.3 item 2"], 'by "')
repl["slw §7 item 6"] = quoted_after(ent["§7 item 6"], 'by "')
e8 = ent['§8, "E, positive direction" (sketch), second bullet']
i = e8.index('Replace the bullet by the following text') ; i = e8.index(': "', i) + 3
j = e8.index('" The exponent', i)
repl["slw §8 bullet"] = e8[i:j]

# depth-two §6
d6 = d26
# §0 item 6 blockquote
i = d6.index("- **§0 item 6.** Replace by:\n") + len("- **§0 item 6.** Replace by:\n")
j = d6.index("- **§2.3 A3", i)
block = d6[i:j]
lines = [ln[4:] if ln.startswith("  > ") else ln for ln in block.rstrip("\n").split("\n")]
repl["d2 §0 item 6"] = "\n".join(lines)
def after_by(name, marker='by: "'):
    i = d6.index(name); k = d6.index(marker, i) + len(marker)
    j = d6.index('"\n', k)
    return d6[k:j]
repl["d2 §2.3 A3"] = after_by("- **§2.3 A3, last sentence.**")
repl["d2 §6.1"] = after_by('- **§6.1 "High dimension')
repl["d2 §6.4"] = after_by("- **§6.4, second bullet.**")
i = d6.index("- **§7 item 3, last sentence.**"); k = d6.index('by "At depth two, on', i)+4; j = d6.index('"\n', k)
repl["d2 §7 item 3"] = d6[k:j]
i = d6.index("- **Appendix A, paragraph"); 
k1 = d6.index('by "The runs are recorded', i)+4; j1 = d6.index('" Replace', k1)
repl["d2 App A (1)"] = d6[k1:j1]
k2 = d6.index('by "the captured fraction', j1)+4; j2 = d6.index('"\n', k2)
repl["d2 App A (2)"] = d6[k2:j2]
repl["d2 §5 heading"] = "Depth two ($L=2$), every $c>0$"

for k,v in repl.items():
    ok = v in final
    print(f"{k:20s} len={len(v):5d} present={ok}")
    if not ok:
        # find longest prefix present
        lo, hi = 0, len(v)
        while lo < hi:
            mid = (lo+hi+1)//2
            if v[:mid] in final: lo = mid
            else: hi = mid-1
        print("   longest prefix present:", lo, "next chars:", repr(v[lo:lo+120]))
