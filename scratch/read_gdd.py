import re

pdf_path = r'C:/Users/USER/.gemini/antigravity/brain/517403fc-fc58-497d-818a-9d02776f093f/.user_uploaded/media_1793241436401_6695f75c.pdf'
with open(pdf_path, 'rb') as f:
    content = f.read()

# PDF text streams often uncompressed or flate compressed
import zlib
streams = re.findall(b'stream[\r\n]+(.*?)[\r\n]+endstream', content, re.DOTALL)
all_text = []
for s in streams:
    try:
        decomp = zlib.decompress(s)
        # extract strings inside parentheses in TJ or Tj
        txts = re.findall(rb'\((.*?)\)\s*T[jJ]', decomp)
        for t in txts:
            all_text.append(t.decode('utf-8', errors='ignore'))
    except:
        pass

full_str = ' '.join(all_text)
print("Extracted chars:", len(full_str))
for line in full_str.split('.'):
    l_low = line.lower()
    if any(k in l_low for k in ['niebla', 'combate', 'pelea', 'arena', 'enemigo', 'pared', 'muro', 'circular', 'oleada', 'spawn']):
        print("-", line.strip()[:140])

