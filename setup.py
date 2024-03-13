from Cython.Build import cythonize
from setuptools import setup

setup(

    ext_modules=cythonize('dynamic_array.pyx')
)
