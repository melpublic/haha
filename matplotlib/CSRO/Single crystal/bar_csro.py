# %%
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import os.path

############------params-----##############
temp = [300,2500,2700,2900,3100] #temperature
savename = "CSRO.png"
xlabel = 'Pair'
ylabel = 'CSRO'
legend_title = 'HEA-Single crystal'
legend_loc = 'lower left'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

colors=list(mcolors.CSS4_COLORS.keys())
element = ['Nb', 'Mo', 'W', 'Ta', 'V'] #type
pair_list = []

for i in range(len(element)):
    for j in range(len(element)):
        pair = element[i] + '-' + element[j]
        pair_list.append(pair)

fig, ax1 = plt.subplots(tight_layout=True, figsize=(16, 6), dpi=150)
ax1.axhline(y=0,color='k')

x = np.arange(len(pair_list))
offset = 0.15 #need to check
tempindex = [-2, -1, 0, 1, 2] #need to check

for i in range(len(temp)):
    filename = './dat/CSRO_' + str(temp[i]) + '.dat' #csro file name
    data = np.genfromtxt(filename, delimiter=':')
    barx = x+offset*tempindex[i]
    #print(len(temp))
    lns1 = ax1.bar(barx, data[:,1], width=offset, label=str(temp[i])+'K')

ax1.set_xticks(x)
ax1.set_xticklabels(pair_list)
plt.xlabel(xlabel, fontsize=15, fontweight='bold')
plt.ylabel(ylabel, fontsize=15, fontweight='bold')
plt.tick_params(axis='x', labelsize=12)
plt.tick_params(axis='y', labelsize=14)

#ax1.set_ylim(ymax=1)

ax1.legend(title=legend_title,loc=legend_loc, fontsize=12)
plt.savefig(savename)
plt.show()

# %%
