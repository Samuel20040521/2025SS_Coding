import matplotlib.pyplot as plt
import numpy as np

# Parameters
mu_p = 100e-4
mu_n = 350e-4
epsilon_ox = 3.45e-11
t_ox = 9e-9
W_n = W_p = 5e-6
L_n = L_p = 0.4e-6
C_ox = epsilon_ox / t_ox

k_n = mu_n * C_ox * W_n / L_n
k_p = mu_p * C_ox * W_p / L_p

V_G2 = 2.0
V_THN = 0.7
V_THP = -0.8


# Piecewise function
def I_x(V_x, V_G):
    if V_x < V_G + abs(V_THP):
        return 0
    elif V_x < V_G + abs(V_THP) + np.sqrt(k_n / k_p) * (V_G - V_THN):
        return -k_p * (V_x - V_G - abs(V_THP))
    else:
        return k_n * (V_G - V_THN)


# Generate data
V_x = np.linspace(0, 6, 500)
I_x_0 = np.zeros_like(V_x)
I_x_G2 = [I_x(v, V_G2) * 1e3 for v in V_x]  # Convert to mA

# Plot
plt.figure(figsize=(8.27, 2.922))  # A4 size in inches
plt.plot(V_x, I_x_0, label="$V_{{G}} = 0.5 V$", color="blue")
plt.plot(V_x, I_x_G2, label=f"$V_{{G}} = {V_G2} V$", color="red")
plt.xlabel("$V_x$ (V)")
plt.ylabel("$G_m$")
plt.title("2.24(b) $G_m$ versus $V_x$")
plt.legend()
plt.grid(True)
plt.savefig("ECD_HW1_2_24_b_Gm_vs_Vx.png")
plt.show()
