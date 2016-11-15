subroutine init(cpdair)
  use rrtmg_sw_init
  implicit none
  real(kind=8),intent(in) :: cpdair
  call rrtmg_sw_ini(cpdair)
end subroutine init

subroutine rad(nlay, nlev, &
                    play, plev, tlay, tlev, tsfc, &
                    qlay, o3lay, &
                    co2ppmv, ch4vmr, n2ovmr, o2vmr, &
                    cfc11vmr,cfc12vmr,cfc22vmr,ccl4vmr, &
                    albedo, coszen, fday, scon, &
                    swuflxc,swdflxc)
             ! rrtmg_sw
             !
             ! wrapper to call RRTMG shortwave routine, returning clear sky values. 
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
             ! albedo : surface albedo (scalar, or grey body)
             ! coszen : cosine of solar zenith angle
             ! fday : fractional length of day (ratio of daylight to 24 hrs) 
             ! scon : solar constant in W m-2
             ! 
             !
             !
             ! outputs:
             ! swuflxc(nlev) upward sw flux clearsky
             ! swdflxc(nlev) downward sw flux clearsky
             use rrtmg_sw_rad
             use parrrsw, only : nbndsw, naerec
             
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
             real(kind=8),                  intent(in) :: albedo
             real(kind=8),                  intent(in) :: coszen
             real(kind=8),                  intent(in) :: fday
             real(kind=8),                  intent(in) :: scon
             real(kind=8), dimension(nlev),intent(out) :: swuflxc
             real(kind=8), dimension(nlev),intent(out) :: swdflxc         
             
             
             ! local vars, vectors expanded to matrices to call RRTMG
             integer                      :: icld 
             integer                      :: iaer 
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
             real(kind=8) , dimension (1)       :: aldir2
             real(kind=8) , dimension (1)       :: asdir2
             real(kind=8) , dimension (1)       :: aldif2
             real(kind=8) , dimension (1)       :: asdif2
             integer                   :: dyofyr
             real(kind=8)                       :: adjes
             real(kind=8) , dimension (1)       :: coszen2
             integer                   :: inflgsw 
             integer                   :: iceflgsw 
             integer                   :: liqflgsw 
             real(kind=8) , dimension (1, nlay) :: cldfr2
             real(kind=8) , dimension (1, nlay) :: cicewp2 
             real(kind=8) , dimension (1, nlay) :: cliqwp2 
             real(kind=8) , dimension (1, nlay) :: reice2
             real(kind=8) , dimension (1, nlay) :: reliq2 
             real(kind=8) , dimension (nbndsw,1, nlay) :: taucld2 
             real(kind=8) , dimension (nbndsw,1, nlay) :: ssacld2
             real(kind=8) , dimension (nbndsw,1, nlay) :: asmcld2
             real(kind=8) , dimension (nbndsw,1, nlay) :: fsfcld2
             real(kind=8) , dimension (1, nlay,nbndsw) :: tauaer2 
             real(kind=8) , dimension (1, nlay,nbndsw) :: ssaaer2
             real(kind=8) , dimension (1, nlay,nbndsw) :: asmaer2
             real(kind=8) , dimension (1, nlay,nbndsw) :: ecaer2 
             real(kind=8) , dimension (1, nlev) :: swuflx2 
             real(kind=8) , dimension (1, nlev) :: swdflx2 
             real(kind=8) , dimension (1, nlay) :: swhr2
             real(kind=8) , dimension (1, nlev) :: swuflxc2 
             real(kind=8) , dimension (1, nlev) :: swdflxc2 
             real(kind=8) , dimension (1, nlay) :: swhrc2
             
             
             ! constants 
             real(kind=8) , parameter :: fo3 = 1.657 !Mo3/Mo2
             real(kind=8) , parameter :: fh2o = .6221 ! Mh2o/Mo2
             
             
             !other
             integer j
             
             !expand arguments
             icld = 0
             iaer = 0
             inflgsw = 0
             iceflgsw = 0
             liqflgsw = 0
             cldfr2(:,:) = 0.0d0
             taucld2(:,:,:) = 0.0d0
             ssacld2(:,:,:) = 0.0d0
             asmcld2(:,:,:) = 0.0d0
             fsfcld2(:,:,:) = 0.0d0
             cicewp2(:,:) = 0.0d0
             cliqwp2(:,:) = 0.0d0
             reice2(:,:) = 0.0d0
             reliq2(:,:) = 0.0d0
             
             tauaer2(:,:,:) = 0.0d0
             ssaaer2(:,:,:) = 0.0d0
             asmaer2(:,:,:) = 0.0d0
             ecaer2(:,:,:) = 0.0d0
             
             do j = 1,nlay
             	play2(1,j) = play(j)
             	tlay2(1,j) = tlay(j)
             	h2ovmr2(1,j) = qlay(j)/fh2o
             	o3vmr2(1,j) = o3lay(j)/fo3
             	co2vmr2(1,j) = co2vmr*dble(1.0e-06)
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
             coszen2 = coszen
             adjes = fday
             dyofyr = 0
             
             asdir2(1) = albedo
             asdif2(1) = albedo
             aldir2(1) = albedo
             aldif2(1) = albedo
             
             
             !call rrtmg_sw
             call rrtmg_sw &
            (  1     ,nlay    ,icld    ,iaer    , &
             play2   ,plev2   ,tlay2   ,tlev2  ,tsfc2   , &
             h2ovmr2 ,o3vmr2  ,co2vmr2 ,ch4vmr2 ,n2ovmr2 ,o2vmr2, &
             asdir2  ,asdif2  ,aldir2  ,aldif2  , &
             coszen2 ,adjes   ,dyofyr  ,scon    , &
             inflgsw ,iceflgsw,liqflgsw,cldfr2  , &
             taucld2 ,ssacld2 ,asmcld2 ,fsfcld2 , &
             cicewp2 ,cliqwp2 ,reice2  ,reliq2  , &
             tauaer2 ,ssaaer2 ,asmaer2 ,ecaer2  , &
             swuflx2 ,swdflx2 ,swhr2   ,swuflxc2,swdflxc2 ,swhrc2)
             
             !unpack output
             do j = 1,nlev
             	swuflxc(j) = swuflxc2(1,j)
             	swdflxc(j) = swdflxc2(1,j)
             enddo
end subroutine rad
