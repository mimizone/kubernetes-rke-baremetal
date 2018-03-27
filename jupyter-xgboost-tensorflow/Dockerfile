FROM tensorflow/tensorflow:latest-gpu

MAINTAINER mimizone <https://github.com/mimizone>

RUN curl -LO http://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    bash Miniconda2-latest-Linux-x86_64.sh -p /miniconda -b && \
    rm Miniconda2-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda
 
RUN apt-get update && apt-get install -y \
    python-setuptools

RUN pip install --upgrade pip
RUN pip install numpy xgboost
RUN pip install http://download.pytorch.org/whl/cu75/torch-0.3.0.post4-cp27-cp27mu-linux_x86_64.whl && pip install torchvision

RUN conda create -n py36 -y python=3.6
RUN bash -c "source activate py36; pip install numpy ipython ipykernel xgboost; python -m ipykernel install --name Python3.6"
RUN bash -c "source activate py36; pip install http://download.pytorch.org/whl/cu75/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl; pip install torchvision"

ENV PASSWORD="password"