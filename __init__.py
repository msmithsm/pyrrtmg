#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
pyRRTMG interface package, offering FORTRAN backend for RRTMG in python API.

Created on Sat Nov 12 21:51:47 2016

@author: maxwell
"""

__all__ = ['lw', 'sw', 'functiontest']


#import lw and sw submodules
from . import lw
from . import sw
from .functiontest import functiontest
