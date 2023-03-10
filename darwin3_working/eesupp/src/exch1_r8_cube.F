#include "CPP_EEOPTIONS.h"

CBOP
C     !ROUTINE: EXCH1_R8_CUBE

C     !INTERFACE:
      SUBROUTINE EXCH1_R8_CUBE(
     U                 array,
     I                 withSigns,
     I                 myOLw, myOLe, myOLs, myOLn, myNz,
     I                 exchWidthX, exchWidthY,
     I                 cornerMode, myThid )

C     !DESCRIPTION:
C     *==============================================================*
C     | SUBROUTINE EXCH1_R8_CUBE
C     | o Forward-mode edge exchanges for R8 array on CS config.
C     *==============================================================*
C     | Controlling routine for exchange of XY edges of an array
C     | distributed in X and Y.
C     | This is a preliminary (exch1), simpler version with few
C     | limitations (no MPI, 1 tile per face, regular 6 squared faces,
C     | multi-threads only on shared arrays, i.e., in commom block)
C     | that are fixed in generalised pkg/exch2 implementation.
C     *==============================================================*

C     !USES:
      IMPLICIT NONE

C     == Global data ==
#include "SIZE.h"
#include "EEPARAMS.h"

C     !INPUT/OUTPUT PARAMETERS:
C     == Routine arguments ==
C     array       :: Array with edges to exchange.
C     withSigns   :: Flag controlling whether field sign depends on orientation
C                 :: (signOption not yet implemented but needed for SM exch)
C     myOLw,myOLe :: West  and East  overlap region sizes.
C     myOLs,myOLn :: South and North overlap region sizes.
C     exchWidthX  :: Width of data region exchanged in X.
C     exchWidthY  :: Width of data region exchanged in Y.
C                    Note --
C                    1. In theory one could have a send width and
C                    a receive width for each face of each tile. The only
C                    restriction would be that the send width of one
C                    face should equal the receive width of the sent to
C                    tile face. Dont know if this would be useful. I
C                    have left it out for now as it requires additional
C                    bookeeping.
C     cornerMode  :: Flag indicating whether corner updates are needed.
C     myThid      :: my Thread Id number

      INTEGER myOLw, myOLe, myOLs, myOLn, myNz
      _R8     array( 1-myOLw:sNx+myOLe,
     &               1-myOLs:sNy+myOLn,
     &               myNz, nSx, nSy )
      LOGICAL withSigns
      INTEGER exchWidthX
      INTEGER exchWidthY
      INTEGER cornerMode
      INTEGER myThid

C     !LOCAL VARIABLES:
C     == Local variables ==
C     theSimulationMode :: Holds working copy of simulation mode
C     theCornerMode     :: Holds working copy of corner mode
C     I,J,K             :: Loop and index counters
C     bl,bt,bn,bs,be,bw :: tile indices
c     INTEGER theSimulationMode
c     INTEGER theCornerMode
      INTEGER I,J,K
      INTEGER bl,bt,bn,bs,be,bw
      CHARACTER*(MAX_LEN_MBUF) msgBuf

C     == Statement function ==
C     tilemod :: Permutes indices to return neighboring tile index
C                on six face cube.
      INTEGER tilemod
      tilemod(I)=1+mod(I-1+6,6)
CEOP

c     theSimulationMode = FORWARD_SIMULATION
c     theCornerMode     = cornerMode

c     IF ( simulationMode.EQ.REVERSE_SIMULATION ) THEN
c       WRITE(msgBuf,'(A)') 'EXCH1_R8_CUBE: AD mode not implemented'
c       CALL PRINT_ERROR( msgBuf, myThid )
c       STOP 'ABNORMAL END: EXCH1_R8_CUBE: no AD code'
c     ENDIF
      IF ( sNx.NE.sNy .OR.
     &     nSx.NE.6 .OR. nSy.NE.1 .OR.
     &     nPx.NE.1 .OR. nPy.NE.1 ) THEN
        WRITE(msgBuf,'(2A)') 'EXCH1_R8_CUBE: Wrong Tiling'
        CALL PRINT_ERROR( msgBuf, myThid )
        WRITE(msgBuf,'(2A)') 'EXCH1_R8_CUBE: ',
     &   'works only with sNx=sNy & nSx=6 & nSy=nPx=nPy=1'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: EXCH1_R8_CUBE: Wrong Tiling'
      ENDIF

C     For now tile<->tile exchanges are sequentialised through
C     thread 1. This is a temporary feature for preliminary testing until
C     general tile decomposistion is in place (CNH April 11, 2001)
      CALL BAR2( myThid )
      IF ( myThid .EQ. 1 ) THEN

       DO bl = 1, 5, 2

        bt = bl
        bn=tilemod(bt+2)
        bs=tilemod(bt-1)
        be=tilemod(bt+1)
        bw=tilemod(bt-2)

        DO K = 1, myNz
         DO J = 1, sNy
          DO I = 1, exchWidthX

C          Tile Odd:Odd+2 [get] [North<-West]
           array(J,sNy+I,K,bt,1) = array(I,sNy+1-J,K,bn,1)
C          Tile Odd:Odd-1 [get] [South<-North]
           array(J,1-I,K,bt,1) = array(J,sNy+1-I,K,bs,1)
C          Tile Odd:Odd+1 [get] [East<-West]
           array(sNx+I,J,K,bt,1) = array(I,J,K,be,1)
C          Tile Odd:Odd-2 [get] [West<-North]
           array(1-I,J,K,bt,1) = array(sNx+1-J,sNy+1-I,K,bw,1)

          ENDDO
         ENDDO
        ENDDO

        bt = bl+1
        bn=tilemod(bt+1)
        bs=tilemod(bt-2)
        be=tilemod(bt+2)
        bw=tilemod(bt-1)

        DO K = 1, myNz
         DO J = 1, sNy
          DO I = 1, exchWidthX

C          Tile Even:Even+1 [get] [North<-South]
           array(J,sNy+I,K,bt,1) = array(J,I,K,bn,1)
C          Tile Even:Even-2 [get] [South<-East]
           array(J,1-I,K,bt,1) = array(sNx+1-I,sNy+1-J,K,bs,1)
C          Tile Even:Even+2 [get] [East<-South]
           array(sNx+I,J,K,bt,1) = array(sNx+1-J,I,K,be,1)
C          Tile Even:Even-1 [get] [West<-East]
           array(1-I,J,K,bt,1) = array(sNx+1-I,J,K,bw,1)

          ENDDO
         ENDDO
        ENDDO

       ENDDO

      ENDIF
      CALL BAR2(myThid)

      RETURN
      END
