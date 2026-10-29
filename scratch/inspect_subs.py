with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re

# Check sub_resources
subs = re.findall(r'\[sub_resource type="([^"]+)" id="([^"]+)"\]', text)
print(f"Total sub_resources: {len(subs)}")
for typ, sid in subs:
    print(f"  {typ:25} {sid}")

