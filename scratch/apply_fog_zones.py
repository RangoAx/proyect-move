import re

with open('levels/map_1/toy_box.tscn', 'r', encoding='utf-8') as f:
    text = f.read()

# Update ZonePueblo
old_pueblo = """[node name="ZonePueblo" type="Area3D" parent="EnemySpawnZones" unique_id=2140000010]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 20, 0, 22)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Pueblo"
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])"""

new_pueblo = """[node name="ZonePueblo" type="Area3D" parent="EnemySpawnZones" unique_id=2140000010]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 20, 0, 22)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Pueblo"
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])
can_respawn = false
enable_circular_fog_wall = true
fog_wall_radius = 18.0"""

# Update ZoneCaminoBosque
old_camino = """[node name="ZoneCaminoBosque" type="Area3D" parent="EnemySpawnZones" unique_id=2140000020]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 62, 0, 42)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Camino al Bosque"
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])"""

new_camino = """[node name="ZoneCaminoBosque" type="Area3D" parent="EnemySpawnZones" unique_id=2140000020]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 62, 0, 42)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Camino al Bosque"
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])
can_respawn = false
enable_circular_fog_wall = true
fog_wall_radius = 16.5"""

# Update ZoneBosque
old_bosque = """[node name="ZoneBosque" type="Area3D" parent="EnemySpawnZones" unique_id=2140000030]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 80, 0, 72)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Bosque"
enemy_scenes = Array[PackedScene]([ExtResource("7_gg1b1"), ExtResource("7_gg1b1"), ExtResource("7_gg1b1"), ExtResource("7_gg1b1")])"""

new_bosque = """[node name="ZoneBosque" type="Area3D" parent="EnemySpawnZones" unique_id=2140000030]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 80, 0, 72)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Bosque"
enemy_scenes = Array[PackedScene]([ExtResource("7_gg1b1"), ExtResource("7_gg1b1"), ExtResource("7_gg1b1"), ExtResource("7_gg1b1")])
can_respawn = false
enable_circular_fog_wall = true
fog_wall_radius = 17.5"""

# Update ZoneEntradaIglesia
old_iglesia = """[node name="ZoneEntradaIglesia" type="Area3D" parent="EnemySpawnZones" unique_id=2140000040]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 35, 0, -36)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Entrada Iglesia"
can_respawn = false
requires_church_key = true
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("7_gg1b1"), ExtResource("7_gg1b1")])"""

new_iglesia = """[node name="ZoneEntradaIglesia" type="Area3D" parent="EnemySpawnZones" unique_id=2140000040]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 35, 0, -36)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Entrada Iglesia"
can_respawn = false
requires_church_key = true
enable_circular_fog_wall = true
fog_wall_radius = 16.0
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("7_gg1b1"), ExtResource("7_gg1b1")])"""

# Update ZoneAbajoPueblo
old_abajo = """[node name="ZoneAbajoPueblo" type="Area3D" parent="EnemySpawnZones" unique_id=2140000050]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 20, 0, 65)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Abajo del Pueblo"
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])"""

new_abajo = """[node name="ZoneAbajoPueblo" type="Area3D" parent="EnemySpawnZones" unique_id=2140000050]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 20, 0, 65)
collision_layer = 0
collision_mask = 4
script = ExtResource("1_d84ol")
zone_name = "Abajo del Pueblo"
enemy_scenes = Array[PackedScene]([ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("8_jmlt3"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork"), ExtResource("20_pitchfork")])
can_respawn = false
enable_circular_fog_wall = true
fog_wall_radius = 17.5"""

assert old_pueblo in text, "old_pueblo not found!"
text = text.replace(old_pueblo, new_pueblo)

assert old_camino in text, "old_camino not found!"
text = text.replace(old_camino, new_camino)

assert old_bosque in text, "old_bosque not found!"
text = text.replace(old_bosque, new_bosque)

assert old_iglesia in text, "old_iglesia not found!"
text = text.replace(old_iglesia, new_iglesia)

assert old_abajo in text, "old_abajo not found!"
text = text.replace(old_abajo, new_abajo)

with open('levels/map_1/toy_box.tscn', 'w', encoding='utf-8') as f:
    f.write(text)

print("Successfully updated all combat encounter zones in toy_box.tscn!")

