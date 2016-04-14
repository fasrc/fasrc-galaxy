#!/bin/bash
export GALAXY_VIRTUAL_ENV=/galaxy_venv
source $GALAXY_VIRTUAL_ENV/bin/activate && \
pip install setuptools --upgrade && \
pip install -v psutil scipy numpy rpy2 matplotlib biopython blist biom-format h5py cogent mlpy mpi4py
