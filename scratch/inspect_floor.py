with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
nodes = re.findall(r'\[node name="([^"]+)"\s+type="([^"]+)"[^\]]*\](?:[\r\n]+transform = Transform3D\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,\s*(-?[\d\.]+),\s*(-?[\d\.]+),\s*(-?[\d\.]+)\))?', text)

for name, typ, x, y, z in nodes:
    if any(k in name.lower() for k in ['plane', 'piso', 'floor', 'terrain', 'mesh', 'navigation', 'barrier', 'church']):
        print(f"{name:30} {typ:25} ({x}, {y}, {z})")

