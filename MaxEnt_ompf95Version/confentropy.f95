!subroutine conf_entropy(tid,natom,atype,confentropy,atomentropy,weight,CN_No,CN_ID)
subroutine conf_entropy(natom,atype,confentropy,weight,CN_No,CN_ID)
!use information

use omp_lib
implicit real*8(a-h,o-z)  
integer natom
real*8 weight(5)
integer atype(natom),CN_No(natom,5),CN_ID(natom,5,50)
real*8,INTENT(OUT) :: confentropy
!real*8,INTENT(OUT) :: atomentropy(natom)
!
!call cpu_time(start)
!!$ start = omp_get_wtime()

confentropy = 0.0 ! configurational entropy
!atomentropy = 0.0 ! entropy of each atom for normshuffle, set 1 for inital
!shared(atomentropy)
!$OMP PARALLEL reduction(+:confentropy)
!$OMP DO PRIVATE(i,neID) 
!!! 
!do 1 i=1,natom
do  i=1,natom
do neID = 1,CN_No(i,1) ! atom ID of a neighbor type
          JID = CN_ID(i,1,neID)
            if(atype(i) .eq. atype(JID))then !only consider atoms with the same type
				confentropy = confentropy + 1.0
            !!$OMP ATOMIC UPDATE
				!atomentropy(i) = atomentropy(i) + 1.0                    
             endif           
!           endif		  
!3 		continue                      
enddo                      

enddo

!$OMP END DO
!$OMP END PARALLEL 
call cpu_time(finish)
!!$ finish = omp_get_wtime()
!!$        print *,"****maxThreads:",omp_get_max_threads(), "imc step: ",imc, "time consumption:",finish-start," sec."

return
end
