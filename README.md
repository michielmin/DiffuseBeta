# DiffuseBeta
Program to compute an simple estimate of the energy transport on a planet

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


