FROM tensorflow/tensorflow:latest-gpu

MAINTAINER alex@milowski.com

RUN curl -LO http://repo.continuum.io/miniconda/Miniconda-latest-Linux-x86_64.sh
RUN bash Miniconda-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

RUN apt-get update
RUN apt-get install -y build-essential libgomp1 gcc git cmake python-setuptools

# download and build xgboost
RUN cd /opt && \
  git clone --recursive https://github.com/dmlc/xgboost && \
  cd xgboost && \
  mkdir build && \
  cd build && \
  cmake .. -DUSE_CUDA=ON && \
  make -j4

RUN pip install --upgrade pip
RUN apt-get install -y gfortran libopenblas-dev liblapack-dev
RUN pip install numpy

RUN cd /opt/xgboost && \
    cd python-package && \
    python setup.py install

RUN conda create -n py36 -y python=3.6
RUN bash -c "source activate py36; pip install numpy ipython ipykernel; python -m ipykernel install --name Python3.6"
RUN cd /opt/xgboost/python-package && \
    bash -c "source activate py36; python setup.py install"

RUN pip install http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp27-cp27mu-linux_x86_64.whl && pip install torchvision

RUN bash -c "source activate py36; pip install http://download.pytorch.org/whl/cu80/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl; pip install torchvision"
