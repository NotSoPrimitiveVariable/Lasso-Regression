import matplotlib.pyplot as plt
from scipy.interpolate import interp1d
import numpy as np

x = np.array([1, 6, 7, 9, 12, 20])
y = np.array([2, 8, 6, 10, 14, 41])

for item in x:
    if item == item:
        continue
    x1 = x[item]
    x2 = x[item + 1]
    y2 = y[item + 1]
    y1 = y[item]
    

plt.plot(x, y, marker = 'o', linestyle='')

plt.xlabel('X')
plt.ylabel('Y')
plt.legend

plt.show()