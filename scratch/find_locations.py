import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

pattern = re.compile(r'\[node name="([^"]+)"\s+(?:type="([^"]+)"|instance=ExtResource\("([^"]+)"\))[^\]]*\](?:[\r\n]+transform = Transform3D\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,\s*(-?[\d\.]+),\s*(-?[\d\.]+),\s*(-?[\d\.]+)\))?')

for m in pattern.finditer(text):
    name, typ, inst, x, y, z = m.groups()
    lower = name.lower()
    if any(k in lower for k in ['axe', 'key', 'church', 'player', 'casa']):
        pos = f"({x}, {y}, {z})" if x else "no transform"
        print(f"{name:25} typ={typ} inst={inst} pos={pos}")

