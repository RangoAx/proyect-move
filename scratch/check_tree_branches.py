with open('components/ui/ability_tree.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

import re
matches = re.findall(r'ability_string = "([^"]+)"', text)
print("Branches in ability_tree.tscn:", matches)
for m in re.finditer(r'\[node name="([^"]+)"[^\]]*instance=ExtResource\("2_branch"\)\](.*?)((?=\n\[node)|\Z)', text, re.DOTALL):
    print("Node:", m.group(1))
    for line in m.group(2).splitlines():
        if 'explanation' in line or 'ability' in line:
            print("  ", line)

