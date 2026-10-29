with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
m = re.search(r'\[node name="Player"[^\]]*\](.*?)(?=\[node name="FogVolume|\Z)', text, re.DOTALL)
if m:
    print(m.group(0)[:1200])

