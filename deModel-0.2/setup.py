from distutils.core import setup

long_descr = '''The Python package deModel provides a fixed point data
type for Python, allowing the development of algorithm models in fixed
point arithmetic. The basic data type is represented by the class
DeFixedInt, which stores data as an integer and keeps information about
the decimal point. When performing basic arithmetic operations with this
data type, the decimal point is adjusted based on some fundamental rules
of fixed point arithmetic.'''

setup(name='deModel',
      packages=['deModel'],
      version="0.2",
      description="Package to model fixed point arithmetic algorithms.",
      long_description = long_descr,
      author="Dillon Engineering",
      author_email="info@dilloneng.com",
      url="http://www.dilloneng.com",
      download_url="http://www.dilloneng.com/documents/downloads",
      license="LGPL",
      platforms=["Any"]
      )
