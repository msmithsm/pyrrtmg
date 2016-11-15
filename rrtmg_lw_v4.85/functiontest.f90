program functiontest
  implicit none 
  
  real, dimension(6) :: play
  real, dimension(7) :: plev
  real, dimension(6) :: tlay
  real, dimension(7) :: tlev
  real               :: tsfc
  real, dimension(6) :: qlay
  real, dimension(6) :: o3lay
  real               :: co2ppmv
  real               :: o2vmr
  
  real, dimension(7) :: uflxc
  real, dimension(7) :: dflxc
  
  integer i
  
  
  
  print*, 'starting funcitontest'
  call stdatm(play, plev, tlay, tlev, tsfc, qlay, o3lay, co2ppmv, o2vmr)
  print*, 'pass stdatm call'
  
  
  call rad(6, 7, &
                    play, plev, tlay, tlev, tsfc, &
                    qlay, o3lay, &
                    co2ppmv, 0.0, 0.0, o2vmr, &
                    0.0,0.0,0.0,0.0, &
                    1.0, &
                    uflxc,dflxc)
                    print*, 'pass rrtmg_lw interface call'

  do i = 1,7
    print*, plev(i), tlev(i), uflxc(i), dflxc(i)
  enddo
  
  print*, 'pass functiontest'
  
  
end program functiontest

subroutine stdatm(play, plev, tlay, tlev, tsfc, qlay, o3lay, co2ppmv, o2vmr) 
	implicit none
  	real, dimension(6), intent(out) :: play
  	real, dimension(7), intent(out) :: plev
  	real, dimension(6), intent(out) :: tlay
  	real, dimension(7), intent(out) :: tlev
  	real,               intent(out) :: tsfc
  	real, dimension(6), intent(out) :: qlay
  	real, dimension(6), intent(out) :: o3lay
  	real,               intent(out) :: co2ppmv
  	real,               intent(out) :: o2vmr
  	
  	
  	
  	
  	
  	plev  = (/ 1013.25, 226.32, 54.75, 8.68, 1.10, .669, .0395 /)
  	tlev  = (/ 288.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.65 /) 
  	tsfc = 288.15
  	play = 0.5*(plev(1:6) + plev(2:7))
  	tlay = 0.5*(tlev(1:6) + tlev(2:7))
  	qlay(:) = 0.0
  	o3lay(:) = 0.0
  	co2ppmv = 356.0
  	o2vmr = 0.21
  	
  	
  
  end subroutine 
  
