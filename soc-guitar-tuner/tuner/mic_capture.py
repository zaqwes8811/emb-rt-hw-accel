#!/usr/bin/env python
# coding: utf-8

import sys
sys.path.append( "../../" )  # fixme: bad!

from matlab_ext import *

#http://python-sounddevice.readthedocs.org/en/0.3.1/
# sudo apt-get install libffi-dev
# sudo pip install cffi
# sudo pip install sounddevice

import sounddevice as sd
import numpy as np
from scipy.io.wavfile import write
from scipy.io.wavfile import read

# fixme: записать в *.wav

def rec( fs, fn ):
	sd.default.samplerate = fs
	sd.default.dtype = 'int16'  # fixme: uint?
	sd.default.channels = 1

	duration = 10
	X = sd.rec(duration * fs)
	X = (X.T)[0]

	sd.wait()

 	write( 'e.wav', fs, X )


def analyse( fs, fn ):
	# fixme: по максимиум не выйдет, особенно на толстых струнах
	#   можно найти несколько пиков и... а если один, или некоторые с
	#   пропусками? порог по децибелам? но как это сделать в железе
	#   или посчитать в проце? тогда нужно тянуть весь спектр
	#
	# Похоже нужно искать основной тон
	#   http://www.gmstrings.ru/articles/obshchie-voprosy-i-teoriya/struny-stoyachie-volny-i-garmoniki/
	#
	# моды похоже зависят от места в котором ты дернул струну

	gr = [ 82.41, 110.00, 146.82, 196.00, 246.94, 329.63 ]
	grs = []
	for p in gr:
		for i in range(1, 4):
			grs.append( p * i )

	os = 100*np.ones( len( grs) )

	rate, X = read( fn )

	# High-pass filter

	# Разбиваем на фреймы и обрабатываем
	for frame in range(1):
		# DFT
		P1, f = fft_one_side( X , size( X ), fs )
		plot( f, P1 )
		plot( grs, os, 'o')

	grid()
	show()


def main():
	fs = 1000#48000
	fn = 'e.wav'
	if False:
		rec( fs, fn )
	else:
		analyse( fs, fn )

if __name__== '__main__':
	main()
