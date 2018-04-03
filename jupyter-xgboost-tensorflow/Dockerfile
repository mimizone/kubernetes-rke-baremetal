FROM tensorflow/tensorflow:latest-gpu

MAINTAINER mimizone <https://github.com/mimizone>

#CONDA
RUN curl -LO http://repo.continuum.io/miniconda/Miniconda2-latest-Linux-x86_64.sh && \
    bash Miniconda2-latest-Linux-x86_64.sh -p /miniconda -b && \
    rm Miniconda2-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

#few tools
RUN apt-get update && apt-get install -y \
    dnsutils \ 
    git \
    iputils-ping \ 
    nano \
    python-setuptools \
    vim \
    wget

# Python, torch etc...
RUN pip install --upgrade pip
RUN pip install numpy xgboost
RUN pip install http://download.pytorch.org/whl/cu75/torch-0.3.0.post4-cp27-cp27mu-linux_x86_64.whl && pip install torchvision

# python 3.6 environment
COPY environment-3.6.yml /opt/environment-3.6.yml
# RUN conda create -n py36 -y python=3.6
RUN conda env create -n py36 -f /opt/environment-3.6.yml python=3.6
RUN bash -c "source activate py36; pip install numpy ipython ipykernel xgboost; python -m ipykernel install --name Python3.6"
RUN bash -c "source activate py36; pip install http://download.pytorch.org/whl/cu75/torch-0.3.0.post4-cp36-cp36m-linux_x86_64.whl; pip install torchvision"

# password for jupyter
ENV PASSWORD="password"
#fix for arrow/tab in the shell/vim
ENV SHELL="/bin/bash"
