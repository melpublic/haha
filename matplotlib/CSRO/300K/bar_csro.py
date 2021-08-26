# %%
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import os.path

############------params-----##############
temp = 300
dat = ['Single crystal','25.3 nm','5.2 nm']
fs = 15 #fontsize=fs
savename = "CSRO.png"
xlabel = 'Pair'
ylabel = 'CSRO'
legend_title = str(temp) + ' K'
legend_loc = 'upper right'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

colors=list(mcolors.CSS4_COLORS.keys())
element = ['Nb', 'Mo', 'W', 'Ta', 'V']
pair_list = []

for i in range(len(element)):
    for j in range(len(element)):
        pair = element[i] + '-' + element[j]
        pair_list.append(pair)

fig, ax1 = plt.subplots(tight_layout=True, figsize=(16, 6), dpi=150)
ax1.axhline(y=0,color='k')
#ax1.grid(axis='y')

x = np.arange(len(pair_list))
offset = 0.25

for i in range(len(dat)):
    filename = dat[i] + '.dat'
    data = np.genfromtxt(filename, delimiter=':')
    barx = x+offset*i
    #print(len(temp))
    lns1 = ax1.bar(barx, data[:,1], width=offset, label=str(dat[i]))

ax1.set_xticks(x)
ax1.set_xticklabels(pair_list)
#ax1.set_ylim(ymax=1)

plt.xlabel(xlabel, fontsize=15, fontweight='bold')
plt.ylabel(ylabel, fontsize=15, fontweight='bold')
plt.tick_params(axis='x', labelsize=12)
plt.tick_params(axis='y', labelsize=14)

ax1.legend(title=legend_title,loc=legend_loc, bbox_to_anchor=(0.9, 1), fontsize=12)
plt.savefig(savename)
plt.show()

# %%
