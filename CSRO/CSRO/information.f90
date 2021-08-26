      MODULE Information
	IMPLICIT REAL*8(A-H,O-Z)
      Parameter(refangle=50.)
	INTEGER,save:: natom,inHA,modNo,nsearch,ntot_type
      REAL*8,save::rad_converter
      REAL*8,save::ux,uy,uz,hlux,hluy,hluz
	REAL*8:: rlist
      INTEGER,ALLOCATABLE:: cn(:),neighbor(:,:),num(:),ntype_atom_No(:)
      INTEGER,ALLOCATABLE:: cntemp(:),npair_No(:,:),npair_rlistsq(:,:)
	!cntemp:initial trial CN neitemp:
      INTEGER,ALLOCATABLE:: cnini(:),neini(:,:)
	REAL*8,ALLOCATABLE:: x(:),y(:),z(:),index_disHA(:),ave_bondL(:,:)
	REAL*8,ALLOCATABLE:: ave_CN(:),ave_partial_CN(:,:)
!	REAL*8,ALLOCATABLE:: dis_diff(:),dis_same(:)
	INTEGER,ALLOCATABLE::nbinpnt(:),nbin(:)            
      CHARACTER(LEN=2),ALLOCATABLE::ele(:)
	CHARACTER(LEN=2),ALLOCATABLE::elem_name(:)
	
!.... HAindex

      INTEGER,ALLOCATABLE::npoint(:),i_index(:),j_index(:),   &
                           npool(:),index_2(:),index_3(:),index_4(:), &
                           HA(:),Partial_HA(:,:,:)	
      REAL*4,ALLOCATABLE:: list(:)
	INTEGER ::npair,nabors	      
	ENDMODULE 