# %%
import math

import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import MaxNLocator
from numpy import poly1d, polyfit

font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)

structure = ['5.2', '10.0', '15.6', '20.1', '', '27.9', '', '36.2', 'inf']
gs = [5.2, 10.0, 15.6, 20.1, 25.3, 27.9, 31.9, 36.2, float('inf')]
xlabel = 'grain size (nm)'
###########################################################################################################
data1 = np.genfromtxt('./T_Yield_strengths.dat')

#########################################################################################################
fig, ax5 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)

savename5 = "hall-petch.png"
xlabel5 = 'Grain size D$^{-1/2}$ (nm$^{-1/2}$)'
ylabel5 = 'Yield stress (GPa)'

mgs = []
for i in gs:
    print(i,math.sqrt(1/i))
    mgs.append(math.sqrt(1/i))

lns1 = ax5.scatter(mgs[:], data1[:,2])
ys = data1[:,2]
ys = ys.tolist()
print(mgs[-4:])
print(data1[-4:,2])
#print(ys.index(max(ys)))

#hall-petch
plt.plot(np.unique(mgs[-4:]), np.poly1d(np.polyfit(mgs[-4:], data1[-4:,2], 1))(np.unique(mgs[-4:])), color='tab:green', label='hall-petch')
coeff = polyfit(mgs[-4:], data1[-4:,2], 1)
print('hall-petch','σy = %.2f + (%.2f)*d^(-1/2)' % (coeff[1],coeff[0]))

#inverse hall-petch
plt.plot(np.unique(mgs[:-3]), np.poly1d(np.polyfit(mgs[:-3], data1[:-3,2], 1))(np.unique(mgs[:-3])), color='tab:orange', label='inverse hall-petch')
coeff = polyfit(mgs[:-3], data1[:-3,2], 1)
print('inverse hall-petch','σy = %.2f + (%.2f)*d^(-1/2)' % (coeff[1],coeff[0]))

#dash line
ax5.axvline(x=mgs[ys.index(max(ys))], ymin=0, ymax=1, linestyle = '--', color = 'k')

ax2 = ax5.twiny()
lns1 = ax2.scatter(mgs[:], data1[:,2])
plt.xticks(mgs[:],structure, rotation=30)
ax2.set_xlabel('Grain size (nm)', fontsize=15, fontweight='bold')

ax5.set_xlabel(xlabel5, fontsize=15, fontweight='bold')
ax5.set_ylabel(ylabel5, fontsize=15, fontweight='bold')

ax5.tick_params(axis='x', labelsize=14)
ax5.tick_params(axis='y', labelsize=14)

ax5.legend(loc='upper right', fontsize=12)

########################################################################################################
#fig = plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)
#ax1 = fig.add_subplot(131)

#下標效果
#plt.xlabel('RR$_{n}$ (ms)', fontsize=20)

#上標效果
#plt.ylabel('RR$^{n+1}$ (ms)', fontsize=20)

#ax5.set_xlim(0.15, 0.45)
plt.savefig(savename5)
plt.show()

# %%
