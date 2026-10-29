with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
m = re.search(r'\[node name="WorldEnvironment"[^\]]*\](.*?)(?=\[node|\Z)', text, re.DOTALL)
if m:
    print(m.group(0)[:1500])

m2 = re.search(r'\[sub_resource type="Environment"[^\]]*\](.*?)(?=\[sub_resource|\Z)', text, re.DOTALL)
if m2:
    print(m2.group(0)[:1500])

