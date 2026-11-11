import re, sys
for i, line in enumerate(open(sys.argv[1]), 1):
    if line.startswith('|'):
        for seg in re.findall(r'\$[^$]*\$', line):
            if '|' in seg:
                print(i, seg)
