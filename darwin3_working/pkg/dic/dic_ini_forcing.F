#include "DIC_OPTIONS.h"

CBOP
C !ROUTINE: DIC_INI_FORCING

C !INTERFACE: ==========================================================
      SUBROUTINE DIC_INI_FORCING( myThid )

C !DESCRIPTION:
c initializes forcing fields to zero
c (or to reasonable values)

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "DIC_VARS.h"
#include "DIC_LOAD.h"

C !INPUT PARAMETERS: ===================================================
C  myThid               :: thread number
      INTEGER myThid
CEOP

#ifdef ALLOW_DIC

c !LOCAL VARIABLES: ===================================================
       INTEGER bi,bj,i,j
#ifdef DIC_CALCITE_SAT
      INTEGER k
#endif
#if (defined (READ_PAR) && defined (USE_QSW))
       CHARACTER*(MAX_LEN_MBUF) msgBuf
#endif

C First call requires that we initialize everything to zero for safety
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
         DIC_ldRec(bi,bj) = 0
       ENDDO
      ENDDO
      CALL LEF_ZERO( dicwind0,myThid )
      CALL LEF_ZERO( dicwind1,myThid )
      CALL LEF_ZERO( atmosp0,myThid )
      CALL LEF_ZERO( atmosp1,myThid )
      CALL LEF_ZERO( silicaSurf0, myThid )
      CALL LEF_ZERO( silicaSurf1, myThid )
      CALL LEF_ZERO( ice0,myThid )
      CALL LEF_ZERO( ice1,myThid )
#ifdef READ_PAR
      CALL LEF_ZERO( par0,myThid )
      CALL LEF_ZERO( par1,myThid )
#endif
#ifdef ALLOW_FE
      CALL LEF_ZERO( feinput0,myThid )
      CALL LEF_ZERO( feinput1,myThid )
#endif
#ifdef LIGHT_CHL
      CALL LEF_ZERO( chlinput,myThid )
#endif
#ifdef DIC_CALCITE_SAT
      DO bj = myByLo(myThid), myByHi(myThid)
       DO bi = myBxLo(myThid), myBxHi(myThid)
        DO k=1,Nr
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
           silicaDeep0(i,j,k,bi,bj) = 0. _d 0
           silicaDeep1(i,j,k,bi,bj) = 0. _d 0
          ENDDO
         ENDDO
        ENDDO
       ENDDO
      ENDDO
#endif

#ifdef READ_PAR
#ifdef USE_QSW
        WRITE(msgBuf,'(2A)')
     &       ' DIC_INI_FORCING: You can not use READ_PAR ',
     &       ' and USE_QSW'
        CALL PRINT_ERROR( msgBuf, myThid )
        STOP 'ABNORMAL END: S/R DIC_INI_FORCING'
#endif
#endif

C set reasonable values to those that need at least something
       DO bj = myByLo(myThid), myByHi(myThid)
        DO bi = myBxLo(myThid), myBxHi(myThid)
         DO j=1-OLy,sNy+OLy
          DO i=1-OLx,sNx+OLx
            WIND(i,j,bi,bj)       = 5. _d 0*maskC(i,j,1,bi,bj)
            AtmosP(i,j,bi,bj)     = 1. _d 0*maskC(i,j,1,bi,bj)
            silicaSurf(i,j,bi,bj) = 7.6838 _d -3*maskC(i,j,1,bi,bj)
            fIce(i,j,bi,bj)       = 0. _d 0
            FluxCO2(i,j,bi,bj)    = 0. _d 0
#ifdef READ_PAR
            PAR(i,j,bi,bj)        = 100. _d 0*maskC(i,j,1,bi,bj)
#endif
#ifdef LIGHT_CHL
C If the chlorophyll climatology is not provided, use this default value.
            CHL(i,j,bi,bj)        = 1. _d -2*maskC(i,j,1,bi,bj)
#endif
#ifdef ALLOW_FE
            InputFe(i,j,bi,bj)    = 1. _d -11*maskC(i,j,1,bi,bj)
#endif
          ENDDO
         ENDDO
#ifdef DIC_CALCITE_SAT
         IF ( useCalciteSaturation ) THEN
          DO k=1,Nr
           DO j=1-OLy,sNy+OLy
            DO i=1-OLx,sNx+OLx
              silicaDeep(i,j,k,bi,bj) = 3. _d -2*maskC(i,j,k,bi,bj)
            ENDDO
           ENDDO
          ENDDO
         ENDIF
#endif
C-    end bi,bj loops
        ENDDO
       ENDDO

#endif /* ALLOW_DIC */
      RETURN
      END
