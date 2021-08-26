!      This Code helps you to creat the first neighbor atom list of a referenced atom and then find 
!      the HA index distribution with the averged CN and bond length. You also need a perl to analyze the HA index
!      It was developed by Prof. Shin-Pon Ju and can only be used in Ju's group or with Ju's permission!
!
!      Example input files: cninput.dat, cninput-bcc.dat, cninput-fcc.dat, cninput-hcp.dat.
!     The input format should follow these example files, or you may change the source code for your own format!
!     ****** You need to provide the following file:

!     1. alloy_composition.dat:-->
!
!     ##you must follow the below template
!     2  #element total types in cfg files
!     Mg
!     Ca 
!     5.5  # the distance of RDF second minima of the second peak--> by ovito 





!...  1.2012/01/25
!..   2.2012/03/18.... good for both PBC and Non-PBC cases..  
!.....3.2012/12/02.... fix some trivial bugs
!.....4.2013/01/02.... general code for both crystal and amorphous materials, but element type should be given.     
!.....5.2013/04/19.... 計算鍵長，使當角度小於45之第二臨近距離去除
!.....6.2017/08/06 ... read format for lammps cfg

	include 'information.f90'
	   
      program Coordination_Number

	USE Information 	
      IMPLICIT REAL*8(A-H,O-Z)
!........
      
      REAL*8:: vx(500),vy(500),vz(500),distemp(500)
	INTEGER:: nkill(500),nk_index(500)
	real*8 :: disnear(4,4)
!........
      rad_converter=	180./3.1415926
		
!      near_dis=0.d0


      open(119,file="alloy_composition.dat",status='old')
	read(119,*)   ! skip a line 
	read(119,*)ntot_type ! total atom types in cfg

      ALLOCATE(elem_name(ntot_type)) !the element name of the corresponding atom type
      ALLOCATE(ntype_atom_No(ntot_type)) ! the atom No. of each type
      ALLOCATE(ave_CN(ntot_type)) !averaged CN of each type
	ALLOCATE(ave_partial_CN(ntot_type,ntot_type)) !averaged CN of each pair, the first one is the reference atom
	ALLOCATE(ave_bondL(ntot_type,ntot_type)) !averaged bond lengths of all pairs
      ALLOCATE(npair_No(ntot_type,ntot_type)) !the bond number of each pair, the first index is the refernce atom type
      ALLOCATE(npair_rlistsq(ntot_type,ntot_type))
      do i =1,ntot_type
         read(119,*)elem_name(i)         
	enddo 
	
	read(119,*)rlist ! the maximal value among all rlist values

      do i =1,ntot_type
	  do j=1,ntot_type
           if(i.le.j) then
		   read(119,*)temp
		   npair_rlistsq(i,j)=temp*temp
		   npair_rlistsq(j,i)=npair_rlistsq(i,j) 
		 endif	  
	  enddo 
	enddo

      close(119)    

      open(112,file="input.cfg",status='old')
!........... read cfg file		    
      read(112,*)
	read(112,*)ntime
	read(112,*)
      read(112,*)natom
       
!########### open matrixes after reading natom!
      ALLOCATE(x(natom))
	ALLOCATE(y(natom))
	ALLOCATE(z(natom))      
      ALLOCATE(index_disHA(natom))
	ALLOCATE(cn(natom))
	ALLOCATE(cntemp(natom))
	ALLOCATE(cnini(natom))	
	ALLOCATE(ele(natom))
      ALLOCATE(neighbor(natom,40))!could be very large if many atoms used.      
      ALLOCATE(neini(natom,40)) ! search over closest 27 cells, so use 300 for the maximal value
      ALLOCATE(nbin(natom))
!	ALLOCATE(dis_same(natom))
!	ALLOCATE(dis_diff(natom))
	ALLOCATE(num(natom)) ! type number ID in lammps

!     HA index
      maxpair=natom*40 ! should be natom*40, but too many to do so
      ALLOCATE(i_index(maxpair)) ! i atom of a pair
	ALLOCATE(j_index(maxpair)) ! j atom of a pair
	ALLOCATE(npool(30000)) ! all co-neigh atoms' neighbour atoms (including the original pair atoms) for a pair (so 15*15 for maxmun, use 300 is ok)
      !ALLOCATE(list(maxpair*100)) ! keeping all co-neighbour atom IDs of all pairs
      ALLOCATE(npoint(maxpair)) ! the beginning co-neighbour atom index of a pair
      ALLOCATE(index_2(maxpair))
      ALLOCATE(index_3(maxpair))
	ALLOCATE(index_4(maxpair))
	ALLOCATE(HA(maxpair))
	ALLOCATE(Partial_HA(ntot_type,ntot_type,50000)) !HA could larger than 1991

 	

