!     This fortran code can have you get the msd from the cfg file of the lammps output
!     Developed by Prof. Shin-Pon Ju at NSYSU 2017/06/27 
program msd
implicit none
Integer i,j,k,cfgnum,natom,totalnatom,naveragenum
Integer typenum,nn
Integer,allocatable:: tt(:),type(:)
Integer,allocatable:: ncount(:)
real*8,allocatable:: disp(:)!allcoordx(:),allcoordy(:),allcoordz(:),
real*4,allocatable:: coordx(:,:),coordy(:,:),coordz(:,:)
real*8:: timestep,del_t,dispx,dispy,dispz
real ::start, finish
character(len=17) :: filename
character(len=12) :: first
character(len=4) :: last
character(len=3) :: num

typenum = 5
open(112,file='finput.dat',status='old')
read(112,*)cfgnum
read(112,*)natom
read(112,*)totalnatom
read(112,*)timestep
read(112,*)naveragenum
allocate(type(totalnatom))!allcoordx(totalnatom),allcoordy(totalnatom),allcoordz(totalnatom),
allocate(coordx(0:typenum,totalnatom),coordy(0:typenum,totalnatom),coordz(0:typenum,totalnatom))
allocate(ncount(cfgnum-naveragenum),disp(cfgnum-1))
allocate(tt(0:typenum))
tt(:) = 0

call cpu_time(start)
do i=1,totalnatom
    read(112,*) coordx(0,i),coordy(0,i),coordz(0,i),type(i)
    !print*,allcoordx(i),allcoordy(i),allcoordz(i),type(i)
    do nn=1,typenum
      if (type(i) .eq. nn) then
        tt(nn) = tt(nn) + 1
        !print*,i,allcoordx(i),allcoordy(i),allcoordz(i),type(i)
        coordx(nn,tt(nn)) = coordx(0,i)
        coordy(nn,tt(nn)) = coordy(0,i)
        coordz(nn,tt(nn)) = coordz(0,i)
      endif
    enddo
enddo
close(112)
call cpu_time(finish)
print*,"time consumption:",finish-start," sec."

!print*,tt(1)
tt(0) = totalnatom
do nn=0,typenum
    write(num,'(I1)')nn
    first = 'fortran4msd_'
    last = '.dat'
    filename = first//trim(num)//last
    print*,filename

  open(123,file=filename,status='unknown')
  disp=0 
  ncount=0
  !write( *, * )coordy(2),coordy(1)
  !read(*,*)
  natom = tt(nn)/cfgnum

  do i=1,cfgnum-naveragenum
    do j=1,naveragenum
      do k=1,natom
  !	write( *, * )i,j
      dispx=coordx(nn,(i+j-1)*natom+k)-coordx(nn,(j-1)*natom+k)
      dispy=coordy(nn,(i+j-1)*natom+k)-coordy(nn,(j-1)*natom+k)
      dispz=coordz(nn,(i+j-1)*natom+k)-coordz(nn,(j-1)*natom+k)
      disp(i+j-1)=disp(i+j-1)+dispx*dispx+dispy*dispy+dispz*dispz
  !   write( *, * )dispx,dispy,dispz,disp(j-i)
  !	write( *, * )(j-1)*natom+k,(i-1)*natom+k,i,j,k
  !	read(*,*)
  	  enddo 
      ncount(i)=ncount(i)+1
    enddo
  enddo

  do i=1,cfgnum-naveragenum
     del_t=dble(i)*timestep
     write(123,*)del_t,disp(i)/(dble(ncount(i))*dble(natom))
     write(*,*)i,disp(i),ncount(i),dble(natom)
     !read(*,*)
  enddo        
  close(123)
enddo

deallocate(coordx,coordy,coordz,ncount,disp)
END
