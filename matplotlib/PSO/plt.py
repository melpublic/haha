#%%
import matplotlib.pyplot as plt
import numpy as np

font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)

savename = "pso.png"
legend_label1 = 'B2 crystal'
legend_label2 = 'B2 void'
legend_label3 = 'B2 HEA'
legend_label4 = 'B2 MD'
legend_label5 = 'L12 MD'
legend_label6 = 'HEA MD'
legend_label7 = 'B2 surface'
legend_label8 = 'B2 GSFE'
legend_loc = 'upper left'

data=np.genfromtxt("./00BestFittedComparision.dat",comments='pxx') #忽略pxx開頭

# modify------------------------------------------------------------------------
crystalx=data[10:220,2] 
crystaly=data[10:220,4]

voidx=data[220:250,2] 
voidy=data[220:250,4] 

surfacex=data[250:580,2] 
surfacey=data[250:580,4]

HEAx=data[580:584,2] 
HEAy=data[580:584,4]

mdx=data[584:1184,2] 
mdy=data[584:1184,4]

l12mdx=data[1184:1584,2] 
l12mdy=data[1184:1584,4] 

HEAmdx=data[1584:1744,2] 
HEAmdy=data[1584:1744,4]

gsfex=data[1744:,2] 
gsfey=data[1744:,4]
#print(gsfex)
#-------------------------------------------------------------------------------

plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)

# modify------------------------------------------------------------------------
plt.scatter(crystalx,crystaly, c='b',           marker='o', label=legend_label1)
plt.scatter(voidx,voidy,       c='g',           marker='v', label=legend_label2)
plt.scatter(HEAx,HEAy,         c='c',           marker='p', label=legend_label3)
plt.scatter(mdx,mdy,           c='m',           marker='h', label=legend_label4)
plt.scatter(l12mdx,l12mdy,     c='deepskyblue', marker='1', label=legend_label5)
plt.scatter(HEAmdx,HEAmdy,     c='orange',      marker='*', label=legend_label6)
plt.scatter(surfacex,surfacey, c='r',           marker='s', label=legend_label7)
plt.scatter(gsfex,gsfey,       c='lime',        marker='x', label=legend_label8)
#-------------------------------------------------------------------------------

plt.xlabel('DFT (eV/atom)' , {'fontsize':15}, fontweight='bold')
plt.ylabel('MEAM (eV/atom)', {'fontsize':15}, fontweight='bold')

plt.tick_params(axis='x', labelsize=14)
plt.tick_params(axis='y', labelsize=14)

left,right = plt.xlim()
plt.plot(plt.xlim(),plt.xlim(),color='black') #45度線

plt.legend(fontsize=10)

plt.savefig(savename)
plt.show()
# %%
