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

V_G1 = 0.5
V_G2 = 2.0
V_THN = 0.7
V_THP = -0.8


# Piecewise function
def I_x(V_x, V_G):
    if V_x < V_G - V_THN:
        return k_n * ((V_G - V_THN) * V_x - 0.5 * V_x**2)
    elif V_x < V_G + abs(V_THP):
        return 0.5 * k_n * (V_G - V_THN) ** 2
    else:
        return 0.5 * (k_n * (V_G - V_THN) ** 2 + k_p * (V_x - V_G - abs(V_THP)) ** 2)


def I_x2(V_x, V_G):
    if V_x < V_G + abs(V_THP):
        return 0
    else:
        return 0.5 * (k_p * (V_x - V_G - abs(V_THP)) ** 2)


# Generate data
V_x = np.linspace(0, 6, 500)
I_x_G1 = [I_x2(v, V_G1) * 1e3 for v in V_x]
I_x_G2 = [I_x(v, V_G2) * 1e3 for v in V_x]  # Convert to mA

# Plot
plt.figure(figsize=(8.27, 2.922))  # A4 size in inches
plt.plot(V_x, I_x_G1, label=f"$V_{{G}} = {V_G1} V$", color="blue")
plt.plot(V_x, I_x_G2, label=f"$V_{{G}} = {V_G2} V$", color="red")
plt.xlabel("$V_x$ (V)")
plt.ylabel("$I_x$ (mA)")
plt.title("2.24(a) $I_x$ versus $V_x$")
plt.legend()
plt.grid(True)
plt.savefig("ECD_HW1_2_24_a_Ix_vs_Vx.png")
plt.show()
