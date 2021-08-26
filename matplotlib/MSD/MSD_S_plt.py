#%%
import matplotlib.pyplot as plt
import numpy as np

############------input-----##############
savename = "MSD.png"

xlabel = 'Time (ps)'
ylabel = 'MSD (Å$^{2}$)'

temp = [2600, 2700, 2800, 2900, 3100, 3200, 3300, 3400]#
mark = ['o', 'v', '1', 's', '*', 'x', 'd', 'p', 'h', 'h']
Tm = 3100

legend_title = 'HEA-1'
legend_loc = 'upper left'
frequency = 50
lw = 1.5
ms = 6
##########################################

fig = plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)
ax1 = fig.add_subplot(111)

for i in range(len(temp)):
    filename = 'fortran4msd_' + str(temp[i]) + '.dat' 
    data = np.loadtxt(filename)

    labelname = str(temp[i]) + ' K'
    lns = ax1.plot(data[:,0],data[:,1],'-',label=labelname ,marker=mark[i], markevery=frequency, linewidth=lw, markersize=ms)

left, bottom, width, height = 0.3, 0.7, 0.25, 0.25
ax2 = fig.add_axes([left, bottom, width, height])

for i in range(len(temp)):
    if temp[i] < Tm:
        filename = 'fortran4msd_' + str(temp[i]) + '.dat' 
        data = np.loadtxt(filename)
        labelname = str(temp[i]) + ' K'
        ax2.plot(data[:,0],data[:,1],'-',label=labelname ,marker=mark[i],markevery=frequency, linewidth=lw, markersize=ms)

#軸設定
ax1.set_xlabel(xlabel,fontsize=15, fontweight='bold')
ax1.set_ylabel(ylabel,fontsize=15, fontweight='bold')
ax2.set_xlabel(xlabel,fontsize=6, fontweight='bold')
ax2.set_ylabel(ylabel,fontsize=6, fontweight='bold')

plt.xticks(np.linspace(0,500,6))
plt.xticks(fontsize=6)
plt.yticks(fontsize=6)

#legend
ax1.legend(title = legend_title)

plt.savefig(savename)
plt.show()
# %%
