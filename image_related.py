# encoding: utf-8

import sys
# sys.path.append("./deModel-0.2")

import deModel
import numpy as np

import cv2

if __name__ == '__main__':
    if 0:
        fn = '/home/zaqwes/Dropbox/Pictures/the_composer_by_stellarstatelogic-d5srz6u.png'
        img = cv2.imread(fn, 0)
        dim = np.array(np.array(img.shape) * 0.5, dtype=np.int32)
        tmp = dim[0]
        dim[0] = dim[1]
        dim[1] = tmp
        img = cv2.resize(img, tuple(dim))

        y_end, x_end = img.shape
        print "(y_end, x_end)",  y_end, x_end

        # to mif
        for j in range(y_end):
            for i in range(x_end):
                px_val = img[j, i]

    if 1:
        # in [0, 48] prec 0.01
        # out [-100, 100] prec 0.01
        print np.ceil(np.log2(48))
        print np.ceil(np.abs(np.log2(0.01)))  # np.abs last is wrong
        print np.ceil(np.log2(100)) + 1  # +1 signed


        # Sum if f is equal
        # 2**f - move point left
        #x + y = (x * 2*f + y * 2 * f) / 2**f

        # Attention!!!
        # "One issue we need to be aware of is that a design might represent dif-
        # ferent signals as fixed-point numbers of different lengths or with the binary
        # point in different positions"

        # Rules:
        '''
        Unsigned Wordlength:
        U(a, b) is a + b

        Signed Wordlength:
        A(a, b) is a + b + 1

        Unsigned range:
        U(a, b) is 0 <= x <= 2**a - 2**-b

        Signed range:
        A(a, b) -2**a <= alpha <= 2**a - 2**-b

        Addition res:
        X(e, f) is X(e+1, f)

        Unsigned Multiplication
        U(a 1 , b 1 ) × U(a 2 , b 2 ) = U(a 1 + a 2 , b 1 + b 2 ).

        Signed Multiplication
        A(a 1 , b 1 ) × A(a 2 , b 2 ) = A(a 1 + a 2 + 1, b 1 + b 2 ).

        Wordlength reduction:
        HIn(A(a, b)) = A(a, n − a − 1) and
        LOn(A(a, b)) = A(n − b − 1, b).  fixme: ???

        Similarly, for unsigned values,
        HIn(U(a, b)) = U(a, n − a) and
        LOn(U(a, b)) = U(n − b, b).

        '''


