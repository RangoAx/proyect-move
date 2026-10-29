import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

pattern = re.compile(r'\[node name="([^"]+)"(?:\s+type="([^"]+)")?(?:\s+parent="([^"]+)")?(?:\s+instance=ExtResource\("([^"]+)"\))?')
for m in pattern.finditer(text):
    name, typ, parent, inst = m.groups()
    p = parent if parent else "ROOT"
    t = typ if typ else f"Inst({inst})"
    print(f"{p:30} -> {name:30} [{t}]")

