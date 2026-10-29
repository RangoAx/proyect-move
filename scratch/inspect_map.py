import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

# Pattern matching node definitions and their transforms
pattern = re.compile(r'\[node name="([^"]+)"\s+(?:type="([^"]+)"|instance=([^\s\]]+))[^\]]*\](?:[\r\n]+transform = Transform3D\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,\s*(-?[\d\.]+),\s*(-?[\d\.]+),\s*(-?[\d\.]+)\))?')

matches = pattern.findall(text)
print(f"Total nodes found: {len(matches)}")
for name, typ, inst, x, y, z in matches:
    lower = name.lower()
    if any(k in lower for k in ['church', 'axe', 'key', 'player', 'casa', 'piso', 'light', 'spawn', 'zone', 'colis', 'suelo', 'floor', 'fence', 'tree', 'world']):
        kind = typ if typ else f"Inst: {inst}"
        pos = f"({x}, {y}, {z})" if x else "no transform"
        print(f"{name:32} {kind:30} {pos}")

