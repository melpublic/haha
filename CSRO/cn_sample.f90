      subroutine cn_sample
      USE Information
      IMPLICIT REAL*8(A-H,O-Z)
      INTEGER:: nbcc,nonbcc,nfcc,ntotalbond,n1,n2,n3,nnatom
      REAL::vx(50),vy(50),vz(50),avecn,avebond
      CHARACTER*20::fname
      INTEGER::num11,num12,num13,num21,num22,num23,num31,num32,num33

!.......	Check whether the real local BCC is or not!
      nnatom=natom
	
	nbcc= 0
	nonbcc=0
	nfcc = 0
      num11=0
      num12=0
      num13=0
      num22=0
	      num21=0
      num23=0
	      num33=0
      num32=0
	      num31=0
      avebond11=0.
	avebond12=0.
	avebond13=0.
	      avebond21=0.
	avebond22=0.
	avebond23=0.
	      avebond31=0.
	avebond32=0.
	avebond33=0.
	n1=0
	n2=0
	n3=0
	do 11 i=1,natom
!       write(*,*)i,cn(i)
!	pause
!.......Checking BCC.............
	   if(cn(i).eq.8.d0)then	     
	      do 12 j=1,8
               j1=neighbor(i,j)	
               rx = x(j1)-x(i)
	         ry = y(j1)-y(i)
	         rz = z(j1)-z(i)
               if(rx .lt. -hlux) rx=rx+ux
	         if(rx .gt. hlux) rx=rx-ux
	         if(ry .lt. -hluy) ry=ry+uy
	         if(ry .gt. hluy) ry=ry-uy
               if(rz .lt. -hluz) rz=rz+uz
	         if(rz .gt. hluz) rz=rz-uz
               dis = dsqrt(rx*rx+ry*ry+rz*rz)
               vx(j)=rx/dis
               vy(j)=ry/dis
               vz(j)=rz/dis
 12        continue
         icheck=0
!...........check the angle by the referencd atom i and any its two neighbor atoms
           do 13 i1=1,7
              do 14 i2=i1+1,8
                  angin=vx(i1)*vx(i2)+vy(i1)*vy(i2)+vz(i1)*vz(i2)
	            if(angin .le.-0.99999999) angin=-0.999999999
                  if(angin .ge. 0.99999999) angin= 0.999999999
                  angle=acos(angin)
	            angle = angle*rad_converter
                  if(angle.gt.160.)icheck =icheck+1
 14           continue
 13        continue
             if(icheck .eq.4)then
	          nbcc=nbcc+1
! 1=========== Show all local BCC in gjf files ============

! c               write(fname,'(a,i6.6,a)')'BCC',nbcc,'.gjf'
!                open(112,file=fname,status='unknown')
!                write(112,*)'#'
!	          write(112,*)' '
!	          write(112,*)'md-morphology'
!	          write(112,*)' '
!	          write(112,*) '0 1'			     
!                write(112,'(A2,3f14.8)')'Au',x(i),y(i),z(i)
!	           do ib=1,8
!                   write(112,'(A,3f14.8)')ele(neighbor(i,ib)),
!     &                    				 x(neighbor(i,ib)),
!     &			        y(neighbor(i,ib)),z(neighbor(i,ib))
!                 enddo
!                close(112)
	       else
	          nonbcc=nonbcc+1
! 2============== Show all local nonBCC structures in gjf files.

!               write(fname,'(a6,i6.6,a)')'nonBCC',nonbcc,'.gjf'
!                open(112,file=fname,status='unknown')
!                write(112,*)'#'
!	          write(112,*)' '
!	          write(112,*)'md-morphology'
!	          write(112,*)' '
!	          write(112,*) '0 1'
!                write(112,'(A,3f14.8)')'Au',x(i),y(i),z(i)
!	            do ib=1,8
!                    write(112,'(A,3f14.8)')ele(neighbor(i,ib)),
!     &				                     x(neighbor(i,ib)),
!     &		                y(neighbor(i,ib)),z(neighbor(i,ib))
!                  enddo
!               close(112)
             endif
	  endif
	  
!.......Checking FCC

        if(cn(i).eq.12)then
	  
	     nfcc=nfcc+1

! 3============== Show all local fcc structures in gjf files.

!                write(fname,'(a,i6.6,a)')'fcc',nfcc,'.gjf'
!                open(112,file=fname,status='unknown')
!                write(112,*)'#'
!	          write(112,*)' '
!	          write(112,*)'md-morphology'
!	          write(112,*)' '
!	          write(112,*) '0 1'
!                write(112,'(A,3f14.8)')'Au',x(i),y(i),z(i)
!	            do ib=1,12
!                    write(112,'(A,3f14.8)')ele(neighbor(i,ib)),
!     &				                     x(neighbor(i,ib)),
!     &		                y(neighbor(i,ib)),z(neighbor(i,ib))
!                  enddo
!               close(112)
	  endif
11    continue
	
