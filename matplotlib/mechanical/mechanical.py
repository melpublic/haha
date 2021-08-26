#%%
import matplotlib.pyplot as plt
import numpy as np
import math
from numpy import polyfit, poly1d

structure = ['5.2 nm', '10.0 nm', '15.6 nm', '20.1 nm', '25.3 nm', '27.9 nm']
xlabel = 'Grain size (nm)'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################################################################################
fig, ax1 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
ax12 = ax1.twinx()
data1 = np.genfromtxt('./output/T_Yield_strengths.dat')
savename1 = "yield_stress.png"
ylabel1 = 'Yield stress (GPa)'
ylabel12 = 'Yield strain (%)'

lns1 = ax1.plot(structure[:], data1[:,2], 'o-', color='tab:blue', label='Yield stress')
lns2 = ax12.plot(structure[:], data1[:,4], 'o-', color='tab:orange', label='Yield strain')

ax1.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax1.set_ylabel(ylabel1, fontsize=15, fontweight='bold')
ax12.set_ylabel(ylabel12, fontsize=15, fontweight='bold')

ax1.tick_params(axis='x', labelsize=14)
ax1.tick_params(axis='y', labelsize=14)
ax12.tick_params(axis='y', labelsize=14)

lns = lns1+lns2
labs = [l.get_label() for l in lns]
ax1.legend(lns, labs, loc=0, fontsize=12)
plt.savefig(savename1)
############################################################################################################
fig, ax2 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
ax22 = ax2.twinx()
data2 = np.genfromtxt('./output/T_ultimate_ss.dat')
savename2 = "ultimate stres.png"
ylabel2 = 'Ultimate stress (GPa)'
ylabel22 = 'Ultimate strain (%)'

lns1 = ax2.plot(structure[:], data2[:,2], 'o-', color='tab:blue', label='Ultimate stress')
lns2 = ax22.plot(structure[:], data2[:,4], 'o-', color='tab:orange', label='Ultimate strain')

ax2.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax2.set_ylabel(ylabel2, fontsize=15, fontweight='bold')
ax22.set_ylabel(ylabel22, fontsize=15, fontweight='bold')

ax2.tick_params(axis='x', labelsize=14)
ax2.tick_params(axis='y', labelsize=14)
ax22.tick_params(axis='y', labelsize=14)

lns = lns1+lns2
labs = [l.get_label() for l in lns]
ax2.legend(lns, labs, loc='upper left', bbox_to_anchor=(0.1, 1), fontsize=12)
plt.savefig(savename2)
###########################################################################################################
fig, ax3 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
ax32 = ax3.twinx()
data3 = np.genfromtxt('./output/T_Young_modulus.dat')
data32 = np.genfromtxt('./GB_fraction.dat',comments='#')
savename3 = "young_modulus.png"
ylabel3 = 'Young modulus (GPa)'
ylabel32 = 'GB fraction (%)'

lns1 = ax3.plot(structure[:], data3[:,2], 'o-', color='tab:blue', label='Young modulus')
lns2 = ax32.plot(structure[:], data32[:,1], 'o-', color='tab:orange', label='GB fraction')

#x = [5.2, 10.0, 15.6, 20.1, 25.3, 27.9, 31.9]
#plt.plot(np.unique(x), np.poly1d(np.polyfit(x, data32[1:,1], 1))(np.unique(x)))

ax3.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax3.set_ylabel(ylabel3, fontsize=15, fontweight='bold')
ax32.set_ylabel(ylabel32, fontsize=15, fontweight='bold')

ax3.tick_params(axis='x', labelsize=14)
ax3.tick_params(axis='y', labelsize=14)
ax32.tick_params(axis='y', labelsize=14)

lns = lns1+lns2
labs = [l.get_label() for l in lns]
ax3.legend(lns, labs, loc='upper left', bbox_to_anchor=(0.1, 1), fontsize=12)
plt.savefig(savename3)
#########################################################################################################
data4 = np.genfromtxt('./output/T_Flow_stress.dat')
datad = []
datad = data2[:,2] - data4[:,1]
print(datad)

savename4 = "flow_stress.png"
ylabel4 = 'Flow stress (GPa)'
ylabel42 = 'Stress difference (GPa)'

fig, ax4 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
ax42 = ax4.twinx()

lns1 = ax4.plot(structure[:], data4[:,1], 'o-', label='Flow stress')
lns2 = ax42.plot(structure[:], datad[:], 'o-', color='tab:orange', label='Stress difference')
#ax42.axhline(y=datad[-1], xmin=0, xmax=1, linestyle = '--', color = 'r') #dash line

ax4.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax4.set_ylabel(ylabel4, fontsize=15, fontweight='bold')
ax42.set_ylabel(ylabel42, fontsize=15, fontweight='bold')

ax4.tick_params(axis='x', labelsize=14)
ax4.tick_params(axis='y', labelsize=14)
ax42.tick_params(axis='y', labelsize=14)

lns = lns1+lns2
labs = [l.get_label() for l in lns]
ax4.legend(lns, labs, loc='upper left', fontsize=12)#, bbox_to_anchor=(0.03, 0.95)
plt.savefig(savename4)
#########################################################################################################

plt.show()

# %%
