import re

with open('levels/map_1/toy_box.tscn.bak', 'r', encoding='utf-8', errors='ignore') as f:
    text = f.read()

# 1. Add extra ExtResources if not already present
ext_resources_to_add = """
[ext_resource type="Script" path="res://components/world/combat_arena.gd" id="21_arena"]
[ext_resource type="Script" path="res://levels/map_1/enemy_reveal_trigger.gd" id="22_reveal"]
[ext_resource type="PackedScene" path="res://components/world/cabin.tscn" id="23_cabin"]
[ext_resource type="PackedScene" path="res://components/world/barricade.tscn" id="24_barricade"]
[ext_resource type="PackedScene" path="res://components/world/tombstone.tscn" id="25_tombstone"]
[ext_resource type="PackedScene" path="res://components/world/fence.tscn" id="26_fence"]
"""

# Place after last ext_resource
last_ext_idx = text.rfind('[ext_resource')
end_of_last_ext = text.find('\n\n', last_ext_idx)
text = text[:end_of_last_ext] + ext_resources_to_add + text[end_of_last_ext:]

# 2. Add sub_resources for arena collision shapes and enemy reveal
sub_resources_to_add = """
[sub_resource type="BoxShape3D" id="BoxShape3D_reveal"]
size = Vector3(2.5, 4.0, 8.0)

[sub_resource type="BoxShape3D" id="BoxShape3D_arena1"]
size = Vector3(26.0, 6.0, 26.0)

[sub_resource type="BoxShape3D" id="BoxShape3D_arena2"]
size = Vector3(26.0, 6.0, 26.0)

[sub_resource type="BoxShape3D" id="BoxShape3D_arena3"]
size = Vector3(26.0, 6.0, 26.0)

[sub_resource type="BoxShape3D" id="BoxShape3D_arena4"]
size = Vector3(28.0, 6.0, 28.0)
"""

last_sub_idx = text.rfind('[sub_resource')
end_of_last_sub = text.find('\n\n', last_sub_idx)
text = text[:end_of_last_sub] + sub_resources_to_add + text[end_of_last_sub:]

# 3. Update PerimeterBarriers to compact the boundaries
text = re.sub(
    r'(\[node name="NorthWall"[^\]]*\]\s*transform = Transform3D\([^\)]+,\s*)-?[\d\.]+,\s*-?[\d\.]+,\s*-?[\d\.]+\)',
    r'\g<1>0, 4, -65)',
    text
)
text = re.sub(
    r'(\[node name="SouthWall"[^\]]*\]\s*transform = Transform3D\([^\)]+,\s*)-?[\d\.]+,\s*-?[\d\.]+,\s*-?[\d\.]+\)',
    r'\g<1>0, 4, 55)',
    text
)
text = re.sub(
    r'(\[node name="EastWall"[^\]]*\]\s*transform = Transform3D\([^\)]+,\s*)-?[\d\.]+,\s*-?[\d\.]+,\s*-?[\d\.]+\)',
    r'\g<1>58, 4, 0)',
    text
)
text = re.sub(
    r'(\[node name="WestWallNorth"[^\]]*\]\s*transform = Transform3D\([^\)]+,\s*)-?[\d\.]+,\s*-?[\d\.]+,\s*-?[\d\.]+\)',
    r'\g<1>-102, 4, -30)',
    text
)
text = re.sub(
    r'(\[node name="WestWallSouth"[^\]]*\]\s*transform = Transform3D\([^\)]+,\s*)-?[\d\.]+,\s*-?[\d\.]+,\s*-?[\d\.]+\)',
    r'\g<1>-102, 4, 30)',
    text
)

# 4. Remove old Casa 1-8 definitions in NavigationRegion3D and replace with new Cabins, Fences, and Tombstones
old_casas_pattern = re.compile(r'\[node name="Casa\d*"\s+parent="NavigationRegion3D"[^\]]*\].*?(?=\[node name="Plane"|\Z)', re.DOTALL)

