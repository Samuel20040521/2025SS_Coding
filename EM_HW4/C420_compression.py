# make_comparison.py
import math
import os

import numpy as np
from PIL import Image, ImageDraw

ORIG = "input.jpg"       # ← 原圖檔名
REC  = "output.jpg"      # ← 重建圖檔名
OUT  = "comparison.png"  # ← 對照圖輸出

def psnr(a, b):
    mse = np.mean((a.astype(np.float32) - b.astype(np.float32))**2)
    return float('inf') if mse == 0 else 20*math.log10(255.0/math.sqrt(mse))

# 讀圖
orig = Image.open(ORIG).convert("RGB")
rec  = Image.open(REC ).convert("RGB")

# 計算 PSNR
val = psnr(np.asarray(orig), np.asarray(rec))

# 建立白底畫布（多留 40px 放標題）
margin = 40
W, H   = orig.width + rec.width, orig.height + margin
canvas = Image.new("RGB", (W, H), (255, 255, 255))

# 貼圖
canvas.paste(orig, (0, margin))
canvas.paste(rec,  (orig.width, margin))

# 標題
draw = ImageDraw.Draw(canvas)
draw.text((orig.width//2 - len("Original")*3, 10), "Original",              fill=(0,0,0))
cap = f"Reconstructed (PSNR {val:.2f} dB)"
draw.text((orig.width + rec.width//2 - len(cap)*3, 10), cap, fill=(0,0,0))

canvas.save(OUT)
print(f"[✓] Saved {OUT}  (PSNR = {val:.2f} dB)")
