#!/usr/bin/env python
# coding: utf-8

import sys
sys.path.append('external/deModel-0.2/')

# http://docs.scipy.org/doc/numpy-1.10.1/user/basics.types.html
import numpy as np
import binascii

# http://www.dilloneng.com/demodel.html
import deModel as dm
from deModel import DeFixedInt as fxd_int

#
#
#
# http://www.digitalsignallabs.com/papers.htm
#
#
#
# http://stackoverflow.com/questions/10321978/integer-to-bitfield-as-a-list
def bitfield(n):
    return [int(digit) for digit in bin(n)[2:]] # [2:] to chop off the "0b" part

# 0..1-1/2^N
class uint8_less_one( object ):
	def __init__( self, size, val ):

		self.val = np.ones( size, dtype=np.uint8 )

	def lshift( self ):
		pass

	def __str__( self ):
		return ""
#
#
#

if __name__=='__main__':
	a = fxd_int(8, 2, 0.2)
	b = fxd_int(8, 2, 0.5)
	#print fxd_int(8, 2, a + b)
	#print float( b )
	b.showRange()
	(a + b).showRange()
	print hex( fxd_int(8, 2, 0)-(a+b) )
	print hex(b)
	print b << 1
	print b.fValue

	### CORDIC
	#a = str( int( hex(fxd_int( 1, 8, 1.0 )), 16 ) )
	a = fxd_int( 0, 12, 0.5 )
	print a
	a.showRange()
	print a.width  # A(a, b) - size = a+b+1 for signed
	a = hex( a )
	#print binascii.unhexlify(a)
	#print a