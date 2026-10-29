with open('levels/map_1/church_insides.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

import re
nodes = re.findall(r'\[node name="([^"]+)"[^\]]*\]', text)
print("Nodes in church_insides.tscn:")
for n in nodes:
    print("  ", n)