!       end check local BCC and FCC!	

	avecn = 0.d0
	ntotalbond =0
	avebond = 0.d0
	do 17 i=1,natom
          avecn=avecn+dble(cn(i))
	    ntotalbond = ntotalbond+cn(i)
            do 18 j=1,cn(i)
               j1=neighbor(i,j)	
               rx = x(j1)-x(i)
	         ry = y(j1)-y(i)
	         rz = z(j1)-z(i)
               if(abs(rx).gt.hlux)rx = abs(rx) - ux	      
               if(abs(ry).gt.hluy)ry = abs(ry) - uy	       
               if(abs(rz).gt.hluz)rz = abs(rz) - uz
               dis = dsqrt(rx*rx+ry*ry+rz*rz)
              avebond = avebond+dis 
18          continue	
17	continue
      avecn=avecn/dble(natom)
	avebond=avebond/dble(ntotalbond)
!--------------------------Write Data-----------------------------------------------
!      open(168,file="cn_output.dat",status='unknown')
!
!
!      write(168,*)"Average Coordination Number: ",avecn
!      write(168,*)"Average Bond Length: ",avebond
!      write(168,*)"BCC Percentage: ",dble(nbcc)/dble(natom)*100.d0
!	write(168,*)"FCC or HCP Percentage: ",dble(nfcc)/dble(natom)*100.
!-------------------------------------------------------------------------------------
!      close(168)


!      open(789,file="cn_count.dat",status='unknown')
!	open(218,file="average-r.dat",status='unknown')
	open(219,file="CSRO.dat",status='unknown')


      npair_No =0 ! two dimensional array for counting the number of differnt pair types
	ave_bondL = 0.d0 !two dimensional array for accumulating the distance  of differnt pair types
      ntype_atom_No = 0 ! one dimensional array for counting the atom number of different types  
      ave_CN = 0.d0 ! one dimensional array for counting average CN of each atom type
      ave_partial_CN =0.d0 ! two dimensional array for counting average CN of each atom pair

      do 123 ii=1,natom
	   do 456 jj=1,cn(ii)

               j1=neighbor(ii,jj)	
               rx = x(j1)-x(ii)
	         ry = y(j1)-y(ii)
	         rz = z(j1)-z(ii)
               if(abs(rx).gt.hlux)rx = abs(rx) - ux	      
               if(abs(ry).gt.hluy)ry = abs(ry) - uy	       
               if(abs(rz).gt.hluz)rz = abs(rz) - uz
               dis = dsqrt(rx*rx+ry*ry+rz*rz)
			 
			 do nt1=1,ntot_type
			    do nt2=1,ntot_type

                     if(ele(ii).eq.elem_name(nt1) .and. ele(neighbor(ii,jj)).eq.elem_name(nt2))then

	                    npair_No(nt1,nt2) = npair_No(nt1,nt2) +1
                          ave_bondL(nt1,nt2)=ave_bondL(nt1,nt2)+ dis
                      endif	      

			    enddo
			 enddo
456      continue
       
         ntype_atom_No(num(ii))=ntype_atom_No(num(ii))+1
             
123   continue ! loop over all atoms
      

      do nt1=1,ntot_type
	  npartial =0
          if(ntype_atom_No(nt1) .ne. 0) then ! the atom No of type nt1 is not 0
             do nt2=1,ntot_type
          
	          ave_partial_CN(nt1,nt2)=dble(npair_No(nt1,nt2))/dble(ntype_atom_No(nt1))
!	          write(789,*)elem_name(nt1), "-" ,elem_name(nt2),": ", ave_partial_CN(nt1,nt2)
                   if(npair_No(nt1,nt2) .ne. 0)then
                          
                     temp_aved=ave_bondL(nt1,nt2)/dble(npair_No(nt1,nt2))
!                     write(218,*)'ave-radius ',elem_name(nt1), "-" ,elem_name(nt2),": ", temp_aved
                   endif
                npartial=npartial+npair_No(nt1,nt2)
	    
	       enddo

	     ave_CN(nt1) =dble(npartial)/dble(ntype_atom_No(nt1))
!           write(789,*)"CN of",elem_name(nt1),": ", ave_CN(nt1)
	   endif
      enddo
      
!      close(789)     
!      close(218)

!....... writing CSRO

	do nt1=1,ntot_type
	  npartial =0
          if(ntype_atom_No(nt1) .ne. 0 .and. ave_CN(nt1) .gt. 0.d0) then ! the atom No of type nt1 is not 0
             do nt2=1,ntot_type	          
                   !if(npair_No(nt1,nt2) .ne. 0 )then
                       CSRO= 1.d0-ave_partial_CN(nt1,nt2)/(ave_CN(nt1)*dble(ntype_atom_No(nt2))/dble(natom))  
                     write(219,*)"CSRO ",elem_name(nt1), "-" ,elem_name(nt2),": ",CSRO 
                     !write(*,*)"CSRO ",elem_name(nt1), "-" ,elem_name(nt2),": ",CSRO 
                   !endif    
	       enddo	    
	   endif
      enddo
      
!      close(789)     
!      close(218)
      close(219)
      
      return
      end