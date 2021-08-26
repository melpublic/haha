# %%
import matplotlib.pyplot as plt
#from brokenaxes import brokenaxes
#from matplotlib.gridspec import GridSpec
import numpy as np
#from scipy import stats

############------input-----##############
savename = "DandE.png"
xlabel = 'Temperature (K)'
y1label = 'Density'# SD (Å)
y2label = 'Enthalpy (eV/atom)'
frequency = 5
lw = 1.5
ms = 8
fontsize = 12 #fontsize=fontsize fontweight='bold'
structure = ['HEA','Nb', 'Mo', 'W', 'Ta', 'V']#
legend_loc = 'upper left'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

fig, ax1 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)

Enthalpy_data = np.genfromtxt("./Enthalpy_Temperature.dat")

lns1 = ax1.plot(Enthalpy_data[:,1], Enthalpy_data[:,-1], 'o-', color = 'blue', markevery=frequency, linewidth=lw, markersize=ms, label='Density')
Tm1=26
Tm2=55
ax1.plot(np.unique(Enthalpy_data[:Tm1,1]), np.poly1d(np.polyfit(Enthalpy_data[:Tm1,1], Enthalpy_data[:Tm1,-1], 1))(np.unique(Enthalpy_data[:Tm1,1])), color='tab:green')
ax1.plot(np.unique(Enthalpy_data[Tm1-1:Tm2+1,1]), np.poly1d(np.polyfit(Enthalpy_data[Tm1-1:Tm2+1,1], Enthalpy_data[Tm1-1:Tm2+1,-1], 1))(np.unique(Enthalpy_data[Tm1-1:Tm2+1,1])), color='tab:red')
ax1.plot(np.unique(Enthalpy_data[Tm2:,1]), np.poly1d(np.polyfit(Enthalpy_data[Tm2:,1], Enthalpy_data[Tm2:,-1], 1))(np.unique(Enthalpy_data[Tm2:,1])), color='tab:green')

ax2 = ax1.twinx() #sencond y axis
lns2 = ax2.plot(Enthalpy_data[:,1], Enthalpy_data[:,5], 'o-', color = 'orange', markevery=frequency, linewidth=lw, markersize=ms, label='Enthalpy')

plt.axvline(x=Enthalpy_data[Tm1-1,1], ymin=0, ymax=1, linestyle = '--', color = 'k') #dash line
plt.axvline(x=Enthalpy_data[Tm2,1], ymin=0, ymax=1, linestyle = '--', color = 'k') #dash line
plt.axvline(x=2900, ymin=0, ymax=1, linestyle = '--', color = 'k') #dash line
print(Enthalpy_data[Tm1-1,1],Enthalpy_data[Tm2,1])

ymin, ymax = ax1.get_ylim()
yd = ymax + ymin
ax1.annotate('', (Enthalpy_data[Tm1-1,1],yd/2), xytext=(-45, 0),textcoords='offset points', arrowprops=dict(facecolor='black', arrowstyle='<|-'))
ax1.text(2170,11.09,str(int(Enthalpy_data[Tm1-1,1]))+'K',fontsize=15)

ax1.annotate('', (Enthalpy_data[Tm2,1],yd/2), xytext=(75, 0),textcoords='offset points', arrowprops=dict(facecolor='black', arrowstyle='<|-'))
ax1.text(3390,11.09,str(int(Enthalpy_data[Tm2,1]))+'K',fontsize=15)

ax1.annotate('', (2900,11.5), xytext=(-45, 0),textcoords='offset points', arrowprops=dict(facecolor='black', arrowstyle='<|-'))
ax1.text(2570,11.49,'2900K',fontsize=15)

ax1.set_xlabel(xlabel,fontsize=15, fontweight='bold')
ax1.set_ylabel(y1label,fontsize=15, fontweight='bold')
ax2.set_ylabel(y2label,fontsize=15, fontweight='bold')

ax1.tick_params(axis='x', labelsize=14)
ax1.tick_params(axis='y', labelsize=14)
ax2.tick_params(axis='y', labelsize=14)

lns = lns1+lns2
labs = [l.get_label() for l in lns]
ax1.legend(lns, labs, loc='upper right', bbox_to_anchor=(1, 0.75), fontsize=12)

plt.savefig(savename)
plt.show()
# %%
