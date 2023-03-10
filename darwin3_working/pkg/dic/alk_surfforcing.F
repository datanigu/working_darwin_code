#include "DIC_OPTIONS.h"

CBOP
C !ROUTINE: ALK_SURFFORCING

C !INTERFACE: ==========================================================
      SUBROUTINE ALK_SURFFORCING( PTR_ALK , GALK,
     I           bi,bj,imin,imax,jmin,jmax,
     I           myTime, myIter, myThid )

C !DESCRIPTION:
C Calculate the alkalinity change due to freshwater flux
C Update alkalinity tendency term

C !USES: ===============================================================
      IMPLICIT NONE
#include "SIZE.h"
#include "DYNVARS.h"
#include "EEPARAMS.h"
#include "PARAMS.h"
#include "GRID.h"
#include "FFIELDS.h"
#include "DIC_VARS.h"

C !INPUT PARAMETERS: ===================================================
C  PTR_ALK              :: alkalinity field
C  bi,bj                :: tile indices
C  myTime               :: current time
C  myIter               :: current timestep
C  myThid               :: thread number
      _RL  PTR_ALK(1-OLx:sNx+OLx,1-OLy:sNy+OLy,Nr)
      INTEGER iMin,iMax,jMin,jMax, bi, bj
      _RL myTime
      INTEGER myIter, myThid

C !OUTPUT PARAMETERS: ==================================================
C  GALK                 :: tendency term of alkalinity
      _RL  GALK(1-OLx:sNx+OLx,1-OLy:sNy+OLy)

#ifdef ALLOW_PTRACERS
#ifdef DIC_BIOTIC

#ifdef ALLOW_OLD_VIRTUALFLUX
C !LOCAL VARIABLES: ====================================================
C  i,j                  :: loop indices
      INTEGER i,j
CEOP

        DO j=jmin,jmax
          DO i=imin,imax
            IF (maskC(i,j,1,bi,bj).NE.0. _d 0) THEN
c calculate virtual flux
c EminusPforV = dS/dt*(1/Sglob)
C NOTE: Be very careful with signs here!
C Positive EminusPforV => loss of water to atmos and increase
C in salinity. Thus, also increase in other surface tracers
C (i.e. positive virtual flux into surface layer)
              GALK(i,j)=gsm_ALK*surfaceForcingS(i,j,bi,bj)*
     &                  recip_drF(1)/gsm_S
c OR
c let virtual flux be zero
c             GALK(i,j)=0.d0
c
            ELSE
              GALK(i,j)=0. _d 0
            ENDIF
          ENDDO
         ENDDO
#endif /* ALLOW_OLD_VIRTUALFLUX */

#endif
#endif
        RETURN
        END
