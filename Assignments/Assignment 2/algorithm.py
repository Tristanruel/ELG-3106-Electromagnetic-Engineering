import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def compute_data(n2_value, incident_angle_deg):
    # Constants
    n1 = 120 * np.pi
    
    # Formulas
    incident_angle_rad = np.radians(incident_angle_deg)
    transmission_angle_rad = np.arcsin(np.sin(incident_angle_rad) / np.sqrt(8))
    transmission_angle_deg = np.degrees(transmission_angle_rad)
    
    
    Γ_TE = (n2_value * np.cos(incident_angle_rad) - n1 * np.cos(transmission_angle_rad)) / (n2_value * np.cos(incident_angle_rad) + n1 * np.cos(transmission_angle_rad))
    
    τ_TE = (2 * n2_value * np.cos(incident_angle_rad)) / (n2_value * np.cos(incident_angle_rad) + n1 * np.cos(transmission_angle_rad))
    
    
    Γ_TM = (n2_value * np.cos(transmission_angle_rad) - n1 * np.cos(incident_angle_rad)) / (n2_value * np.cos(transmission_angle_rad) + n1 * np.cos(incident_angle_rad))
    
    τ_TM = (2 * n2_value * np.cos(incident_angle_rad)) / (n2_value * np.cos(transmission_angle_rad) + n1 * np.cos(incident_angle_rad))

    T_TE_squared = τ_TM**2 * (n1 * np.cos(transmission_angle_rad) / (n2_value * np.cos(incident_angle_rad)))
    
    R_TE = Γ_TE**2
    T_TE = 1 - R_TE
    
    R_TM = Γ_TM**2
    T_TM = 1 - R_TM
    
    return {
        "n1": n1,
        "n2": n2_value,
        "Incident Angle": incident_angle_deg,
        "Transmission Angle": transmission_angle_deg,
        "R (TE)": R_TE,
        "T (TE)": T_TE,
        "R (TM)": R_TM,
        "T (TM)": T_TM,
        "Incident Angle in Rads": incident_angle_rad,
        "Transmission Angle (Rads)": transmission_angle_rad,
        "Γ (TE)": Γ_TE,
        "τ (TE)": τ_TE,
        "T (TE).1": T_TE_squared,
        "Γ (TM)": Γ_TM,
        "τ (TM)": τ_TM
    }

def plot_reflectivity_transmissivity(n2_value, incident_angles):

    data_list = [compute_data(n2_value, angle) for angle in incident_angles]
    df = pd.DataFrame(data_list)
    

    incident_angle_degrees = df["Incident Angle"]
    Rte = df["R (TE)"]
    Tte = df["T (TE)"]
    Rtm = df["R (TM)"]
    Ttm = df["T (TM)"]

    # Plotting
    plt.figure(figsize=(16, 9))
    plt.plot(incident_angle_degrees, Rte, label='R (TE)', color='blue')
    plt.plot(incident_angle_degrees, Tte, label='T (TE)', color='red')
    plt.plot(incident_angle_degrees, Rtm, label='R (TM)', color='green')
    plt.plot(incident_angle_degrees, Ttm, label='T (TM)', color='orange')
    plt.title('Reflectivity and Transmissivity vs. Incident Angle')
    plt.xlabel('Incident Angle (degrees)')
    plt.ylabel('Coefficient')
    plt.legend(loc='upper right', title='Legend')
    plt.grid(True)
    plt.savefig("reflectivity_transmissivity_graph.png", dpi=600)  # Save figure as PNG
    plt.show()


n2_value = (120 * np.pi)/np.sqrt(8)  
incident_angles = np.arange(0, 90.5, 0.5)  # Angles from 0 to 90 in steps of 0.5 degrees
plot_reflectivity_transmissivity(n2_value, incident_angles)

data_list = [compute_data(n2_value, angle) for angle in incident_angles]
df = pd.DataFrame(data_list)


condensed_data = df[["Incident Angle", "Transmission Angle", "R (TE)", "T (TE)", "R (TM)", "T (TM)"]]

# Save the full data
output_file_path = "computed_data.xlsx"
df.to_excel(output_file_path, index=False, engine='openpyxl')
print(df)
# Save the condensed data
condensed_file_path = "condensed_data.xlsx"
condensed_data.to_excel(condensed_file_path, index=False, engine='openpyxl')

