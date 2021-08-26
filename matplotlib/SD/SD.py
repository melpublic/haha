# %%
import matplotlib.pyplot as plt
from brokenaxes import brokenaxes
from matplotlib.gridspec import GridSpec
import numpy as np

############------input-----##############
savename = "SD.png"
xlabel = 'Temperature (K)'
y1label = 'SD (Å$^{2}$)'
y2label = 'Enthalpy (eV/atom)'
frequency = 20
lw = 1.5
ms = 8
fontsize = 12 #fontsize=fontsize fontweight='bold'
structure = ['System','Nb', 'Mo', 'W', 'Ta', 'V']#
legend_loc = 'upper left'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

fig, ax1 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)

Enthalpy_data = np.genfromtxt("./Enthalpy_Temperature.dat")
for i in range(len(structure)):
        filename = './fortran4msd_' + str(i) + '.dat'
        sd_data = np.loadtxt(filename)
        lns1 = ax1.plot(Enthalpy_data[:,1], sd_data[:,1], '-', label=structure[i], markevery=frequency, linewidth=lw, markersize=ms)

ax2 = ax1.twinx() #sencond y axis
lns6 = ax2.plot(Enthalpy_data[:,1], Enthalpy_data[:,5], '-', color = 'orange', markevery=frequency, linewidth=lw, markersize=ms)

#Turning point
delta = []
sd_data = np.loadtxt('./fortran4msd_0.dat')
for i in range(len(sd_data[1:,0])-1):
    if(i != 0):
        delta.append((sd_data[i+1,1] - sd_data[i,1])/sd_data[i+1,1])
    
#print(delta[:])
tp_index = np.argmax(delta[:])
Tm = 2940#int(Enthalpy_data[tp_index,1]) #need to check
print(Tm)

ymin, ymax = ax1.get_ylim()
plt.axvline(x=Tm, ymin=0, ymax=1, linestyle = '--', color = 'k') #dash line
ax1.annotate(str(Tm)+'K', (Tm,ymax/2), xytext=(-75, -2),textcoords='offset points', arrowprops=dict(facecolor='black', arrowstyle='<|-'),fontsize = 15)

#軸設定
#ax1.set_xlim(300, 2500)
#ax1.set_ylim(-0.5, 4.5)
ax1.set_xlabel(xlabel,fontsize=15, fontweight='bold')
ax1.set_ylabel(y1label,fontsize=15, fontweight='bold')
ax2.set_ylabel(y2label,fontsize=15, fontweight='bold')

ax1.tick_params(axis='x', labelsize=14)
ax1.tick_params(axis='y', labelsize=14)
ax2.tick_params(axis='y', labelsize=14)

ax1.legend(loc=legend_loc, fontsize=12)

plt.savefig(savename)
plt.show()
# %%
