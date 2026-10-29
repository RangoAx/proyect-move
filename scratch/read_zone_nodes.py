with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if '[node name="Zone' in l:
        print(f"Line {i+1}: {l.strip()}")
        for j in range(i+1, min(i+15, len(lines))):
            if lines[j].startswith('['):
                break
            print(f"  {lines[j].strip()}")

