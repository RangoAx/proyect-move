import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

# Add ext_resources for new props if not present
new_exts = """
[ext_resource type="PackedScene" path="res://components/world/pine_tree.tscn" id="27_pine"]
[ext_resource type="PackedScene" path="res://components/world/dead_tree.tscn" id="28_dead"]
[ext_resource type="PackedScene" path="res://components/world/rock_boulder.tscn" id="29_rock"]
[ext_resource type="PackedScene" path="res://components/world/crate.tscn" id="30_crate"]
[ext_resource type="PackedScene" path="res://components/world/barrel.tscn" id="31_barrel"]
[ext_resource type="PackedScene" path="res://components/world/street_lantern.tscn" id="32_lantern"]
"""

if '27_pine' not in text:
    last_ext_idx = text.rfind('[ext_resource')
    end_of_last_ext = text.find('\n\n', last_ext_idx)
    text = text[:end_of_last_ext] + new_exts + text[end_of_last_ext:]

# Prop instances to add to NavigationRegion3D
extra_props = """
[node name="Lantern_Crossroads" parent="NavigationRegion3D" instance=ExtResource("32_lantern")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -21.0, 0.0, 0.0)

[node name="Lantern_AxeAltar" parent="NavigationRegion3D" instance=ExtResource("32_lantern")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16.0, 0.0, -35.0)

[node name="Lantern_Village" parent="NavigationRegion3D" instance=ExtResource("32_lantern")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16.0, 0.0, 35.0)

[node name="Lantern_Church" parent="NavigationRegion3D" instance=ExtResource("32_lantern")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 38.0, 0.0, -43.0)

[node name="Rock_ForkCenter" parent="NavigationRegion3D" instance=ExtResource("29_rock")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, -15.0, 0.0, 0.0)

[node name="Rock_NorthEdge" parent="NavigationRegion3D" instance=ExtResource("29_rock")]
transform = Transform3D(0.8, 0, 0.6, 0, 1.0, 0, -0.6, 0, 0.8, -5.0, 0.0, -35.0)

[node name="Rock_SouthEdge" parent="NavigationRegion3D" instance=ExtResource("29_rock")]
transform = Transform3D(0.9, 0, -0.4, 0, 1.0, 0, 0.4, 0, 0.9, -5.0, 0.0, 35.0)

[node name="Crate_Village1" parent="NavigationRegion3D" instance=ExtResource("30_crate")]
transform = Transform3D(0.965926, 0, 0.258819, 0, 1, 0, -0.258819, 0, 0.965926, 15.0, 0.0, 32.0)

[node name="Crate_Village2" parent="NavigationRegion3D" instance=ExtResource("30_crate")]
transform = Transform3D(0.866025, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866025, 15.0, 0.9, 32.0)

[node name="Barrel_Village1" parent="NavigationRegion3D" instance=ExtResource("31_barrel")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 16.2, 0.0, 31.5)

[node name="Barrel_Village2" parent="NavigationRegion3D" instance=ExtResource("31_barrel")]
transform = Transform3D(0.939693, 0, 0.34202, 0, 1, 0, -0.34202, 0, 0.939693, 21.0, 0.0, 38.0)

[node name="PineTree_Forest1" parent="NavigationRegion3D" instance=ExtResource("27_pine")]
transform = Transform3D(1.1, 0, 0, 0, 1.1, 0, 0, 0, 1.1, -8.0, 0.0, -26.0)

[node name="PineTree_Forest2" parent="NavigationRegion3D" instance=ExtResource("27_pine")]
transform = Transform3D(0.9, 0, 0, 0, 0.9, 0, 0, 0, 0.9, 8.0, 0.0, -38.0)

[node name="PineTree_Forest3" parent="NavigationRegion3D" instance=ExtResource("27_pine")]
transform = Transform3D(1.2, 0, 0, 0, 1.2, 0, 0, 0, 1.2, 22.0, 0.0, -45.0)

[node name="DeadTree_Grave1" parent="NavigationRegion3D" instance=ExtResource("28_dead")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 27.0, 0.0, -44.0)

[node name="DeadTree_Grave2" parent="NavigationRegion3D" instance=ExtResource("28_dead")]
transform = Transform3D(0.707107, 0, 0.707107, 0, 1, 0, -0.707107, 0, 0.707107, 36.0, 0.0, -36.0)
"""

# Insert right after Tombstone6
if 'Lantern_Crossroads' not in text:
    tomb_idx = text.find('[node name="Tombstone6"')
    end_of_tomb = text.find('\n\n', tomb_idx)
    text = text[:end_of_tomb] + extra_props + text[end_of_tomb:]

with open('levels/map_1/toy_box.tscn', 'w', encoding='utf-8') as f:
    f.write(text)

print("Props successfully populated in toy_box.tscn!")

