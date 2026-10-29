with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
m = re.findall(r'\[node name="Plane\d*"[^\]]*\](.*?)(?=\[node|\Z)', text, re.DOTALL)
for content in m:
    print(content[:400])

