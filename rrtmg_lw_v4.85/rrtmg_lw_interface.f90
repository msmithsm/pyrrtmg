subroutine init(cpdair)
  use rrtmg_lw_init
  implicit none
  real(kind=8),intent(in) :: cpdair
  call rrtmg_lw_ini(cpdair)
end subroutine init

subroutine rad(nlay, nlev, &
                    play, plev, tlay, tlev, tsfc, &
                    qlay, o3lay, &
                    co2ppmv, ch4vmr, n2ovmr, o2vmr, &
                    cfc11vmr,cfc12vmr,cfc22vmr,ccl4vmr, &
                    emis, &
                    uflxc,dflxc)
             ! rrtmg_lw 
             !
             ! wrapper to call RRTMG longwave routine, returning clear sky values. 
             ! Assumes no clouds/aerosols, only radiatively active gases
             !
             ! inputs: 
             ! nlay : the number of atmospheric layers
             ! nlev : = nlay+ 1 the number of grid levels
             ! play(nlay) layer pressure
             ! plev(nlev) level pressure 
             ! tlay(nlay) layer temperature
             ! tlev(nlev) level temperature
             ! tsfc       skin temperature
             ! qlay(nlay) h2o mass mixing ratio (g/g)
             ! o3lay(nlay) o3 mass mixing ratio (g/g)
             ! co2ppmv, ch4vmr, n2ovmr, o2vmr, cfc11vmr, cfc12vmr, cfc22vmr, ccl4vmr: 
             ! 		volume mixing ratio for other gases. Assumed to be uniformly mixed
             ! emis : surface emissivity (scalar, or grey body)
             ! 
             !
             !
             ! outputs:
             ! uflxc(nlev) upward lw flux clearsky
             ! dflxc(nlev) downlard lw flux clearsky
             use rrtmg_lw_rad
             use parrrtm, only : nbndlw
             
             implicit none
             
             
             !Arguments
             integer, intent(in) :: nlay
             integer, intent(in) :: nlev
             real(kind=8), dimension(nlay), intent(in) :: play
             real(kind=8), dimension(nlev), intent(in) :: plev
             real(kind=8), dimension(nlay), intent(in) :: tlay
             real(kind=8), dimension(nlev), intent(in) :: tlev
             real(kind=8),                  intent(in) :: tsfc
             real(kind=8), dimension(nlay), intent(in) :: qlay
             real(kind=8), dimension(nlay), intent(in) :: o3lay    
             real(kind=8),                  intent(in) :: co2ppmv
             real(kind=8),                  intent(in) :: ch4vmr
             real(kind=8),                  intent(in) :: n2ovmr
             real(kind=8),                  intent(in) :: o2vmr
             real(kind=8),                  intent(in) :: cfc11vmr
             real(kind=8),                  intent(in) :: cfc12vmr
             real(kind=8),                  intent(in) :: cfc22vmr
             real(kind=8),                  intent(in) :: ccl4vmr
             real(kind=8),                  intent(in) :: emis
             real(kind=8), dimension(nlev),intent(out) :: uflxc
             real(kind=8), dimension(nlev),intent(out) :: dflxc         
             
             
             ! local vars, vectors expanded to matrices to call RRTMG
             integer                      :: icld 
             integer                      :: idrv 
             real(kind=8) , dimension (1, nlay) :: play2
             real(kind=8) , dimension (1, nlev) :: plev2
             real(kind=8) , dimension (1, nlay) :: tlay2
             real(kind=8) , dimension (1, nlev) :: tlev2
             real(kind=8) , dimension (1)       :: tsfc2
             real(kind=8) , dimension (1, nlay) :: h2ovmr2
             real(kind=8) , dimension (1, nlay) :: o3vmr2
             real(kind=8) , dimension (1, nlay) :: co2vmr2
             real(kind=8) , dimension (1, nlay) :: ch4vmr2
             real(kind=8) , dimension (1, nlay) :: n2ovmr2
             real(kind=8) , dimension (1, nlay) :: o2vmr2
             real(kind=8) , dimension (1, nlay) :: cfc11vmr2
             real(kind=8) , dimension (1, nlay) :: cfc12vmr2
             real(kind=8) , dimension (1, nlay) :: cfc22vmr2
             real(kind=8) , dimension (1, nlay) :: ccl4vmr2
             real(kind=8) , dimension (1, nbndlw) :: emis2
             integer                   :: inflglw 
             integer                   :: iceflglw 
             integer                   :: liqflglw 
             real(kind=8) , dimension (1, nlay) :: cldfr2
             real(kind=8) , dimension (1, nlay) :: cicewp2 
             real(kind=8) , dimension (1, nlay) :: cliqwp2 
             real(kind=8) , dimension (1, nlay) :: reice2
             real(kind=8) , dimension (1, nlay) :: reliq2 
             real(kind=8) , dimension (nbndlw,1, nlay) :: taucld2 
             real(kind=8) , dimension (1, nlay,nbndlw) :: tauaer2 
             real(kind=8) , dimension (1, nlev) :: uflx2 
             real(kind=8) , dimension (1, nlev) :: dflx2 
             real(kind=8) , dimension (1, nlay) :: hr2
             real(kind=8) , dimension (1, nlev) :: uflxc2 
             real(kind=8) , dimension (1, nlev) :: dflxc2 
             real(kind=8) , dimension (1, nlay) :: hrc2
             
             
             ! constants 
             real(kind=8) , parameter :: fo3 = 1.657 !Mo3/Mo2
             real(kind=8) , parameter :: fh2o = .6221 ! Mh2o/Mo2
             
             
             !other
             integer j
             
             !expand arguments
             icld = 0
             idrv = 0
             inflglw = 0
             iceflglw = 0
             liqflglw = 0
             cldfr2(:,:) = 0.0d0
             cicewp2(:,:) = 0.0d0
             cliqwp2(:,:) = 0.0d0
             reice2(:,:) = 0.0d0
             reliq2(:,:) = 0.0d0
             taucld2(:,:,:) = 0.0d0
             tauaer2(:,:,:) = 0.0d0
             
             do j = 1,nlay
             	play2(1,j) = play(j)
             	tlay2(1,j) = tlay(j)
             	h2ovmr2(1,j) = qlay(j)/fh2o
             	o3vmr2(1,j) = o3lay(j)/fo3
             	co2vmr2(1,j) = co2ppmv*dble(1.0e-06)
             	ch4vmr2(1,j) = ch4vmr
             	n2ovmr2(1,j) = n2ovmr
             	o2vmr2(1,j) = o2vmr
             	cfc11vmr2(1,j) = cfc11vmr
             	cfc12vmr2(1,j) = cfc12vmr
             	cfc22vmr2(1,j) = cfc22vmr
             	ccl4vmr2(1,j) = ccl4vmr
             	print*, play(j), tlay(j), qlay(j), o3lay(j)            			
             enddo
             
             do j = 1,nlev
             	plev2(1,j) = plev(j)
             	tlev2(1,j) = tlev(j)
             enddo
            
             tsfc2 = tsfc
             
             do j = 1,nbndlw
             		emis2(1,j) = emis
             enddo
             
             !call rrtmg_lw
             call rrtmg_lw(1    ,nlay    ,icld    ,idrv    , &
             play2    ,plev2    ,tlay2    ,tlev2    ,tsfc2    , &
             h2ovmr2  ,o3vmr2   ,co2vmr2  ,ch4vmr2  ,n2ovmr2  ,o2vmr2, &
             cfc11vmr2,cfc12vmr2,cfc22vmr2,ccl4vmr2 ,emis2    , &
             inflglw ,iceflglw,liqflglw,cldfr2   , &
             taucld2  ,cicewp2 ,cliqwp2  ,reice2   ,reliq2   , &
             tauaer2  , &
             uflx2    ,dflx2    ,hr2      ,uflxc2  ,dflxc2,  hrc2 ) 
             
             !unpack output
             do j = 1,nlev
             	uflxc(j) = uflxc2(1,j)
             	dflxc(j) = dflxc2(1,j)
             enddo
end subroutine rad
