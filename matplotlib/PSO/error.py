#%%
import matplotlib.pyplot as plt
import numpy as np

font = {'family': 'serif',
        'serif': 'Times New Roman',
        'weight': 'normal',
        'size': 10}
plt.rc('font', **font)

savename = "pso_bar.png"

data=np.genfromtxt("./00BestFittedComparision.dat",comments='pxx') #忽略pxx開頭
data[10:,6].sort() #need to check
print(data[10:,6])

p0 = 0
p2 = p3 = p4 = p5 = p6 = p7 = p8 = p9 = p10 = p11 = 0
n2 = n3 = n4 = n5 = n6 = n7 = n8 = n9 = n10 = n11 = 0
counter = 0
for i in data[10:,6]:
    #print(i)
    if 1 > i > -1:
        p0 += 1
        counter += 1
    
    elif 2 > i > 1:
        p2 += 1
        counter += 1
    elif 3 > i > 2:
        p3 += 1
        counter += 1
    elif 4 > i > 3:
        p4 += 1
        counter += 1
    elif 5 > i > 4:
        p5 += 1
        counter += 1

    elif 6 > i > 5:
        p6 += 1
    elif 7 > i > 6:
        p7 += 1
    elif 8 > i > 7:
        p8 += 1
    elif 9 > i > 8:
        p9 += 1
    elif 10 > i > 9:
        p10 += 1
    elif i > 10:
        p11 += 1

    elif -2 < i < -1:
        n2 += 1
        counter += 1
    elif -3 < i < -2:
        n3 += 1
        counter += 1
    elif -4 < i < -3:
        n4 += 1
        counter += 1
    elif -5 < i < -4:
        n5 += 1
        counter += 1

    elif -6 < i < -5:
        n6 += 1
    elif -7 < i < -6:
        n7 += 1
    elif -8 < i < -7:
        n8 += 1
    elif -9 < i < -8:
        n9 += 1
    elif -10 < i < -9:
        n10 += 1
    elif i < -10:
        n11 += 1

err_list = (n11, n10, n9, n8, n7, n6, n5, n4, n3, n2, p0, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
num = n2+n3+n4+n5+n6+n7+n8+n9+n10+n11+p0+p2+p3+p4+p5+p6+p7+p8+p9+p10+p11
#print(n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, p0, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11)
#print(n6, n7, n8, n9, n10, n11, p6, p7, p8, p9, p10, p11)
#print(num)
#print(counter)

index1 = list(range(0, -11, -1))
index2 = list(range(1,11))
index1.extend(index2)
index1.sort()
#print(index1)

plt.figure(tight_layout=True, figsize=(8, 6), dpi=150)
plt.bar(index1,err_list, .5)
plt.xlabel('Energy error (%)', fontsize=15, fontweight='bold')
plt.ylabel('Proportion', fontsize=15, fontweight='bold')
plt.tick_params(axis='x', labelsize=14)
plt.tick_params(axis='y', labelsize=14)

plt.savefig(savename)
plt.show()
# %%