!#####################			  			  
      read(112,*)
      read(112,*)xlo, xhi
	ux=(xhi-xlo)
      read(112,*)ylo, yhi
	uy=(yhi-ylo)	
      read(112,*)zlo, zhi
	uz=(zhi-zlo)

!......if not a PBC system, set a reasonable large values for ux,uy,uz to avoid interaction between images
!...... 
	hlux = ux/2.
	hluy = uy/2.
	hluz = uz/2.
		
      read(112,*)

      do 117 j2=1,natom
        read(112,*)ID,num(ID),x(ID),y(ID),z(ID) !! ******** You should check the format for your cases
!	  write(*,*)ID,num(ID),x(ID),y(ID),z(ID)
!	   write(*,*)"test1"
          
        ele(id)=elem_name(num(id))
	    
	  
        ! write(*,*)"test2" 
! .............. move the origin to (0,0,0)
        x(ID) = x(ID) -xlo
	  y(ID) = y(ID) -ylo
	  z(ID) = z(ID) -zlo     
117   continue      
	close(112)

      zmax=maxval(z)
      zmin=minval(z)
      alength=zmax-zmin
    
	xmin=minval(x)
      ymin=minval(y) 
      zmin=minval(z)

!  shift the minimal coordinates to zero
      do 33 i=1,natom
        x(i)=x(i)-xmin
        y(i)=y(i)-ymin
        z(i)=z(i)-zmin
33	continue
     
      call list1 ! get neighbor list within a specific distance
     
      cn = 0 ! integer one-dimensinal array
      cntemp = 0 !integer one-dimensinal array 
       
! $$$$$$$$$$$$    assign the initial values for the near distance of each pair	 
       
       

      do 111 i=1,natom ! the largest loop

!###   01.  Get the vectors from atom i to all its neighbour atoms within the initial distance (must be fewer than 40 after adjusting the rlist value)
	   do 121 j=1,cnini(i)
            j1=neini(i,j)	
            rx = x(j1)-x(i)
	      ry = y(j1)-y(i)
	      rz = z(j1)-z(i)
	      !#####################################  PBC evaluation here!
            if(rx .lt. -hlux) rx=rx+ux
	      if(rx .gt. hlux) rx=rx-ux
	      if(ry .lt. -hluy) ry=ry+uy
	      if(ry .gt. hluy) ry=ry-uy
            if(rz .lt. -hluz) rz=rz+uz
	      if(rz .gt. hluz) rz=rz-uz
            dis = dsqrt(rx*rx+ry*ry+rz*rz)	
!.....get the unit vector from the reference atom i to its neighbor atom j
      !      write(*,*)"j : ",j
            vx(j)=rx/dis
            vy(j)=ry/dis
            vz(j)=rz/dis 
 121     continue


!.....02. Use any two neighbour atoms of atom i to evaluate which one is not real first neighbour atom	
       ikill = 0
       nk_index = 0
         do 131 i1=1,cnini(i)-1	 
            do 141 i2=i1+1,cnini(i)
          j1=neini(i,i1)!atom j1 (neighbor of atom i) from loop 131
          j2=neini(i,i2) !atom j2 (neighbor of atom i) from loop 141

         If(nk_index(i1) .eq.0 .and.nk_index(i2) .eq.0)then !nk_index(i1)=0 --> atom not removed, =1 removed  
!.........check the angle form at the reference atom a with any two of it's neighbor atoms
	         
			 angin=vx(i1)*vx(i2)+vy(i1)*vy(i2)+vz(i1)*vz(i2) !做內積

	         if(angin .le.-0.99999999) angin=-0.999999999 !avoid numerical error
               if(angin .ge. 0.99999999) angin= 0.999999999 !avoid numerical error
               angle=acos(angin)      
	         angle = angle*rad_converter !change rad.to angle	            
				
				if(angle.le.refangle)then  !(<50度)  

