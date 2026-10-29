import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

zones = re.split(r'\[node name="(Zone[^"]+)" type="Area3D"', text)
for i in range(1, len(zones), 2):
    zname = zones[i]
    zbody = zones[i+1].split('[node name="Zone')[0]
    pos_match = re.search(r'transform = Transform3D\([^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, ([^,]+), ([^,]+), ([^)]+)\)', zbody)
    zone_pos = (float(pos_match.group(1)), float(pos_match.group(2)), float(pos_match.group(3))) if pos_match else (0,0,0)
    print(f"=== {zname} at {zone_pos} ===")
    
    # find markers
    marker_chunks = re.findall(r'\[node name="(Marker3D[^"]*)"[^\n]*\](?:\ntransform = Transform3D\([^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, [^,]+, ([^,]+), ([^,]+), ([^)]+)\))?', zbody)
    for mname, mx, my, mz in marker_chunks:
        if mx:
            lx, ly, lz = float(mx), float(my), float(mz)
            gx, gy, gz = zone_pos[0] + lx, zone_pos[1] + ly, zone_pos[2] + lz
            print(f"  {mname}: local=({lx:.1f}, {lz:.1f}), global=({gx:.1f}, {gz:.1f})")
        else:
            print(f"  {mname}: local=(0, 0), global=({zone_pos[0]:.1f}, {zone_pos[2]:.1f})")

