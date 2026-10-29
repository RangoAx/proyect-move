import re

with open('components/pawns/player/player.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

for m in re.finditer(r'\[node name="([^"]+)" type="Label"[^\]]*\](?:\n([^\n]+))?', text):
    print(m.group(1), ":", m.group(2) if m.group(2) else '')

