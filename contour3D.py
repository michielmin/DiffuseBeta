import matplotlib
import numpy as np
import matplotlib.cm as cm
import matplotlib.pyplot as plt
import sys

with open("structure3D.dat") as file:
    data = [[float(digit) for digit in line.split()] for line in file]

nx=len(data[0][:])
ny=len(data[:])

print(nx)
print(ny)

x=np.arange(-180, 180.0, (360.0+360.0/float(nx))/float(nx))
y=np.arange(-90, 90.0, (180.0+180.0/float(ny))/float(ny))

fig, ax = plt.subplots()
ax.set_aspect(1.0)
#CS = ax.contourf(x, y, data, 100,cmap='coolwarm',levels=[0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0])
CS = ax.contourf(x, y, data, 100,cmap='coolwarm')
CS = ax.contour(x, y, data, colors='k')
ax.clabel(CS, inline=1, fontsize=10)
ax.set_xlabel('longitude')
ax.set_ylabel('lattitude')

ax.axvline(90., color='blue')
ax.axvline(-90., color='blue')
ax.axvline(0., color='red')

fig.savefig("Structure3D.pdf")
