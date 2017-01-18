"""
Perform a function test on pyRRTMG package.

Check to make sure package is installed and running correctly.
This function will not give advice on how to fix the problems, but if it
passes you know everything is working as it should.
"""

import numpy as np

from . import sw,lw

def stdatm():
	plev  = np.array([ 1013.25, 226.32, 54.75, 8.68, 1.10, .669, .0395])
	tlev  = np.array([ 288.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.65 ])
	tsfc = 288.15
	play = 0.5*(plev[1:] + plev[:-1])
	tlay = 0.5*(tlev[1:] + tlev[:-1])
	qlay = np.zeros(6)
	o3lay = np.zeros(6)
	return (play, plev, tlay, tlev, tsfc, qlay, o3lay)

def functiontest():
    (play, plev, tlay, tlev, tsfc, qlay, o3lay) = stdatm()
    print('pass stdatm call')

    lw.init()
    sw.init()
    (uflxc, dflxc) = lw.rad(play,plev,tlay,tlev,tsfc,qlay,o3lay)
    print('pass rrtmg_lw interface call')
    (swuflxc, swdflxc) = sw.rad(play, plev, tlay, tlev, tsfc,qlay, o3lay)
    print('pass rrtmg_sw interface call')

    print('{0:7s} {1:6s} {2:6s} {3:6s} {4:6s} {5:6s}'.format('P', 'T', 'LWUP', 'LWDN', 'SWUP', 'SWDN' ))
    for p,t,u,d,us,ds in zip(plev,tlev,uflxc,dflxc,swuflxc,swdflxc):
        print('{0:7.2f} {1:6.2f} {2:6.2f} {3:6.2f} {4:6.2f} {5:6.2f}'.format(p,t,u,d,us,ds))

    print('pass functiontest')

