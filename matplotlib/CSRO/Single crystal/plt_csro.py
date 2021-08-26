# %%
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np
import os.path

############------params-----##############
savename = "plt.png"
xlabel = 'Temperture (K)'
ylabel = 'The average CSRO square value'
labelfont = 'large'
legend_loc = 'upper left'
font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)
##########################################

colors=list(mcolors.CSS4_COLORS.keys())
element = ['Nb', 'Mo', 'W', 'Ta', 'V'] #type
pair_list = []
filenum = 34 #csro number

for i in range(len(element)):
    for j in range(len(element)):
        pair = element[i] + '-' + element[j]
        pair_list.append(pair)

x = []
for i in range(filenum):
    temp = 300 + i*100
    x.append(temp)
    filename = './dat/CSRO_' + str(temp) + '.dat'
    data = np.genfromtxt(filename, delimiter=':')
    if(i == 0):
        all_list = np.zeros((1, len(pair_list)))
    all_list = np.vstack([all_list,data[:,1]])
#print(all_list.shape)
#print(all_list[1:,0]) #temp, pair

fig, ax1 = plt.subplots(tight_layout=True, figsize=(8, 6), dpi=150)
#x = list(range(filenum))
csro_list = np.zeros((2, filenum))

for i in range(filenum):
    n = i + 1
    for j in range(len(pair_list)):
        if (j % (len(element)+1) == 0):
            csro_list[0,i] = csro_list[0,i] + (all_list[n,j]**2)/5
        else:
            csro_list[1,i] = csro_list[1,i] + (all_list[n,j]**2)/20
       
lns1 = ax1.plot(x,csro_list[0,:],label='Same element type pair')
lns2 = ax1.plot(x,csro_list[1,:],label='Different element type pair')

Tm_index = np.argmin(csro_list[0,:])
print(x[Tm_index])

#ymin, ymax = ax1.get_ylim()
#yd = ymax-ymin
#temp = [310,860,1500,2530,2920]
#h = [0.25,0.81]
#offset = [0.02, 0.01, 0.1, -0.1, 0.1, 0.1]
#position = ['right','right','left','left','right','center']
#s = ['(I)', '(II)', '(III)', '(IV)', '(V)', '(VI)']
#c=0
#for i in temp:
#    n = x.index(i)
#    ax1.scatter(x[n],csro_list[0,n],color='k',marker='o', linewidths=2)
#    plt.axvline(x=i, ymin=0, ymax=h[c], linestyle = '--', color = 'k') #dash line
#    ax1.text(i, csro_list[0,n]+offset[c], s=s[c], horizontalalignment=position[c], fontsize=20)
#    c += 1

ax1.set_xlabel(xlabel, fontsize=15, fontweight='bold')
ax1.set_ylabel(ylabel, fontsize=15, fontweight='bold')
ax1.legend(loc=legend_loc, fontsize=12)

plt.tick_params(axis='x', labelsize=14)
plt.tick_params(axis='y', labelsize=14)

plt.savefig(savename)
plt.show()

# %%
