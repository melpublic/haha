#%%
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats
from matplotlib.pyplot import MultipleLocator

############------input-----##############
filename = "HEA2_SS.png" #check-------------------
xlabel = 'Strain'
ylabel = 'Stress (GPa)'
y2label = 'Fraction (%)'
labelfont = 12
legend_loc = 'upper left'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

def SS(strain,stress):
    n = 0
    num = 0
    Ustress = 0
    Ustrain = 0
    xValues = []
    yValues = []
    for i in strain:
        #print(strain[n],stress[n], file = modified_SS)
        if i <= 0.02:
            #print (i,stress[n]) 
            xValues.append(i)
            yValues.append(stress[n])
        if stress[n] > Ustress:
            Ustress = stress[n]
            Ustrain = i*100
        n = n +1
    slope, intercept, r_value, p_value, std_err = stats.linregress(xValues, yValues)
    return slope, Ustress, Ustrain

data1 = np.loadtxt("HEA2_modified_SS.dat") #check-------------------
strain = data1[:,0]
stress = data1[:,1]
slope, Ustress, Ustrain = SS(strain,stress)
#print(slope, Ustress, Ustrain)
print('%s Ym: %.2f ' % ('HEA',slope))
print('%s Ustress: %.2f Ustrain: %.2f' % ('HEA', Ustress, Ustrain))

fig = plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)
ax1 = fig.add_subplot(111)

lns = ax1.plot(strain, stress, '-',label='HEA-2') #check-------------------

#yield strength-----------------------------------------------------------------------------------------------------------
abline_values = [slope * (j - 0.002) for j in strain]
#lnsa1 = ax1.plot(strain[:80], abline_values[:80], 'r-')

#print(strain[10], abline_values[10])
y=stress[:80]-abline_values[:80] #!!!
nLen=len(strain[:80])
xzero=np.zeros((nLen,))
yzero=np.zeros((nLen,))
for j in range(nLen-1):
    if np.dot(y[j], y[j+1]) == 0:#   等於0的情況
        if y[j]==0:
            xzero[j]=j
            yzero[j]=0
        if y[j+1] == 0:
            xzero[j+1]=j+1
            yzero[j+1]=0
    elif np.dot(y[j],y[j+1]) < 0:# 一定有交點，用一次插值
        yzero[j] = np.dot(abs(y[j]) * abline_values[j+1] + abs(y[j+1])*abline_values[j], 1/(abs(y[j+1])+abs(y[j])))
        xzero[j] = strain[10] + ((yzero[j]-abline_values[10])/slope) #modifiy
    else:
        pass           
for j in range(nLen):
    if xzero[j]==0 and (yzero[j]==0):# 除掉不是交點的部分
        xzero[j]=0
        yzero[j]=0
#print(np.max(xzero))
#print(np.max(yzero))
ystrain = np.max(xzero)*100
print('%s Ystress: %.2f Ystrain: %.2f' % ('HEA',np.max(yzero),ystrain))
#-----------------------------------------------------------------------------------------------------------------------

ax1.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax1.set_ylabel(ylabel, fontsize=15, fontweight='bold')

plt.tick_params(axis='x', labelsize=14)
plt.tick_params(axis='y', labelsize=14)

fig.legend(loc=1, bbox_to_anchor=(1,1), bbox_transform=ax1.transAxes,fontsize=12)

plt.savefig(filename)
plt.show()
# %%
