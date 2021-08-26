# %%
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import os.path

############------params-----##############
temp1 = 300  #initial temperature
temp2 = 3100 #end temperature
savename = "CSRO_diff.png"
xlabel = 'Pair'
ylabel = 'CSRO difference'
legend_title = 'HEA-Single crystal'
legend_loc = 'lower right'
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
offset = 0.3

filename1 = './dat/CSRO_' + str(temp1) + '.dat' #initial temperature filename
filename2 = './dat/CSRO_' + str(temp2) + '.dat' #end temperature filename
data1 = np.genfromtxt(filename1, delimiter=':') 
data2 = np.genfromtxt(filename2, delimiter=':') 
data = data2 - data1
barx = x
lns1 = ax1.bar(barx, data[:,1], width=offset)

ax1.set_xticks(x)
ax1.set_xticklabels(pair_list)
plt.xlabel(xlabel, fontsize=15, fontweight='bold')
plt.ylabel(ylabel, fontsize=15, fontweight='bold')
plt.tick_params(axis='x', labelsize=12)
plt.tick_params(axis='y', labelsize=14)
#ax1.set_ylim(ymax=1)

plt.savefig(savename)
plt.show()

# %%
