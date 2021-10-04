	subroutine DiffuseBeta(beta,long,latt,nlong,nlatt,Kxx,vxx,powvxx,contrast)
c**********************************************************************************************
c Subroutine to compute the 3D structure of a planet assuming diffusion of the beta parameter
c Dayside is located at		long = +/-pi
c Noghtside is located at	long = 0
c terminators are at 		long = +/-pi/2
c
c INPUT parameters:
c long(nlong):		Array containing the boundaries of the longitudinal cells
c latt(nlatt):		Array containing the boundaries of the latitudinal cells
c nlong:			Number of cell boundaries (note this is one more than the number of cells)
c nlatt:			Number of cell boundaries (note this is one more than the number of cells)
c Kxx:				Value for the dimensionless diffusion coefficient
c vxx:				Value for the dimensionless velocity
c NOTE: only the ratio vxx/Kxx is important for the outcome
c powvxx:			Value for the exponent of the latitudinal dependence of vxx
c contrast:			Required night to day contract of the atmosphere
c
c OUTPUT parameters:
c beta(nlong-1,nlatt-1):	beta values at the cell centers
	IMPLICIT NONE
	integer nlatt,nlong,NN
	integer,allocatable :: IWORK(:)
	integer i,info,j,NRHS,ii(nlong-1,nlatt-1)
	real*8 beta(nlong-1,nlatt-1),Kxx,vxx,long(nlong),latt(nlatt),S(nlong-1,nlatt-1)
	real*8 pi,tot,x((nlatt-1)*(nlong-1)),contrast,eps,powvxx
	parameter(eps=1d-4)
	real*8 la(nlatt-1),lo(nlong-1),tp,tm,tot1,tot2,cmax,cmin
	real*8,allocatable :: A(:,:)
	integer j0,jm,jp,k,niter,maxiter
	parameter(pi=3.1415926536)
	real*8 smax,smin,scale,betamin,betamax,contr

	do i=1,nlong-1
		lo(i)=(long(i)+long(i+1))/2d0
	enddo
	do j=1,nlatt-1
		la(j)=(latt(j)+latt(j+1))/2d0
	enddo
	k=0
	do i=1,nlong-1
		do j=1,nlatt-1
			k=k+1
			ii(i,j)=k
		enddo
	enddo
	if(contrast.le.0d0) then
		beta=0d0
		do i=1,nlong-1
			do j=1,nlatt-1
				if(abs(lo(i)).le.pi/2d0) beta(i,j)=abs(cos(lo(i))*cos(la(j)))
			enddo
		enddo
		return
	else if(contrast.ge.1d0.and.vxx.eq.0d0) then
		do i=1,nlong-1
			do j=1,nlatt-1
				beta(i,j)=0.25
			enddo
		enddo
		return
	endif

	allocate(IWORK(nlatt*nlong))
	allocate(A((nlatt-1)*(nlong-1),(nlatt-1)*(nlong-1)))

	smax=-sqrt(2.4)
	smin=-sqrt(3.2)
	scale=1d0
	
	contr=contrast*10d0
	maxiter=500
	niter=0
	do while(abs((contrast-contr)/(contrast+contr)).gt.eps.and.abs((smax-smin)/(smax+smin)).gt.eps.and.niter.lt.maxiter)

	niter=niter+1
	
	S=0d0
	A=0d0
	tot=0d0
	do i=1,nlong-1
		do j=1,nlatt-1
			if(abs(lo(i)).le.pi/2d0) S(i,j)=-cos(lo(i))*cos(la(j))
		enddo
	enddo
	do i=1,nlong-1
		do j=1,nlatt-1
			j0=ii(i,j)
			x(j0)=S(i,j)
			A(j0,j0)=A(j0,j0)-1d0
			if(i.gt.1) then
				jm=ii(i-1,j)
			else
				jm=ii(nlong-1,j)
			endif
			if(i.lt.nlong-1) then
				jp=ii(i+1,j)
			else
				jp=ii(1,j)
			endif
			A(j0,jm)=A(j0,jm)+0.5d0*vxx*scale*real(nlong)*cos(la(j))**(powvxx-1d0)
			A(j0,jp)=A(j0,jp)-0.5d0*vxx*scale*real(nlong)*cos(la(j))**(powvxx-1d0)
			A(j0,jm)=A(j0,jm)+Kxx*scale*(real(nlong)/cos(la(j)))**2
			A(j0,j0)=A(j0,j0)-2d0*Kxx*scale*(real(nlong)/cos(la(j)))**2
			A(j0,jp)=A(j0,jp)+Kxx*scale*(real(nlong)/cos(la(j)))**2

			if(j.gt.1) then
				jm=ii(i,j-1)
				tm=latt(j)
			else
				k=i+nlong/2
				if(k.gt.nlong-1) k=k-nlong+1
				jm=ii(k,1)
				tm=latt(1)
			endif
			if(j.lt.nlatt-1) then
				jp=ii(i,j+1)
				tp=latt(j+1)
			else
				k=i+nlong/2
				if(k.gt.nlong-1) k=k-nlong+1
				jp=ii(k,nlatt-1)
				tp=latt(nlatt)
			endif
			A(j0,jp)=A(j0,jp)+Kxx*scale*real(nlatt*2)**2*cos(tp)/cos(la(j))
			A(j0,jm)=A(j0,jm)+Kxx*scale*real(nlatt*2)**2*cos(tm)/cos(la(j))
			A(j0,j0)=A(j0,j0)-Kxx*scale*real(nlatt*2)**2*(cos(tp)+cos(tm))/cos(la(j))
		enddo
	enddo

	NRHS=1
	NN=(nlong-1)*(nlatt-1)
	call DGESV( NN, NRHS, A, NN, IWORK, x, NN, info )

	betamin=0d0
	betamax=0d0
	tot1=0d0
	tot2=0d0
	do i=1,nlong-1
		do j=1,nlatt-1
			j0=ii(i,j)
			beta(i,j)=x(j0)
			tot1=tot1+beta(i,j)*cos(la(j))
			tot2=tot2+cos(la(j))
			if(abs(lo(i)).le.pi/2d0) then
				betamax=betamax+beta(i,j)*abs(cos(la(j))*cos(lo(i)))
			else
				betamin=betamin+beta(i,j)*abs(cos(la(j))*cos(lo(i)))
			endif
		enddo
	enddo
	beta=beta*0.25*tot2/tot1
	contr=betamin/betamax

	print*,'iteration: ',niter,' contrast: ',contr

	if(contr.lt.contrast) then
		smin=scale
		cmin=contr
		if(smax.lt.0d0) then
			scale=scale*10d0
		else
			scale=scale+(smax-scale)*(contrast-contr)/(cmax-contr)
		endif
	else
		smax=scale
		cmax=contr
		if(smin.lt.0d0) then
			scale=scale/10d0
		else
			scale=scale+(smin-scale)*(contrast-contr)/(cmin-contr)
		endif
	endif
	enddo

	deallocate(IWORK)
	deallocate(A)
	
	return
	end
	
