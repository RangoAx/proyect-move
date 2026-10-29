with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if line.startswith('[node name='):
        for w in ['player', 'axe', 'key', 'church', 'casa']:
            if w in line.lower():
                print(f"Line {i}: {line.strip()}")
                for j in range(i+1, min(i+5, len(lines))):
                    print(f"   {lines[j].strip()}")
                break

