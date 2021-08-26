# %%
import matplotlib.pyplot as plt
import numpy as np
from numpy import polyfit, poly1d
from scipy.optimize import curve_fit
import math
import sympy as sym

font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
structure = [25.3, 20.1, 15.6, 10.0, 5.2]#31.9, 27.9,
#print(structure[:],data[:,1])

data = np.genfromtxt('output.dat',comments='#')

mstructure = []
for i in structure:
    #print(i,math.sqrt(1/i))
    mstructure.append(1/i)

fig, ax = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
lns1 = ax.plot(structure[:],data[1:,1],linewidth=2, color='tab:blue',marker='o', label='MD predicted melting points')
plt.axhline(y=2940, xmin=0, xmax=1, linestyle = '--', color = 'k') #dash line

def func(x, a, b):
        data = np.genfromtxt('output.dat',comments='#')
        return data[0,1]*np.exp(a/(x**b))
        #return data[0,1]*np.exp(a*(x**b))

popt, pcov = curve_fit(func,  structure[:],  data[1:,1])
y2 = [func(i, popt[0], popt[1]) for i in np.arange(5, 100, 0.01)]
x2 = [i for i in np.arange(5, 100, 0.01)]

plt.plot(x2,y2,'r--', label='Curve fitting')
print("a = %.2f , b = %.2f" % (popt[0], popt[1]))

ax.set_xlim(5,50)
#ax.set_ylim(ymin=data[-1,1])
plt.xticks(fontsize=14)
plt.yticks(fontsize=14)

ax.set_xlabel('Grain sizes (nm)',fontsize=15, fontweight='bold')
ax.set_ylabel('Temperature (K)',fontsize=15, fontweight='bold')

plt.legend(loc='lower right', bbox_to_anchor=(1, 0.7), fontsize=12)

plt.savefig("Tm.png")
plt.show()

# %%
