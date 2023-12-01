import numpy as np
import matplotlib.pyplot as plt
import pandas as pd



c = 3e8  


def calculate_x(Er):
    return 0.56 * ((Er - 0.9) / (Er + 3))**0.05

def calculate_y(s):
    return 1 + 0.02 * np.log((s**4 + 0.00037 * s**2) / (s**4 + 0.43)) + 0.05 * np.log(1 + 0.00017 * s**3)

def calculate_Eeff(Er, s, x, y):
    return (Er + 1) / 2 + (Er - 1) / 2 * (1 + (10) / s)**(-x * y)

def calculate_Z0(Eeff, s):
    t = (30.67 / s)**0.75
    return 60 / np.sqrt(Eeff) * np.log((6 + (2 * np.pi - 6) * np.exp(-t)) / s + np.sqrt(1 + 4 / s**2))

def approximation_a(Z0, Er):
    q = (60 * np.pi**2) / (Z0 * np.sqrt(Er))
    return (2 / np.pi) * ((q - 1) - np.log(2 * q - 1) + (Er - 1) / (2 * Er) * (np.log(q - 1) + 0.29 - 0.52 / Er))

def approximation_b(Z0, Er):
    p = np.sqrt((Er + 1) / 2) * (Z0 / 60) + (Er - 1) / (Er + 1) * (0.23 + 0.12 / Er)
    return (8 * np.exp(p)) / (np.exp(2 * p) - 2)


Er_10 = 10
h = 1e-3 
s_values_10 = np.array([0.5, 1.0, 1.2, 1.5, 2.0, 3.0, 4.0, 5.0])
provided_Z0_values_10 = np.array([65.711672, 48.740235, 44.414188, 39.435683, 33.30811, 25.528372, 20.759498, 17.520966])

Er_2 = 2
s_values_2 = np.arange(0.5, 5.1, 0.1)
Z0_values_2 = []


for s in s_values_2:
    x = calculate_x(Er_2)
    y = calculate_y(s)
    Eeff = calculate_Eeff(Er_2, s, x, y)
    Z0_values_2.append(calculate_Z0(Eeff, s))

reverse_engineered_s_values_a_10 = [approximation_a(Z0, Er_10) for Z0 in provided_Z0_values_10]
reverse_engineered_s_values_b_10 = [approximation_b(Z0, Er_10) for Z0 in provided_Z0_values_10]
reverse_engineered_s_values_a_2 = [approximation_a(Z0, Er_2) for Z0 in Z0_values_2]
reverse_engineered_s_values_b_2 = [approximation_b(Z0, Er_2) for Z0 in Z0_values_2]

relative_differences_a_10 = 100 * (np.array(reverse_engineered_s_values_a_10) - s_values_10) / s_values_10
relative_differences_b_10 = 100 * (np.array(reverse_engineered_s_values_b_10) - s_values_10) / s_values_10

# Calculate the percent difference between simulated and calculated Z0 values for Er=10
calculated_Z0_values_10 = [calculate_Z0(calculate_Eeff(Er_10, s, calculate_x(Er_10), calculate_y(s)), s) for s in s_values_10]
percent_diff_Z0_10 = 100 * (calculated_Z0_values_10 - provided_Z0_values_10) / provided_Z0_values_10

# Plotting the percent difference for Er=10
plt.figure(figsize=(12, 6))
plt.plot(s_values_10, percent_diff_Z0_10, '-o')
plt.xlabel('Width-to-Thickness Ratio s')
plt.ylabel('Percent Difference in Z0 (%)')
plt.title('Percent Difference Between Simulated and Calculated Z0 Values for Er=10')
plt.grid(True)
plt.savefig('Percent_Difference_Z0_Er10.png')
plt.show(block=False)

# Plotting the percent difference in S values for Er=10
plt.figure(figsize=(12, 6))
plt.plot(s_values_10, relative_differences_a_10, '-o', label='Approximation A')
plt.plot(s_values_10, relative_differences_b_10, '-o', label='Approximation B')
plt.xlabel('Width-to-Thickness Ratio s')
plt.ylabel('Percent Difference in S (%)')
plt.title('Percent Difference in S for Er=10')
plt.legend()
plt.grid(True)
plt.savefig('Percent_Difference_S_Er10.png')
plt.show(block=False)

relative_differences_a_2 = 100 * (np.array(reverse_engineered_s_values_a_2) - s_values_2) / s_values_2
relative_differences_b_2 = 100 * (np.array(reverse_engineered_s_values_b_2) - s_values_2) / s_values_2

# Plotting the percent difference in S values for Er=2
plt.figure(figsize=(12, 6))
plt.plot(s_values_2, relative_differences_a_2, '-o', label='Approximation A')
plt.plot(s_values_2, relative_differences_b_2, '-o', label='Approximation B')
plt.xlabel('Width-to-Thickness Ratio s')
plt.ylabel('Percent Difference in S (%)')
plt.title('Percent Difference in S for Er=2')
plt.legend()
plt.grid(True)
plt.savefig('Percent_Difference_S_Er2.png')
plt.show(block=False)

Z0_values_2 = np.array(Z0_values_2)
valid_range_a_10 = provided_Z0_values_10[np.abs(relative_differences_a_10) <= 2]
valid_range_b_10 = provided_Z0_values_10[np.abs(relative_differences_b_10) <= 2]
valid_range_a_2 = Z0_values_2[np.abs(relative_differences_a_2) <= 2]
valid_range_b_2 = Z0_values_2[np.abs(relative_differences_b_2) <= 2]

print("Valid range for Approximation A for Er=10:", valid_range_a_10)
print("Valid range for Approximation B for Er=10:", valid_range_b_10)
print("Valid range for Approximation A for Er=2:", valid_range_a_2)
print("Valid range for Approximation B for Er=2:", valid_range_b_2)

data = {
    'Valid Range A for Er=10': pd.Series(valid_range_a_10),
    'Valid Range B for Er=10': pd.Series(valid_range_b_10),
    'Valid Range A for Er=2': pd.Series(valid_range_a_2),
    'Valid Range B for Er=2': pd.Series(valid_range_b_2)
}

df = pd.DataFrame(data)
excel_filename = "results.xlsx"
df.to_excel(excel_filename, index=False, engine='openpyxl')

print(f"Data saved to {excel_filename}")
plt.show()