import re

with open("levels/map_1/toy_box.tscn", "r", encoding="utf-8") as f:
    text = f.read()

node_blocks = re.findall(r'\[node name="([^"]+)"(?: type="([^"]+)")?(?: parent="([^"]+)")?[^\]]*\](.*?)(?=\n\[node|\n\[editable|\Z)', text, re.DOTALL)

print(f"Total nodes: {len(node_blocks)}")
for name, ntype, parent, body in node_blocks:
    if any(k in name.lower() or (parent and k in parent.lower()) for k in ["player", "church", "axe", "key", "casa", "zone", "tree", "tutorial"]):
        m = re.search(r'transform\s*=\s*Transform3D\([^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,[^,]+,\s*([-\d\.]+),\s*([-\d\.]+),\s*([-\d\.]+)\)', body)
        pos = f"({m.group(1)}, {m.group(2)}, {m.group(3)})" if m else "no transform"
        print(f"{name:30} type={ntype or 'instance':15} parent={parent or 'root':30} pos={pos}")

