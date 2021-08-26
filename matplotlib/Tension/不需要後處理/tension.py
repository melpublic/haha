#%%
import math
import os
from collections import Counter

import matplotlib.animation as animation
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.animation import FFMpegWriter
from scipy import stats

############------input-----##############
savename = "HEA_SS.png"
xlabel = 'Strain'
y1label = 'Stress (GPa)'
frequency = 10
lw = 1.5
ms = 8
labelfont = 'large'
legend_loc = 'upper left'
structure = ['5.2nm', '10.0nm', '15.6nm', '20.1nm', '25.3nm', '27.9nm']#
mark = ['o', 'v', '1', 's', '*', 'x', 'd', 'p', 'h', 'h']
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
path = './output'
if not os.path.isdir(path):
    os.mkdir(path)
##########################################

def SS(filename,Init_stress):
    data = np.genfromtxt(filename)
    negleng = data[0,1]
    negstress = data[0,-1]
    posleng = data[1,1]
    posstress = data[1,-1]
    reflen = negleng+(posleng-negleng)*abs(negstress)/(abs(negstress)+posstress)

    stress = data[:,-1]
    lz = data[:,1]
    stress[0] = 0
    lz[0] = 0
    strain = (lz/reflen)-1.0
    strain[0] = 0
    #print (strain)
    #modified_SS = open(mSSname, mode='w')

    n = 0
    num = 0
    total = 0
    Ustress = 0
    Ustrain = 0

    xValues = []
    yValues = []
    for i in strain:
        #print(strain[n],stress[n], file = modified_SS)
        if n >= Init_stress:
            total = total + stress[n]
            num = num + 1

        if i <= 0.02:
            #print (i,stress[n]) 
            xValues.append(i)
            yValues.append(stress[n])

        if stress[n] > Ustress:
            Ustress = stress[n]
            Ustrain = i*100
        n = n +1
    
    flowStress = total/num
    #print (xValues,yValues)
    #modified_SS.close()

    slope, intercept, r_value, p_value, std_err = stats.linregress(xValues, yValues)
    #print("slope: %f    intercept: %f" % (slope, intercept)) #Young_modulus
    return strain, stress, slope, flowStress, Ustress, Ustrain

fig = plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)
ax1 = fig.add_subplot(111)

Ym = open("./output/T_Young_modulus.dat", mode='w')
Ys = open("./output/T_Yield_strengths.dat", mode='w')
Fs = open("./output/T_Flow_stress.dat", mode='w')
Uss = open("./output/T_ultimate_ss.dat", mode='w')

for i in range(len(structure)):
    filename = './input/' + str(structure[i]) + '_Strain_Stress.dat' # Strain Stress filename
    legend_label = structure[i]

    strain, stress, slope, flowStress, Ustress, Ustrain = SS(filename,Init_stress=150) # Init_stress -> Initial flow stress

    lns = ax1.plot(strain, stress, '-', marker=mark[i], label=legend_label, markevery=frequency, linewidth=lw, markersize=ms)
    print('%s Ym: %.2f ' % (str(structure[i]),slope), file = Ym)
    print(str(structure[i]),flowStress, file = Fs)
    print('%s Ustress: %.2f Ustrain: %.2f' % (str(structure[i]), Ustress, Ustrain), file = Uss)

    # yield_strengths--------------------------------------------------------------------------------------------------------
    abline_values = [slope * (j - 0.002) for j in strain] # offset
    #lnsa1 = ax1.plot(strain[:80], abline_values[:80], 'r-')
    #print(strain[10], abline_values[10])

    y=stress[:80]-abline_values[:80] #!!!
    nLen=len(strain[:80])
    xzero=np.zeros((nLen,))
    yzero=np.zeros((nLen,))
    for j in range(nLen-1):
        if np.dot(y[j], y[j+1]) == 0:# 等於0的情況
            if y[j]==0:
                xzero[j]=j
                yzero[j]=0
            if y[j+1] == 0:
                xzero[j+1]=j+1
                yzero[j+1]=0
        elif np.dot(y[j],y[j+1]) < 0:# 有交點 用一次插值
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
    print('%s Ystress: %.2f Ystrain: %.2f' % (str(structure[i]),np.max(yzero),ystrain), file = Ys)
    #-------------------------------------------------------------------------------------------------------------------------

Ym.close()
Ys.close()
Fs.close()

ax1.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax1.set_ylabel(y1label, fontsize=15, fontweight='bold')

ax1.tick_params(axis='x', labelsize=14)
ax1.tick_params(axis='y', labelsize=14)

ax1.set_xlim(0, 0.2)
ax1.set_ylim(0, 12)
ax1.legend(loc=legend_loc, fontsize=10)

plt.savefig(savename)
plt.show()

# %%