new_world_props = """
[node name="Cabin_Arena1" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(-1, 0, -8.74228e-08, 0, 1, 0, 8.74228e-08, 0, -1, 4.0, 0.0, -32.0)

[node name="Cabin_Arena2_A" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -3.0, 0.0, 32.0)

[node name="Cabin_Arena2_B" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8.0, 0.0, 32.0)

[node name="Cabin_AxeAltar" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(-1, 0, -8.74228e-08, 0, 1, 0, 8.74228e-08, 0, -1, 26.0, 0.0, -42.0)

[node name="Cabin_Village1" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 12.0, 0.0, 42.0)

[node name="Cabin_Village2" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 24.0, 0.0, 36.0)

[node name="Cabin_Village3" parent="NavigationRegion3D" instance=ExtResource("23_cabin")]
transform = Transform3D(-4.37114e-08, 0, -1, 0, 1, 0, 1, 0, -4.37114e-08, 28.0, 0.0, 18.0)

[node name="Fence_ForkNorth" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(0.92388, 0, -0.382683, 0, 1, 0, 0.382683, 0, 0.92388, -20.0, 0.0, -4.0)

[node name="Fence_ForkSouth" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(0.92388, 0, 0.382683, 0, 1, 0, -0.382683, 0, 0.92388, -20.0, 0.0, 4.0)

[node name="Fence_North1" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -10.0, 0.0, -16.0)

[node name="Fence_North2" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(0.866025, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866025, 10.0, 0.0, -28.0)

[node name="Fence_South1" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -10.0, 0.0, 16.0)

[node name="Fence_South2" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(0.866025, 0, 0.5, 0, 1, 0, -0.5, 0, 0.866025, 10.0, 0.0, 28.0)

[node name="Fence_ConnNorth" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, 22.0, 0.0, -6.0)

[node name="Fence_ConnSouth" parent="NavigationRegion3D" instance=ExtResource("26_fence")]
transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, 22.0, 0.0, 6.0)

[node name="Tombstone1" parent="NavigationRegion3D" instance=ExtResource("25_tombstone")]
transform = Transform3D(0.965926, 0, 0.258819, 0, 1, 0, -0.258819, 0, 0.965926, 28.0, 0.0, -40.0)

[node name="Tombstone2" parent="NavigationRegion3D" instance=ExtResource("25_tombstone")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 32.0, 0.0, -42.0)

[node name="Tombstone3" parent="NavigationRegion3D" instance=ExtResource("25_tombstone")]
transform = Transform3D(0.866025, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866025, 34.0, 0.0, -38.0)

[node name="Tombstone4" parent="NavigationRegion3D" instance=ExtResource("25_tombstone")]
transform = Transform3D(0.984808, 0, -0.173648, 0, 1, 0, 0.173648, 0, 0.984808, 29.0, 0.0, -47.0)

[node name="Tombstone5" parent="NavigationRegion3D" instance=ExtResource("25_tombstone")]
transform = Transform3D(0.939693, 0, 0.34202, 0, 1, 0, -0.34202, 0, 0.939693, 33.0, 0.0, -48.0)

[node name="Tombstone6" parent="NavigationRegion3D" instance=ExtResource("25_tombstone")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 38.0, 0.0, -42.0)
"""

text = old_casas_pattern.sub(new_world_props + "\n", text)

# 5. Place ChurchKey in village clearing and AxeNew in axe altar
text = re.sub(
    r'\[node name="Keys" type="Node3D"[^\]]*\].*?(?=\[node name="AxeNew")',
    r'[node name="ChurchKey" parent="." instance=ExtResource("8_rjftq")]\ntransform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 18.0, 0.4, 35.0)\n\n',
    text,
    flags=re.DOTALL
)

text = re.sub(
    r'(\[node name="AxeNew"[^\]]*\]\s*transform = Transform3D\([^\)]+,\s*)-?[\d\.]+,\s*-?[\d\.]+,\s*-?[\d\.]+\)',
    r'\g<1>18.0, 0.4, -35.0)',
    text
)

# 6. Add EnemyRevealTrigger under TutorialTriggers5
reveal_node = """
[node name="EnemyRevealTrigger" type="Area3D" parent="TutorialTriggers5"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -54.0, 0.0, -11.0)
script = ExtResource("22_reveal")
dialogue_text = "Antonio: ¿Qué demonios son esas cosas...?"
cinematic_duration = 3.2
target_zone = NodePath("../../EnemySpawnZones/ZonePrimerosEnemigos")

[node name="CollisionShape3D" type="CollisionShape3D" parent="TutorialTriggers5/EnemyRevealTrigger"]
shape = SubResource("BoxShape3D_reveal")
"""

