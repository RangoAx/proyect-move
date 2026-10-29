with open('components/pawns/player/player.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

import re
match = re.search(r'\[node name="ProgressBar".*?(?=\n\[node|\Z)', text, re.DOTALL)
if match:
    print(match.group(0))

