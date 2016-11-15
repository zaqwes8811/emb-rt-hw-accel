deModel Release 0.2
===================

Introduction
------------

The Python package deModel provides a fixed point data type for Python,
allowing the develop of algorithms using fixed point arithmetic. The
basic data type is represented by the class DeFixedInt, which stores
data as an integer and keeps information about the decimal point. When
performing basic arithmetic operations with this data type, the decimal
point is adjusted based on some fundamental rules of fixed point
arithmetic. For further details about those rules we recommend a paper
by Randy Yates titled "Fixed Point Arithmetic: An Introduction",
available from the Digital Signal Labs page. 

http://www.digitalsignallabs.com/fp.pdf


Installation
------------

The installation of the package is fairly simple. When using the
platform-independent source you can use the tar command to unpack it.

~> tar -xvf deModel-0.2.tar.gz

Then change into the newly created directory and run the setup.py script:

~> cd deModel-0.2/
~/deModel-0.2> python setup.py install

If you are using the native Windows installation of Python then just
use the provided Windows installer for deModel. Executing the
installer will guide you through the installation process.

Documentation
-------------

See the code documentation, available through pydoc. On Windows go
under 

  Start -> All Programs -> Python -> Module Docs

On Linux enter on the command line:

> pydoc -g &

Hit the "open browser" button in the opening window, which in turn will
open the browser with the Python module documentation. Search for the
deModel package.


TODO
----

The DeFixedInt class does not support the division operator. Also
compare operations only consider the integer value, not the
representing float value.


Author
------

Dillon Engineering, Inc. <info@dilloneng.com>

