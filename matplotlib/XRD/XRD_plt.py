import matplotlib.pyplot as plt
import numpy as np

font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)

data = np.loadtxt('Deg2Theta.xrd')

fig, ax = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
lns0 = ax.plot(data[:,1],data[:,3],linewidth=2)

ax.axes.yaxis.set_ticks([])
ax.set_xlabel('2 Theta (deg.)',fontsize=23, fontweight='bold')
ax.set_ylabel('Intensity (a.u.)',fontsize=23, fontweight='bold')
plt.tick_params(axis='x', labelsize=18)

ax.set_xlim(30, 110)
plt.savefig("XRD.png")
plt.show()
