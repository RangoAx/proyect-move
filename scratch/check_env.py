with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

import re
matches = re.findall(r'\[node name="WorldEnvironment"[^\]]*\]', text)
print("WorldEnvironment nodes:", matches)
env_sub = re.findall(r'\[sub_resource type="Environment" id="([^"]+)"\](.*?)(?=\n\[sub_resource|\n\[node)', text, re.DOTALL)
for eid, content in env_sub:
    print(f"Environment {eid}:")
    for line in content.splitlines():
        if 'fog' in line.lower():
            print("  ", line)

