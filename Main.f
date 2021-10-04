	program Example
	IMPLICIT NONE
	integer nlong,nlatt,i,j
	real*8 pi
	parameter(nlong=36,nlatt=18)
	parameter(pi=3.14159265358979323846)
	real*8 long(nlong),latt(nlatt),beta(nlong-1,nlatt-1)
	real*8 Kxx,vxx,powvxx,night2day,shift
	
	Kxx=1d0
	vxx=20d0
	powvxx=3d0
	night2day=0.2
		
	do i=1,nlong
		long(i)=-pi+2d0*pi*real(i-1)/real(nlong-1)
	enddo
	do j=1,nlatt
		latt(j)=-pi/2d0+pi*real(j-1)/real(nlatt-1)
	enddo
	
	call DiffuseBeta(beta,long,latt,nlong,nlatt,Kxx,vxx,powvxx,night2day)

	call DetermineShift(long,beta,nlong,nlatt,shift)
	print*,'hotspot shift: ',shift

	open(unit=20,file="structure3D.dat",RECL=6000)
	do j=1,nlatt-1
		write(20,*) beta(1:nlong-1,j)
	enddo
	close(unit=20)


	end
	
	
	subroutine DetermineShift(long,beta,nlong,nlatt,shift)
	IMPLICIT NONE
	integer nlong,nlatt,i,j,k
	real*8 shift,beta(nlong-1,nlatt-1),max,x1,x2,x3,y1,y2,y3,pi,long(nlong)
	parameter(pi=3.1415926536)
	
	j=nlatt/2
	max=0d0
	k=nlong/2
	do i=1,nlong-1
		if(beta(i,j).gt.max) then
			max=beta(i,j)
			k=i
		endif
	enddo
	if(k.eq.1) then
		y1=beta(nlong-1,j)
		y2=beta(k,j)
		y3=beta(k+1,j)
		x1=(long(nlong-1)+long(nlong))/2d0
		x2=(long(k)+long(k+1))/2d0
		x3=(long(k+1)+long(k+2))/2d0
	else if(k.eq.nlong-1) then
		y1=beta(k-1,j)
		y2=beta(k,j)
		y3=beta(1,j)
		x1=(long(k-1)+long(k))/2d0
		x2=(long(k)+long(k+1))/2d0
		x3=(long(1)+long(2))/2d0
	else
		y1=beta(k-1,j)
		y2=beta(k,j)
		y3=beta(k+1,j)
		x1=(long(k-1)+long(k))/2d0
		x2=(long(k)+long(k+1))/2d0
		x3=(long(k+1)+long(k+2))/2d0
	endif
	shift=-(((y1-y2)/(x1-x2))*((x1*x1-x2*x2)/(x1-x2)-(x2*x2-x3*x3)/(x2-x3))/((y1-y2)/(x1-x2)-(y2-y3)/(x2-x3))
     &		-(x1*x1-x2*x2)/(x1-x2))/2d0
	
	shift=shift*180d0/pi
	
	return
	end

