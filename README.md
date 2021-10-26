# DiffuseBeta
Program to compute a simple estimate of the energy transport on a planet

The DiffuseBeta code is constructed to provide an analytic estimate of the distribution
of energy around a planet using the setup described in Chubb et al. 2021

The files contained in this distribution are:

DiffuseBeta.f
This is the file containing the main subroutine. Described in the file are the in and outputs.

Main.f
This is an example on how to run the code using a given set of parameters.

Lapack.f
This contains the subroutines from the Lapack library that are used to solve the diffusion equation.

contour3D.py
A python program that can be used to create a plot from the output of Main.f.

Makefile
A makefile that compiles Main.f DiffuseBeta.f and Lapack.f into an executable.

=====================================================================================

The main parameters to vary in Main.f:

nlong, nlatt = number of longitude and lattitide points, respectively
Kxx = horizontal diffusion parameter (K_Lambda,Phi in Chubb et al. 2021)
vxx = parameter for equatorial wind speed (V_Lambda in Chubb et al. 2021)
powvxx = Exponent determining the latitudinal extent of equatorial winds (n_phi in Chubb et al. 2021)
night2day = Heat redistribution factor. Integrated energy on nightside divided by integrated energy on the dayside (f_red in Chubb et al. 2021)

=====================================================================================

