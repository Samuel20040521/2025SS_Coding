#!/usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
from scipy.special import factorial
from math import log, exp

def kl_divergence(p_true, p_model):
    """計算 D(p_true || p_model) = Σ p_true[i] * ln(p_true[i] / p_model[i])，
    若 p_true[i] = 0 則那一項視為 0。"""
    mask = p_true > 0
    return np.sum(p_true[mask] * np.log(p_true[mask] / p_model[mask]))

# 1) 定義 PX(n)
n_max = 50  # 掃描到足夠大的 n，確保 PZ 的 tail 都到接近 0
n = np.arange(0, n_max+1)
P_X = np.zeros_like(n, dtype=float)
P_X[:6] = 1/6  # n = 0,1,2,3,4,5 為均勻分佈，其餘為 0  :contentReference[oaicite:0]{index=0}

# (a) PY(n) = (1 - exp(-1/σ)) * exp(-n/σ)，σ ∈ (0,1], 步進 0.02
sigmas = np.arange(0.02, 1.0001, 0.02)
best_sigma = None
best_kl_sigma = float('inf')

for σ in sigmas:
    # discrete exponential distribution over n>=0
    a = 1 - np.exp(-1/σ)
    P_Y = a * np.exp(-n/σ)
    P_Y /= P_Y.sum()  # 理論上 sum 已經 ~1，但為保險做正規化
    kl = kl_divergence(P_X, P_Y)
    if kl < best_kl_sigma:
        best_kl_sigma = kl
        best_sigma = σ

# (b) PZ(n) = e^{-λ} λ^n / n!，λ ∈ (1,5], 步進 0.1
lambdas = np.arange(1.0, 5.0001, 0.1)
best_lambda = None
best_kl_lambda = float('inf')

for λ in lambdas:
    P_Z = np.exp(-λ) * λ**n / factorial(n)
    P_Z /= P_Z.sum()
    kl = kl_divergence(P_X, P_Z)
    if kl < best_kl_lambda:
        best_kl_lambda = kl
        best_lambda = λ

# 輸出結果
print(f"最小 KL(PY‖PX) 的 σ = {best_sigma:.2f}, KL = {best_kl_sigma:.6f}")
print(f"最小 KL(PZ‖PX) 的 λ = {best_lambda:.1f}, KL = {best_kl_lambda:.6f}")
