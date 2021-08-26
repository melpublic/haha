import matplotlib.pyplot as plt
import numpy as np
import warnings; warnings.filterwarnings(action='once')
#import mplcursors mplcursors.cursor(lns1)

############------params-----##############
savename = "RDF.png"
xlabel = 'r (Å)'
ylabel = 'g (r)'
labelfont = 'large'
legend_loc = 'upper left'
structure = ['BCC-Mo','RHEA']
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################
fig = plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)
ax1 = fig.add_subplot(111)

for i in range(len(structure)):
    filename = './' + str(structure[i]) + 'RDF.dat'
    data = np.loadtxt(filename)

    x = data[:,0]
    y = data[:,1]
    legend_label = structure[i]
    lns1 = ax1.plot(x, y, '-', label=legend_label,linewidth='2')

ax1.set_xlabel(xlabel,fontsize=15, fontweight='bold')
ax1.set_ylabel(ylabel,fontsize=15, fontweight='bold')

ax1.tick_params(axis='x', labelsize=14)
ax1.tick_params(axis='y', labelsize=14)

ax1.legend(loc = legend_loc, fontsize=16)

ax1.set_xlim(0, 7)
plt.savefig(savename)
plt.show()