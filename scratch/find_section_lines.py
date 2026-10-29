with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    lines = f.readlines()

p_start = None
tut_start = None
for i, l in enumerate(lines):
    if '[node name="Player"' in l:
        p_start = i
    if '[node name="TutorialTriggers5"' in l:
        tut_start = i

print(f"Player at line {p_start}, TutorialTriggers5 at line {tut_start}")

