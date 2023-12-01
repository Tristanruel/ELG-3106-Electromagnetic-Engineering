import numpy as np
import math
import matplotlib.pyplot as plt
import pandas as pd


s=np.array(np.arange(0.5,5.1,0.1))
Er1=10
Er2=2


t=(30.67/s)**0.75

x1=0.56*(((Er1-0.9)/(Er1+3))**0.05)
x2=0.56*(((Er2-0.9)/(Er2+3))**0.05)

y=1+(0.02*np.log(((s**4)+(0.00037*(s**2)))/(((s**4)+(0.43)))))+(0.05*np.log(1+(0.00017*(s**3))))


Eeff1=((Er1+1)/2)+(((Er1-1)/2)*np.power(1+(10/s),-x1*y))
Eeff2=((Er2+1)/2)+(((Er2-1)/2)*np.power(1+(10/s),-x2*y))

Z1=np.array((60/np.sqrt(Eeff1))*np.log(((6+((2*np.pi)*np.exp(-t)))/s)+np.sqrt(1+(4/(s**2)))))
Z2=np.array((60/np.sqrt(Eeff2))*np.log(((6+((2*np.pi)*np.exp(-t)))/s)+np.sqrt(1+(4/(s**2)))))


q1=(60*np.pi**2)/(Z1*np.sqrt(Er1))
s1=(2/np.pi)*((q1-1)-np.log((2*q1)-1)+(((Er1+1)/(2))*(np.log(q1-1)+0.29-(0.52/Er1))))


q2=(60*np.pi**2)/(Z1*np.sqrt(Er2))
s2=(2/np.pi)*((q2-1)-np.log((2*q2)-1)+(((Er2+1)/(2))*(np.log(q2-1)+0.29-(0.52/Er2))))

data = {"S":s, "Z1": Z1, "Z2":Z2, "S1":s1, "S2":s2}
df = pd.DataFrame(data)
print(df)
excel_filename = "data.xlsx"
df.to_excel(excel_filename, index=False, engine='openpyxl')

print(f"Data saved to {excel_filename}")