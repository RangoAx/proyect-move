with open('enemies/enemy_lumberjack.tscn', 'r', encoding='utf-8') as f:
    text = f.read()
print("enemy_lumberjack.tscn lines:", len(text.splitlines()))
print("first 30 lines:\n", '\n'.join(text.splitlines()[:30]))

