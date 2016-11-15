# encoding: utf-8

import numpy as np

import cv2

if __name__ == '__main__':
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

