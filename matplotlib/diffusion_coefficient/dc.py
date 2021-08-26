#%%
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
from sklearn.datasets import make_regression
from sklearn import linear_model
import math
from collections import Counter

############------input-----##############
savename = "diffusion_coefficient.png"
xlabel = '1/Temperature (1/K)'
ylabel = 'ln(D) (m$^{2}$/s)'

structure = ['HEA-1', 'Pd', 'Rh', 'Co', 'Pt']
filenum = ['all','1','2','3','4']
temp = [3100, 3200, 3300, 3400]
mark = ['o', 'v', '1', 's', '*', 'x', 'd', 'p', 'h', 'h']

legend_loc = 'lower left'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

def dc(ini_temp,temp_interval,total,datname,typename):
    xValues = []
    yValues = []
    for i in range(total):
        temperature = ini_temp + i*temp_interval
        filename = str(temperature) + '/' + datname
        data = np.loadtxt(filename)
        slope, intercept, r_value, p_value, std_err = stats.linregress(data[399:,0], data[399:,1])
        #print("slope: %f    intercept: %f" % (slope, intercept))
        R_tempe = 1/temperature
        #D = slope/6
        D = math.log((slope*1e-8)/6,math.e) # A^2/ps -> m^2/s >> 1e-8
        xValues.append(R_tempe)
        yValues.append(D)
        #print("%s temperature: %d    X: %.3e    Y: %.3e" % (typename, temperature, R_tempe, D))
    return xValues, yValues

fig, ax1 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)

output = open("output.dat", mode='w')
for i in range(len(structure)):
    filename = 'fortran4msd_' + filenum[i] +'.dat'
    dcx, dcy = dc(ini_temp=3100, temp_interval=100, total=4, datname=filename, typename=structure[i])   
    lns1 = ax1.scatter(dcx, dcy, marker=mark[i], label=structure[i])
    plt.plot(np.unique(dcx), np.poly1d(np.polyfit(dcx, dcy, 1))(np.unique(dcx)))
    coeff = np.polyfit(dcx, dcy, 1)
    print("%s D0: %.2e Q: %.2f" % (structure[i],math.exp(coeff[1]),-coeff[0]*8.314/1000), file = output) # R=8.314 J/mol
output.close()

mtemp = []
for i in temp:
    mtemp.append(1/i)
#print(mtemp)
ax2 = ax1.twiny()
filename = 'fortran4msd_' + filenum[0] +'.dat'
dcx, dcy = dc(ini_temp=3100, temp_interval=100, total=4, datname=filename, typename=structure[0])
lns1 = ax2.scatter(dcx, dcy)
plt.xticks(mtemp[:],temp)

ax1.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax1.set_ylabel(ylabel, fontsize=15, fontweight='bold')

ax1.tick_params(axis='x', labelsize=14)
ax2.tick_params(axis='x', labelsize=14)
ax1.tick_params(axis='y', labelsize=14)

ax1.legend(loc=legend_loc)

plt.savefig(savename)
plt.show()


# %%
