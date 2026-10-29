with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

for i, l in enumerate(lines):
    if 'Piso' in l:
        print(f"Line {i}: {l}")
        for j in range(i, min(i+15, len(lines))):
            print(lines[j], end='')
        break

