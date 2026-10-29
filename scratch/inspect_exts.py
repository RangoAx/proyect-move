with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
exts = re.findall(r'\[ext_resource[^\]]+\]', text)
for e in exts:
    print(e)