text = re.sub(
    r'(\[node name="TutorialTriggers4"[^\]]*\].*?shape = SubResource\("BoxShape3D_yf5fn"\))',
    r'\g<1>\n' + reveal_node,
    text,
    flags=re.DOTALL
)

# 7. In EnemySpawnZones, keep ONLY ZonePrimerosEnemigos and remove the old wandering zones
spawn_zones_pattern = re.compile(r'\[node name="ZonePueblo"\s+type="Area3D"\s+parent="EnemySpawnZones".*?(?=\[node name="AxeEnemy"|\Z)', re.DOTALL)
text = spawn_zones_pattern.sub('', text)

# 8. Remove the stray AxeEnemy in tutorial corridor and replace with the 4 CombatArenas
arenas_definition = """
[node name="CombatArenas" type="Node3D" parent="."]

[node name="Arena1_CaminoNorte" type="Area3D" parent="CombatArenas" node_paths=PackedStringArray("door_cabin_markers", "fog_markers", "barrier_nodes")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.0, -25.0)
script = ExtResource("21_arena")
arena_name = "Camino Norte"
trigger_type = 0
enemy_scenes = Array[PackedScene]([ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])
door_cabin_markers = [NodePath("Marker_Door")]
fog_markers = [NodePath("Marker_Fog1"), NodePath("Marker_Fog2")]
barrier_nodes = [NodePath("Barricade_West"), NodePath("Barricade_East")]

[node name="CollisionShape3D" type="CollisionShape3D" parent="CombatArenas/Arena1_CaminoNorte"]
shape = SubResource("BoxShape3D_arena1")

[node name="Marker_Door" type="Marker3D" parent="CombatArenas/Arena1_CaminoNorte"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 4.0, 0.0, -2.5)

[node name="Marker_Fog1" type="Marker3D" parent="CombatArenas/Arena1_CaminoNorte"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -5.0, 0.0, 5.0)

[node name="Marker_Fog2" type="Marker3D" parent="CombatArenas/Arena1_CaminoNorte"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 7.0, 0.0, -2.0)

[node name="Barricade_West" parent="CombatArenas/Arena1_CaminoNorte" instance=ExtResource("24_barricade")]
transform = Transform3D(0.92388, 0, 0.382683, 0, 1, 0, -0.382683, 0, 0.92388, -12.0, 0.0, 7.0)

[node name="Barricade_East" parent="CombatArenas/Arena1_CaminoNorte" instance=ExtResource("24_barricade")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 12.0, 0.0, 0.0)

[node name="Arena2_CaminoSur" type="Area3D" parent="CombatArenas" node_paths=PackedStringArray("door_cabin_markers", "fog_markers", "barrier_nodes")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.0, 25.0)
script = ExtResource("21_arena")
arena_name = "Camino Sur"
trigger_type = 0
enemy_scenes = Array[PackedScene]([ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])
door_cabin_markers = [NodePath("Marker_Door1"), NodePath("Marker_Door2")]
fog_markers = [NodePath("Marker_Fog1")]
barrier_nodes = [NodePath("Barricade_West"), NodePath("Barricade_East")]

[node name="CollisionShape3D" type="CollisionShape3D" parent="CombatArenas/Arena2_CaminoSur"]
shape = SubResource("BoxShape3D_arena2")

[node name="Marker_Door1" type="Marker3D" parent="CombatArenas/Arena2_CaminoSur"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -3.0, 0.0, 2.5)

[node name="Marker_Door2" type="Marker3D" parent="CombatArenas/Arena2_CaminoSur"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8.0, 0.0, 2.5)

[node name="Marker_Fog1" type="Marker3D" parent="CombatArenas/Arena2_CaminoSur"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 2.0, 0.0, -7.0)

[node name="Barricade_West" parent="CombatArenas/Arena2_CaminoSur" instance=ExtResource("24_barricade")]
transform = Transform3D(0.92388, 0, -0.382683, 0, 1, 0, 0.382683, 0, 0.92388, -12.0, 0.0, -7.0)

[node name="Barricade_East" parent="CombatArenas/Arena2_CaminoSur" instance=ExtResource("24_barricade")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 12.0, 0.0, 0.0)

[node name="Arena3_AltarHacha" type="Area3D" parent="CombatArenas" node_paths=PackedStringArray("door_cabin_markers", "fog_markers", "barrier_nodes")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 18.0, 0.0, -35.0)
script = ExtResource("21_arena")
arena_name = "Altar del Hacha"
trigger_type = 1
enemy_scenes = Array[PackedScene]([ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("7_gg1b1")])
door_cabin_markers = [NodePath("Marker_Door")]
fog_markers = [NodePath("Marker_Fog1"), NodePath("Marker_Fog2")]
barrier_nodes = [NodePath("Barricade_West"), NodePath("Barricade_South"), NodePath("Barricade_East")]

[node name="CollisionShape3D" type="CollisionShape3D" parent="CombatArenas/Arena3_AltarHacha"]
shape = SubResource("BoxShape3D_arena3")

[node name="Marker_Door" type="Marker3D" parent="CombatArenas/Arena3_AltarHacha"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 8.0, 0.0, -2.5)

[node name="Marker_Fog1" type="Marker3D" parent="CombatArenas/Arena3_AltarHacha"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -4.0, 0.0, 3.0)

[node name="Marker_Fog2" type="Marker3D" parent="CombatArenas/Arena3_AltarHacha"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 4.0, 0.0, 7.0)

[node name="Barricade_West" parent="CombatArenas/Arena3_AltarHacha" instance=ExtResource("24_barricade")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -6.0, 0.0, 10.0)

[node name="Barricade_South" parent="CombatArenas/Arena3_AltarHacha" instance=ExtResource("24_barricade")]
transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, 0.0, 0.0, 23.0)

[node name="Barricade_East" parent="CombatArenas/Arena3_AltarHacha" instance=ExtResource("24_barricade")]
transform = Transform3D(0.707107, 0, -0.707107, 0, 1, 0, 0.707107, 0, 0.707107, 7.0, 0.0, -3.0)

[node name="Arena4_EntradaIglesia" type="Area3D" parent="CombatArenas" node_paths=PackedStringArray("door_cabin_markers", "fog_markers", "barrier_nodes")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 28.0, 0.0, -45.0)
script = ExtResource("21_arena")
arena_name = "Camino a la Iglesia"
trigger_type = 2
enemy_scenes = Array[PackedScene]([ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("7_gg1b1")])
door_cabin_markers = []
fog_markers = [NodePath("Marker_Fog1"), NodePath("Marker_Fog2"), NodePath("Marker_Fog3"), NodePath("Marker_Fog4")]
barrier_nodes = [NodePath("Barricade_FromAxe"), NodePath("Barricade_FromSouth"), NodePath("Barricade_ChurchDoor")]

[node name="CollisionShape3D" type="CollisionShape3D" parent="CombatArenas/Arena4_EntradaIglesia"]
shape = SubResource("BoxShape3D_arena4")

[node name="Marker_Fog1" type="Marker3D" parent="CombatArenas/Arena4_EntradaIglesia"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -1.0, 0.0, 6.0)

[node name="Marker_Fog2" type="Marker3D" parent="CombatArenas/Arena4_EntradaIglesia"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5.0, 0.0, 5.0)

[node name="Marker_Fog3" type="Marker3D" parent="CombatArenas/Arena4_EntradaIglesia"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.0, 0.0, -5.0)

[node name="Marker_Fog4" type="Marker3D" parent="CombatArenas/Arena4_EntradaIglesia"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 7.0, 0.0, -3.0)

[node name="Barricade_FromAxe" parent="CombatArenas/Arena4_EntradaIglesia" instance=ExtResource("24_barricade")]
transform = Transform3D(0.707107, 0, -0.707107, 0, 1, 0, 0.707107, 0, 0.707107, -3.0, 0.0, 7.0)

[node name="Barricade_FromSouth" parent="CombatArenas/Arena4_EntradaIglesia" instance=ExtResource("24_barricade")]
transform = Transform3D(0, 0, 1, 0, 1, 0, -1, 0, 0, -3.0, 0.0, 20.0)

[node name="Barricade_ChurchDoor" parent="CombatArenas/Arena4_EntradaIglesia" instance=ExtResource("24_barricade")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 10.0, 0.0, 0.0)
"""

text = re.sub(
    r'\[node name="AxeEnemy"[^\]]*\].*?(?=\[editable|\Z)',
    arenas_definition + '\n',
    text,
    flags=re.DOTALL
)

with open('levels/map_1/toy_box.tscn', 'w', encoding='utf-8') as f:
    f.write(text)

print("toy_box.tscn generated successfully!")

