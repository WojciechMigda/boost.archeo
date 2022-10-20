Motivation
==========

In some of my personal projects which depend on subset of C++ ``boost`` libraries, said libraries are bundled together in one of the repository's subfolders.

While this works very well, because ``boost`` version is fixed, no submodules need to be downloaded or system packages need to be installed and everything just compiles and runs, it becomes a headache if you would like to try to upgrade such bundled ``boost`` but you did not keep track of specific ``boost`` libraries which were thrown together.

This script is an attempt to solve this problem by performing *archeological excavation* of present ``boost`` header files and matching them against all header files distributed with specified ``boost`` release.

Usage
=====

Suppose folder where your project stores ``boost`` include files is ``/repo/github/my_project/external/boost/include/boost`` and ``boost``'s version is 1.72.0. Then simply invoke ``archeo.py``:

.. code-block::

  $ archeo.py -d /repo/github/my_project/external/boost/include/boost -v 1.72.0

Produced output will include identified libraries, as well as list of present header files which were not matched against any official ``boost`` library released with specified version.

Synopsis
========

.. code-block::

  usage: archeo.py [-h] [-d BOOST_FOLDER] [-v VERSION]

  optional arguments:
    -h, --help            show this help message and exit
    -d BOOST_FOLDER, --boost-folder BOOST_FOLDER
                          Directory with boost include headers.
    -v VERSION, --version VERSION
                          Assumed boost version, e.g. 1.80.0.

Dependencies
============

Python dependencies are listed in ``requirements.txt`` file.

License
=======
This script and associated repository contents are released under MIT license.
