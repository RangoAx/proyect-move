import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

for match in re.finditer(r'\[sub_resource type="BoxShape3D" id="(BoxShape3D_zone_[^"]+)"\]\nsize = Vector3\(([^)]+)\)', text):
    print(match.group(1), ":", match.group(2))

