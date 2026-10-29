with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
m = re.findall(r'\[node name="([^"]+)"\s+type="CollisionShape3D"\s+parent="NavigationRegion3D/PerimeterBarriers"[^\]]*\](.*?)(?=\[node|\Z)', text, re.DOTALL)
for name, content in m:
    print(f"Perimeter: {name}")
    print(content[:300])

