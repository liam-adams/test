"""A setuptools based setup module.
See:
https://packaging.python.org/guides/distributing-packages-using-setuptools/
https://github.com/pypa/sampleproject
"""

from setuptools import setup, find_packages

setup(
    name="searchapi",  # Required
    version="0.1.0",  # Required
    author="Liam Adams",  # Optional
    packages=find_packages(),  # Required
    python_requires=">=3.11, <4",
)