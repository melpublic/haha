      subroutine list1
	USE Information
      IMPLICIT REAL*8(A-H,O-Z)

113    continue 
      rlistsq=rlist*rlist ! set the square of reference radius for an atom

	rlisttest=rlist

      nlistx=aint(ux/rlisttest) !get the integer, and remove the decimal. (nlistx*rlisttest < ux)
	nlisty=aint(uy/rlisttest)
	nlistz=aint(uz/rlisttest)
      
	fnlistx=Dble(nlistx)
	fnlisty=Dble(nlisty)
	fnlistz=Dble(nlistz)

      rlistx=rlisttest+(ux-fnlistx*rlisttest)/fnlistx
      rlisty=rlisttest+(uy-fnlisty*rlisttest)/fnlisty
	rlistz=rlisttest+(uz-fnlistz*rlisttest)/fnlistz

	rlistsqx=rlistx*rlistx
	rlistsqy=rlisty*rlisty
	rlistsqz=rlistz*rlistz

	
	nxcell=nint(ux/rlistx)-1 ! get the closest integer
	nycell=nint(uy/rlisty)-1
	nzcell=nint(uz/rlistz)-1

      ntotal=(nxcell+5)*(nycell+5)*(nzcell+5)
	Allocate(nbinpnt(ntotal))
      
      rlistxinv=1.d0/rlistx
	rlistyinv=1.d0/rlisty
	rlistzinv=1.d0/rlistz

      nbinpnt =0
      nbin =0
      cnini = 0
      neini =0

      do i=1,natom
          ix=x(i)*rlistxinv
          iy=y(i)*rlistyinv
          iz=z(i)*rlistzinv
          ib=iz*(nxcell+1)*(nycell+1)+iy*(nxcell+1)+ix+1 	       
          nbin(i)=nbinpnt(ib)       
          nbinpnt(ib)=i	
      enddo       

	do i=1,natom       
          ii=ii+1
          xtmp=x(i)
          ytmp=y(i)
          ztmp=z(i)
        
          ixx=xtmp*rlistxinv
          iyy=ytmp*rlistyinv
          izz=ztmp*rlistzinv
          ib=izz*(nxcell+1)*(nycell+1)+iyy*(nxcell+1)+ixx+1
	
1         do k1=-1,1
2           do k2=-1,1
              do k3=-1,1        
                ix=ixx+k1

                 if(ix.lt.0) ix=nxcell
	          if(ix.gt.nxcell) ix=0 
			          
                iy=iyy+k2

                if(iy.lt.0) iy=nycell
	          if(iy.gt.nycell) iy=0
       
                iz=izz+k3

                if(iz.lt.0) iz=nzcell
	          if(iz.gt.nzcell) iz=0
                ib=iz*(nxcell+1)*(nycell+1)+iy*(nxcell+1)+ix+1
                j=nbinpnt(ib)

10              if(j.gt.0)then
                  if(j.gt.i)then
                    delx=xtmp-x(j)
                    dely=ytmp-y(j)
                    delz=ztmp-z(j)
				  if(delx .lt. -hlux) delx=delx+ux
	              if(delx .gt. hlux) delx=delx-ux
	              if(dely.lt. -hluy) dely=dely+uy
	              if(dely .gt. hluy) dely=dely-uy
                    if(delz.lt. -hluz) delz=delz+uz
	              if(delz .gt. hluz) delz=delz-uz				           
                    rsq=delx*delx+dely*dely+delz*delz
                    !if(rsq .le. rlistsq)then
				  if(rsq .le. npair_rlistsq(num(i),num(j)))then                     
                      cnini(i) = cnini(i)+1                     
	                  if(cnini(i) .gt.40)then
                          write(*,*)"Neighbor counter is over 60"
	                    write(*,*)"Please use a shorter rlist"
                          rlist = rlist-0.1
                          Deallocate(nbinpnt)
			   			goto 113 
	                  endif
                      neini(i,cnini(i))=j
                      cnini(j) = cnini(j)+1                      
                        if(cnini(j) .gt.40)then
                          write(*,*)"Neighbor counter is over 60"
	                    write(*,*)"Please use a shorter rlist"
                          rlist = rlist-0.1
                          Deallocate(nbinpnt)
			    		goto 113
	                 endif
                      neini(j,cnini(j))=i 
                    endif
                  endif          
                  j=nbin(j)	  
                  goto 10
                endif
3             enddo
            enddo
          enddo
      enddo	 
!c       do i=1,natom
!c        write(*,*)i,cnini(i)
!c	 enddo
!c	pause
!c...... keep the closest 60 atoms  
!c	rlist=rlist+0.3
      write(*,*)"The best rlist = ", rlist
	return
      end   