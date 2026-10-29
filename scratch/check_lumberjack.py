import struct, json

with open("assets/models/pawns/enemy/lumberjack/Leñador v2.glb", "rb") as f:
    magic = f.read(4)
    version, length = struct.unpack("<II", f.read(8))
    chunk_len, chunk_type = struct.unpack("<II", f.read(8))
    json_bytes = f.read(chunk_len)
    data = json.loads(json_bytes.decode("utf-8"))
    
    anims = [a.get("name", "unnamed") for a in data.get("animations", [])]
    print("Animations:", anims)

