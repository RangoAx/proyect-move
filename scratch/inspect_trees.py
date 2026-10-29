with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
m = re.findall(r'\[node name="(TreeGroup\d|PerimeterTrees|PerimeterBarriers|CanopyBarriers)"[^\]]*\](.*?)(?=\[node|\Z)', text, re.DOTALL)
for name, content in m:
    print(f"=== {name} ===")
    print(content[:600])

