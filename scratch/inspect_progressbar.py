import re

with open('components/pawns/player/player.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

for m in re.finditer(r'\[node name="([^"]*ProgressBar[^"]*|[^"]*HUD[^"]*)"[^\]]*\](.*?)(?=\n\[node|\Z)', text, re.DOTALL):
    print(m.group(0)[:600])
    print('='*40)