!                     weigdis =disHA(i)*(angle/refangle) !weight function!
                      angle_ratio = angle/refangle          !angle=0-180 !refangle=50
       ! must be careful testing in the future
                if(ele(j1) .eq. ele(j2))then !the same atom size
	             if(angle_ratio.le.1 .and.angle_ratio.gt.0.6)then   !50-30
                     weigdis = angle_ratio*2           !0.6-1
	            elseif(angle_ratio.le.0.6 .and.angle_ratio.gt.0.3)then  !30-15
                     weigdis = angle_ratio*1.5          !0.3-0.15
                  elseif(angle_ratio.le.0.3 .and.angle_ratio.ge.0.0)then   !15-0
                     weigdis = angle_ratio*1.          !0.15-0 
                    endif
                 			   
			   else     ! different atom types
                    if(angle_ratio.le.1 .and.angle_ratio.gt.0.6)then
                     weigdis = angle_ratio*2     !0.84-1.4
	            elseif(angle_ratio.le.0.6 .and.angle_ratio.gt.0.3)then
                     weigdis = angle_ratio*1.5     !0.72-0.36
                  elseif(angle_ratio.le.0.3 .and.angle_ratio.ge.0.0)then
                     weigdis = angle_ratio*1.0     !0.3-0
                    endif
             
	            endif
                      
	               rx = x(j1)-x(i)
	               ry = y(j1)-y(i)
                     rz = z(j1)-z(i)
                    !############################## PBC ##############
                     if(rx.ge.hlux)rx = rx - ux
                     if(rx.le.-hlux)rx = rx + ux	       
                     if(ry.ge.hluy)ry = ry - uy
                     if(ry.le.-hluy)ry = ry + uy	       
                     if(rz.ge.hluz)rz = rz - uz
                     if(rz.le.-hluz)rz = rz + uz
                     dis1 = dsqrt(rx*rx+ry*ry+rz*rz)
	               
	               rx = x(j2)-x(i)
	               ry = y(j2)-y(i)
	               rz = z(j2)-z(i)
	              !######################### PBC ##################
                     if(rx.ge.hlux)rx = rx - ux
                     if(rx.le.-hlux)rx = rx + ux	       
                     if(ry.ge.hluy)ry = ry - uy
                     if(ry.le.-hluy)ry = ry + uy	       
                     if(rz.ge.hluz)rz = rz - uz
                     if(rz.le.-hluz)rz = rz + uz
                     dis2 = dsqrt(rx*rx+ry*ry+rz*rz)	
				     
!========================================================================
	                  if(abs(dis1-dis2).ge.weigdis)then !one of the pair atoms is not the first neighbour atom of atom i
					  
				         if(dis1.ge.dis2)then	
                                 ikill=ikill+1
                                 nkill(ikill)= j1 !ready to remove j1 from cnini
	                           nk_index(i1) = 1
	                     else    
                                 ikill=ikill+1
                                 nkill(ikill)= j2 !ready to remove j2 from cnini
                                 nk_index(i2) = 1
	                     endif 

                        elseif(dis1.gt.disnear(num(i),num(j1)))then

                                 ikill=ikill+1
                                 nkill(ikill)= j1 !ready to remove j1 from cnini
	                           nk_index(i1) = 1

                        elseif(dis2.gt.disnear(num(i),num(j2)))then

                                 ikill=ikill+1
                                 nkill(ikill)= j2 !ready to remove j2 from cnini
                                 nk_index(i2) = 1

                   
                        endif

!==========================================================================================


           endif
			   
			endif        
 141        continue
 131     continue 
         
!........modify here!!!
!#### 03. remove those not the first neighbour atoms of atom i 
! ikill: the near atom ID to be remove    
         ncnt=0
        do 241 ic=1,cnini(i)
          j1=neini(i,ic)
	    icheck =0
!             do 242 ik=1,ikill
!              if(nkill(ik).eq.j1)icheck=1
! 242          continue
           if(icheck.eq.0)then ! icheck =0 --> not remove this atom from the original neighbour array
             ncnt=ncnt+1
	       neighbor(i,ncnt)=j1
	    endif
241     continue
        
        cn(i)=ncnt
!	write(*,*)i,ncnt
111   continue

!      write(*,*)CN(3815),neighbor(3815,7)
!	pause
!==============================================
      !call GJF_CNprinter !show local structures with it's first neighbor atoms in gaussview      
!      write(*,*)'1'
	!call HA_index
!      write(*,*)'2'
!	call gjfprinter
!      call gjfprinter_HAneigh
!	call gjf_CNprinter
!      write(*,*)'3' 
      call cn_sample
      
	end
	
	include 'cn_sample.f90'  
	!include 'HA_index.f90' 
      include 'list.f90'
	!include 'gjfprinter.f90'
      !include 'gjf_CNprinter.f90'
	!include 'gjfprinter_HAneigh.f90'