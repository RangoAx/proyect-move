import re

path = "levels/map_1/toy_box.tscn"
with open(path, "r", encoding="utf-8") as f:
    text = f.read()

# 1. Add ext_resource if not present
if "res://components/world/fog_turnaround_hazard.gd" not in text:
    ext_hazard = '[ext_resource type="Script" path="res://components/world/fog_turnaround_hazard.gd" id="33_hazard"]\n'
    # insert after 32_lantern
    text = text.replace('id="32_lantern"]\n', 'id="32_lantern"]\n' + ext_hazard)

# 2. Add sub_resource BoxShape3D_hazard if not present
if "BoxShape3D_hazard" not in text:
    sub_hazard = '[sub_resource type="BoxShape3D" id="BoxShape3D_hazard"]\nsize = Vector3(14, 8, 20)\n\n'
    text = text.replace('[sub_resource type="BoxShape3D" id="BoxShape3D_reveal"]', sub_hazard + '[sub_resource type="BoxShape3D" id="BoxShape3D_reveal"]')

# 3. Add FogTurnaroundHazard under TutorialTriggers5
if "FogTurnaroundHazard" not in text:
    hazard_node = '''[node name="FogTurnaroundHazard" type="Area3D" parent="TutorialTriggers5"]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, -106.0, 0.0, -11.0)
script = ExtResource("33_hazard")

[node name="CollisionShape3D" type="CollisionShape3D" parent="TutorialTriggers5/FogTurnaroundHazard"]
shape = SubResource("BoxShape3D_hazard")

'''
    text = text.replace('[node name="TutorialTriggers" type="Area3D" parent="TutorialTriggers5"', hazard_node + '[node name="TutorialTriggers" type="Area3D" parent="TutorialTriggers5"')

# 4. Clean up corrupted UTF-8 encodings in tutorial strings
text = text.replace("RATÃ“N", "RATÓN")
text = text.replace("MantÃ©n", "Mantén")
text = text.replace("Â¿QuÃ©", "¿Qué")

with open(path, "w", encoding="utf-8", newline="\n") as f:
    f.write(text)

print("Updated toy_box.tscn successfully.")

