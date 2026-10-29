import wave
import math
import struct

sample_rate = 44100
duration = 4.0  # 4 seconds looping/fading ringing
freq1 = 3450.0  # Main high-pitched tinnitus frequency
freq2 = 3520.0  # Slight beat frequency for ear-ringing realism

num_samples = int(sample_rate * duration)
audio_data = bytearray()

for i in range(num_samples):
    t = float(i) / sample_rate
    # Envelope: soft attack (0.5s), sustain, soft release (0.5s)
    if t < 0.5:
        env = t / 0.5
    elif t > duration - 0.5:
        env = (duration - t) / 0.5
    else:
        env = 1.0
    
    # Combined high frequency tone with gentle modulation
    val = (math.sin(2.0 * math.pi * freq1 * t) * 0.7 + math.sin(2.0 * math.pi * freq2 * t) * 0.3) * env * 0.4
    
    sample = int(max(min(val * 32767.0, 32767.0), -32768.0))
    audio_data.extend(struct.pack('<h', sample))

out_path = r"c:\Godot Proyects\proyect-move\assets\audio\ringing.wav"
with wave.open(out_path, 'wb') as wav_file:
    wav_file.setnchannels(1)      # Mono
    wav_file.setsampwidth(2)      # 16-bit
    wav_file.setframerate(sample_rate)
    wav_file.writeframes(audio_data)

print(f"Generated {out_path} ({len(audio_data)} bytes)")

